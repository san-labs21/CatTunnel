#!/bin/bash
clear
echo -e "┌──────────────────────────────────────┐"
echo -e "│   .:: CREATE NEW VMESS ACCOUNT ::.   │"
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
NEW_ENTRY='{"id": "'"$NEW_UUID"'", "alterId": 0, "email": "'"$user"'"},'
COMMENT_LINE="## $user $exp"
ESCAPED_ENTRY=$(echo "$COMMENT_LINE\n$NEW_ENTRY" | sed 's/[&/\]/\\&/g')

# Sisipkan setelah baris yang mengandung "// VMESS" atau "// VMESS-GRPC"
sed -i "/\/\/ VMESS$/a $COMMENT_LINE\n$NEW_ENTRY" "$CONFIG_FILE"
sed -i "/\/\/ VMESS-GRPC$/a $COMMENT_LINE\n$NEW_ENTRY" "$CONFIG_FILE"

# ==== Fungsi Create Link
HOST=$(cat /etc/xray/domain)

# Fungsi buat JSON VMess
build_vmess() {
    local proto="$1"
    local json="$2"
    echo "$json" | jq -c . | base64 | tr -d '\n'
}

# --- Buat 3 jenis link ---
link_tls=$(build_vmess "TLS" '{
  "v": "2",
  "ps": "'"${user}-TLS"'",
  "add": "'"${HOST}"'",
  "port": "443",
  "id": "'"${NEW_UUID}"'",
  "aid": "0",
  "net": "ws",
  "type": "none",
  "host": "'"${HOST}"'",
  "path": "/vmess",
  "tls": "tls",
  "sni": "'"${HOST}"'"
}')

link_ws=$(build_vmess "WS" '{
  "v": "2",
  "ps": "'"${user}-WS"'",
  "add": "'"${HOST}"'",
  "port": "80",
  "id": "'"${NEW_UUID}"'",
  "aid": "0",
  "net": "ws",
  "type": "none",
  "host": "'"${HOST}"'",
  "path": "/vmess",
  "tls": ""
}')

link_grpc=$(build_vmess "gRPC" '{
  "v": "2",
  "ps": "'"${user}-gRPC"'",
  "add": "'"${HOST}"'",
  "port": "443",
  "id": "'"${NEW_UUID}"'",
  "aid": "0",
  "net": "grpc",
  "type": "gun",
  "host": "'"${HOST}"'",
  "path": "/vmess-grpc",
  "tls": "tls",
  "sni": "'"${HOST}"'"
}')

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

link1="vmess://${link_tls}"
link2="vmess://${link_ws}"
link3="vmess://${link_grpc}"


rm -rf /etc/xray/history/vmess-$user

cat > /etc/xray/history/vmess-$user <<EOF
✅ VMess Account Berhasil Dibuat
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

# Tampilkan hasil
echo ""
echo ""
echo "✅ VMess Account Berhasil Dibuat"
echo " Username    : $user"
echo " Expired     : $exp"
echo "Limit IP     : $jumlah"
echo "-----------------------------------------------"
echo "UUID: $NEW_UUID"
echo "Host: $HOST"
echo "-----------------------------------------------"
echo "1. WebSocket + TLS (Port 443)"
echo "vmess://$link_tls"
echo
echo "2. WebSocket (tanpa TLS, Port 80)"
echo "vmess://$link_ws"
echo
echo "3. gRPC (Port 443)"
echo "vmess://$link_grpc"
echo "-----------------------------------------------"

systemctl restart xray

echo "Tekan Enter Untuk Kembali (↩️)"
read -s
menu
