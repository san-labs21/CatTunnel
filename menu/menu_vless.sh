#!/bin/bash
clear
# Definisi Warna
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
echo -e "${BLUE}   ┌──────────────────────────────────────┐${NC}"
echo -e "${BLUE}   |      .::   MENU VLESS MANAGER  ::.   │${NC}"
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e "      1. Create New Account              "
echo -e "      2. Renew Account                   "
echo -e "      3. Delete Account                  "
echo -e "      4. List Account                    "
echo -e "      5. Trial Account 1 Hari          "
echo -e "      6. View Vless Detail Account        "
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e ""
read -p "Select Menu (0 To Back Menu) : " pilihan
# Memproses pilihan
case $pilihan in
    1)
        add-vless.sh
        ;;
    2)
        renew-vless.sh
        ;;
    3)
        delete-vless.sh
        ;;
    4)
        list-user-vless.sh
        ;;
    5)
        trial-vless.sh
        ;;
    6)
        detail-vless.sh
        ;;
    0)
        menu
        ;;
    *)
        menu_vless.sh
        ;;
esac
