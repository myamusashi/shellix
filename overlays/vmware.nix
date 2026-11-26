final: prev: {
    vmware-workstation = prev.vmware-workstation.overrideAttrs (oldAttrs: {
        installPhase = ''
            ${oldAttrs.installPhase}

            mv $out/bin/vmware $out/bin/vmware-bin

            makeWrapper $out/bin/vmware-bin $out/bin/vmware \
                --set GTK_THEME "Adwaita-dark" \
                --set FONTCONFIG_FILE "${final.fontconfig.out}/etc/fonts/fonts.conf" \
                --set FONTCONFIG_PATH "${final.fontconfig.out}/etc/fonts"

            if [ -f $out/share/applications/vmware-workstation.desktop ]; then
              substituteInPlace $out/share/applications/vmware-workstation.desktop \
                --replace "Exec=@@BINARY@@" "Exec=$out/bin/vmware"

              substituteInPlace $out/share/applications/vmware-player.desktop \
                --replace "Exec=@@BINARY@@" "Exec=$out/bin/vmware"
            fi
        '';
    });
}
