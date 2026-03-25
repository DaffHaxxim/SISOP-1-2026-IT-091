#!/bin/bash
INPUT_FILE="./gsxtrack.json"
OUTPUT_FILE="./titik-penting.txt"

if [ ! -f "$INPUT_FILE" ]; then
  echo "Error: '$INPUT_FILE' tidak ditemukan." >&2
  exit 1
fi

# Regex grep untuk filter baris yang mengandung field yang dibutuhkan
# Regex sed untuk membersihkan syntax JSON dan mengambil nilainya saja
# Awk untuk mengelompokkan setiap 4 baris menjadi 1 baris output
grep -E '"(id|site_name|latitude|longitude)":' "$INPUT_FILE" \
  | sed 's/.*: *//; s/[",]//g; s/^ *//; s/ *$//' \
  | awk '{
      if (NR % 4 == 1) id = $0
      else if (NR % 4 == 2) name = $0
      else if (NR % 4 == 3) lat = $0
      else printf "%s, %s, %s, %s\n", id, name, lat, $0
    }' \
  | sort > "$OUTPUT_FILE"
