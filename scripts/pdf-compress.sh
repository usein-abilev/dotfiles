#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <file1> [file2 ...]" >&2
    exit 1
fi

echo "Compressing $# PDF file(s)..."
echo

for file in "$@"; do
    if [ ! -f "$file" ]; then
        echo "Error: No such file '$file'" >&2
    elif [[ "$(head -c 4 "$file")" == "%PDF" ]]; then
        filenameext=$(basename "$file")
        dir=$(dirname "$file")
        base="${filenameext%.*}"
        output="$dir/$base.compressed.pdf"

        # prevent accidental overwrite of input if named .compressed.pdf
        if [ "$(realpath "$file")" = "$(realpath -m "$output")" ]; then
             echo "Error: Output file matches input file '$file'" >&2
             continue
        fi

        echo "Compressing '$file' -> '$output'"

        gs -sDEVICE=pdfwrite \
           -dCompatibilityLevel=1.4 \
           -dPDFSETTINGS=/ebook \
           -dNOPAUSE \
           -dQUIET \
           -dBATCH \
           "-sOutputFile=$output" \
           "$file"

    else 
        echo "Error: Invalid PDF file '$file'" >&2
    fi
done

echo "Finished. Compressed $# file(s)"
