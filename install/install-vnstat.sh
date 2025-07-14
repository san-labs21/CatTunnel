#!/bin/bash

# Cek interface utama
NET=$(ip route show default | awk '{print $5}')

# Update & instal dependensi
apt update
apt -y install vnstat libsqlite3-dev

# Jika ingin build dari source (opsional)
cd /root
wget https://humdi.net/vnstat/vnstat-2.6.tar.gz
tar zxvf vnstat-2.6.tar.gz
cd vnstat-2.6
./configure --prefix=/usr --sysconfdir=/etc && make && make install

# Buat database untuk interface
vnstat -u -i $NET

# Sesuaikan konfigurasi
sed -i "s/Interface \"eth0\"/Interface \"$NET\"/" /etc/vnstat.conf

# Izin akses
chown -R vnstat:vnstat /var/lib/vnstat

# Enable service
systemctl enable vnstat
systemctl restart vnstat
