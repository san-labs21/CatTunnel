#!/bin/bash

# ==== Export Warna
green='\e[0;32m'
NC='\e[0m'

# ==== Export CREDITS
CREDITS="${green} ـــــــــــــــﮩ٨ـ QuickTunnel ${NC}" 

# ==== Export Github Link 
GITHUB="https://raw.githubusercontent.com/Sandhj/QuickTunnel/main/"

# ==== Export Domain
domain=$(cat /root/domain)

echo -e "$CREDITS"
# ==== Install Paket Yang Dibutuhkan
# Bersihkan cache dan update
apt clean all && apt update -y
# Paket utama untuk Xray
apt install -y curl socat gnupg gnupg2 gnupg1
apt install nginx -y
# Paket tambahan/pendukung
apt install -y iptables iptables-persistent chrony apt-transport-https dnsutils lsb-release ntpdate zip pwgen openssl netcat-openbsd cron bash-completion xz-utils wget
# Setting NTP
timedatectl set-ntp true
ntpdate pool.ntp.org
systemctl enable chrony
systemctl restart chrony
# Cek status chrony
chronyc sourcestats -v
chronyc tracking -v

# ==== Set Timezone
timedatectl set-timezone Asia/Makassar

# ==== Configurasi Socket
domainSock_dir="/run/xray"
mkdir -p "$domainSock_dir"
chown www-data:www-data "$domainSock_dir"
chmod 755 "$domainSock_dir"


# ==== Make Folder XRay
mkdir -p /var/log/xray
mkdir -p /etc/xray
chown www-data:www-data /var/log/xray
chmod +x /var/log/xray
touch /var/log/xray/access.log
touch /var/log/xray/error.log
touch /var/log/xray/access2.log
touch /var/log/xray/error2.log

echo -e "$CREDITS"
# ==== Install Xray Core
latest_version="$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u www-data --version $latest_version

echo -e "$CREDITS"
# ==== Cert Domain Dengan Acme
systemctl stop nginx
mkdir /root/.acme.sh
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc


# ==== Ambil Config.json dan Xray.conf
wget -q "${GITHUB}tools/config.json" -O /etc/xray/config.json
wget -q "${GITHUB}tools/xray.conf" -O /etc/nginx/conf.d/xray.conf
               
# === Buat System Service
rm -rf /etc/systemd/system/xray.service.d
cat <<EOF> /etc/systemd/system/xray.service
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE                                 AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target

EOF
cat > /etc/systemd/system/runn.service <<EOF
[Unit]
Description=Quick
After=network.target

[Service]
Type=simple
ExecStartPre=-/usr/bin/mkdir -p /var/run/xray
ExecStart=/usr/bin/chown www-data:www-data /var/run/xray
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# ==== Restart System
systemctl daemon-reload
systemctl enable xray
systemctl restart xray
systemctl restart nginx
systemctl enable runn
systemctl restart runn
