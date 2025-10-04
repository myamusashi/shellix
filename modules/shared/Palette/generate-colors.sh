#!/usr/bin/env bash

set -euo pipefail

readonly WALLPAPER_CMD="qs -c lock ipc call img get "
readonly MATUGEN_ARGS="scheme-tonal-spot"
readonly OUTPUT_DIR="."

get_color_data() {
	local format="$1"
	matugen image "$($WALLPAPER_CMD)" -t "$MATUGEN_ARGS" -j "$format" | jq '.colors.dark'
}

RGB_DATA=$(get_color_data "rgb")
RGBA_DATA=$(get_color_data "rgba")
HEX_DATA=$(get_color_data "hex")
STRIP_DATA=$(get_color_data "strip")

readonly RGB_DATA
readonly RGBA_DATA
readonly HEX_DATA
readonly STRIP_DATA

output_nix_format() {
	local data="$1"
	local transform_func="$2"
	echo "{"
	echo "$data" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while IFS=' ' read -r key value; do
		local transformed_value
		transformed_value=$($transform_func "$value")
		printf '  %s = "%s";\n' "$key" "$transformed_value"
	done
	echo "}"
}

transform_rgb() {
	echo "$1" | awk -F'[(),]' '{
        r = int($2 + 0.5)
        g = int($3 + 0.5) 
        b = int($4 + 0.5)
        printf "rgb(%d, %d, %d)", r, g, b
    }'
}

transform_rgb-strip() {
	echo "$1" | awk -F'[(),]' '{
        r = int($2 + 0.5)
        g = int($3 + 0.5) 
        b = int($4 + 0.5)
        printf "%d, %d, %d", r, g, b
    }'
}

transform_rgba() {
	echo "$1" | awk -F'[(),]' '{
        r = int($2 + 0.5)
        g = int($3 + 0.5)
        b = int($4 + 0.5) 
        printf "rgba(%d, %d, %d, 0.85)", r, g, b
    }'
}

transform_hex() {
	echo "$1"
}

transform_hex16bit() {
	echo "$1" | awk -F'[(), ]+' '{
        r = int($2); g = int($3); b = int($4); a = int($5)
        printf "%02x%02x%02x%02x", a, r, g, b
    }'
}

transform_strip() {
	echo "$1"
}

main() {
	echo "Generating rgb-strip.nix..."
	output_nix_format "$RGB_DATA" "transform_rgb-strip" > "$OUTPUT_DIR/rgb-strip.nix"

	echo "Generating rgb.nix..."
	output_nix_format "$RGB_DATA" "transform_rgb" >"$OUTPUT_DIR/rgb.nix"

	echo "Generating rgba.nix..."
	output_nix_format "$RGB_DATA" "transform_rgba" >"$OUTPUT_DIR/rgba.nix"

	echo "Generating hex.nix..."
	output_nix_format "$HEX_DATA" "transform_hex" >"$OUTPUT_DIR/hex.nix"

	echo "Generating hex16bit.nix..."
	output_nix_format "$RGBA_DATA" "transform_hex16bit" >"$OUTPUT_DIR/hex16bit.nix"

	echo "Generating strip.nix..."
	output_nix_format "$STRIP_DATA" "transform_strip" >"$OUTPUT_DIR/strip.nix"

	if command -v alejandra >/dev/null 2>&1; then
		alejandra "$OUTPUT_DIR"/*.nix 2>/dev/null || true
	fi

	echo "Color extraction complete!"
}

main "$@"
