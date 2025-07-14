#!/bin/bash

# Konfigurasi
LOG_FILE="/var/log/xray/access.log"            # Path access.log
CLIENT_CONFIG="/etc/xray/limitip/clients_limit.conf"             # File konfigurasi client
INITIAL_LINES=1000                             # Jumlah baris awal yang diambil
FILTERED_LINES=20                              # Jumlah baris terfilter yang diperiksa

# Konfigurasi Telegram Bot
TELEGRAM_BOT_TOKEN="$(cat /etc/xray/token)"    # Token bot Telegram
TELEGRAM_CHAT_ID="$(cat /etc/xray/chatid)"     # Chat ID tujuan

# Fungsi untuk format pesan Telegram
format_telegram_message() {
    local user=$1
    local limit=$2
    local count=$3
    local ips=$4
    
    echo "🚨 <b>PELANGGARAN BATAS DEVICE</b> 🚨"
    echo "━━━━━━━━━━━━━━━━━━━━━━"
    echo "▪️ <b>User:</b> <code>$user</code>"
    echo "▪️ <b>Batas IP:</b> $limit"
    echo "▪️ <b>IP Aktif:</b> $count"
    echo "━━━━━━━━━━━━━━━━━━━━━━"
    echo "📌 <b>Daftar IP:</b>"
    echo "$ips" | awk '{print "• " $0}'
    echo "━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️ <b>Status:</b> Melebihi batas!"
}

# Fungsi kirim notifikasi ke Telegram
send_telegram_alert() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d text="$message" \
        -d parse_mode="HTML" > /dev/null
}

# Fungsi cek IP aktif (hanya ambil IP setelah "from")
check_active_ips() {
    local user=$1
    local limit=$2
    
    # Ambil 1000 baris terakhir, filter by user, ambil 50 baris terbaru
    local active_ips=$(tail -n $INITIAL_LINES "$LOG_FILE" | grep "$user" | tail -n $FILTERED_LINES | awk '
    {
        # Ambil IP setelah "from"
        for (i=1; i<=NF; i++) {
            if ($i == "from") {
                split($(i+1), a, ":");
                print a[1];
                break;
            }
        }
    }' | sort | uniq)
    
    local ip_count=$(echo "$active_ips" | grep -v '^$' | wc -l)
    
    # Jika melebihi batas
    if [ "$ip_count" -gt "$limit" ]; then
        local formatted_ips=$(echo "$active_ips" | tr '\n' ' ' | sed 's/ $//')
        local message=$(format_telegram_message "$user" "$limit" "$ip_count" "$formatted_ips")
        send_telegram_alert "$message"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $user melebihi batas: $ip_count/$limit IP - $formatted_ips"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $user dalam batas: $ip_count/$limit IP"
    fi
}

# Fungsi utama
main() {
    echo "Memulai pengecekan batas device..."
    echo "Waktu pengecekan: $(date)"
    echo "Memeriksa $FILTERED_LINES baris terfilter dari $INITIAL_LINES baris terakhir"
    echo "----------------------------------------"
    
    # Baca file konfigurasi
    while IFS='=' read -r user limit || [ -n "$user" ]; do
        # Skip komentar dan baris kosong
        [[ "$user" =~ ^# ]] || [ -z "$user" ] && continue
        
        echo "Memeriksa user: $user (batas: $limit IP)"
        check_active_ips "$user" "$limit"
        echo "----------------------------------------"
    done < "$CLIENT_CONFIG"
    
    echo "Pengecekan selesai pada: $(date)"
}

# Jalankan program utama
main
