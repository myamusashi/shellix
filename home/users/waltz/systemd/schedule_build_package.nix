{
  lib,
  pkgs,
  ...
}: {
  # Pastikan systemd diaktifkan (biasanya sudah default)
  # systemd.enable = true;

  # Service untuk Garbage Collection
  systemd.services.nix-gc = lib.mkDefault {
    description = "NixOS Garbage Collection";
    wantedBy = ["multi-user.target"];
    path = with pkgs; [nix]; # Pastikan nix ada di PATH
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.nix}/bin/nix-collect-garbage -d";
    };
  };

  # Timer untuk Garbage Collection (akan berjalan setiap bulan)
  systemd.timers.nix-gc = lib.mkDefault {
    description = "Monthly NixOS Garbage Collection";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "monthly"; # Jalankan setiap bulan
      Persistent = true; # Jika mesin mati, akan dijalankan saat boot berikutnya
    };
  };

  # Service untuk build server machine (waltz)
  systemd.services.nixos-build-waltz = {
    description = "NixOS Build for Waltz Server";
    wantedBy = ["multi-user.target"];
    path = with pkgs; [nix]; # Pastikan nix ada di PATH
    # Pastikan garbage collection selesai sebelum build dimulai
    after = ["nix-gc.service"];
    requires = ["nix-gc.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.nixos-rebuild}/bin/nixos-rebuild build --keep-going --flake path:/etc/nixos#waltz";
    };
  };

  # Timer untuk build server machine (waltz) - akan berjalan setiap bulan
  systemd.timers.nixos-build-waltz = {
    description = "Monthly NixOS Build for Waltz Server";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "monthly"; # Jalankan setiap bulan
      Persistent = true;
    };
  };

  # Service untuk build main machine (nixos)
  systemd.services.nixos-build-nixos = {
    description = "NixOS Build for Main Machine";
    wantedBy = ["multi-user.target"];
    path = with pkgs; [nix]; # Pastikan nix ada di PATH
    # Pastikan garbage collection selesai sebelum build dimulai
    after = ["nix-gc.service"];
    requires = ["nix-gc.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.nixos-rebuild}/bin/nixos-rebuild build --keep-going --flake path:/etc/nixos#nixos";
    };
  };

  # Timer untuk build main machine (nixos) - akan berjalan setiap bulan
  systemd.timers.nixos-build-nixos = {
    description = "Monthly NixOS Build for Main Machine";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "monthly"; # Jalankan setiap bulan
      Persistent = true;
    };
  };

  # Service untuk build home-manager (user level)
  # Meskipun ini user level, kita jalankan sebagai root karena diminta
  # dan untuk memastikan PATH dan lingkungan yang konsisten.
  # Jika Anda ingin ini berjalan sebagai user tertentu, Anda perlu membuat
  # user-level systemd service/timer, yang sedikit lebih kompleks.
  systemd.services.home-manager-build-myamusashi = {
    description = "Home-Manager Build for Myamusashi";
    wantedBy = ["multi-user.target"];
    path = with pkgs; [nix home-manager]; # Pastikan nix dan home-manager ada di PATH
    # Pastikan garbage collection selesai sebelum build dimulai
    after = ["nix-gc.service"];
    requires = ["nix-gc.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.home-manager}/bin/home-manager build --keep-going --flake path:/etc/nixos#myamusashi";
    };
    Environment = {
      HOME = "/home/myamusashi";
    };
  };

  # Timer untuk build home-manager (user level) - akan berjalan setiap bulan
  systemd.timers.home-manager-build-myamusashi = {
    description = "Monthly Home-Manager Build for Myamusashi";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "monthly"; # Jalankan setiap bulan
      Persistent = true;
    };
  };
}
