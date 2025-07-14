#!/bin/bash
BLUE='\033[0;34m'
NC='\033[0m' # No Color
clear

CRON_ENTRY="auto_reboot"

# Fungsi untuk menambahkan atau memperbarui entri crontab
set_cron_reboot() {
    echo "Masukkan waktu reboot otomatis:"
    read -p "Jam (0-23): " hour
    read -p "Menit (0-59): " minute

    # Validasi input
    if ! [[ "$hour" =~ ^[0-9]+$ && "$minute" =~ ^[0-9]+$ ]]; then
        echo "Input harus berupa angka."
        return 1
    fi

    if (( hour < 0 || hour > 23 || minute < 0 || minute > 59 )); then
        echo "Jam harus antara 0-23 dan menit antara 0-59."
        return 1
    fi

    # Hapus entri lama jika ada
    remove_old_cron

    # Tambahkan entri baru ke crontab
    (crontab -l 2>/dev/null; echo "$minute $hour * * * reboot # $CRON_ENTRY") | crontab -

    echo "✅ Reboot otomatis diatur pada pukul $hour:$minute setiap hari."
    sleep 2
}

# Fungsi untuk menghapus entri lama
remove_old_cron() {
    if crontab -l 2>/dev/null | grep -q "$CRON_ENTRY"; then
        echo "🔄 Menghapus entri reboot lama..."
        crontab -l | grep -v "$CRON_ENTRY" | crontab -
    fi
    sleep 2
}

# Fungsi untuk melihat entri reboot saat ini
show_current_reboot() {
    entry=$(crontab -l 2>/dev/null | grep "$CRON_ENTRY")
    if [ -n "$entry" ]; then
        echo "⏰ Jadwal reboot saat ini:"
        echo "$entry"
    else
        echo "❌ Tidak ada jadwal reboot yang diatur."
    fi
    sleep 3
}

# Fungsi utama menu
main_menu() {
    while true; do
        clear
        echo ""
        echo -e "${BLUE}   ┌──────────────────────────────────────┐${NC}"
        echo -e "${BLUE}   |      .::   SET REBOOT TIME  ::.      │${NC}"
        echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
        echo "    1. Atur waktu reboot"
        echo "    2. Lihat jadwal reboot saat ini"
        echo "    3. Hapus jadwal reboot"
        echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
        echo""
        read -p "Pilih opsi (0 to back menu): " choice

        case $choice in
            1)
                set_cron_reboot
                ;;
            2)
                show_current_reboot
                ;;
            3)
                if crontab -l | grep -q "$CRON_ENTRY"; then
                    remove_old_cron
                    echo "🗑️ Jadwal reboot berhasil dihapus."
                else
                    echo "❌ Tidak ada jadwal reboot untuk dihapus."
                fi
                ;;
            0)
                menu
                ;;
            *)
                set-reboot-time.sh
                ;;
        esac
    done
}

# Jalankan menu utama
main_menu
