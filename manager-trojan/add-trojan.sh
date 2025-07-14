#!/bin/bash
clear
echo -e "┌──────────────────────────────────────┐"
echo -e "│  .:: CREATE NEW TROJAN ACCOUNT ::.   │"
echo -e "└──────────────────────────────────────┘"
echo ""
read -p "Username : " user
read -p "Masa Aktif: " jumlah_hari
read -p "Limit IP: " jumlah

# Memastikan input adalah angka positif
if ! [[ "$jumlah_hari" =~ ^[0-9]+$ ]]; then
  echo "Input harus berupa angka positif."
  exit 1
fi

# === Setting Limit IP
# Lokasi file konfigurasi
FILE="/etc/xray/limitip/clients_limit.conf"

if ! [[ "$jumlah" =~ ^[0-9]+$ ]]; then
  echo "Jumlah koneksi harus berupa angka!"
  exit 1
fi
# Tambahkan data ke file
echo "$user=$jumlah" >> $FILE



# === Tambahkan Akun Ke Json

CONFIG_FILE="/etc/xray/config.json"
NEW_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]')
tanggal_sekarang=$(date +"%Y-%m-%d")
exp=$(date -d "$tanggal_sekarang + $jumlah_hari days" +"%Y-%m-%d")
NEW_ENTRY='{"password": "'"$NEW_UUID"'", "email": "'"$user"'"},'
COMMENT_LINE="#! $user $exp"
ESCAPED_ENTRY=$(echo "$COMMENT_LINE\n$NEW_ENTRY" | sed 's/[&/\]/\\&/g')

# Sisipkan setelah baris yang mengandung "// VMESS" atau "// VMESS-GRPC"
sed -i "/\/\/ TROJAN$/a $COMMENT_LINE\n$NEW_ENTRY" "$CONFIG_FILE"
sed -i "/\/\/ TROJAN-GRPC$/a $COMMENT_LINE\n$NEW_ENTRY" "$CONFIG_FILE"

# ==== Create Link Trojan
HOST=$(cat /etc/xray/domain)

# Parameter umum
PORT=443
SECURITY="tls"
SNI_PARAM="sni=${HOST}"
HOST_PARAM="host=${HOST}"

# --- WebSocket + TLS ---
PATH_WS="/trojan-ws"
PARAMS_WS="type=ws&${HOST_PARAM}&path=${PATH_WS}&security=${SECURITY}&${SNI_PARAM}"
LINK_WS="trojan://${NEW_UUID}@${HOST}:${PORT}?${PARAMS_WS}#${user}-TLS"

# --- gRPC ---
PATH_GRPC="/trojan-grpc"
PARAMS_GRPC="type=grpc&${HOST_PARAM}&serviceName=${PATH_GRPC}&security=${SECURITY}&${SNI_PARAM}"
LINK_GRPC="trojan://${NEW_UUID}@${HOST}:${PORT}?${PARAMS_GRPC}#${user}-gRPC"

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

# Simpan Data Akun
link1="${LINK_WS}"
link2="${LINK_GRPC}"
rm -rf /etc/xray/history/trojan-$user 

cat > /etc/xray/history/trojan-$user <<EOF
✅ Account Trojan Berhasil Dibuat
Username     : $user
Expired      : $exp
Limit IP     : $jumlah
-----------------------------------------------
UUID         : $NEW_UUID
Host/SNI     : $HOST
Port         : $PORT
-----------------------------------------------
1. WebSocket + TLS
${link1}

2. gRPC
${link1}
-----------------------------------------------
EOF

# Tampilkan hasil
echo ""
echo ""
echo "✅ Account Trojan Berhasil Dibuat" 
echo "Username     : $user"
echo "Expired      : $exp"
echo "Limit IP     : $jumlah"
echo "-----------------------------------------------"
echo "UUID         : $NEW_UUID"
echo "Host/SNI     : $HOST"
echo "Port         : $PORT"
echo "-----------------------------------------------"
echo "1. WebSocket + TLS"
echo "$LINK_WS"
echo
echo "2. gRPC"
echo "$LINK_GRPC"
echo "-----------------------------------------------"

systemctl restart xray

echo "Tekan Enter Untuk Kembali (↩️)"
read -s
menu
