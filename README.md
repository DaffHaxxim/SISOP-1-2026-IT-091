# SISOP-1-2026-IT-091

**Sistem Operasi — Praktikum Modul 1**

**Sulthan Daffa Al Hasyimi - 5027251091**

**SISOP (C) - Asisten ROOT**

---

## Soal 1 — Kereta Argo Ngawi Jesgejes (KANJ)

### Soal

Kereta Argo Ngawi Jesgejes (KANJ) adalah kereta yang melayani penumpang setiap harinya. Tersedia sebuah file CSV bernama `passenger.csv` yang berisi data penumpang kereta tersebut. Tugas ini meminta pembuatan skrip AWK (`KANJ.sh`) yang mampu menjawab lima pertanyaan berbeda berdasarkan opsi huruf yang diberikan saat menjalankan program.

**Kode eksekusi**

```bash
awk -f KANJ.sh passenger.csv [opsi]
```

| Opsi | Pertanyaan |
|------|-----------|
| `a`  | Berapa jumlah seluruh penumpang? |
| `b`  | Berapa jumlah gerbong penumpang? |
| `c`  | Siapa penumpang tertua dan berapa usianya? |
| `d`  | Berapa rata-rata usia seluruh penumpang? |
| `e`  | Berapa jumlah penumpang kelas Business? |

---

### Data — `passenger.csv`

File CSV berisi 10 baris data penumpang dengan kolom: Name, Age, Carriage, Class. di isi sendiri secara custom

| Name   | Age | Carriage | Class          |
|--------|-----|----------|----------------|
| Alya   | 22  | 1        | Economy Class  |
| Bima   | 35  | 2        | Business Class |
| Citra  | 29  | 1        | Economy Class  |
| Damar  | 41  | 3        | Executive Class|
| Eka    | 18  | 2        | Economy Class  |
| Farah  | 52  | 4        | Business Class |
| Gilang | 31  | 3        | Economy Class  |
| Hana   | 27  | 4        | Business Class |
| Imam   | 46  | 2        | Executive Class|
| Joko   | 60  | 1        | Economy Class  |

Total: 10 penumpang, 4 gerbong unik (1–4), 3 kelas penumpang.

---

### Penjelasan Kode — `KANJ.sh`

#### `BEGIN` — Inisialisasi

```awk
BEGIN {
    FS = ","
    option = ARGV[2]
    delete ARGV[2]
}
```

Blok `BEGIN` dieksekusi sebelum AWK membaca baris data apapun.

- **`FS = ","`**
  Menetapkan pemisah field (field separator) sebagai koma. Ini memungkinkan AWK mem-parsing file CSV sehingga setiap kolom dapat diakses dengan `$1` (Name), `$2` (Age), `$3` (Carriage), `$4` (Class).

- **`option = ARGV[2]`**
  `ARGV` adalah array argumen baris perintah. Ketika skrip dijalankan dengan `awk -f KANJ.sh passenger.csv a`, maka: `ARGV[0]` = `awk`, `ARGV[1]` = `passenger.csv`, `ARGV[2]` = `a`. Baris ini menyimpan huruf opsi ke variabel `option`.

- **`delete ARGV[2]`**
  Menghapus elemen ketiga dari `ARGV`. Ini penting karena AWK akan mencoba membuka setiap elemen `ARGV` sebagai file input. Jika tidak dihapus, AWK akan mencoba membuka file bernama `a` dan menghasilkan error.

---

#### `NR > 1` — Pemrosesan Data Per Baris

```awk
NR > 1 {
    total++

    carriage[$3] = 1

    age = $2 + 0
    total_age += age

    if (total == 1 || age > max_age) {
        max_age = age
        oldest = $1
    }

    if ($4 == "Business Class") {
        business_count++
    }
}
```

Blok ini dieksekusi untuk setiap baris yang dibaca AWK, dengan kondisi `NR > 1` yang berarti baris nomor lebih dari 1 — dengan kata lain, baris header (baris pertama berisi `Name,Age,Carriage,Class`) dilewati.

- **`total++`**
  Menghitung jumlah penumpang. Setiap baris data (satu penumpang) menambah nilai `total` sebesar 1.

- **`carriage[$3] = 1`**
  Menggunakan *associative array* dengan nomor gerbong (`$3`) sebagai kunci. Karena kunci array bersifat unik, duplikat otomatis terhapus, hanya gerbong yang berbeda yang tersimpan sebagai kunci. Nilai `1` hanya placeholder saja.

- **`age = $2 + 0`**
  Mengonversi nilai usia dari string ke angka (idiom AWK). Penambahan `+ 0` memastikan operasi aritmatika berikutnya berjalan dengan benar.

- **`total_age += age`**
  Menjumlahkan seluruh usia penumpang secara kumulatif. Digunakan nanti untuk menghitung rata-rata.

