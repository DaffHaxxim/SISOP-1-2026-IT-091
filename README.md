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

File CSV berisi 208 baris data penumpang dengan kolom: **Nama Penumpang**, **Usia**, **Kursi Kelas**, **Gerbong**.

| Nama Penumpang | Usia | Kursi Kelas | Gerbong  |
|----------------|------|-------------|----------|
| Budi Hartanto  | 34   | Economy     | Gerbong2 |
| Sinta Livia    | 28   | Business    | Gerbong1 |
| Fajar Binar    | 50   | Executive   | Gerbong4 |
| ...            | ...  | ...         | ...      |
| Jaja Mihardja  | 85   | Executive   | Gerbong2 |

Total: 208 penumpang, 4 gerbong unik (Gerbong1–Gerbong4), 3 kelas penumpang (Economy, Business, Executive).

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
  Menetapkan pemisah field (field separator) sebagai koma. Ini memungkinkan AWK mem-parsing file CSV sehingga setiap kolom dapat diakses dengan `$1` (Nama Penumpang), `$2` (Usia), `$3` (Kursi Kelas), `$4` (Gerbong).

- **`option = ARGV[2]`**
  `ARGV` adalah array argumen baris perintah. Ketika skrip dijalankan dengan `awk -f KANJ.sh passenger.csv a`, maka: `ARGV[0]` = `awk`, `ARGV[1]` = `passenger.csv`, `ARGV[2]` = `a`. Baris ini menyimpan huruf opsi ke variabel `option`.

- **`delete ARGV[2]`**
  Menghapus elemen ketiga dari `ARGV`. Ini penting karena AWK akan mencoba membuka setiap elemen `ARGV` sebagai file input. Jika tidak dihapus, AWK akan mencoba membuka file bernama `a` dan menghasilkan error.

---

#### `NR > 1` — Pemrosesan Data Per Baris

```awk
NR > 1 {
    total++

    carriage[$4] = 1

    age = $2 + 0
    total_age += age

    if (total == 1 || age > max_age) {
        max_age = age
        oldest = $1
    }

    if ($3 == "Business") {
        business_count++
    }
}
```

Blok ini dieksekusi untuk setiap baris yang dibaca AWK, dengan kondisi `NR > 1` yang berarti baris nomor lebih dari 1 — dengan kata lain, baris header (baris pertama berisi `Nama Penumpang,Usia,Kursi Kelas,Gerbong`) dilewati.

- **`total++`**
  Menghitung jumlah penumpang. Setiap baris data (satu penumpang) menambah nilai `total` sebesar 1.

- **`carriage[$4] = 1`**
  Menggunakan *associative array* dengan nama gerbong (`$4`) sebagai kunci. Karena kunci array bersifat unik, duplikat otomatis terhapus, hanya gerbong yang berbeda yang tersimpan sebagai kunci. Nilai `1` hanya placeholder saja.

- **`age = $2 + 0`**
  Mengonversi nilai usia dari string ke angka (idiom AWK). Penambahan `+ 0` memastikan operasi aritmatika berikutnya berjalan dengan benar.

- **`total_age += age`**
  Menjumlahkan seluruh usia penumpang secara kumulatif. Digunakan nanti untuk menghitung rata-rata.

- **Pengecekan penumpang tertua:**
  Pada penumpang pertama (`total == 1`) atau ketika usia saat ini lebih besar dari `max_age`, variabel `max_age` dan `oldest` diperbarui. Hasilnya: `oldest = "Jaja Mihardja"`, `max_age = 85`.

- **`if ($3 == "Business")`**
  Mencocokkan kolom Kursi Kelas secara *exact match*. Nilai kelas dalam CSV adalah `Economy`, `Business`, dan `Executive` (tanpa suffix " Class"). Hasilnya: `business_count = 74`.

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
  Mencetak nilai `total` langsung. Hasilnya: 208 orang.

- **Opsi `b`:**
  Mengiterasi array `carriage` menggunakan `for (c in carriage)` untuk menghitung jumlah kunci unik (Gerbong1, Gerbong2, Gerbong3, Gerbong4). Hasilnya: 4 gerbong.

