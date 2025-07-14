#!/bin/bash
clear 
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# ==== Setup Input Domain
echo -e "${BLUE}┌───────────────────────────────────────────────────┐${NC}"
echo -e "${BLUE}│      .:: UPDATE CERTIFIED DOMAIN SERVER ::.       │${NC}"
echo -e "${BLUE}└───────────────────────────────────────────────────┘${NC}"

# Ambil domain dari file
DOMAIN_FILE="/etc/xray/domain"
domain=$(cat "$DOMAIN_FILE")

if [ -z "$domain" ]; then
  echo "❌ Domain tidak ditemukan di $DOMAIN_FILE"
  exit 1
fi

# Path sertifikat
CERT_PATH="/etc/xray/xray.crt"
KEY_PATH="/etc/xray/xray.key"
ACME_DIR="/root/.acme.sh"

# Hentikan Nginx agar bisa menggunakan port 80
systemctl stop nginx

# Renew sertifikat
echo "[*] Memulai proses renew sertifikat untuk domain: $domain..."

cd "$ACME_DIR" || { echo "❌ Direktori $ACME_DIR tidak ditemukan!"; exit 1; }

# Upgrade acme.sh jika perlu
./acme.sh --upgrade --auto-upgrade

# Terbitkan ulang sertifikat
./acme.sh --issue -d "$domain" --standalone -k ec-256 --force

# Instal ulang sertifikat
./acme.sh --installcert -d "$domain" \
  --fullchainpath "$CERT_PATH" \
  --keypath "$KEY_PATH" \
  --ecc

# Restart Nginx dan XRay
systemctl start nginx
systemctl restart xray

# Cek keberhasilan
if [ -f "$CERT_PATH" ] && [ -f "$KEY_PATH" ]; then
  echo "✅ Sertifikat berhasil diperbarui untuk domain: $domain"
else
  echo "❌ Gagal memperbarui sertifikat!"
  exit 1
fi 

echo ""
echo "Tekan Enter Untuk Menuju Menu Utama(↩️)"
read -s
menu
