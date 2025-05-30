{
  pkgs,
  inputs,
  ...
}: let
  qtfm = pkgs.callPackage ./extra/qtfm.nix {};
  reactionary = pkgs.callPackage ./extra/reactionary.nix {};
in {
  environment.systemPackages = with pkgs; [
    qtfm
    reactionary
    inputs.kwin-effects-forceblur.packages.${system}.default
    home-manager
    vim
    lftp
    zed-editor-fhs
    poppler_utils
    libreoffice
    proton-pass
    vulkan-tools
    libgdiplus
    winetricks
    polkit
    ciscoPacketTracer8
    tree-sitter
    proton-ge-custom
    libgcc
    libGL
    libGLU
    pciutils
    blesh
    gnome-keyring
    onlyoffice-desktopeditors
    ffmpeg
    pcsx2
    apacheHttpd
    nemo-with-extensions
    vulkan-tools
    (
      vmware-workstation.overrideAttrs (e: {
        installPhase = ''
          ${e.installPhase}
          mv $out/bin/vmware $out/bin/vmware-bin
          makeWrapper $out/bin/vmware-bin $out/bin/vmware \
            --set GTK_THEME "Adwaita-dark"
          if [ -f $out/share/applications/vmware-workstation.desktop ]; then
            substituteInPlace $out/share/applications/vmware-workstation.desktop \
              --replace "Exec=@@BINARY@@" "Exec=$out/bin/vmware"
          fi
        '';

        nativeBuildInputs = (e.nativeBuildInputs or []) ++ [pkgs.makeWrapper];
      })
    )
    kdePackages.sddm-kcm
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
    dynamips
    wireshark
    ubridge
    busybox
    inetutils
    libvirt
    python3
    upower
    upower-notify
    virt-viewer
    alejandra
    kdePackages.kcalc
    kdePackages.kcharselect
    kdePackages.kcolorchooser
    kdePackages.ksystemlog
    kdePackages.isoimagewriter
    kdePackages.partitionmanager
    kdePackages.dolphin
    kdePackages.kate
    hardinfo2
    kdiff3
  ];
}
