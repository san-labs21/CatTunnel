#!/bin/bash
# Set mode noninteractive
export DEBIAN_FRONTEND=noninteractive
clear

# ==== Export Warna
green='\e[0;32m'
NC='\e[0m'

# ==== Export Link Github 
GITHUB="https://raw.githubusercontent.com/san-labs21/CatTunnel/main/"


# ==== Setup Input Domain
echo -e "┌───────────────────────────────────────────────────┐"
echo -e "│  Setup Your Domain For This Script | ${green}QuickTunnel${NC}  │"
echo -e "└───────────────────────────────────────────────────┘"
echo ""
read -p "Type Your Domain : " domain

mkdir -p /etc/xray/limitip/
mkdir -p /etc/xray/history/
echo $domain >> /root/domain
echo $domain >> /etc/xray/domain

# Jangan tampilkan prompt untuk iptables-persistent
echo 'iptables-persistent iptables-persistent/autosave_v4 boolean false' | sudo debconf-set-selections
echo 'iptables-persistent iptables-persistent/autosave_v6 boolean false' | sudo debconf-set-selections

# Konfigurasi untuk mempertahankan file konfigurasi yang ada
echo "openssh-server openssh-server/permit-root-login select keep-current" | debconf-set-selections
echo "openssh-server openssh-server/use-pam select keep-current" | debconf-set-selections
echo "openssh-server openssh-server/use-login select keep-current" | debconf-set-selections

# Lakukan upgrade
apt-get update
apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

# ==== Install SSH & Xray
wget -q ${GITHUB}install/install-ssh.sh && chmod +x install-ssh.sh && ./install-ssh.sh
wget -q ${GITHUB}install/install-xray2.sh && chmod +x install-xray2.sh && ./install-xray2.sh
# ==== Install Menu
wget -q ${GITHUB}install/install-menu.sh && chmod +x install-menu.sh && ./install-menu.sh
# ==== Install Vnstat
wget -q ${GITHUB}install/install-vnstat.sh && chmod +x install-vnstat.sh && ./install-vnstat.sh
# ==== Install Auto Backup
wget -q ${GITHUB}tools/auto_backup.sh && chmod +x auto_backup.sh && ./auto_backup.sh
# ==== Install Swap 1GB
wget -q ${GITHUB}tools/swap-1gb.sh && chmod +x swap-1gb.sh && ./swap-1gb.sh
# ==== Buat Vnv untuk keperluan Bot
cd
cd /opt

OS=$(grep -Ei '^(NAME|VERSION_ID)=' /etc/os-release | cut -d= -f2 | tr -d '"')

# Ekstrak nama distro dan versi
DISTRO=$(echo "$OS" | head -n1)
VERSION=$(echo "$OS" | tail -n1)

# Cek apakah Debian 12
if [[ "$DISTRO" == "Debian GNU/Linux" && "$VERSION" == "12" ]]; then
    echo "OS Terdeteksi: Debian 12"
    apt update && apt install python3.11-venv -y

# Cek apakah Ubuntu 24.04 LTS
elif [[ "$DISTRO" == "Ubuntu" && "$VERSION" == "24.04" ]]; then
    echo "OS Terdeteksi: Ubuntu 24.04 LTS"
    apt update && apt install python3.12-venv -y

# Jika bukan salah satu dari di atas
else
    echo "OS Tidak Didukung!"
    echo "Distro: $DISTRO"
    echo "Versi: $VERSION"
    exit 1
fi


python3 -m venv bot
source bot/bin/activate
apt-get install -y python3-pip

# matikan Vnv
deactivate
cd

# ==== Memasang Default Menu saat Boot
cat> /root/.profile << END
# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n || true
clear
menu
END
chmod 644 /root/.profile

# ==== Install Limit IP Xray
cd /usr/bin/
wget -q ${GITHUB}tools/check-ip-limit.sh && chmod +x check-ip-limit.sh
cd
cd /etc/xray/limitip
wget -q ${GITHUB}tools/clients_limit.conf
cd

# ===== Pasang Cronjob limitIP
CRON_JOB="*/5 * * * * /usr/bin/check-ip-limit.sh"
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

# ===== Pasang Cronjob clear cache
CRON_JOB="0 3 * * * /usr/bin/clear-cache.sh"
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

# ==== Pasang auto Delete Expired
(crontab -l 2>/dev/null; echo "0 23 * * * /usr/bin/expired.sh") | crontab -

# ==== Pasang auto Reboot
(crontab -l 2>/dev/null; echo "0 5 * * * reboot # auto_reboot") | crontab -

# ==== Pasang Cek System
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/bin/status-service.sh") | crontab -


echo ""
echo -e "┌─────────────────────────────────────┐"
echo -e "│   .::  SUCCESFULLY INSTALLED ::.    │"
echo -e "└─────────────────────────────────────┘"
echo "   _____      _     _______                     _ "
echo "  / ____|    | |   |__   __|                   | |"
echo " | |     __ _| |_     | |_   _ _ __  _ __   ___| |"
echo " | |    / _\` | __|    | | | | | '_ \\| '_ \ / _ \ |"
echo " | |___| (_| | |_     | | |_| | | | | | | |  __/ |"
echo "  \\_____\__,_|\__|    |_|\__,_|_| |_|_| |_|\___|_|"
echo "                                                  "
echo "                                                  "

rm -rf /root/*

echo "Tekan Enter Untuk Menuju Menu Utama(↩️)"
read -s
menu