- **Pengecekan penumpang tertua:**
  Pada penumpang pertama (`total == 1`) atau ketika usia saat ini lebih besar dari `max_age`, variabel `max_age` dan `oldest` diperbarui. Hasilnya: `oldest = "Joko"`, `max_age = 60`.

- **`if ($4 == "Business Class")`**
  Mencocokkan kolom Class secara (*exact match*). Penumpang yang termasuk Business Class: Bima, Farah, Hana, artinya `business_count = 3`.

---

#### `END` — Keluaran Berdasarkan Opsi

```awk
END {
    if (option == "a") {
        print "Jumlah seluruh penumpang KANJ adalah " total " orang"

    } else if (option == "b") {
        carriage_count = 0
        for (c in carriage) {
            carriage_count++
        }
        print "Jumlah gerbong penumpang KANJ adalah " carriage_count

    } else if (option == "c") {
        print oldest " adalah penumpang kereta tertua dengan usia " max_age " tahun"

    } else if (option == "d") {
        if (total > 0) {
            average_age = int(total_age / total)
        } else {
            average_age = 0
        }
        print "Rata-rata usia penumpang adalah " average_age " tahun"

    } else if (option == "e") {
        print "Jumlah penumpang business class ada " business_count+0 " orang"

    } else {
        print "Soal tidak dikenali. Gunakan a, b, c, d, atau e."
        exit 1
    }
}
```

Blok `END` dieksekusi setelah seluruh baris data selesai diproses. Di sinilah hasil akhir dicetak sesuai opsi yang dipilih.

- **Opsi `a`:**
  Mencetak nilai `total` langsung. Hasilnya: 10 orang.

- **Opsi `b`:**
  Mengiterasi array `carriage` menggunakan `for (c in carriage)` untuk menghitung jumlah kunci unik (gerbong 1, 2, 3, 4). Hasilnya: 4 gerbong.

- **Opsi `c`:**
  Mencetak nama (`oldest`) dan usia tertinggi (`max_age`) yang telah disimpan selama pemrosesan baris. Hasilnya: Joko, 60 tahun.

- **Opsi `d`:**
  Menghitung `int(total_age / total)` = `int(361 / 10)` = `int(36.1)` = 36 tahun. Fungsi `int()` membulatkan ke bawah, bukan membulatkan biasa.

- **Opsi `e`:**
  Mencetak `business_count+0` — penambahan `+0` memastikan nilai dicetak sebagai angka (bukan string kosong jika tidak ada penumpang Business Class). Hasilnya: 3 orang.

- **Fallback:**
  Jika opsi yang diberikan bukan `a`–`e`, program mencetak pesan error dan keluar dengan kode `1`.

---

### Output 

```bash
$ awk -f KANJ.sh passenger.csv a
Jumlah seluruh penumpang KANJ adalah 10 orang

$ awk -f KANJ.sh passenger.csv b
Jumlah gerbong penumpang KANJ adalah 4

$ awk -f KANJ.sh passenger.csv c
Joko adalah penumpang kereta tertua dengan usia 60 tahun

$ awk -f KANJ.sh passenger.csv d
Rata-rata usia penumpang adalah 36 tahun

$ awk -f KANJ.sh passenger.csv e
Jumlah penumpang business class ada 3 orang
```

---

## Soal 2 — Ekspedisi Pesugihan Gunung Kawi (Mas Amba)

### Deskripsi Soal

Mas Amba adalah pengelola bisnis pesugihan di Gunung Kawi, Jawa Timur. Setelah wafat, sistem data yang digunakan untuk mengelola ekspedisi para peziarah ternyata sudah kedaluwarsa. Data koordinat titik-titik penting ekspedisi tersimpan dalam file GeoJSON. 


---

### Unduh File dari Google Drive menggunakan `gdown`

```bash
pip install gdown
gdown --fuzzy "https://drive.google.com/file/d/FILE_ID/view?usp=sharing"
```

---

### Ekstrak ZIP

```bash
unzip ekspedisi.zip
```

---

### mengedit `parserkoordinat.sh`

```bash
nano parserkoordinat.sh
```

Skrip ini membaca `gsxtrack.json` dan menghasilkan `titik-penting.txt`.

#### Deklarasi Variabel & Guard Check

```bash
INPUT_FILE="./gsxtrack.json"
OUTPUT_FILE="./titik-penting.txt"

if [ ! -f "$INPUT_FILE" ]; then
  echo "Error: '$INPUT_FILE' tidak ditemukan." >&2
  exit 1
fi
```

- Mendefinisikan path input dan output sebagai variabel 
- `[ ! -f "$INPUT_FILE" ]` — mengecek apakah file **tidak** ada. Jika file tidak di temukan, maka program akan mengeluarkan `1`

#### `grep`: Filter Baris yang Relevan dari JSON

