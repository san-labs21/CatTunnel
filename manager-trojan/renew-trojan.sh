#!/bin/bash

# Fungsi untuk menampilkan daftar user
tampilkan_user() {
    clear
echo ""
echo "  ┌──────────────────────────────────────┐"
echo "  │      .:: RENEW TROJAN ACCOUNT ::.    │"
echo "  └──────────────────────────────────────┘"
echo "   No. | User              | Expired Date"
echo "  -----|-------------------|--------------"
    

    declare -A seen_users
    counter=1

    # Baca baris dengan '#?' dari config.json
    grep '#!' /etc/xray/config.json | while read -r line; do
        user=$(echo "$line" | awk '{print $2}')
        expired=$(echo "$line" | awk '{print $3}')

        # Hindari duplikat dalam tampilan
        if [[ -z "${seen_users[$user]}" ]]; then
            seen_users[$user]=1
            printf "%-6s | %-19s | %-15s\n" "   $counter" "$user" "$expired"
            ((counter++))
        fi
    done

    total_users=$((counter - 1))
    echo "  ----------------------------------------"
    echo ""
}

# Mulai script
tampilkan_user

read -p "Masukkan nomor user untuk diperpanjang: " pilihan

# Validasi input nomor user
if ! [[ "$pilihan" =~ ^[0-9]+$ ]]; then
    echo "Input tidak valid. Harus angka."
    exit 1
fi

# Ambil username berdasarkan nomor yang dipilih
user_to_renew=$(grep '#!' /etc/xray/config.json | awk '{print $2}' | uniq | sed -n "${pilihan}p")

if [[ -z "$user_to_renew" ]]; then
    echo "User tidak ditemukan!"
    exit 1
fi

# Ambil salah satu expired date dari user tersebut (boleh semua, tapi ambil contoh saja)
expired_date=$(grep "#! $user_to_renew " /etc/xray/config.json | head -n1 | awk '{print $3}')

echo "Memilih user: $user_to_renew, Expired saat ini: $expired_date"
read -p "Tambahkan berapa hari? " tambah_hari

# Validasi jumlah hari
if ! [[ "$tambah_hari" =~ ^[0-9]+$ ]]; then
    echo "Input hari tidak valid."
    exit 1
fi

# Hitung tanggal baru
timestamp_expired=$(date -d "$expired_date" +%s)
new_timestamp=$((timestamp_expired + tambah_hari * 86400))  # 86400 detik per hari
new_expired=$(date -d "@$new_timestamp" "+%Y-%m-%d")


# Backup file asli sebelum edit
cp /etc/xray/config.json /etc/xray/config.json.bak

# Ganti tanggal expired untuk **SEMUA entry dengan username yang sama**
sed -i "/#! $user_to_renew / s/ [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/ $new_expired/" /etc/xray/config.json

#Hasil
echo ""
echo "┌──────────────────────────────┐"
echo "│     ✅ AKUN DIPERBARUI       │"
echo "└──────────────────────────────┘"
echo "  User   : $user_to_renew"
echo "  Expire : $new_expired"
echo "────────────────────────────────"
echo "Tekan Enter Untuk Kembali (↩️)"
read -s
menu
