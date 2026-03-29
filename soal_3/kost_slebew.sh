#!/bin/bash

DATA_FILE="data/penghuni.csv"
HISTORY_FILE="sampah/history_hapus.csv"
LOG_FILE="log/tagihan.log"
LAPORAN_FILE="rekap/laporan_bulanan.txt"

touch "$DATA_FILE" "$HISTORY_FILE" "$LOG_FILE" "$LAPORAN_FILE"

tampil_menu() {
    clear
     echo "============================================"
    echo " _  __          _       ______ __      __"
    echo "| |/ /___  ___ | |_    /  ____|  |    |  |"
    echo "| ' // _ \/ __|| __|  |   (___|  | ___|  |___    _____ __        __"
    echo "| . \ (_) \__ \| |_    \___   \  |/ _ \  '__  \ /  _  \  \  /\  /  /"
    echo "|_|\_\___/|___/ \__|   ____)     |  __/  |__)  |   ___/\  \/  \/  /"
    echo "                      |______/|__|\___|_._____/ \_____|  \__/\__/"
    echo "============================================"
    echo "    SISTEM MANAJEMEN KOST SLEBEW"
    echo "============================================" 
    echo ""
    echo "  ID | OPTION"
    echo "  ------------------------------------------"
    echo "   1 | Tambah Penghuni Baru"
    echo "   2 | Hapus Penghuni"
    echo "   3 | Tampilkan Daftar Penghuni"
    echo "   4 | Update Status Penghuni"
    echo "   5 | Cetak Laporan Keuangan"
    echo "   6 | Kelola Cron (Pengingat Tagihan)"
    echo "   7 | Exit Program"
    echo "========================================"
    echo -n "Enter option [1-7]: "
}

