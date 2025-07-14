#!/bin/bash

# Fungsi restart dengan animasi titik
restart_service() {
    local service_name=$1
    local max_dots=15  # jumlah maksimal titik per baris
    echo -n "Restart $service_name "

    # Tambahkan titik sesuai panjang nama service agar selaras
    case "$service_name" in
        "nginx")        pad=12 ;;
        "dropbear")     pad=8 ;;
        "ws-service")   pad=6 ;;
        "auto")         pad=12 ;;
        *)              pad=10 ;;
    esac

    for ((i=1; i<=pad; i++)); do
        echo -n "."
        sleep 0.05
    done

    # Restart service
    systemctl restart "$service_name" > /dev/null 2>&1
    echo -e " ✅"
}

# Restart semua service dengan animasi
restart_service "nginx"
restart_service "dropbear"
restart_service "ws-service"
restart_service "auto"

echo "Tekan Enter Untuk Menuju Menu Utama(↩️)"
read -s
menu

