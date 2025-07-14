#!/bin/bash

# Warna untuk output
GREEN='\e[32m'
YELLOW='\e[33m'
RED='\e[31m'
BLUE='\e[34m'
NC='\e[0m'

versi=$(cat /etc/xray/version)
# Fungsi spinner sederhana
spinner() {
    local pid=$!
    local delay=0.1
    local spin='-\|/'
    while [ "$(ps a | awk '{print $1}' | grep -e "$pid")" ]; do
        for i in $(seq 0 3); do
            printf "\r${YELLOW}[%c] ${NC} %s..." "${spin:$i:1}" "$1"
            sleep $delay
        done
    done
    printf "\r\33[2K"
}

# Fungsi bar progres
progress_bar() {
    local duration=${1:-3}  # Durasi animasi dalam detik
    local bar_length=45     # Panjang total bar
    local delay=$(echo "scale=3; $duration / $bar_length" | bc)

    printf "${BLUE}[${NC}"
    for ((i=1; i<=$bar_length; i++)); do
        sleep $delay
        printf "${GREEN}█${NC}"
    done
    printf "${BLUE}] 100%%${NC} ✅ Selesai\n"
}

# Mulai waktu eksekusi
start_time=$(date +%s)

clear
echo -e "${GREEN}┌──────────────────────────────────────┐${NC}"
echo -e "${GREEN}│      QUICKTUNNEL MENU INSTALLER      │${NC}"
echo -e "${GREEN}└──────────────────────────────────────┘${NC}"

# Langkah 1: Cek koneksi
echo -ne "${YELLOW}🔍 Memeriksa koneksi internet...${NC}"
ping -c 1 github.com > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "\r❌ Gagal: Tidak ada koneksi internet.\n"
    exit 1
fi
echo -e "\r✅ Koneksi stabil ke GitHub.\n"

# Langkah 2: Unduh install-menu.sh
echo -ne "${YELLOW}📦 Mengunduh Pembaruan Script. . .${NC}"
wget -q https://raw.githubusercontent.com/san-labs21/CatTunnel/main/install/install-menu.sh &
spinner "Mengunduh Update"
wait $!

if [ ! -f "install-menu.sh" ]; then
    echo -e "\r❌ Gagal: File Update tidak ditemukan.\n"
    exit 1
fi
chmod +x install-menu.sh
echo -e "\r✅ File Update berhasil diunduh.\n"

# Langkah 3: Simulasi pemrosesan
echo -ne "${YELLOW}⚙️  Memproses konfigurasi awal...${NC}"
bash install-menu.sh
progress_bar 3
echo -e "✅ Konfigurasi selesai.\n"

# Langkah 4: Jalankan skrip
echo -ne "${YELLOW}🚀 Menjalankan Pembaruan. . .${NC}"
spinner "Menjalankan Pembaruan"
wait $!

exit_code=$?
if [ $exit_code -ne 0 ]; then
    echo -e "\r❌ Gagal menjalankan Pembaruan. Lihat log:\n"
    cat /tmp/quicktunnel_menu.log
    exit $exit_code
fi
echo -e "\r✅ Script Telah Berhasil Diperbaharui. Versi saat ini $versi \n"

# Akhir
end_time=$(date +%s)
duration=$((end_time - start_time))

echo -e "${GREEN}┌──────────────────────────────────────┐${NC}"
echo -e "${GREEN}│   UPDATE BERHASIL KE VERSI TERBARU   │${NC}"
echo -e "${GREEN}└──────────────────────────────────────┘${NC}"
