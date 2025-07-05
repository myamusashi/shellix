#!/usr/bin/env bash

SCREENSHOT_DIR="$HOME/Pictures/screenshot"
SOUND_FILE="$HOME/.dots/home/programs/hypr/scripts/camera-13695.mp3"
WOFI_CONFIG="$HOME/.config/wofi/screenshot.css"

# Create screenshot directory if it doesn't exist
mkdir -p "$SCREENSHOT_DIR"

# Screenshot options (matching your original script)
OPTIONS="screenshot window
screenshot selection
screenshot eDP-1
screenshot HDMI-A-2
screenshot both screens"

# Show wofi menu
SELECTION=$(echo -e "$OPTIONS" | wofi \
	--dmenu \
	--prompt "󰄀 " \
	--width 220 \
	--height 400 \
	--lines 5 \
	--style "$WOFI_CONFIG" \
	--cache-file=/dev/null \
	--hide-scroll \
	--matching=contains)

# Generate filename with timestamp (matching your format)
IMG="$SCREENSHOT_DIR/$(date +%Y-%m-%d_%H-%m-%s).png"

# Function to handle post-screenshot actions (matching your original goto_link function)
goto_link() {
	ACTION=$(notify-send -a "Screen Capture" --action="default=open link" -i "$IMG" "Screenshot Taken" "${IMG}")

	if [ "$ACTION" == "default" ]; then
		foot --single-instance yazi $IMG
	fi
}

# Execute based on selection (keeping your original logic)
case "$SELECTION" in
"screenshot window")
	output=$(hyprshot -m window -d -s -o "$HOME/Pictures/screenshot/" -f "$(date +%Y-%m-%d_%H-%m-%s).png")
	if ! [[ "$output" =~ "selection cancelled" ]]; then
		wl-copy <"$IMG"
		mpg123 "$HOME/.dots/home/programs/hypr/scripts/camera-13695.mp3"
		sleep 1
		goto_link
	else
		notify-send -u critical -a "Screen Capture" "Screenshot Failed" "Failed to take screenshot."
	fi
	;;
"screenshot selection")
	grim -g "$(slurp)" "$IMG"
	if [ $? -eq 0 ]; then
		wl-copy <"$IMG"
		mpg123 "$HOME/.dots/home/programs/hypr/scripts/camera-13695.mp3"
		sleep 1
		goto_link
	else
		notify-send -u critical -a "Screen Capture" "Screenshot Failed" "Failed to take screenshot."
	fi
	;;
"screenshot eDP-1")
	sleep 2
	grim -c -o eDP-1 "$IMG"
	if [ $? -eq 0 ]; then
		wl-copy <"$IMG"
		mpg123 "$HOME/.dots/home/programs/hypr/scripts/camera-13695.mp3"
		goto_link
	else
		notify-send -u critical -a "Screen Capture" "Screenshot Failed" "Failed to take screenshot on eDP-1."
	fi
	;;
"screenshot HDMI-A-2")
	sleep 2
	grim -c -o HDMI-A-2 "$IMG"
	if [ $? -eq 0 ]; then
		wl-copy <"$IMG"
		goto_link
		mpg123 "$HOME/.dots/home/programs/hypr/scripts/camera-13695.mp3"
	else
		notify-send -u critical -a "Screen Capture" "Screenshot Failed" "Failed to take screenshot on HDMI-A-2."
	fi
	;;
"screenshot both screens")
	sleep 2
	grim -c -o eDP-1 "${IMG//.png/-eDP-1.png}"
	GRIM_EDP=$?
	grim -c -o HDMI-A-2 "${IMG//.png/-HDMI-A-2.png}"
	GRIM_HDMI=$?

	if [ $GRIM_EDP -eq 0 ] && [ $GRIM_HDMI -eq 0 ]; then
		montage "${IMG//.png/-eDP-1.png}" "${IMG//.png/-HDMI-A-2.png}" -tile 2x1 -geometry +0+0 "$IMG"
		wl-copy <"$IMG"
		rm "${IMG//.png/-eDP-1.png}" "${IMG//.png/-HDMI-A-2.png}"
		mpg123 "$HOME/.dots/home/programs/hypr/scripts/camera-13695.mp3"
		goto_link
	else
		notify-send -u critical -a "Screen Capture" "Screenshot Failed" "Failed to take screenshot on both screens."
	fi
	;;
*)
	# User cancelled or no selection
	exit 0
	;;
esac
