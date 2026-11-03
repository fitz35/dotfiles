#!/usr/bin/env bash
# Rofi menu to lock / logout / reboot / shutdown (i3 / sway $mod+Escape, power button, bar power icon)

source "$MY_SCRIPT_DIR/lib.sh"

OPTIONS="Lock\nLogout\nReboot\nShutdown\nReturn"
CHOICE=$(echo -e $OPTIONS | "$MY_SCRIPT" rofi -dmenu -p "System")

case $CHOICE in
    Lock)
        "$MY_SCRIPT" lock
        ;;
    Logout)
        # thunderbird doesn't exit properly at logout
        # so we kill it manually
        pkill thunderbird ; wm_msg exit
        ;;
    Reboot)
        systemctl reboot
        ;;
    Shutdown)
        systemctl poweroff
        ;;
    Return)

        ;;
esac
