#!/bin/bash
RANDOM_HURUF=$(cat /dev/urandom | tr -dc 'A-Z' | head -c4)
export RANDOM_HURUF

clear
echo -e "┌──────────────────────────────────────┐"
echo -e "│  .:: CREATE TRIAL VLESS ACCOUNT ::.  │"
echo -e "└──────────────────────────────────────┘"
echo ""
user=Trial-$RANDOM_HURUF
jumlah_hari=1


# === Tambahkan Akun Ke Json
CONFIG_FILE="/etc/xray/config.json"
NEW_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]')
tanggal_sekarang=$(date +"%Y-%m-%d")
exp=$(date -d "$tanggal_sekarang + $jumlah_hari days" +"%Y-%m-%d")
NEW_ENTRY='{"id": "'"$NEW_UUID"'", "email": "'"$user"'"},'
COMMENT_LINE="#? $user $exp"
ESCAPED_ENTRY=$(echo "$COMMENT_LINE\n$NEW_ENTRY" | sed 's/[&/\]/\\&/g')

# Sisipkan setelah baris yang mengandung "// VMESS" atau "// VMESS-GRPC"
sed -i "/\/\/ VLESS$/a $COMMENT_LINE\n$NEW_ENTRY" "$CONFIG_FILE"
sed -i "/\/\/ VLESS-GRPC$/a $COMMENT_LINE\n$NEW_ENTRY" "$CONFIG_FILE"

# === Create Link Vmess
HOST=$(cat /etc/xray/domain)

# Buat remark
remark_tls="${user}-TLS"
remark_ws="${user}-WS"
remark_grpc="${user}-gRPC"

# --- Buat 3 jenis link ---
link_tls="vless://${NEW_UUID}@${HOST}:443?path=/vlessws&security=tls&encryption=none&type=ws&host=${HOST}&sni=${HOST}#${remark_tls}"
link_ws="vless://${NEW_UUID}@${HOST}:80?path=/vless-grpc&security=none&encryption=none&type=ws&host=${HOST}#${remark_ws}"
link_grpc="vless://${NEW_UUID}@${HOST}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=/vless-grpc&host=${HOST}&sni=${HOST}#${remark_grpc}"

#Animsi Loading
animate() {
  local delay=0.1
  local bar=""
  for ((i=0; i<20; i++)); do
    bar+="-"
    printf "\r[%-20s]" "$bar"
    sleep $delay
  done
}

echo "Creating New Account..."
animate


echo ""
echo ""
# Tampilkan hasil
echo "✅ Account VLess Berhasil Dibuat"
echo "Username: $user"
echo "Expired: $exp"
echo "-----------------------------------------------"
echo "UUID: $NEW_UUID"
echo "Host: $HOST"
echo "-----------------------------------------------"
echo "1. WebSocket + TLS (Port 443)"
echo "$link_tls"
echo
echo "2. WebSocket (tanpa TLS, Port 80)"
echo "$link_ws"
echo
echo "3. gRPC (Port 443)"
echo "$link_grpc"
echo "-----------------------------------------------"

systemctl restart xray

echo "Tekan Enter Untuk Kembali (↩️)"
read -s
menu