```bash
grep -E '"(id|site_name|latitude|longitude)":' "$INPUT_FILE"
```

 Perintah ini mengekstrak  4 field yang dibutuhkan menggunakan * *regex* (`-E`). Untuk setiap dari 4 fitur dalam JSON, dihasilkan 4 baris secara berurutan: `id`, `site_name`, `latitude`, `longitude`. Total: 16 baris.

Contoh output untuk satu fitur:

```
"id": "node_001",
"site_name": "Titik Berak Paman Mas Mba",
"latitude": -7.920000,
"longitude": 112.450000,
```

#### `sed`: Bersihkan Sintaks JSON

```bash
| sed 's/.*: *//; s/[",]//g; s/^ *//; s/ *$//'
```

Empat substitusi dirangkai dengan `;`:

| Ekspresi | Fungsi |
|----------|--------|
| `s/.*: *//` | Menghapus semua karakter hingga `: ` (membuang kunci JSON, menyimpan nilai) |
| `s/[",]//g` | Menghapus semua tanda kutip ganda dan koma |
| `s/^ *//` | Menghapus spasi di awal baris (*leading whitespace*) |
| `s/ *$//` | Menghapus spasi di akhir baris (*trailing whitespace*) |

Setelah tahap ini, setiap baris adalah nilai bersih: `node_001`, `Titik Berak Paman Mas Mba`, `-7.920000`, `112.450000`.

#### `awk`: Gabungkan 4 Baris Menjadi 1 Baris

```bash
| awk '{
    if (NR % 4 == 1) id = $0
    else if (NR % 4 == 2) name = $0
    else if (NR % 4 == 3) lat = $0
    else printf "%s, %s, %s, %s\n", id, name, lat, $0
  }'
```

- `NR % 4` menghasilkan sisa pembagian nomor baris dengan 4, bersiklus `1→2→3→0` untuk setiap kelompok 4 baris.
- Baris dengan sisa `1` disimpan sebagai `id`, sisa `2` sebagai `name`, sisa `3` sebagai `lat`.
- Pada sisa `0` (setiap baris ke-4), `printf` mencetak keempat nilai yang telah dikumpulkan dalam format CSV.
- Ini merakit kembali 4 nilai tiap fitur menjadi satu baris output.

####`sort` dan Redirect Output

```bash
| sort > "$OUTPUT_FILE"
```

- `sort` mengurutkan baris output secara alfabet — karena ID node diawali `node_00X`, hasilnya tersusun berdasarkan urutan node.
- `>` mengarahkan seluruh output ke file `titik-penting.txt`.

**output di `titik-penting.txt` yang dihasilkan:**

```
node_001, Titik Berak Paman Mas Mba, -7.920000, 112.450000
node_002, Basecamp Mas Fuad, -7.920000, 112.468100
node_003, Gerbang Dimensi Keputih, -7.937960, 112.468100
node_004, Tembok Ratapan Keputih, -7.937960, 112.450000
```

---

### mengedit `nemupusaka.sh`

```bash
bash nemupusaka.sh
```

Skrip ini membaca `titik-penting.txt` dan menghitung titik pusat geografis dari keempat node.

#### AWK untuk membaca baris 1 dan 3 (Diagonal Persegi Panjang)

```awk
awk -F', ' '
NR == 1 {
    latitude1 = $3
    longitude1 = $4
}
NR == 3 {
    latitude2 = $3
    longitude2 = $4
}
```

- `-F', '` menetapkan pemisah field sebagai `, ` (koma-spasi) sesuai format `titik-penting.txt`.
- `NR == 1` mengambil koordinat `node_001` (`-7.920000, 112.450000`).
- `NR == 3` mengambil koordinat `node_003` (`-7.937960, 112.468100`).
- Keduanya adalah sepasang diagonal dari persegi panjang yang dibentuk oleh 4 titik node. Titik tengah diagonal suatu persegi panjang sama dengan pusat geometrisnya.

#### `END`: Hitung dan Simpan Titik Pusat

```awk
END {
    mid_lat = (latitude1 + latitude2) / 2
    mid_lon = (longitude1 + longitude2) / 2
    printf "Koordinate pusat: (%f, %f)\n", mid_lat, mid_lon
}
' titik-penting.txt > posisipusaka.txt
```

- Rata-rata aritmatika sederhana dari dua nilai latitude dan dua nilai longitude.
- `printf` dengan format `%f` mencetak angka dalam format *floating-point* atau 6 desimal.
- Output dialihkan ke `posisipusaka.txt` menggunakan `>`.

#### Display Hasil

```bash
cat posisipusaka.txt
```

Mencetak isi file ke terminal

---

### Output

```bash 
$ ./nemupusaka.sh
Koordinate pusat: (-7.928980, 112.459050)
```

---
