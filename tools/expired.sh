#!/bin/bash

CONFIG_FILE="/etc/xray/config.json"
LIMIT_FILE="/etc/xray/limitip/clients_limit.conf"
HISTORY_DIR="/etc/xray/history"
TODAY=$(date +%Y-%m-%d)
TEMP_FILE=$(mktemp)

# Periksa file config.json
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE not found!"
    exit 1
fi

# Periksa file clients_limit.conf
if [ ! -f "$LIMIT_FILE" ]; then
    echo "Error: $LIMIT_FILE not found!"
    exit 1
fi

# Periksa directory history
if [ ! -d "$HISTORY_DIR" ]; then
    echo "Warning: History directory $HISTORY_DIR not found!"
fi

# Proses komentar untuk mencari user expired
echo "Checking for expired users..."

# Gunakan temporary file untuk menyimpan username expired
> "$TEMP_FILE"

# Proses tanpa pipe untuk menjaga variabel
while read -r line; do
    if [[ "$line" == *"##"* ]]; then
        username=$(echo "$line" | awk '{print $2}')
        exp_date=$(echo "$line" | awk '{print $3}')
        
        # Bandingkan tanggal dengan hari ini
        if [[ "$exp_date" < "$TODAY" ]]; then
            echo "EXPIRED: $username (expired on: $exp_date)"
            echo "$username" >> "$TEMP_FILE"
            
            # Hapus dari limit file
            sed -i "/^${username}=/d" "$LIMIT_FILE"
        else
            echo "ACTIVE : $username (expires on: $exp_date)"
            # Hapus limit IP untuk user aktif
            sed -i "/^${username}=/d" "$LIMIT_FILE"
        fi
    fi
done < "$CONFIG_FILE"

# Baca username expired dari temporary file
expired_users=()
if [ -s "$TEMP_FILE" ]; then
    mapfile -t expired_users < "$TEMP_FILE"
fi
rm "$TEMP_FILE"

# Fungsi untuk menghapus user dari config.json
delete_from_config() {
    local user=$1
    # Cari baris komentar user dan hapus baris tersebut + 1 baris berikutnya
    sed -i "/^[[:space:]]*##[[:space:]]*.*$user[[:space:]]/,+1d" "$CONFIG_FILE"
}

# Fungsi untuk menghapus history user
delete_history() {
    local user=$1
    local history_file="${HISTORY_DIR}/vmess-${user}"
    
    if [ -f "$history_file" ]; then
        echo "Deleting history file: $history_file"
        rm -f "$history_file"
    fi
}

