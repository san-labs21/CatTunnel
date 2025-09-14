#!/bin/bash
apt update -y
apt upgrade -y
apt install lolcat -y
apt install figlet -y
apt install neofetch -y
apt install screenfetch -y
cd
rm -rf /root/udp
mkdir -p /root/udp

# install udp-custom
wget "https://raw.githubusercontent.com/san-labs21/CatTunnel/main/udp/udp-custom-linux-amd64" -O /root/udp/udp-custom
chmod +x /root/udp/udp-custom

wget "https://raw.githubusercontent.com/san-labs21/CatTunnel/main/udp/config.json" -O /root/udp/config.json
chmod 644 /root/udp/config.json

if [ -z "$1" ]; then
cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom by ePro Dev. Team and modify by sslablk

[Service]
User=root
Type=simple
ExecStart=/root/udp/udp-custom server
WorkingDirectory=/root/udp/
Restart=always
RestartSec=2s

[Install]
WantedBy=default.target
EOF
else
cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom by ePro Dev. Team and modify by sslablk

[Service]
User=root
Type=simple
ExecStart=/root/udp/udp-custom server -exclude $1
WorkingDirectory=/root/udp/
Restart=always
RestartSec=2s

[Install]
WantedBy=default.target
EOF
fi

clear

cd $HOME
mkdir /etc/Sslablk
cd /etc/Sslablk
wget "https://raw.githubusercontent.com/san-labs21/CatTunnel/main/udp/system.zip" 
unzip system
cd /etc/Sslablk/system
mv menu /usr/local/bin
cd /etc/Sslablk/system
chmod +x ChangeUser.sh
chmod +x Adduser.sh
chmod +x DelUser.sh
chmod +x Userlist.sh
chmod +x RemoveScript.sh
chmod +x torrent.sh
cd /usr/local/bin
chmod +x menu
cd /etc/Sslablk
rm system.zip

echo start service udp-custom
systemctl start udp-custom &>/dev/null

echo enable service udp-custom
systemctl enable udp-custom &>/dev/null
