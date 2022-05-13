#!/usr/bin/env bash
##
# Le fichier audio à analyser est-il stéréo ou mono ?
#
# Dépendances: mediainfo, ffmpeg, bc, rm
##

APP_VERSION="v0.2"

FFMPEG_CMD=$(which ffmpeg)
MEDIAINFO_CMD=$(which mediainfo)

SRC=$1

QUIET_MODE=0 # mode silencieux
FAST_MODE=0 # en mode fast, on n'analyse que le début du son, durée définie avec $MAX_LENGTH
MAX_LENGTH="00:01:00.0" # 1 min

# si après traitement le niveau moyen est en dessous d'un seuil en dB,
THRESHOLD_MONO=-80.0 # le fichier exporté est silencieux
THRESHOLD_MAYBE_MONO=-40.0 # le fichier exporté est pas fort, doute
# si au dessus, peu de doute que le fichier soit une vraie stéréo

usage()
{
  echo "Usage: $0 -i input.wav [-q] [-f] [-h] [-v]"
  echo "-i : chemin de l'audio à analyser"
  echo "-q : mode silencieux: n'affiche que la conclusion"
  echo "-f : mode fast: n'analyse que la 1ère minute de l'audio"
  echo "-h : affichage de cette aide"
  echo "-v : affichage de la version"
  exit
}

version()
{
  echo "is-stereo.sh ${APP_VERSION}"
  exit
}

requirements()
{
  if [[ ! $FFMPEG_CMD ]]; then
    echo "commande ffmpeg introuvable"
    exit 1
  fi

  if [[ ! $MEDIAINFO_CMD ]]; then
    echo "commande mediainfo introuvable"
    exit 1
  fi
}

main()
{
  requirements

  [ $# -lt 1 ] && usage

  while getopts "i:qfhv" option; do
    case "${option}" in
      i) SRC="${OPTARG}";;
      q) QUIET_MODE=1;;
      f) FAST_MODE=1;;
      h) usage;;
      v) version;;
      *) ;;
    esac
  done

  if [[ ! $SRC ]]; then
    usage
  fi

  if [[ ! -f $SRC ]]; then
    echo "$SRC n'existe pas"
    exit 1
  else
    if (( "$QUIET_MODE" == 0 )); then
      echo "Analyse de $SRC"
    fi
  fi

  nb_channels=$("$MEDIAINFO_CMD" --Inform="Audio;%Channels%" "$SRC")
  if (( "$nb_channels" == 1 )); then
    if (( "$QUIET_MODE" == 0 )); then
      echo "$SRC est MONO (1 seul canal trouvé par mediainfo)"
    else
      echo "MONO"
    fi
    exit 0
  fi

  if (( "$nb_channels" == 2 )); then
    if (( "$QUIET_MODE" == 0 )); then
      echo "$SRC possède 2 canaux d'après mediainfo..."
      echo "- Inversion de phase du 2ème canal..."
    fi

    LIMIT=""
    if (( "$FAST_MODE" == 1 )); then
      LIMIT="-t $MAX_LENGTH"
      if (( "$QUIET_MODE" == 0 )); then
        echo "- Mode rapide: analyse seulement le début du fichier ($LIMIT)"
      fi
    fi

    $FFMPEG_CMD -hide_banner -loglevel error -y -i "$SRC" -af "aeval='val(0)|-val(1)':c=same" $LIMIT tmp.wav

    if (( "$QUIET_MODE" == 0 )); then
      echo "- Séparation en 2 fichiers"
    fi

    $FFMPEG_CMD -hide_banner -loglevel error -i tmp.wav -map_channel 0.0.0 tmp1.wav -map_channel 0.0.1 tmp2.wav

    if (( "$QUIET_MODE" == 0 )); then
      echo "- Sommation des 2 canaux"
    fi

    $FFMPEG_CMD -hide_banner -loglevel error -y -i tmp1.wav -i tmp2.wav -filter_complex amix=inputs=2:duration=longest tmpsum.wav
    mean_volume=$(ffmpeg -y -i tmpsum.wav -af "volumedetect" -f null /dev/null 2>&1 | grep mean_volume | cut -d " " -f 5)

    if (( "$QUIET_MODE" == 0 )); then
      echo "- Ménage des fichiers temporaires"
    fi

    rm tmp.wav tmp1.wav tmp2.wav tmpsum.wav

    if (( "$QUIET_MODE" == 0 )); then
      echo "Calcul du volume moyen après inversion de phase + sommation = $mean_volume dB"
    fi

    if (( $(echo "$mean_volume < $THRESHOLD_MONO" | bc -l) )); then
      if (( "$QUIET_MODE" == 0 )); then
        echo "Ce fichier est MONO (les 2 pistes sont identiques)"
      else
        echo "MONO"
      fi
    elif (( $(echo "$mean_volume < $THRESHOLD_MAYBE_MONO" | bc -l) )); then
      if (( "$QUIET_MODE" == 0 )); then
        echo "Ce fichier est sans doute MONO (ex: source mono émise sur les ondes avec de la friture)"
      else
        echo "MONO (presque)"
      fi
    else
      if (( "$QUIET_MODE" == 0 )); then
        echo "Ce fichier est STEREO (peu de doute)"
      else
        echo "STEREO"
      fi
    fi
  fi
}

main "$@"
