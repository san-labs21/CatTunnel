#!/bin/bash

# Hapus Direktori lama kalau ada
rm -rf /opt/regisip
mkdir -p /opt/regisip

# aktifkan Enviroment Bot
cd /opt/
source bot/bin/activate

cd /opt/regisip

wget -q https://raw.githubusercontent.com/san-labs21/CatTunnel/main/bot/registrasiIP/regis.py

echo " SILAHKAN INPUT GITHUB TOKEN KAMU :"
read -p " Token : " GITHUB

sed -i "s/GITHUB_TOKEN_MU/${GITHUB}/" /opt/regisip/regis.py

apt-get install -y python3-pip

# Instal modul Python yang diperlukan
pip3 install requests
pip3 install schedule
pip3 install pyTelegramBotAPI

cat <<EOL > run.sh
#!/bin/bash
source /opt/bot/bin/activate
python3 /opt/regisip/regis.py
EOL

wget -q https://raw.githubusercontent.com/san-labs21/CatTunnel/main/bot/registrasiIP/regis.py

# Buat file service systemd
cat <<EOF > /etc/systemd/system/regisip.service
[Unit]
Description=Backup and Restore Bot Service
After=network.target

[Service]
ExecStart=/usr/bin/bash /opt/regisip/run.sh
WorkingDirectory=/opt/regisip
StandardOutput=inherit
StandardError=inherit
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd dan mulai service
systemctl daemon-reload
systemctl enable regisip
systemctl start regisip

deactivate 

cd
rm -rf /root/*