# Hapus user expired dari config.json dan history
if [ ${#expired_users[@]} -gt 0 ]; then
    echo -e "\nRemoving expired users..."
    # Hapus duplikat username
    unique_users=($(printf "%s\n" "${expired_users[@]}" | sort -u))
    
    for user in "${unique_users[@]}"; do
        echo "Processing expired user: $user"
        delete_from_config "$user"
        delete_history "$user"
    done
else
    echo -e "\nNo expired users found."
fi

# Hitung total perubahan
echo -e "\nOperation completed:"
echo "- Removed IP limits for all users"
echo "- Deleted ${#expired_users[@]} expired users from config"
echo "- Cleaned up history files for expired users"
systemctl restart xray

# ==== Delete VLESS
# Proses komentar untuk mencari user expired
echo "Checking for expired users..."

# Gunakan temporary file untuk menyimpan username expired
> "$TEMP_FILE"

# Proses tanpa pipe untuk menjaga variabel
while read -r line; do
    if [[ "$line" == *"#?"* ]]; then
        username=$(echo "$line" | awk '{print $2}')
        exp_date=$(echo "$line" | awk '{print $3}')
        
        # Bandingkan tanggal dengan hari ini
        if [[ "$exp_date" < "$TODAY" ]]; then
            echo "EXPIRED: $username (expired on: $exp_date)"
            echo "$username" >> "$TEMP_FILE"
            
            # Hapus dari limit file
            sed -i "/^${username}=/d" "$LIMIT_FILE"
        else
            echo "ACTIVE : $username (expires on: $exp_date)"
            # Hapus limit IP untuk user aktif
            sed -i "/^${username}=/d" "$LIMIT_FILE"
        fi
    fi
done < "$CONFIG_FILE"

# Baca username expired dari temporary file
expired_users=()
if [ -s "$TEMP_FILE" ]; then
    mapfile -t expired_users < "$TEMP_FILE"
fi
rm "$TEMP_FILE"

# Fungsi untuk menghapus user dari config.json
delete_from_config() {
    local user=$1
    # Cari baris komentar user dan hapus baris tersebut + 1 baris berikutnya
    sed -i "/^[[:space:]]*#?[[:space:]]*.*$user[[:space:]]/,+1d" "$CONFIG_FILE"
}

# Fungsi untuk menghapus history user
delete_history() {
    local user=$1
    local history_file="${HISTORY_DIR}/vless-${user}"
    
    if [ -f "$history_file" ]; then
        echo "Deleting history file: $history_file"
        rm -f "$history_file"
    fi
}

# Hapus user expired dari config.json dan history
if [ ${#expired_users[@]} -gt 0 ]; then
    echo -e "\nRemoving expired users..."
    # Hapus duplikat username
    unique_users=($(printf "%s\n" "${expired_users[@]}" | sort -u))
    
    for user in "${unique_users[@]}"; do
        echo "Processing expired user: $user"
        delete_from_config "$user"
        delete_history "$user"
    done
else
    echo -e "\nNo expired users found."
fi

# Hitung total perubahan
echo -e "\nOperation completed:"
echo "- Removed IP limits for all users"
echo "- Deleted ${#expired_users[@]} expired users from config"
echo "- Cleaned up history files for expired users"
systemctl restart xray

# ==== Delete TROJAN 
# Proses komentar untuk mencari user expired
echo "Checking for expired users..."

# Gunakan temporary file untuk menyimpan username expired
> "$TEMP_FILE"

# Proses tanpa pipe untuk menjaga variabel
while read -r line; do
    if [[ "$line" == *"#!"* ]]; then
        username=$(echo "$line" | awk '{print $2}')
        exp_date=$(echo "$line" | awk '{print $3}')
        
        # Bandingkan tanggal dengan hari ini
        if [[ "$exp_date" < "$TODAY" ]]; then
            echo "EXPIRED: $username (expired on: $exp_date)"
            echo "$username" >> "$TEMP_FILE"
            
            # Hapus dari limit file
            sed -i "/^${username}=/d" "$LIMIT_FILE"
        else
            echo "ACTIVE : $username (expires on: $exp_date)"
            # Hapus limit IP untuk user aktif
            sed -i "/^${username}=/d" "$LIMIT_FILE"
        fi
    fi
done < "$CONFIG_FILE"

# Baca username expired dari temporary file
expired_users=()
if [ -s "$TEMP_FILE" ]; then
    mapfile -t expired_users < "$TEMP_FILE"
fi
rm "$TEMP_FILE"

# Fungsi untuk menghapus user dari config.json
delete_from_config() {
    local user=$1
    # Cari baris komentar user dan hapus baris tersebut + 1 baris berikutnya
    sed -i "/^[[:space:]]*#![[:space:]]*.*$user[[:space:]]/,+1d" "$CONFIG_FILE"
}

# Fungsi untuk menghapus history user
delete_history() {
    local user=$1
    local history_file="${HISTORY_DIR}/trojan-${user}"
    
    if [ -f "$history_file" ]; then
        echo "Deleting history file: $history_file"
        rm -f "$history_file"
    fi
}

# Hapus user expired dari config.json dan history
if [ ${#expired_users[@]} -gt 0 ]; then
    echo -e "\nRemoving expired users..."
    # Hapus duplikat username
    unique_users=($(printf "%s\n" "${expired_users[@]}" | sort -u))
    
    for user in "${unique_users[@]}"; do
        echo "Processing expired user: $user"
        delete_from_config "$user"
        delete_history "$user"
    done
else
    echo -e "\nNo expired users found."
fi

# Hitung total perubahan
echo -e "\nOperation completed:"
echo "- Removed IP limits for all users"
echo "- Deleted ${#expired_users[@]} expired users from config"
echo "- Cleaned up history files for expired users"
systemctl restart xray

# ==== Expired SSH
hapus_user_kadaluarsa() {
    echo "Memeriksa dan menghapus akun yang sudah kadaluarsa..."
    for user in $(cut -f1 -d: /etc/passwd); do
        expire_date=$(chage -l "$user" 2>/dev/null | grep "Account expires" | awk -F": " '{print $2}')
        if [[ "$expire_date" != "never" && "$expire_date" != "" ]]; then
            # Konversi tanggal expired dan tanggal hari ini ke format detik sejak epoch
            expire_seconds=$(date -d "$expire_date" +%s 2>/dev/null)
            today_seconds=$(date +%s)

            if [[ "$expire_seconds" -lt "$today_seconds" ]]; then
                echo "Akun $user telah kadaluarsa. Menghapus..."
                userdel -r "$user" &>/dev/null
            fi
        fi
    done
}
hapus_user_kadaluarsa
