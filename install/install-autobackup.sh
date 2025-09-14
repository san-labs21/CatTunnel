#!/bin/bash

# Minta input dari pengguna
read -p "Masukkan token : " new_token
read -p "Masukkan chat : " new_chatid
read -p "Masukkan nama server : " NEW_NAME

# Ganti nilai di file Python dengan perlindungan karakter khusus
sed -i 's/^bot_token\s*=\s*".*"/bot_token = "'"$new_token"'"/' /opt/autobackup/auto.py
sed -i 's/^chat_id\s*=\s*".*"/chat_id = "'"$new_chatid"'"/' /opt/autobackup/auto.py
sed -i "s/NAME_SERVER/${NEW_NAME}/" /opt/autobackup/auto.py

echo $new_token >> /etc/xray/token
echo $new_chatid >> /etc/xray/chatid

systemctl restart auto

echo " ✅ Autobackup Berhasil di Pasang. . .!"

echo "Tekan Enter Untuk Menuju Menu Utama(↩️)"
read -s
menu
