#!/usr/bin/env bash
set -euo pipefail

if [ -t 0 ]; then
  echo "Usage: $0 < filelist.txt"
  echo "       ls *.mp4 | $0"
  echo "       find . -name '*.mp4' | $0"
  exit 1
fi

echo "Converting files to DNxHR HQ (DaVinci Resolve compatible)..."
echo

while IFS= read -r input; do
  [ -z "$input" ] && continue
  dir="$(dirname "$input")"
  base="$(basename "$input" .mp4)"
  output="$dir/${base}.mov"

  echo "Converting: $input -> $output"

  ffmpeg -y -i "$input" \
    -c:v dnxhd -profile:v dnxhr_hq -pix_fmt yuv422p \
    -c:a pcm_s16le \
    -stats \
    "$output" < /dev/null

  echo "Done: $output"
  echo
done

echo "All conversions complete."
echo "Import the .mov files directly into DaVinci Resolve."