tambah_penghuni() {
    echo "========================================"
    echo "         TAMBAH PENGHUNI"
    echo "========================================"

    echo -n "Masukkan Nama: "
    read nama

    echo -n "Masukkan Kamar: "
    read kamar

    if grep -q ",$kamar," "$DATA_FILE" 2>/dev/null; then
        echo "[X] Nomor kamar $kamar sudah terisi!"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    echo -n "Masukkan Harga Sewa: "
    read harga

    if ! [[ "$harga" =~ ^[0-9]+$ ]] || [ "$harga" -le 0 ]; then
        echo "[X] Harga sewa harus berupa angka positif!"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    echo -n "Masukkan Tanggal Masuk (YYYY-MM-DD): "
    read tanggal

    if ! [[ "$tanggal" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "[X] Format tanggal salah! Harus YYYY-MM-DD"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    hari_ini=$(date +%Y-%m-%d)
    if [[ "$tanggal" > "$hari_ini" ]]; then
        echo "[X] Tanggal tidak boleh melebihi hari ini ($hari_ini)!"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    echo -n "Masukkan Status Awal (Aktif/Menunggak): "
    read status

    status_lower=$(echo "$status" | tr '[:upper:]' '[:lower:]')
    if [ "$status_lower" != "aktif" ] && [ "$status_lower" != "menunggak" ]; then
        echo "[X] Status harus Aktif atau Menunggak!"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    if [ "$status_lower" = "aktif" ]; then
        status="Aktif"
    else
        status="Menunggak"
    fi

    echo "$nama,$kamar,$harga,$tanggal,$status" >> "$DATA_FILE"
    echo "[✓] Penghuni $nama berhasil ditambahkan ke kamar $kamar!"
    read -p "Tekan [ENTER] untuk kembali ke menu..."
}

hapus_penghuni() {
    echo "========================================"
    echo "         HAPUS PENGHUNI"
    echo "========================================"

    echo -n "Masukkan nama penghuni yang akan dihapus: "
    read nama_hapus

    baris=$(grep "^$nama_hapus," "$DATA_FILE")

    if [ -z "$baris" ]; then
        echo "[X] Penghuni '$nama_hapus' tidak ditemukan!"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    tanggal_hapus=$(date +%Y-%m-%d)
    echo "$baris,$tanggal_hapus" >> "$HISTORY_FILE"

    grep -v "^$nama_hapus," "$DATA_FILE" > /tmp/penghuni_temp.csv
    mv /tmp/penghuni_temp.csv "$DATA_FILE"

    echo "[✓] Data penghuni '$nama_hapus' berhasil diarsipkan ke sampah/history_hapus.csv dan dihapus dari sistem."
    read -p "Tekan [ENTER] untuk kembali ke menu..."
}

tampil_penghuni() {
    echo "========================================"
    echo "    DAFTAR PENGHUNI KOST SLEBEW"
    echo "========================================"

    if [ ! -s "$DATA_FILE" ]; then
        echo "Belum ada data penghuni."
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    awk -F"," '
    BEGIN {
        print "No | Nama           | Kamar | Harga Sewa      | Status"
        print "----------------------------------------------------------"
        no = 1
    }
    {
        printf "%-3d| %-15s| %-6s| Rp%-15s| %s\n", no, $1, $2, $3, $5
        no++
    }
    END {
        aktif = 0
        menunggak = 0
        print "----------------------------------------------------------"
        printf "Total: %d penghuni | Aktif: %d | Menunggak: %d\n", NR, aktif, menunggak
        print "========================================"
    }
    ' "$DATA_FILE"

    read -p "Tekan [ENTER] untuk kembali ke menu..."
}

update_status() {
    echo "========================================"
    echo "           UPDATE STATUS"
    echo "========================================"

    echo -n "Masukkan Nama Penghuni: "
    read nama_update

    if ! grep -q "^$nama_update," "$DATA_FILE"; then
        echo "[X] Penghuni '$nama_update' tidak ditemukan!"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    echo -n "Masukkan Status Baru (Aktif/Menunggak): "
    read status_baru

    status_lower=$(echo "$status_baru" | tr '[:upper:]' '[:lower:]')
    if [ "$status_lower" != "aktif" ] && [ "$status_lower" != "menunggak" ]; then
        echo "[X] Status harus Aktif atau Menunggak!"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    if [ "$status_lower" = "aktif" ]; then
        status_baru="Aktif"
    else
        status_baru="Menunggak"
    fi

    awk -F"," '
    BEGIN { OFS="," }
    {
        if ($1 == $nama_update) {
            $5 = $status_baru
        }
        print
    }
    ' "$DATA_FILE" > /tmp/penghuni_temp.csv
    mv /tmp/penghuni_temp.csv "$DATA_FILE"

    echo "[✓] Status $nama_update berhasil diubah menjadi: $status_baru"
    read -p "Tekan [ENTER] untuk kembali ke menu..."
}

cetak_laporan() {
    echo "========================================"
    echo "    LAPORAN KEUANGAN KOST SLEBEW"
    echo "========================================"

    if [ ! -s "$DATA_FILE" ]; then
        echo "Tidak ada data penghuni."
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    awk -F"," '
    BEGIN {
        total_aktif = 0
        total_menunggak = 0
        jumlah_kamar = 0
        daftar_menunggak = ""
    }
    {
        jumlah_kamar++
        if ($5 == "Aktif") {
            total_aktif += $3
        } else if ($5 == "Menunggak") {
            total_menunggak += $3
            daftar_menunggak = daftar_menunggak "  " $1 " (Kamar " $2 ")\n"
        }
    END {
        printf "Total pemasukan (Aktif)  : Rp%d\n", total_aktif
        printf "Total tunggakan          : Rp%d\n", total_menunggak
        printf "Jumlah kamar terisi      : %d\n", jumlah_kamar
        print "------------------------------------"
        print "Daftar penghuni menunggak:"
        if (daftar_menunggak == "") {
            print "  Tidak ada tunggakan."
        } else {
            printf "%s", daftar_menunggak
        }
        print "===================================="
    }
    ' "$DATA_FILE" | tee "$LAPORAN_FILE"

    echo ""
    echo "[✓] Laporan berhasil disimpan ke rekap/laporan_bulanan.txt"
    read -p "Tekan [ENTER] untuk kembali ke menu..."
}

kelola_cron() {
    while true; do
        echo "================================"
        echo "       MENU KELOLA CRON"
        echo "================================"
        echo " 1. Lihat Cron Job Aktif"
        echo " 2. Daftarkan Cron Job Pengingat"
        echo " 3. Hapus Cron Job Pengingat"
        echo " 4. Kembali"
        echo "================================"
        echo -n "Pilih [1-4]: "
        read pilih_cron

        case $pilih_cron in
            1)
                echo "--- Daftar Cron Job Pengingat Tagihan ---"
                crontab -l 2>/dev/null | grep "kost_slebew.sh"
                if [ $? -ne 0 ]; then
                    echo "Tidak ada cron job aktif."
                fi
                read -p "Tekan [ENTER] untuk kembali ke menu..."
                ;;
            2)
                echo -n "Masukkan Jam (0-23): "
                read jam
                echo -n "Masukkan Menit (0-59): "
                read menit

                SCRIPT_PATH=$(realpath "$0")
                CRON_CMD="$menit $jam * * * $SCRIPT_PATH --check-tagihan"

                crontab -l 2>/dev/null | grep -v "kost_slebew.sh" > /tmp/cron_temp
                echo "$CRON_CMD" >> /tmp/cron_temp
                crontab /tmp/cron_temp
                rm /tmp/cron_temp

                echo "[✓] Cron job berhasil didaftarkan pada pukul $jam:$menit setiap hari"
                read -p "Tekan [ENTER] untuk kembali ke menu..."
            3)
                crontab -l 2>/dev/null | grep -v "kost_slebew.sh" | crontab -
                echo "[✓] Cron job pengingat tagihan berhasil dihapus."
                read -p "Tekan [ENTER] untuk kembali ke menu..."
                ;;
            4)
                break
                ;;
            *)
                echo "Pilihan tidak valid!"
                ;;
        esac
    done
}

if [ "$1" = "--check-tagihan" ]; then
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    while IFS="," read -r nama kamar harga tanggal status; do
        if [ "$status" = "Menunggak" ]; then
            echo "[$TIMESTAMP] TAGIHAN: $nama (Kamar $kamar) - Menunggak Rp$harga" >> "$LOG_FILE"
        fi
    done < "$DATA_FILE"
    exit 0
fi

while true; do
    tampil_menu
    read opsi

    case $opsi in
        1) tambah_penghuni ;;
        2) hapus_penghuni ;;
        3) tampil_penghuni ;;
        4) update_status ;;
        5) cetak_laporan ;;
        6) kelola_cron ;;
        7)
            echo "Terima kasih, sampai jumpa!"
            exit 0
            ;;
        *)
            echo "Opsi tidak valid! Masukkan angka 1-7."
            sleep 1
            ;;
    esac

