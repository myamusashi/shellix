#!/usr/bin/env bash

HEX_DATA=$(matugen image "$(swww query | head -1 | awk '{print$8}')" -t scheme-tonal-spot -j hex | jq '.colors.dark')
RGBA_DATA=$(matugen image "$(swww query | head -1 | awk '{print$8}')" -t scheme-tonal-spot -j rgba | jq '.colors.dark')

generateHexColor() {
	echo "{"
	echo "$HEX_DATA" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r key hex_value; do
		printf "%s = \"%s\";" "$key" "$hex_value"
	done
	echo "}"
}

generateRGBAColor() {
	echo "{"
	echo "$RGBA_DATA" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r key rgba_value; do
		r_val=$(echo "$rgba_value" | awk -F'[(), ]+' '{print int($2)}')
		g_val=$(echo "$rgba_value" | awk -F'[(), ]+' '{print int($3)}')
		b_val=$(echo "$rgba_value" | awk -F'[(), ]+' '{print int($4)}')
		a_val=$(echo "$rgba_value" | awk -F'[(), ]+' '{print int($5)}')

		printf -v hex_a "%02x" "$a_val"
		printf -v hex_r "%02x" "$r_val"
		printf -v hex_g "%02x" "$g_val"
		printf -v hex_b "%02x" "$b_val"

		parse_color="${hex_a}${hex_r}${hex_g}${hex_b}"

		# Format for Nix output
		printf "%s = \"#%s\";" "$key" "$parse_color"
	done
	echo "}"
}

generateHexColor >matugen.nix
generateRGBAColor >matugenrgba.nix
alejandra matugen*.* 2>/dev/null
