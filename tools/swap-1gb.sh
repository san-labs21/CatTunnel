#!/bin/bash

# Cek apakah swap sudah ada
if swapon --show | grep -q "/swapfile"; then
    echo "❌ Swap sudah aktif. Hapus swap yang ada terlebih dahulu."
    exit 1
fi

# Buat swapfile 1GB
echo "🔄 Membuat swapfile 1GB..."
fallocate -l 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Tambahkan ke fstab agar tetap aktif setelah reboot
echo "/swapfile none swap sw 0 0" >> /etc/fstab

# Optimasi pengaturan swap
echo "🔄 Mengoptimalkan pengaturan swap..."
echo "vm.swappiness=10" >> /etc/sysctl.conf
echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf
sysctl -p

# Verifikasi
echo "✅ Swap 1GB berhasil dibuat!"
