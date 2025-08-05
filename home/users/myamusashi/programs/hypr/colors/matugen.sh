#!/usr/bin/env bash

RGBA_DATA=$(matugen image "$(swww query | head -1 | awk '{print$8}')" -t scheme-tonal-spot -j rgba | jq '.colors.dark')
RGB_DATA=$(matugen image "$(swww query | head -1 | awk '{print$8}')" -t scheme-tonal-spot -j rgb | jq '.colors.dark')

generateRGBAColor() {
	echo "{"
	echo "$RGB_DATA" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r key rgb_value; do
		converted_rgb=$(echo "$rgb_value" | awk -F'[(),]' '{
            r = int($2 + 0.5)
            g = int($3 + 0.5)
            b = int($4 + 0.5)
            printf "rgba(%d, %d, %d, 0.7)", r, g, b
        }')

		# Format as Nix attribute
		printf "  %s = \"%s\";\n" "$key" "$converted_rgb"
	done
	echo "}"
}

generateHexColor() {
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

		color_32bit="${hex_a}${hex_r}${hex_g}${hex_b}"

		# Format for Nix output
		printf "%s = \"%s\";" "$key" "$color_32bit"
	done
	echo "}"
}

generateHexColor >matugen.nix
generateRGBAColor >matugen_rgba.nix
alejandra matugen*.* 2>/dev/null
