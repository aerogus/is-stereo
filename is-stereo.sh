#!/usr/bin/env bash
##
# Le fichier audio à analyser est-il stéréo ou mono ?
#
# Dépendances: mediainfo, ffmpeg, bc, rm
##

SRC=$1
LENGTH=01:00:00.0 # durée de l'échantillon de test
LENGTH=00:01:00.0

echo "=== DEBUT is-stereo.sh ==="

if [[ ! -f $SRC ]]; then
  echo "$SRC n'existe pas"
  exit 1
else
  echo "Analyse de $SRC"
fi

nb_channels=$(mediainfo --Inform="Audio;%Channels%" "$SRC")
if [[ $nb_channels -eq 1 ]]; then
  echo "$SRC est MONO (1 seul canal trouvé par mediainfo)"
  exit
fi

if [[ $nb_channels -eq 2 ]]; then
  echo "$SRC possède 2 canaux d'après mediainfo..."
  echo "- Inversion de phase du 2ème canal (analyse de la 1ère heure seulement)..."
  ffmpeg -hide_banner -loglevel error -y -i "$SRC" -af "aeval='val(0)|-val(1)':c=same" -t $LENGTH tmp.wav
  echo "- Séparation en 2 fichiers"
  ffmpeg -hide_banner -loglevel error -i tmp.wav -map_channel 0.0.0 tmp1.wav -map_channel 0.0.1 tmp2.wav
  echo "- Sommation des 2 canaux"
  ffmpeg -hide_banner -loglevel error -y -i tmp1.wav -i tmp2.wav -filter_complex amix=inputs=2:duration=longest tmpsum.wav
  mean_volume=$(ffmpeg -y -i tmpsum.wav -af "volumedetect" -f null /dev/null 2>&1 | grep mean_volume | cut -d " " -f 5)
  echo "- Ménage des fichiers temporaires"
  rm tmp.wav tmp1.wav tmp2.wav tmpsum.wav
  echo "Calcul du volume moyen après inversion de phase + sommation = $mean_volume dB"
  if (( $(echo "$mean_volume < -80.0" | bc -l) )); then
    echo "Ce fichier est MONO (les 2 pistes sont identiques)"
  elif (( $(echo "$mean_volume < -40.0" | bc -l) )); then
    echo "Ce fichier est presque MONO (ex: source mono émise sur les ondes avec friture)"
  else
    echo "Ce fichier est STEREO (peu de doute)"
  fi
fi

echo "=== FIN is-stereo.sh ==="

