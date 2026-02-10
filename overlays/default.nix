final: prev: let
  hotfixes = import ./hotfixes.nix final prev;
  vmware = import ./vmware.nix final prev;
  packages = import ./packages.nix final prev;
in
  hotfixes // vmware // packages
