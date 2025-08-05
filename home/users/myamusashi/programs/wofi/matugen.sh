#!/usr/bin/env bash

HEX_DATA=$(matugen image "$(swww query | head -1 | awk '{print$8}')" -t scheme-tonal-spot -j hex | jq '.colors.dark')

generateHexColor() {
	echo "{"
	echo "$HEX_DATA" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r key hex_value; do

		printf "%s = \"%s\";\n" "$key" "$hex_value"
	done
	echo "}"
}

generateHexColor >matugen.nix
alejandra matugen*.* 2>/dev/null
