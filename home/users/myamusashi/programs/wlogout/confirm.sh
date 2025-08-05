#!/usr/bin/env bash

confirm_action() {
	local action=$1
	if [ "$WLOGOUT_CONFIRM" = "true" ]; then
		if wofi --dmenu --width 300 --height 100 --prompt "Are you sure you want to $action?" --cache-file /dev/null <<<"No\nYes" | grep -q "Yes"; then
			return 0
		else
			return 1
		fi
	fi
}

shutdown_system() {
	pkexec systemctl poweroff
}

reboot_system() {
	pkexec systemctl reboot
}

hibernate_system() {
	systemctl hibernate
}

suspend_system() {
	systemctl suspend
}

lock_system() {
	qs -c $HOME/.config/quickshell/kurukuru ipc call lockscreen lock
}

logout_system() {
	pkexec pkill .Hyprland-wrapp
}

case "$1" in
"shutdown")
	shutdown_system
	;;
"reboot")
	reboot_system
	;;
"hibernate")
	hibernate_system
	;;
"suspend")
	suspend_system
	;;
"lock")
	lock_system
	;;
"logout")
	logout_system
	;;
*)
	echo "Usage: $0 [shutdown|reboot|hibernate|suspend|lock|logout]"
	exit 1
	;;
esac

exit 0
