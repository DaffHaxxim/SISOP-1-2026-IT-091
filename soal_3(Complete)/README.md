# Soal 3 — Kost Slebew Ambatukam

## Sistem Manajemen Kost Slebew

**Praktikum Sistem Operasi — Modul 1**

Program CLI interaktif untuk mengelola data penghuni kost, dibuat menggunakan **Bash Script** dan **AWK**.

---

## Daftar Isi

1. [Struktur Folder](#1-struktur-folder)
2. [Cara Menjalankan Program](#2-cara-menjalankan-program)
3. [Menu Utama](#3-menu-utama)
4. [Fitur 1 — Tambah Penghuni Baru](#4-fitur-1--tambah-penghuni-baru)
5. [Fitur 2 — Hapus Penghuni](#5-fitur-2--hapus-penghuni)
6. [Fitur 3 — Tampilkan Daftar Penghuni](#6-fitur-3--tampilkan-daftar-penghuni)
7. [Fitur 4 — Update Status Penghuni](#7-fitur-4--update-status-penghuni)
8. [Fitur 5 — Cetak Laporan Keuangan](#8-fitur-5--cetak-laporan-keuangan)
9. [Fitur 6 — Kelola Cron](#9-fitur-6--kelola-cron)
10. [Fitur 7 — Exit Program](#10-fitur-7--exit-program)
11. [Mode Cron: --check-tagihan](#11-mode-cron---check-tagihan)
12. [Penjelasan Kode Per Blok](#12-penjelasan-kode-per-blok)

---

## 1. Struktur Folder

```
soal_3/
├── kost_slebew.sh          (Script Utama)
├── data/
│   └── penghuni.csv        (Database penghuni)
├── log/
│   └── tagihan.log         (Log hasil cron)
├── rekap/
│   └── laporan_bulanan.txt (Laporan keuangan)
├── sampah/
│   └── history_hapus.csv   (Arsip penghuni yang dihapus)
└── README.md               (Dokumentasi ini)
```

**Format CSV** (`data/penghuni.csv`):

| Kolom | Isi | Contoh |
|-------|-----|--------|
| 1 | Nama | Mas Rusdi |
| 2 | Nomor Kamar | 2 |
| 3 | Harga Sewa | 600000 |
| 4 | Tanggal Masuk | 2026-03-06 |
| 5 | Status | Aktif / Menunggak |

Contoh isi file:

```
Mas Rusdi,2,600000,2026-03-06,Aktif
Wowo,1,5000000,2026-03-01,Menunggak
```

---

## 2. Cara Menjalankan Program

Buka terminal, masuk ke folder `soal_3/`, lalu jalankan:

```bash
chmod +x kost_slebew.sh
bash kost_slebew.sh
```

Atau langsung:

```bash
./kost_slebew.sh
```

Program akan menampilkan menu utama dan menunggu input dari pengguna.

---

## 3. Menu Utama

Saat program dijalankan, tampilan menu utama adalah sebagai berikut:

```
========================================
    __ _  _  __  __  ____
   (  / )( \/ _\(  )(_  _)
    )  ( ) __(  O )/  \  )(
   (__\_)(__) \__/\_)__)(__)  SLEBEW
========================================
    SISTEM MANAJEMEN KOST SLEBEW
========================================

  ID | OPTION
  ------------------------------------------
   1 | Tambah Penghuni Baru
   2 | Hapus Penghuni
   3 | Tampilkan Daftar Penghuni
   4 | Update Status Penghuni
   5 | Cetak Laporan Keuangan
   6 | Kelola Cron (Pengingat Tagihan)
   7 | Exit Program
========================================
Enter option [1-7]:
```

Menu ini akan terus muncul kembali (**looping**) setelah setiap aksi selesai, sampai pengguna memilih opsi **7** untuk keluar.

---

## 4. Fitur 1 — Tambah Penghuni Baru

Menambahkan data penghuni baru ke dalam `data/penghuni.csv`.

**Validasi yang dilakukan:**

| Validasi | Aturan |
|----------|--------|
| Nomor Kamar | Tidak boleh bentrok (sudah terisi) |
| Harga Sewa | Harus angka positif |
| Format Tanggal | Harus `YYYY-MM-DD` |
| Tanggal | Tidak boleh di masa depan |
| Status | Hanya `Aktif` atau `Menunggak` (case-insensitive) |

**Contoh interaksi:**

```
========================================
         TAMBAH PENGHUNI
========================================
Masukkan Nama: Mas Rusdi
Masukkan Kamar: 2
Masukkan Harga Sewa: 600000
Masukkan Tanggal Masuk (YYYY-MM-DD): 2026-03-06
Masukkan Status Awal (Aktif/Menunggak): Aktif
[✓] Penghuni Mas Rusdi berhasil ditambahkan ke kamar 2!
Tekan [ENTER] untuk kembali ke menu...
```

**Contoh validasi gagal (kamar bentrok):**

```
Masukkan Nama: Test
Masukkan Kamar: 2
[X] Nomor kamar 2 sudah terisi!
Tekan [ENTER] untuk kembali ke menu...
```

---

## 5. Fitur 2 — Hapus Penghuni

Menghapus data penghuni dari database. Data **tidak langsung hilang** — dipindahkan dulu ke arsip `sampah/history_hapus.csv` dengan tambahan kolom tanggal penghapusan di belakang.

**Contoh interaksi:**

```
========================================
         HAPUS PENGHUNI
========================================
Masukkan nama penghuni yang akan dihapus: Mas Rusdi
[✓] Data penghuni 'Mas Rusdi' berhasil diarsipkan ke
     sampah/history_hapus.csv dan dihapus dari sistem.
Tekan [ENTER] untuk kembali ke menu...
```

**Isi `sampah/history_hapus.csv` setelah dihapus:**

```
Mas Rusdi,2,600000,2026-03-06,Aktif,2026-03-29
```

Kolom terakhir (`2026-03-29`) adalah tanggal penghapusan yang ditambahkan secara otomatis.

---

## 6. Fitur 3 — Tampilkan Daftar Penghuni

Menampilkan seluruh data penghuni dalam format tabel menggunakan **AWK**.

**Contoh output:**

```
========================================
    DAFTAR PENGHUNI KOST SLEBEW
========================================
No | Nama           | Kamar | Harga Sewa      | Status
----------------------------------------------------------
1  | Mas Rusdi      | 2     | Rp600000         | Aktif
2  | Wowo           | 1     | Rp5000000        | Aktif
----------------------------------------------------------
Total: 2 penghuni | Aktif: 2 | Menunggak: 0
========================================
Tekan [ENTER] untuk kembali ke menu...
```

Di baris bawah tabel ditampilkan ringkasan: total penghuni, jumlah yang **Aktif**, dan jumlah yang **Menunggak**.

---

## 7. Fitur 4 — Update Status Penghuni

Mengubah status penghuni dari `Aktif` ke `Menunggak` atau sebaliknya. Input status bersifat **case-insensitive** (boleh huruf besar/kecil).

**Contoh interaksi:**

```
========================================
           UPDATE STATUS
========================================
Masukkan Nama Penghuni: Wowo
Masukkan Status Baru (Aktif/Menunggak): Menunggak
[✓] Status Wowo berhasil diubah menjadi: Menunggak
Tekan [ENTER] untuk kembali ke menu...
```

**Isi CSV setelah update:**

```
Mas Rusdi,2,600000,2026-03-06,Aktif
Wowo,1,5000000,2026-03-01,Menunggak
```

---

## 8. Fitur 5 — Cetak Laporan Keuangan

Menghitung dan menampilkan laporan keuangan menggunakan **AWK**, lalu menyimpan hasilnya ke `rekap/laporan_bulanan.txt`.

**Contoh output:**

```
========================================
    LAPORAN KEUANGAN KOST SLEBEW
========================================
Total pemasukan (Aktif)  : Rp600000
Total tunggakan          : Rp5000000
Jumlah kamar terisi      : 2
------------------------------------
Daftar penghuni menunggak:
  Wowo (Kamar 1)
====================================

[✓] Laporan berhasil disimpan ke rekap/laporan_bulanan.txt
Tekan [ENTER] untuk kembali ke menu...
```

**Jika tidak ada yang menunggak:**

```
Daftar penghuni menunggak:
  Tidak ada tunggakan.
```

---

## 9. Fitur 6 — Kelola Cron

Sub-menu untuk mengatur cron job pengingat tagihan. Menu ini juga melakukan **looping** sampai pengguna memilih **Kembali**.

```
================================
       MENU KELOLA CRON
================================
 1. Lihat Cron Job Aktif
 2. Daftarkan Cron Job Pengingat
 3. Hapus Cron Job Pengingat
 4. Kembali
================================
Pilih [1-4]:
```

### 9.1 — Lihat Cron Job Aktif

Menampilkan cron job yang berhubungan dengan `kost_slebew.sh` menggunakan `crontab -l`.

```
--- Daftar Cron Job Pengingat Tagihan ---
00 07 * * * /home/user/soal_3/kost_slebew.sh --check-tagihan
Tekan [ENTER] untuk kembali ke menu...
```

Jika belum ada:

```
--- Daftar Cron Job Pengingat Tagihan ---
Tidak ada cron job aktif.
```

### 9.2 — Daftarkan Cron Job Pengingat

Mendaftarkan jadwal cron baru. Sistem hanya mengizinkan **satu jadwal aktif** — jika mendaftarkan jadwal baru, jadwal lama otomatis ditimpa (**overwrite**).

```
Masukkan Jam (0-23): 07
Masukkan Menit (0-59): 00
[✓] Cron job berhasil didaftarkan pada pukul 07:00 setiap hari
```

Cron job yang terdaftar akan memanggil script dengan argumen `--check-tagihan`.

### 9.3 — Hapus Cron Job Pengingat

Menghapus semua cron job yang berhubungan dengan `kost_slebew.sh`.

```
[✓] Cron job pengingat tagihan berhasil dihapus.
```

---

## 10. Fitur 7 — Exit Program

Keluar dari program.

```
Terima kasih, sampai jumpa!
```

---

## 11. Mode Cron: --check-tagihan

Ketika script dipanggil dengan argumen `--check-tagihan`, script **tidak** menampilkan menu interaktif. Sebaliknya, ia langsung membaca `data/penghuni.csv`, mencari semua penghuni berstatus **Menunggak**, dan mencatat tagihan mereka ke `log/tagihan.log`.

**Format log:**

```
[YYYY-MM-DD HH:MM:SS] TAGIHAN: <Nama> (Kamar <No>) - Menunggak Rp<Harga>
```

**Contoh isi `log/tagihan.log`:**

```
[2026-03-29 07:00:00] TAGIHAN: Wowo (Kamar 1) - Menunggak Rp5000000
```

**Cara menjalankan manual (untuk testing):**

```bash
bash kost_slebew.sh --check-tagihan
cat log/tagihan.log
```

---

## 12. Penjelasan Kode Per Blok

### 12.1 — Inisialisasi Variabel dan File

```bash
DATA_FILE="data/penghuni.csv"
HISTORY_FILE="sampah/history_hapus.csv"
LOG_FILE="log/tagihan.log"
LAPORAN_FILE="rekap/laporan_bulanan.txt"

touch "$DATA_FILE" "$HISTORY_FILE" "$LOG_FILE" "$LAPORAN_FILE"
```

Menyimpan path file ke dalam variabel agar mudah digunakan di seluruh script. Perintah `touch` memastikan semua file sudah ada (membuat file kosong jika belum ada).

---

### 12.2 — Fungsi `tampil_menu()`

```bash
tampil_menu() {
    clear
    echo "========================================"
    ...
    echo -n "Enter option [1-7]: "
}
```

Membersihkan layar dengan `clear`, lalu menampilkan ASCII banner dan daftar opsi. `echo -n` digunakan agar kursor tetap di baris yang sama (menunggu input).

---

### 12.3 — Fungsi `tambah_penghuni()`

Membaca input satu per satu menggunakan `read`. Setiap input divalidasi:

- **Kamar unik**: `grep -q ",$kamar," "$DATA_FILE"` — mencari apakah nomor kamar sudah ada di CSV.
- **Harga positif**: `[[ "$harga" =~ ^[0-9]+$ ]]` — regex bash untuk cek apakah hanya berisi digit.
- **Format tanggal**: `[[ "$tanggal" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]` — regex cek format YYYY-MM-DD.
- **Tanggal tidak masa depan**: `[[ "$tanggal" > "$hari_ini" ]]` — perbandingan string (format YYYY-MM-DD bisa dibandingkan secara leksikografis).
- **Status valid**: Menggunakan `tr '[:upper:]' '[:lower:]'` untuk mengubah input ke huruf kecil sebelum dicek.

Jika semua validasi lolos, data ditambahkan ke CSV dengan `echo >> "$DATA_FILE"`.

---

### 12.4 — Fungsi `hapus_penghuni()`

```bash
baris=$(grep "^$nama_hapus," "$DATA_FILE")
```

Mencari baris yang dimulai dengan nama penghuni. Jika ditemukan:

1. Baris tersebut ditambahkan ke `history_hapus.csv` beserta tanggal penghapusan
2. `grep -v` digunakan untuk menyalin semua baris **kecuali** yang akan dihapus ke file sementara
3. File sementara dipindahkan menggantikan file asli menggunakan `mv`

---

### 12.5 — Fungsi `tampil_penghuni()`

Menggunakan **AWK** untuk memformat CSV menjadi tabel:

```bash
awk -F"," '
BEGIN { ... }           # Cetak header tabel, inisialisasi counter
{                       # Untuk setiap baris: cetak data + hitung aktif/menunggak
    printf "%-3d| ..."
    if ($5 == "Aktif") aktif++
}
END { ... }             # Cetak footer dengan total
' "$DATA_FILE"
```

- `-F","` — set pemisah field menjadi koma
- `$1`, `$2`, dst. — mengakses kolom ke-1, ke-2, dst.
- `NR` — variabel bawaan AWK yang berisi nomor baris saat ini (digunakan untuk total)
- `printf` — format output dengan lebar kolom tetap (`%-15s` = rata kiri, 15 karakter)

---

### 12.6 — Fungsi `update_status()`

```bash
awk -F"," -v nama="$nama_update" -v status="$status_baru" '
BEGIN { OFS="," }
{
    if ($1 == nama) {
        $5 = status
    }
    print
}
' "$DATA_FILE" > /tmp/penghuni_temp.csv
mv /tmp/penghuni_temp.csv "$DATA_FILE"
```

- `-v nama="..."` — memasukkan variabel bash ke dalam AWK
- `OFS=","` — output field separator, agar `print` menggunakan koma sebagai pemisah
- Jika nama penghuni cocok, field ke-5 (status) diganti dengan status baru
- `print` mencetak seluruh baris (yang sudah/belum diubah) ke file sementara
- File sementara menggantikan file asli

---

### 12.7 — Fungsi `cetak_laporan()`

AWK digunakan untuk menghitung total keuangan:

- **Body block `{ }`**: Setiap baris diperiksa statusnya. Jika `Aktif`, harga ditambahkan ke `total_aktif`. Jika `Menunggak`, harga ditambahkan ke `total_menunggak` dan nama dicatat ke string `daftar_menunggak`.
- **`END` block**: Mencetak ringkasan laporan.
- `tee "$LAPORAN_FILE"` — mencetak output ke layar sekaligus menyimpannya ke file.

---

### 12.8 — Fungsi `kelola_cron()`

Sub-menu dengan `while true` dan `case` untuk mengelola cron job:

- **Lihat**: `crontab -l | grep "kost_slebew.sh"` — menampilkan hanya cron job milik script ini.
- **Daftar baru**: Mengambil crontab yang ada, menghapus entry lama (`grep -v`), menambahkan entry baru, lalu memasang kembali dengan `crontab /tmp/cron_temp`.
- **Hapus**: `crontab -l | grep -v "kost_slebew.sh" | crontab -` — menghapus semua entry yang mengandung `kost_slebew.sh`.

Sistem hanya mengizinkan **satu jadwal aktif** (overwrite).

---

### 12.9 — Handler `--check-tagihan`

```bash
if [ "$1" = "--check-tagihan" ]; then
    ...
    while IFS="," read -r nama kamar harga tanggal status; do
        if [ "$status" = "Menunggak" ]; then
            echo "[...] TAGIHAN: ..." >> "$LOG_FILE"
        fi
    done < "$DATA_FILE"
    exit 0
fi
```

- `$1` — argumen pertama saat script dipanggil
- `IFS=","` — set pemisah field menjadi koma saat `read`
- `read -r` — membaca satu baris CSV dan memecahnya ke variabel
- Hanya penghuni berstatus `Menunggak` yang dicatat ke log
- `exit 0` — keluar langsung tanpa menampilkan menu

---

### 12.10 — Main Loop

```bash
while true; do
    tampil_menu
    read opsi
    case $opsi in
        1) tambah_penghuni ;;
        2) hapus_penghuni ;;
        ...
        7) exit 0 ;;
        *) echo "Opsi tidak valid!" ;;
    esac
done
```

Loop tak terbatas yang menampilkan menu, membaca input, dan menjalankan fungsi yang sesuai menggunakan `case`. Loop hanya berhenti saat pengguna memilih opsi **7** (`exit 0`).

---

*Dibuat untuk Praktikum Sistem Operasi — Modul 1*
