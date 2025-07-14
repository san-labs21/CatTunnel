#!/bin/bash
BLUE='\033[0;34m'
NC='\033[0m' # No Color
clear
echo -e "${BLUE}┌────────────────────────────────────────┐${NC}"
echo -e "${BLUE}│        .:: CHANGE TIME ZONE ::.        │${NC}"
echo -e "${BLUE}└────────────────────────────────────────┘${NC}"
echo "  1. Asia/Jakarta (WIB)"
echo "  2. Asia/Makassar (WITA)"
echo "  3. Asia/Jayapura (WIT)"
echo -e "${BLUE}└────────────────────────────────────────┘${NC}"
echo ""
read -p "Masukkan pilihan (0 Go To Menu) : " choice

case $choice in
    1)
        timezone="Asia/Jakarta"
        ;;
    2)
        timezone="Asia/Makassar"
        ;;
    3)
        timezone="Asia/Jayapura"
        ;;
    0)
        timezone="Asia/Jayapura"
        ;;
    *)
        set-local-time.sh
        ;;
esac

# Backup symlink jika ada
if [ -f /etc/localtime ]; then
    sudo mv /etc/localtime /etc/localtime.bak
fi

# Set zona waktu baru
sudo ln -s /usr/share/zoneinfo/$timezone /etc/localtime

# Verifikasi
echo ""
echo "Zona waktu telah diatur ke: $timezone"
date

echo "Tekan Enter Untuk Menuju Menu Utama(↩️)"
read -s
menu
