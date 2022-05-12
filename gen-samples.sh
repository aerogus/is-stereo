#!/usr/bin/env bash
##
# Générateur de fichiers audio d'exemple
#
# mode mono
# mode double mono
# mode stereo
#
# durée 10 secondes
##

echo "génération sample mono (sinusoïde à 1kHz)..."

ffmpeg -y \
  -f lavfi -i "sine=frequency=1000:duration=10" \
  -c:a pcm_s16le \
  sample-mono.wav

echo "Génération sample double mono (2x sinusoïde à 1kHz)..."

ffmpeg -y \
  -f lavfi -i "sine=frequency=1000:sample_rate=48000:duration=10" \
  -c:a pcm_s16le -ac 2 \
  sample-double-mono.wav

echo "Génération sample stereo (sinusoïde à 1kHz à gauche, sinusoïde à 2kHz à droite)..."

ffmpeg -y \
  -f lavfi -i "sine=frequency=1000:sample_rate=48000:duration=10" \
  -f lavfi -i "sine=frequency=2000:sample_rate=48000:duration=10" \
  -filter_complex "[0:a][1:a]join=inputs=2:channel_layout=stereo[a]" -map "[a]" \
  -c:a pcm_s16le -ac 2 \
  sample-stereo.wav

echo "FIN"