{pkgs, ...}: {
  services.greetd = {
    enable = false;
    vt = 3;
    settings = {
      initial_session = {
        command = "Hyprland";
        user = "myamusashi";
      };
      default_session = {
        command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet tuigreet --remember --remember-user-session --time --asterisks --asterisks-char "+" --greeting "nguwawur cik" --cmd ${pkgs.hyprland}/bin/Hyprland'';
        user = "greeter";
      };
    };
  };
}
