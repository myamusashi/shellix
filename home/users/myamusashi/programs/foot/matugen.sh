#!/usr/bin/env bash

HEX_DATA=$(matugen image "$(swww query | head -1 | awk '{print$8}')" -t scheme-tonal-spot -j strip | jq '.colors.dark')

generateHEXColor() {
	echo "{"
	echo "$HEX_DATA" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r key hex_value; do
		printf "%s = \"%s\";\n" "$key" "$hex_value"
	done
	echo "}"
}
generateHEXColor >matugen.nix
alejandra matugen*.* 2>/dev/null
