#!/usr/bin/env bash

RGB=$(matugen image "$(caelestia wallpaper)" -t scheme-tonal-spot -j rgb | jq '.colors.dark')
RGBA=$(matugen image "$(caelestia wallpaper)" -t scheme-tonal-spot -j rgba | jq '.colors.dark')
HEX=$(matugen image "$(caelestia wallpaper)" -t scheme-tonal-spot -j hex | jq '.colors.dark')
STRIP=$(matugen image "$(caelestia wallpaper)" -t scheme-tonal-spot -j strip | jq '.colors.dark')

parseRGBToNix() {
	echo "{"
	echo "$RGB" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r key rgb_value; do
		clean=$(echo "$rgb_value" | awk -F'[(),]' '{
            r = int($2 + 0.5)
            g = int($3 + 0.5)
            b = int($4 + 0.5)
            printf "rgb(%d, %d, %d)", r, g, b
        }')
		printf "  %s = \"%s\";\n" "$key" "$clean"
	done
	echo "}"

}

parseRGBAToNix() {
	echo "{"
	echo "$RGB" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r key rgb_value; do
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

parseHexToNix() {
	echo "{"
	echo "$HEX" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r key hex_value; do
		printf "  %s = \"%s\";\n" "$key" "$hex_value"
	done
	echo "}"
}

parseHex16BitToNix() {
	echo "{"
	echo "$RGBA" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r key rgba_value; do
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

parseStripToNix() {
	echo "{"
	echo "$STRIP" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r key strip_value; do
		printf "  %s = \"%s\";\n" "$key" "$strip_value"
	done
	echo "}"
}

parseRGBToNix >rgb.nix
parseRGBAToNix >rgba.nix
parseHexToNix >hex.nix
parseHex16BitToNix >hex16bit.nix
parseStripToNix >strip.nix

alejandra *.nix 2>/dev/null
