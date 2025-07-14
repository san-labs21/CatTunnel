#!/bin/bash
clear
# Fungsi untuk menampilkan daftar user
tampilkan_daftar() {
    echo "  ┌──────────────────────────────────────┐"
    echo "  │       .:: RENEW SSH ACCOUNT ::.      │"
    echo "  └──────────────────────────────────────┘"
    printf "   %-3s | %-17s | %-12s\n" "No" "Username" "Expired"
    echo "  ---------------------------------------"

    no=1
    # Menghindari subshell dari pipeline
    while IFS= read -r username; do
        exp=$(chage -l "$username" 2>/dev/null | grep "Account expires" | awk -F": " '{print $2}')
        if [ -n "$exp" ]; then
            printf "   %-3s | %-17s | %-12s\n" "$no" "$username" "$exp"
            no=$((no + 1))
        fi
    done < <(getent passwd | awk -F: '$3 >= 1000 && $3 != 65534 {print $1}')

    echo "  ---------------------------------------"
}
tampilkan_daftar

# Input nomor user
read -p "Select User : " nomor_user


# Ambil username berdasarkan nomor
selected_user=$(getent passwd | awk -F: '$3 >= 1000 && $3 != 65534 {print $1}' | sed -n "${nomor_user}p")

if [ -z "$selected_user" ]; then
    echo "User dengan nomor $nomor_user tidak ditemukan."
    exit 1
fi

# Input durasi perpanjangan
read -p "Berapa hari ingin diperpanjang? : " durasi_hari

if ! [[ "$durasi_hari" =~ ^[0-9]+$ ]] || [ "$durasi_hari" -le 0 ]; then
    echo "Durasi hari tidak valid."
    exit 1
fi

# Hitung tanggal expired baru
expired_date=$(date -d "+$durasi_hari days" +"%Y-%m-%d")

# Lakukan perubahan expired date
chage -E "$expired_date" "$selected_user"

echo ""
echo "┌──────────────────────────────┐"
echo "│   ✅   Berhasil Perpanjang   │"
echo "└──────────────────────────────┘"
echo "  User        : $selected_user"
echo "  New Expired : $expired_date"
echo "────────────────────────────────"
echo "Tekan Enter Untuk Kembali (↩️)"
read -s
menu
