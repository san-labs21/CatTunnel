#!/bin/bash
clear
echo -e "┌──────────────────────────────────────┐"
echo -e "│  .:: CREATE NEW VLESS ACCOUNT ::.    │"
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
NEW_ENTRY='{"id": "'"$NEW_UUID"'", "email": "'"$user"'"},'
COMMENT_LINE="#? $user $exp"
ESCAPED_ENTRY=$(echo "$COMMENT_LINE\n$NEW_ENTRY" | sed 's/[&/\]/\\&/g')

# Sisipkan setelah baris yang mengandung "// VLESS" atau "// VLESS-GRPC"
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

rm -rf /etc/xray/history/vless-$user

# Simpan Data akun
link1="${link_tls}"
link2="${link_ws}"
link3="${link_grpc}"

cat > /etc/xray/history/vless-$user <<EOF
✅ Account VLess Berhasil Dibuat
Username     : $user
Expired      : $exp
Limit IP     : $jumlah
-----------------------------------------------
UUID: $NEW_UUID
Host: $HOST
-----------------------------------------------
1. WebSocket + TLS (Port 443)
${link1}

2. WebSocket (tanpa TLS, Port 80)
${link2}

3. gRPC (Port 443)
${link3}
-----------------------------------------------
EOF

echo ""
echo ""
# Tampilkan hasil
echo "✅ Account VLess Berhasil Dibuat"
echo "Username     : $user"
echo "Expired      : $exp"
echo "Limit IP     : $jumlah"
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