- **Opsi `c`:**
  Mencetak nama (`oldest`) dan usia tertinggi (`max_age`) yang telah disimpan selama pemrosesan baris. Hasilnya: Jaja Mihardja, 85 tahun.

- **Opsi `d`:**
  Menghitung `int(total_age / total)`. Fungsi `int()` membulatkan ke bawah, bukan membulatkan biasa. Hasilnya: 37 tahun.

- **Opsi `e`:**
  Mencetak `business_count+0` — penambahan `+0` memastikan nilai dicetak sebagai angka (bukan string kosong jika tidak ada penumpang Business). Hasilnya: 74 orang.

- **Fallback:**
  Jika opsi yang diberikan bukan `a`–`e`, program mencetak pesan error dan keluar dengan kode `1`.

---

### Output 

```bash
$ awk -f KANJ.sh passenger.csv a
Jumlah seluruh penumpang KANJ adalah 208 orang

$ awk -f KANJ.sh passenger.csv b
Jumlah gerbong penumpang KANJ adalah 4

$ awk -f KANJ.sh passenger.csv c
Jaja Mihardja adalah penumpang kereta tertua dengan usia 85 tahun

$ awk -f KANJ.sh passenger.csv d
Rata-rata usia penumpang adalah 37 tahun

$ awk -f KANJ.sh passenger.csv e
Jumlah penumpang business class ada 74 orang
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

#### Deklarasi Variabel & Check

```bash
INPUT_FILE="./gsxtrack.json"
OUTPUT_FILE="./titik-penting.txt"

if [ ! -f "$INPUT_FILE" ]; then
  echo "Error: '$INPUT_FILE' tidak ditemukan." >&2
  exit 1
fi
```

- Mendefinisikan path input dan output sebagai variabel 
- `[ ! -f "$INPUT_FILE" ]` — mengecek apakah file tidak ada. Jika file tidak di temukan, maka program akan mengeluarkan `1`

#### `grep`: Filter Baris yang Relevan dari JSON

```bash
grep -E '"(id|site_name|latitude|longitude)":' "$INPUT_FILE"
```

 Perintah ini mengekstrak  4 field yang dibutuhkan menggunakan *regex* (`-E`). Untuk setiap dari 4 fitur dalam JSON, dihasilkan 4 baris secara berurutan: `id`, `site_name`, `latitude`, `longitude`. Total: 16 baris.

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
| `s/^ *//` | Menghapus spasi di awal baris  |
| `s/ *$//` | Menghapus spasi di akhir baris |

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

## Soal 3 — Kos Slebew Ambatukam

### Deskripsi Soal

Mas Amba, mahasiswa baru Teknologi Informasi ITS, mendapat amanah dari pamannya untuk mengelola "Kost Slebew" di kawasan Keputih. Ia harus membuat program manajemen kost berbasis CLI interaktif menggunakan Bash script dan AWK. Program memiliki 7 menu utama yang berjalan secara looping sampai pengguna memilih Exit.

---

### Struktur Folder

```
soal_3/
├── kost_slebew.sh          
├── data/
│   └── penghuni.csv        
├── log/
│   └── tagihan.log         
├── rekap/
│   └── laporan_bulanan.txt
└── sampah/
    └── history_hapus.csv  
```
---

### Soal tidak terselesaikan

#### LInisialisasi Variabel dan Folder

 menentukan path file-file yang digunakan dan memastikan file-file tersebut sudah ada menggunakan `touch`

```bash
DATA_FILE="data/penghuni.csv"
HISTORY_FILE="sampah/history_hapus.csv"
LOG_FILE="log/tagihan.log"
LAPORAN_FILE="rekap/laporan_bulanan.txt"

touch "$DATA_FILE" "$HISTORY_FILE" "$LOG_FILE" "$LAPORAN_FILE"
```

#### Menu Utama Loop

Menu utama dibuat menggunakan fungsi `tampil_menu()` yang dipanggil di dalam `while true` loop. Setiap kali pengguna selesai melakukan satu aksi, program kembali ke menu. Loop hanya berhenti jika pengguna memilih opsi 7 (`exit 0`).

