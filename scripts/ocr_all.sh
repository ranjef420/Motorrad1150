#!/usr/bin/env bash
set -euo pipefail
SRC="${1:?source parts dir (e.g., /Users/nickwade/Hilde/parts)}"
OUT="${2:?ocr mirror dir (e.g., /Users/nickwade/Hilde/parts_ocr)}"
mkdir -p "$OUT"
find "$SRC" -type f -name '*.pdf' | while read -r f; do
  rel="${f#$SRC/}"
  outdir="$OUT/$(dirname "$rel")"
  mkdir -p "$outdir"
  # Only OCR if we don't already have an output file
  if [ ! -f "$outdir/$(basename "$f")" ]; then
    ocrmypdf --skip-text --optimize 3 --deskew --rotate-pages \
      "$f" "$outdir/$(basename "$f")"
  fi
done
