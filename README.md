# is-stereo

Script détectant la (vraie) stéréophonie d'un fichier son. Pour ce faire, on inverse la phase d'un des 2 canaux, et on fait une sommation mono du tout. Si le résultat est silencieux, c'est que les 2 pistes étaient égales, donc le fichier mono (bien qu'il puisse posséder techniquement 2 canaux.
 
```
./is-stereo.sh maybe-stereo-sound.wav
=== DEBUT is-stereo.sh ===
Analyse de maybe-stereo-sound.wav
Ce fichier possède 2 canaux d'après mediainfo...
- Inversion de phase du 2ème canal (analyse de la 1ère heure seulement)...
- Séparation en 2 fichiers
- Sommation des 2 canaux
- Ménage des fichiers temporaires
Calcul du volume moyen après inversion de phase + sommation = -46.7 dB
Ce fichier est presque MONO (ex: source mono émise sur les ondes avec friture)
=== FIN is-stereo.sh ===
```