```bash
while true; do
    tampil_menu
    read opsi
    case $opsi in
        1) tambah_penghuni ;;
        ...
        7) exit 0 ;;
    esac
done
```

#### Tambah Penghuni (Opsi 1)

Pengguna memasukkan Nama, Kamar, Harga Sewa, Tanggal Masuk, dan Status. Setiap input divalidasi:

- **Kamar unik**: Menggunakan `grep -q ",$kamar,"` untuk cek apakah nomor kamar sudah ada di CSV.
- **Harga positif**: Menggunakan regex bash `^[0-9]+$` untuk memastikan input hanya berisi angka.
- **Format tanggal**: Regex `^[0-9]{4}-[0-9]{2}-[0-9]{2}$` memastikan format YYYY-MM-DD.
- **Tanggal tidak masa depan**: Perbandingan string (`>`) bekerja karena format YYYY-MM-DD bisa dibandingkan secara leksikografis.
- **Status valid**: Input di-lowercase-kan dulu dengan `tr` sebelum dicek.

Data yang lolos validasi disimpan ke CSV dengan `echo >> "$DATA_FILE"`.

#### Hapus Penghuni (Opsi 2)

Fitur ini mencari penghuni berdasarkan nama menggunakan `grep "^$nama_hapus,"`. Jika ditemukan:

1. Baris data dipindahkan ke `sampah/history_hapus.csv` dengan tambahan kolom tanggal penghapusan
2. Semua baris kecuali yang dihapus disalin ke file sementara dengan `grep -v`
3. File sementara menggantikan file asli dengan `mv`

#### Tampilkan Daftar Penghuni (Opsi 3)

Menggunakan AWK untuk memformat data CSV menjadi tabel. AWK membaca file baris per baris, lalu `printf` mengatur lebar kolom agar rapi.

#### Update Status Penghuni (Opsi 4)

Menggunakan AWK untuk menulis ulang seluruh file CSV. Baris yang nama-nya cocok akan diganti statusnya di kolom ke-5.

#### Cetak Laporan Keuangan (Opsi 5)

AWK digunakan untuk menghitung total pemasukan (penghuni Aktif) dan total tunggakan (penghuni Menunggak). Hasilnya ditampilkan ke layar dan disimpan ke file menggunakan `tee`.

#### Langkah 8 — Kelola Cron (Opsi 6)

Sub-menu dengan 4 pilihan yang juga looping menggunakan `while true` dan `case`. Fitur ini mengatur cron job untuk menjalankan script otomatis setiap hari guna mengecek penghuni yang menunggak.

- **Lihat**: `crontab -l | grep "kost_slebew.sh"`
- **Daftar baru**: Hapus entry lama lalu tambah yang baru
- **Hapus**: `grep -v` untuk membuang entry

#### Handler `--check-tagihan`

Bagian ini berjalan saat script dipanggil dengan argumen `--check-tagihan` oleh cron. Membaca CSV baris per baris dengan `while IFS="," read -r`, lalu mencatat penghuni yang menunggak ke `log/tagihan.log`. Bagian ini sudah berjalan dengan benar.

#### Main Loop (this one incomplete)

Loop utama `while true` yang memanggil `tampil_menu` dan menjalankan fungsi sesuai pilihan.

---

#### Inisialisasi

```bash
DATA_FILE="data/penghuni.csv"
HISTORY_FILE="sampah/history_hapus.csv"
LOG_FILE="log/tagihan.log"
LAPORAN_FILE="rekap/laporan_bulanan.txt"

touch "$DATA_FILE" "$HISTORY_FILE" "$LOG_FILE" "$LAPORAN_FILE"
```

Menyimpan path ke variabel supaya tidak perlu tulis ulang. `touch` membuat file kosong jika belum ada.

#### Fungsi `tampil_menu()`

```bash
tampil_menu() {
    clear
    echo "============================================"
    echo "  _  _____  ___  _____"
    ...
    echo -n "Enter option [1-7]: "
}
```

