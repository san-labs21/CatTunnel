#!/bin/bash
clear 
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# ==== Setup Input Domain
echo -e "${BLUE}┌───────────────────────────────────────────────────┐${NC}"
echo -e "${BLUE}│      .:: CHANGE CERTIFIED DOMAIN SERVER ::.       │${NC}"
echo -e "${BLUE}└───────────────────────────────────────────────────┘${NC}"

# Input domain baru
read -p "Masukkan domain baru Anda: " new_domain

if [ -z "$new_domain" ]; then
  echo "❌ Domain tidak boleh kosong!"
  exit 1
fi

# File penting
DOMAIN_FILE="/etc/xray/domain"
XRAY_CONFIG="/etc/xray/config.json"
CERT_PATH="/etc/xray/xray.crt"
KEY_PATH="/etc/xray/xray.key"
ACME_DIR="/root/.acme.sh"

# Hentikan Nginx untuk gunakan port 80
systemctl stop nginx

# Update domain di file
echo "[*] Memperbarui domain di $DOMAIN_FILE..."
echo "$new_domain" > "$DOMAIN_FILE"

# Update serverName di config XRay jika ada
if grep -q '"serverName"' "$XRAY_CONFIG"; then
  echo "[*] Memperbarui serverName di $XRAY_CONFIG..."
  sed -i "s/\"serverName\": \"[^\"]*\"/\"serverName\": \"$new_domain\"/" "$XRAY_CONFIG"
fi

# Renew sertifikat dengan domain baru
cd "$ACME_DIR" || { echo "❌ Direktori $ACME_DIR tidak ditemukan!"; exit 1; }

./acme.sh --upgrade --auto-upgrade

# Issue sertifikat baru
./acme.sh --issue -d "$new_domain" --standalone -k ec-256 --force

# Instal sertifikat
./acme.sh --installcert -d "$new_domain" \
  --fullchainpath "$CERT_PATH" \
  --keypath "$KEY_PATH" \
  --ecc

# Restart layanan
systemctl start nginx
systemctl restart xray

# Cek keberhasilan
if [ -f "$CERT_PATH" ] && [ -f "$KEY_PATH" ]; then
  echo "✅ Domain berhasil diganti ke: $new_domain"
else
  echo "❌ Gagal mengganti domain atau menerbitkan sertifikat!"
  exit 1
fi

echo ""
echo "Tekan Enter Untuk Menuju Menu Utama(↩️)"
read -s
menu
