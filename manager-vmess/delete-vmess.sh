#!/bin/bash

# Fungsi untuk menampilkan daftar user
tampilkan_user() {
    clear
    echo ""
    
    echo "  ┌──────────────────────────────────────┐"
    echo "  │     .:: DELETE VMESS ACCOUNT ::.     │"
    echo "  └──────────────────────────────────────┘"
    echo "   No. | Username            | Expired"
    echo "  -----|---------------------|------------"

    declare -A seen_users
    counter=1

    # Baca baris dengan '##' dari config.json
    grep '##' /etc/xray/config.json | while read -r line; do
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

read -p "Masukkan nomor user yang ingin dihapus: " pilihan

# Validasi input nomor user
if ! [[ "$pilihan" =~ ^[0-9]+$ ]]; then
    echo "Input tidak valid. Harus angka."
    exit 1
fi

# Ambil username berdasarkan nomor yang dipilih
user_to_delete=$(grep '##' /etc/xray/config.json | awk '{print $2}' | uniq | sed -n "${pilihan}p")

if [[ -z "$user_to_delete" ]]; then
    echo "User tidak ditemukan!"
    exit 1
fi

echo "Anda yakin ingin menghapus user: $user_to_delete? (y/n)"
read confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Penghapusan dibatalkan."
    exit 0
fi

# Backup file asli sebelum edit
cp /etc/xray/config.json /etc/xray/config.json.bak

# Hapus List limit
FILE="/etc/xray/limitip/clients_limit.conf"
grep -v "$user_to_delete" "$FILE" > "${FILE}.tmp" && mv "${FILE}.tmp" "$FILE"


# Hapus baris "## username" dan satu baris setelahnya
sed -i "/## $user_to_delete /{N;d;}" /etc/xray/config.json

echo "┌──────────────────────────────┐"
echo "│   ✅   Berhasil Menghapus    │"
echo "└──────────────────────────────┘"
echo "  User   : $user_to_delete"
echo "────────────────────────────────"

systemctl restart xray
echo "Tekan Enter Untuk Kembali (↩️)"
read -s
menu
