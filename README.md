# is-stereo

Script détectant la (vraie) stéréophonie d'un fichier son. Pour ce faire, on inverse la phase d'un des 2 canaux, et on fait une sommation mono du tout. Si le résultat est silencieux, c'est que les 2 pistes étaient égales, donc le fichier mono (bien qu'il puisse posséder techniquement 2 canaux.

## Génération de fichiers d'exemple

```
% ./gen-samples.sh
Génération sample mono (sinusoïde à 1kHz)...
Génération sample double mono (2x sinusoïde à 1kHz)...
Génération sample stereo (sinusoïde à 1kHz à gauche, sinusoïde à 2kHz à droite)...
```

## Usage

```
Usage: is-stereo.sh -i input.wav [-q] [-f] [-h] [-v]
-i : chemin de l'audio à analyser
-q : mode silencieux: n'affiche que la conclusion
-f : mode fast: n'analyse que la 1ère minute de l'audio
-h : affichage de cette aide
-v : affichage de la version
```

## Exemples d'utilisation

### avec un fichier mono

```
% ./is-stereo.sh sample-mono.wav 
Analyse de sample-mono.wav
sample-mono.wav est MONO (1 seul canal trouvé par mediainfo)
```

### avec un fichier double mono

```
% ./is-stereo.sh sample-double-mono.wav 
Analyse de sample-double-mono.wav
sample-double-mono.wav possède 2 canaux d'après mediainfo...
- Inversion de phase du 2ème canal...
- Séparation en 2 fichiers
- Sommation des 2 canaux
- Ménage des fichiers temporaires
Calcul du volume moyen après inversion de phase + sommation = -91.0 dB
Ce fichier est MONO (les 2 pistes sont identiques)
```

### avec un fichier stéréo

```
% ./is-stereo.sh sample-stereo.wav     
Analyse de sample-stereo.wav
sample-stereo.wav possède 2 canaux d'après mediainfo...
- Inversion de phase du 2ème canal...
- Séparation en 2 fichiers
- Sommation des 2 canaux
- Ménage des fichiers temporaires
Calcul du volume moyen après inversion de phase + sommation = -24.1 dB
Ce fichier est STEREO (peu de doute)
```
