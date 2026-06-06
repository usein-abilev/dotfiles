#!/usr/bin/env bash
set -euo pipefail

if [ -t 0 ]; then
  echo "Usage: $0 < filelist.txt"
  echo "       ls *.mov | $0"
  echo "       find . -name '*.mov' | $0"
  exit 1
fi

echo "Converting files to H.264 High Quality (CRF 18)..."
echo

while IFS= read -r input; do
  [ -z "$input" ] && continue
  dir="$(dirname "$input")"
  base="$(basename "$input" .mov)"
  output="$dir/${base}.mp4"

  echo "Converting: $input -> $output"

  ffmpeg -y -i "$input" \
    -c:v libx264 \
    -crf 18 \
    -preset slow \
    -vf "format=yuv420p" \
    -pix_fmt yuv420p \
    -color_range tv \
    -color_primaries bt709 \
    -color_trc bt709 \
    -colorspace bt709 \
    -c:a aac \
    -b:a 192k \
    -movflags +faststart \
    -map_metadata 0 \
    "$output" < /dev/null

  echo "Done: $output"
  echo
done

echo "All conversions complete."
