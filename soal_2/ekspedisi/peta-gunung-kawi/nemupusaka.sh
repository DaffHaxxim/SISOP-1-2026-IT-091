#!/bin/bash

# Menggunakan awk untuk mengambil baris 1 dan baris 3 sebagai diagonal
awk -F', ' '
NR == 1 {
    latitude1 = $3
    longitude1 = $4
}
NR == 3 {
    latitude2 = $3
    longitude2 = $4
}
END {
    mid_lat = (latitude1 + latitude2) / 2
    mid_lon = (longitude1 + longitude2) / 2
    printf "Koordinate pusat: (%f, %f)\n", mid_lat, mid_lon
}
' titik-penting.txt > posisipusaka.txt

# Menampilkan output ke CLI (Layar)
cat posisipusaka.txt