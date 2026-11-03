#!/usr/bin/env bash
# Rofi menu to lock / logout / reboot / shutdown (i3 $mod+Escape, power button, polybar power icon)

OPTIONS="Lock\nLogout\nReboot\nShutdown\nReturn"
CHOICE=$(echo -e $OPTIONS | "$MY_SCRIPT" rofi -dmenu -p "System")

case $CHOICE in
    Lock)
        # lock i3 session (keep )
        "$MY_SCRIPT" lock
        ;;
    Logout)
        # thunderbird doexn't exit properly at logout
        # so we kill it manually
        pkill thunderbird ; i3-msg exit
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