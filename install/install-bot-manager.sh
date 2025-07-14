#!/bin/bash

# Minta input dari pengguna
read -p "Masukkan Token : " NEW_TOKEN
read -p "Masukkan ChatID : " NEW_CHAT_ID 
read -p "Masukkan Perintah Menu ( Contoh = menu ): " NEW_COMMAND

# Variabel
URL="https://raw.githubusercontent.com/san-labs21/CatTunnel/main/bot/san.zip"
TARGET_DIR="/opt/botmanager"
ZIP_FILE="/tmp/san.zip"

# Membuat direktori target jika belum ada
echo "[+] Membuat direktori $TARGET_DIR jika belum ada..."
sudo mkdir -p "$TARGET_DIR"

# Download file zip
echo "[+] Mengunduh file ZIP..."
wget -q -O "$ZIP_FILE" "$URL"

# Ekstrak file zip ke direktori sementara
TMP_DIR="/tmp/san_extract"
mkdir -p "$TMP_DIR"
echo "[+] Mengekstrak file..."
unzip "$ZIP_FILE" -d "$TMP_DIR"

# Pindahkan menu.py
echo "[+] Memindahkan menu.py..."
sudo mv "$TMP_DIR/menu.py" "$TARGET_DIR/"

# Pindahkan isi folder lain
for folder in LAIN SSH VMESS VLESS TROJAN; do
    if [ -d "$TMP_DIR/$folder" ]; then
        echo "[+] Memindahkan isi folder $folder..."
        sudo mv "$TMP_DIR/$folder"/* "$TARGET_DIR/"
    else
        echo "[-] Folder $folder tidak ditemukan dalam arsip ZIP."
    fi
done

# Hapus file dan direktori sementara
rm -rf "$TMP_DIR" "$ZIP_FILE"

sed -i "s/TOKEN = 'token_tele'/TOKEN = '$NEW_TOKEN'/" /opt/botmanager/menu.py
sed -i "s/AUTHORIZED_CHAT_ID = chat_id/AUTHORIZED_CHAT_ID = $NEW_CHAT_ID/" /opt/botmanager/menu.py
sed -i "s/\['NAMA_SERVER'\]/\['$NEW_COMMAND'\]/" /opt/botmanager/menu.py


# Install Modul
cd /opt
source bot/bin/activate
pip install pyTelegramBotAPI
deactivate



cat <<EOL > /opt/botmanager/run.sh
#!/bin/bash
source /opt/bot/bin/activate
python3 /opt/botmanager/menu.py
EOL

# Buat file service systemd
cat <<EOF > /etc/systemd/system/bot.service
[Unit]
Description=San Bot Manager
After=network.target

[Service]
ExecStart=/usr/bin/bash /opt/botmanager/run.sh
WorkingDirectory=/opt/botmanager
StandardOutput=inherit
StandardError=inherit
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd dan mulai service
systemctl daemon-reload
systemctl enable bot
systemctl start bot
echo "Tekan Enter Untuk Menuju Menu Utama(↩️)"
read -s
menu
