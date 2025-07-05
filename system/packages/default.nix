{
  pkgs,
  pkgs-stable,
  inputs,
  ...
}: let
  qtfm = pkgs.callPackage ./extra/qtfm.nix {};
  reactionary = pkgs.callPackage ./extra/reactionary.nix {};
in {
  environment.systemPackages = with pkgs; [
    # qtfm
    reactionary
    inputs.kwin-effects-forceblur.packages.${system}.default
    pass-wayland
    passExtensions.pass-import
    home-manager
    vim
    lftp
    zed-editor-fhs
    poppler_utils
    proton-pass
    protonmail-bridge
    protonmail-bridge-gui
    vulkan-tools
    vmware-workstation
    libgdiplus
    polkit
    tree-sitter
    libGL
    libGLU
    pciutils
    blesh
    gnome-keyring
    onlyoffice-desktopeditors
    pcsx2
    apacheHttpd
    vulkan-tools
    mendeley
    bitwarden-desktop
    whitesur-kde
    virt-v2v
    cloudflare-warp
    udiskie
    udisks
    wineWowPackages.waylandFull
    winetricks
    carlito
    jflap
    netbeans
    gparted
    linux-wifi-hotspot
    wireshark
    busybox
    inetutils
    libvirt
    python3
    upower
    upower-notify
    virt-viewer
    alejandra
    hardinfo2
    kdiff3
    rofi-network-manager
    networkmanagerapplet
  ];
}
