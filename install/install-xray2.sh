#!/bin/bash

# ==== Export Warna
green='\e[0;32m'
NC='\e[0m'

# ==== Export CREDITS
CREDITS="${green} ـــــــــــــــﮩ٨ـ QuickTunnel ${NC}" 

# ==== Export Github Link 
GITHUB="https://raw.githubusercontent.com/san-labs21/CatTunnel/main/"

# ==== Cek Root
if [ "$(id -u)" != "0" ]; then
  echo -e "${CREDITS}"
  echo -e "Error: Script harus dijalankan sebagai root!" 1>&2
  exit 1
fi

# ==== Export Domain
if [ ! -f "/root/domain" ]; then
  echo -e "${CREDITS}"
  echo -e "Error: File /root/domain tidak ditemukan!"
  exit 1
fi
domain=$(cat /root/domain)

echo -e "$CREDITS"
echo -e "Memulai instalasi Xray-core untuk domain: $domain"

# ==== Install Dependencies
apt clean all && apt update -y
apt install -y curl socat gnupg nginx iptables-persistent chrony dnsutils lsb-release netcat-openbsd

# ==== Time Configuration
timedatectl set-timezone Asia/Makassar
timedatectl set-ntp true
systemctl enable chrony --now

# ==== Persiapkan Direktori Xray
mkdir -p /etc/xray /var/log/xray
chown -R www-data:www-data /var/log/xray
chmod -R 755 /var/log/xray

# ==== Setup Runtime Directory (Menggunakan systemd-tmpfiles)
echo "d /run/xray 755 www-data www-data -" > /etc/tmpfiles.d/xray.conf
systemd-tmpfiles --create --prefix=/run/xray

# ==== Install Xray Core
echo -e "${CREDITS}"
echo -e "Menginstall Xray-core versi terbaru..."
latest_version="$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
if ! bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u www-data --version "$latest_version"; then
  echo -e "Error: Gagal menginstall Xray-core!"
  exit 1
fi

# ==== Install SSL Certificate
echo -e "${CREDITS}"
echo -e "Menginstall SSL certificate menggunakan acme.sh..."
systemctl stop nginx
mkdir -p /root/.acme.sh
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
if ! /root/.acme.sh/acme.sh --issue -d "$domain" --standalone -k ec-256; then
  echo -e "Error: Gagal mengeluarkan sertifikat SSL!"
  exit 1
fi
/root/.acme.sh/acme.sh --installcert -d "$domain" --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc

# ==== Download Konfigurasi
echo -e "${CREDITS}"
echo -e "Mengunduh konfigurasi Xray dan Nginx..."
wget -q "${GITHUB}tools/config.json" -O /etc/xray/config.json
wget -q "${GITHUB}tools/xray.conf" -O /etc/nginx/conf.d/xray.conf

# ==== Optimasi Systemd Service Bawaan Xray
# Tambahkan parameter performa jika diperlukan
if [ -f "/etc/systemd/system/xray.service" ]; then
  sed -i '/\[Service\]/a LimitNOFILE=1000000\nLimitNPROC=10000' /etc/systemd/system/xray.service
  systemctl daemon-reload
fi

# ==== Restart Services
echo -e "${CREDITS}"
echo -e "Restarting services..."
systemctl restart nginx
systemctl enable xray --now

# ==== Validasi Instalasi
echo -e "${CREDITS}"
echo -e "Validasi instalasi:"
if systemctl is-active --quiet xray; then
  echo -e "Status Xray: ${green}Aktif${NC}"
else
  echo -e "Status Xray: ${red}Gagal${NC}"
  journalctl -u xray -n 10 --no-pager
  exit 1
fi

echo -e "${CREDITS}"
echo -e "${green}Instalasi selesai!${NC}"
echo -e "Domain: $domain"
echo -e "Xray config: /etc/xray/config.json"
