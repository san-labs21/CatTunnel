# ==== Link Github
GITHUB="wget -q https://raw.githubusercontent.com/san-labs21/CatTunnel/main"

# ==== Buat Direktori dan masuk
mkdir -p /root/update
cd /root/update

# Perbaharui UPDATE
${GITHUB}/install/install-update.sh

# Ambil File Install UDP
${GITHUB}/install/install-udp.sh

# SSH
${GITHUB}/manager-ssh/trial-ssh.sh
${GITHUB}/manager-ssh/renew-ssh.sh
${GITHUB}/manager-ssh/list-user-ssh.sh
${GITHUB}/manager-ssh/add-ssh.sh
${GITHUB}/manager-ssh/delete-ssh.sh
${GITHUB}/manager-ssh/detail-ssh.sh

# TROJAN
${GITHUB}/manager-trojan/trial-trojan.sh
${GITHUB}/manager-trojan/renew-trojan.sh
${GITHUB}/manager-trojan/list-user-trojan.sh
${GITHUB}/manager-trojan/delete-trojan.sh
${GITHUB}/manager-trojan/add-trojan.sh
${GITHUB}/manager-trojan/detail-trojan.sh

# VLESS
${GITHUB}/manager-vless/trial-vless.sh
${GITHUB}/manager-vless/renew-vless.sh
${GITHUB}/manager-vless/list-user-vless.sh
${GITHUB}/manager-vless/delete-vless.sh
${GITHUB}/manager-vless/add-vless.sh
${GITHUB}/manager-vless/detail-vless.sh

# VMESS
${GITHUB}/manager-vmess/trial-vmess.sh
${GITHUB}/manager-vmess/renew-vmess.sh
${GITHUB}/manager-vmess/list-user-vmess.sh
${GITHUB}/manager-vmess/delete-vmess.sh
${GITHUB}/manager-vmess/add-vmess.sh
${GITHUB}/manager-vmess/detail-vmess.sh

# MENU
${GITHUB}/menu/menu
${GITHUB}/menu/menu_ssh.sh
${GITHUB}/menu/menu_vmess.sh
${GITHUB}/menu/menu_vless.sh
${GITHUB}/menu/menu_trojan.sh
${GITHUB}/menu/menu_lain.sh
${GITHUB}/menu/menu_bot.sh

# TOOLS
${GITHUB}/tools/update-script.sh
${GITHUB}/tools/restart-service.sh
${GITHUB}/tools/expired.sh
${GITHUB}/tools/change-domain.sh
${GITHUB}/tools/update-domain.sh
${GITHUB}/tools/set-local-time.sh
${GITHUB}/tools/set-reboot-time.sh
${GITHUB}/tools/status-service.sh
${GITHUB}/tools/clear-cache.sh

# ==== BERI ISIN AKSES DAN KELUAR 
chmod +x /root/update/*
mv /root/update/* /usr/bin/
cd /root/


# ==== UPDATE INFORMASI VERSION 
cd /etc/xray/
rm version
${GITHUB}/version
cd /root/
