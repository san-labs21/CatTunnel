#!/bin/bash
clear
echo -e "  ┌──────────────────────────────────────┐"
echo -e "  │       .:: LIST SSH ACCOUNT ::.       │"
echo -e "  └──────────────────────────────────────┘"
printf "   %-2s | %-17s | %-12s\n" "No" "Username" "Expired"
echo "  ---------------------------------------"
no=1
getent passwd | while IFS=: read -r username pass uid gid gecos home shell; do
    # Filter hanya user biasa (UID >= 1000 dan bukan nobody/65534)
    if [[ "$uid" -ge 1000 && "$uid" -ne 65534 ]]; then
        exp=$(chage -l "$username" 2>/dev/null | grep "Account expires" | awk -F": " '{print $2}')
        if [ ! -z "$exp" ]; then
            printf "   %-2s | %-17s | %-12s\n" "$no" "$username" "$exp"
            no=$((no + 1))
        fi
    fi
done
echo "  ---------------------------------------"
echo "Tekan Enter Untuk Kembali (↩️)"
read -s
menu
