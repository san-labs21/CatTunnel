#!/bin/bash
clear
# Definisi Warna
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
echo -e "${BLUE}   ┌──────────────────────────────────────┐${NC}"
echo -e "${BLUE}   |      .::   MENU SSH MANAGER  ::.     │${NC}"
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e "      1. Create New Account              "
echo -e "      2. Renew Account                   "
echo -e "      3. Delete Account                  "
echo -e "      4. List Account                    "
echo -e "      5. Trial Account 1 Hari          "
echo -e "      6. View SSH Detail Account      "
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e ""
read -p "Select Menu (0 Back to Menu) : " pilihan
# Memproses pilihan
case $pilihan in
    1)
        add-ssh.sh
        ;;
    2)
        renew-ssh.sh
        ;;
    3)
        delete-ssh.sh
        ;;
    4)
        list-user-ssh.sh
        ;;
    5)
        trial-ssh.sh
        ;;
    6)
        detail-ssh.sh
        ;;
    0)
        menu
        ;;
    *)
        menu_ssh.sh
        ;;
esac
