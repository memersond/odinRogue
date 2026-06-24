#!/usr/bin/env bash

set -euo pipefail

ASEPRITE_BIN="aseprite"
SOURCE_DIR="aseprite"
OUTPUT_DIR="assets"

find "$SOURCE_DIR" -type f -name "*.aseprite" | while read -r file; do
    # Relative path from source directory
    rel_path="${file#"$SOURCE_DIR"/}"
    rel_no_ext="${rel_path%.aseprite}"

    png_file="$OUTPUT_DIR/${rel_no_ext}.png"
    json_file="$OUTPUT_DIR/${rel_no_ext}.json"

    mkdir -p "$(dirname "$png_file")"

    echo "Exporting $file"

    "$ASEPRITE_BIN" \
        --batch \
        "$file" \
        --sheet "$png_file" \
        --data "$json_file" \
        --format json-array

done

echo "Done."