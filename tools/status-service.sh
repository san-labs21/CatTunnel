#!/bin/bash

# Warna ANSI
GREEN='\e[32m'
RED='\e[31m'
YELLOW='\e[33m'
BLUE='\e[34m'
NC='\e[0m'

# Fungsi untuk cek status service
check_service() {
    local service_name="$1"
    if systemctl is-active --quiet "$service_name"; then
        echo -e "🟢  ${service_name} : ${GREEN}Aktif${NC}"
        return 0
    else
        echo -e "🔴  ${service_name} : ${RED}Tidak Aktif${NC}"
        return 1
    fi
}

# Fungsi untuk reboot sistem
reboot_system() {
    echo -e "${YELLOW}⚠️  Salah satu atau lebih layanan penting tidak aktif. Sistem akan reboot dalam 5 detik...${NC}"
    sleep 5
    reboot
}

# Header
echo "┌──────────────────────────────┐"
echo "│     🔍 STATUS LAYANAN VPS    │"
echo "└──────────────────────────────┘"

# Cek status layanan penting
check_service "xray.service"
xray_status=$?
check_service "nginx"
nginx_status=$?

# Cek jika salah satu atau kedua layanan tidak aktif
if [ $xray_status -ne 0 ] || [ $nginx_status -ne 0 ]; then
    reboot_system
fi

# Cek status layanan lainnya (hanya untuk tampilan)
check_service "ws-service.service"
check_service "auto.service"
check_service "dropbear"

# Footer
echo ""
echo "📌 Uptime Sistem: $(uptime -p | sed 's/up //')"
echo "📅 Waktu Sekarang: $(date +"%Y-%m-%d %H:%M")"
echo "-------------------------------"
echo "✔️ Selesai memeriksa layanan."
echo "Tekan Enter Untuk Menuju Menu Utama(↩️)"
read -s