`clear` membersihkan layar. ASCII art ditampilkan sebagai banner. `echo -n` membuat kursor tetap di baris yang sama menunggu input.

#### Fungsi `tambah_penghuni()`

Membaca 5 input dari pengguna secara berurutan. Setiap input divalidasi menggunakan:
- `grep -q` — mengecek keunikan kamar di database
- `[[ =~ ]]` — regex matching untuk format angka dan tanggal
- `tr '[:upper:]' '[:lower:]'` — konversi ke huruf kecil untuk perbandingan case-insensitive

Jika validasi gagal, fungsi `return` (kembali ke menu). Jika lolos, data ditambahkan ke CSV.

#### Fungsi `hapus_penghuni()`

```bash
baris=$(grep "^$nama_hapus," "$DATA_FILE")
```

`grep "^..."` mencari baris yang dimulai dengan nama penghuni. Data dipindahkan ke arsip sebelum dihapus.

```bash
grep -v "^$nama_hapus," "$DATA_FILE" > /tmp/penghuni_temp.csv
mv /tmp/penghuni_temp.csv "$DATA_FILE"
```

`grep -v` mencetak semua baris kecuali yang cocok, jadi baris penghuni yang dihapus tidak ikut tertulis ke file sementara.

#### Fungsi `tampil_penghuni()`

```bash
awk -F"," '
BEGIN { ... }
{ printf "%-3d| %-15s| ...", no, $1, $2, $3, $5 }
END { ... }
' "$DATA_FILE"
```

- `-F","` — set pemisah field ke koma
- `$1`, `$2`, dst. — mengakses kolom CSV
- `printf "%-15s"` — cetak string rata kiri dengan lebar 15 karakter
- `NR` — variabel bawaan AWK berisi jumlah baris yang sudah diproses

#### Fungsi `update_status()`

```bash
awk -F"," '
BEGIN { OFS="," }
{
    if ($1 == $nama_update) {
        $5 = $status_baru
    }
    print
}
' "$DATA_FILE" > /tmp/penghuni_temp.csv
```

`OFS=","` mengatur output field separator. Ketika `$5` diubah dan `print` dipanggil, AWK mencetak seluruh baris dengan koma sebagai pemisah.

#### Fungsi `cetak_laporan()`

AWK menghitung total pemasukan dan tunggakan secara kumulatif. Penghuni yang menunggak dicatat ke string `daftar_menunggak`. Output dicetak ke layar dan file sekaligus menggunakan `tee`.

#### Fungsi `kelola_cron()`

Sub-menu tersendiri dengan loop dan case. Menggunakan perintah crontab:

| Perintah | Fungsi |
|----------|--------|
| `crontab -l` | Melihat daftar cron job aktif |
| `crontab <file>` | Memasang crontab dari file |
| `crontab -` | Memasang crontab dari stdin (pipe) |

ika mendaftarkan jadwal baru, jadwal lama dihapus dulu dengan `grep -v` sebelum menambahkan yang baru.

#### Handler `--check-tagihan`

```bash
if [ "$1" = "--check-tagihan" ]; then
    ...
    while IFS="," read -r nama kamar harga tanggal status; do
        ...
    done < "$DATA_FILE"
    exit 0
fi
```

`$1` adalah argumen pertama saat script dipanggil. `IFS=","` memecah setiap baris CSV ke variabel terpisah. `exit 0` keluar langsung tanpa menampilkan menu.

#### Main Loop

```bash
while true; do
    tampil_menu
    read opsi
    case $opsi in
        1) tambah_penghuni ;;
        ...
        7) exit 0 ;;
    esac
```

Loop tak terbatas yang menampilkan menu dan menjalankan fungsi. Berhenti hanya jika pengguna memilih opsi 7.

---

### Kendala

Saat ini script belum bisa dijalankan karena... something. ada error di berbagai area sepertinya, yang dimana saya kurang paham mengapa, untuk bagian opsi-opsi juga memiliki beberapa salah logika yang (Meski dapat berjalan) memgeluarkan value yang tidak benar
