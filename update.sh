#!/usr/bin/env bash

sudo nix-collect-garbage -d
sudo nixos-rebuild switch --flake path:/etc/nixos#waltz --keep-going |& nom
sudo nixos-rebuild build --flake path:/etc/nixos#nixos --keep-going |& nom
nix-store -qR ./result | cachix push myamusashi
home-manager build --flake path:/etc/nixos#myamusashi --keep-going |& nom
nix-store -qR ./result | cachix push myamusashi
