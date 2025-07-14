#!/bin/bash
domain=$(cat /etc/xray/domain)
clear
# Input dari pengguna
echo -e "┌──────────────────────────────────────┐"
echo -e "│    .:: CREATE NEW SSH ACCOUNT ::.    │"
echo -e "└──────────────────────────────────────┘"
echo ""
read -p "Username : " Login
read -p "Password : " Pass
read -p "Expired : " masaaktif

# Membuat user dengan masa aktif tertentu dan shell /bin/false
useradd -e $(date -d "$masaaktif days" +"%Y-%m-%d") -s /bin/false -M $Login

# Set password untuk user
echo -e "$Pass\n$Pass\n" | passwd $Login &> /dev/null

# Mendapatkan tanggal expired akun
exp=$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')

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

# Simpan Data User
rm -rf /etc/xray/history/ssh-$Login

cat > /etc/xray/history/ssh-$Login <<EOF
✅ Akun SSH telah berhasil dibuat!
------------------------------------
Username : $Login
Password : $Pass
Expired  : $exp
------------------------------------
Host : $domain
Websocket : 80
Websocket (TLS): 443
BadVpn  : 7100-7900
------------------------------------
Websocket :
$domain:80@$Login:$Pass
Websocket TLS/SNI :
$domain:443@$Login:$Pass
------------------------------------
EOF

# Menampilkan informasi akun
echo ""
echo ""
echo "✅ Akun SSH telah berhasil dibuat!"
echo "------------------------------------"
echo "Username : $Login"
echo "Password : $Pass"
echo "Expired  : $exp"
echo "------------------------------------"
echo "Host : $domain"
echo "Websocket : 80"
echo "Websocket (TLS): 443"
echo "BadVpn  : 7100-7900"
echo "------------------------------------"
echo "Websocket :"
echo "$domain:80@$Login:$Pass"
echo "Websocket TLS/SNI :"
echo "$domain:443@$Login:$Pass"
echo "------------------------------------"
echo "Tekan Enter Untuk Kembali (↩️)"
read -s
menu
