#!/bin/bash

# Fungsi untuk membersihkan cache sistem
clean_system_cache() {
    echo "🔄 Membersihkan cache sistem..."
    sync
    echo 3 > /proc/sys/vm/drop_caches
    echo "✅ Cache sistem telah dibersihkan"
}

# Fungsi untuk membersihkan log SSH
clean_ssh_logs() {
    echo "🔄 Membersihkan log SSH..."
    if [ -f "/var/log/auth.log" ]; then
        cat /dev/null > /var/log/auth.log
    fi
    if [ -f "/var/log/secure" ]; then
        cat /dev/null > /var/log/secure
    fi
    echo "✅ Log SSH telah dibersihkan"
}

# Fungsi untuk membersihkan log Xray
clean_xray_logs() {
    echo "🔄 Membersihkan log Xray..."
    if [ -f "/var/log/xray/access.log" ]; then
        cat /dev/null > /var/log/xray/access.log
    fi
    if [ -f "/var/log/xray/error.log" ]; then
        cat /dev/null > /var/log/xray/error.log
    fi
    echo "✅ Log Xray telah dibersihkan"
}

# Fungsi untuk merestart layanan
restart_services() {
    echo "🔄 Merestart layanan..."
    systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null
    systemctl restart xray 2>/dev/null
    echo "✅ Layanan telah direstart"
}

# Fungsi utama
main() {
    echo "🚀 Memulai proses pembersihan..."
    echo "--------------------------------"
    
    clean_system_cache
    echo "--------------------------------"
    clean_ssh_logs
    echo "--------------------------------"
    clean_xray_logs
    echo "--------------------------------"
    restart_services
    echo "--------------------------------"
    
    echo "✨ Pembersihan selesai! VPS akan terasa lebih ringan."
    echo "💾 Memori tersedia:"
    free -h
}

# Jalankan fungsi utama
main
