#!/bin/bash
clear
# Definisi Warna
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
echo -e "${BLUE}   ┌──────────────────────────────────────┐${NC}"
echo -e "${BLUE}   |      .::   MENU TROJAN MANAGER  ::.  │${NC}"
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e "      1. Create New Account              "
echo -e "      2. Renew Account                   "
echo -e "      3. Delete Account                  "
echo -e "      4. List Account                    "
echo -e "      5. Trial Account 1 Hari          "
echo -e "      6. View Trojan Detail Account       "
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e ""
read -p "Select Menu (0 To Back Menu) : " pilihan
# Memproses pilihan
case $pilihan in
    1)
        add-trojan.sh
        ;;
    2)
        renew-trojan.sh
        ;;
    3)
        delete-trojan.sh
        ;;
    4)
        list-user-trojan.sh
        ;;
    5)
        trial-trojan.sh
        ;;
    6)
        detail-trojan.sh
        ;;    
    0)
        menu
        ;;
    *)
        menu_trojan.sh
        ;;
esac
