#!/bin/bash
clear
# Definisi Warna
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
echo -e "${BLUE}   ┌──────────────────────────────────────┐${NC}"
echo -e "${BLUE}   |      .::   MENU TOOLS MANAGER  ::.   │${NC}"
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e "      1. Update Script          "
echo -e "      2. Set Local Time VPS         "
echo -e "      3. Set Reboot Time        "
echo -e "      4. Change Domain          "
echo -e "      5. Update Domain          "
echo -e "      6. Banner SSH             "
echo -e "      7. Install UDP Custom          "
echo -e "      8. Reboot "
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e ""
read -p "Select Menu (0 To Back Menu) : " pilihan
# Memproses pilihan
case $pilihan in
    1)
        install-update.sh
        ;;
    2)
        set-local-time.sh
        ;;
    3)
        set-reboot-time.sh
        ;;
    4)
        change-domain.sh
        ;;
    5)
        update-domain.sh
        ;;
    6)
        nano /etc/issue.net
        ;;
    7)
        install-udp.sh
        ;;
    8)
        reboot
        ;;
    0)
        menu
        ;;
    *)
        menu_lain.sh
        ;;
esac
