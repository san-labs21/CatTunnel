#!/bin/bash
clear
# Header
echo -e "┌──────────────────────────────────────┐"
echo -e "│      .:: DETAIL VLESS ACCOUNT ::.    │"
echo -e "└──────────────────────────────────────┘"

folder="/etc/xray/history/"

# Cek apakah folder ada
if [ ! -d "$folder" ]; then
    echo "Folder $folder tidak ditemukan!"
    exit 1
fi

# Simpan file ke array
files=("$folder"vless-*)

# Tampilkan daftar file tanpa awalan vless-
index=1
file_list=()

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        # Hilangkan awalan 'vless-' dari tampilan
        display_name="${filename#vless-}"
        echo "  $index. $display_name"
        file_list+=("$file")
        ((index++))
    fi
done

# Jika tidak ada file
if [ "${#file_list[@]}" -eq 0 ]; then
    echo "Tidak ada file ditemukan."
    exit 0
fi
echo -e "└──────────────────────────────────────┘"
echo""
# Input pilihan user
read -p "Select User : " pilihan

# Validasi input
if [[ "$pilihan" =~ ^[0-9]+$ ]] && [ "$pilihan" -ge 1 ] && [ "$pilihan" -le "${#file_list[@]}" ]; then
    selected_file="${file_list[$((pilihan-1))]}"
    echo ""  
    cat "$selected_file"
    
    
else
    echo "Pilihan tidak valid!"
fi

echo "Tekan Enter Untuk Menuju Menu Utama(↩️)"
read -s
menu
