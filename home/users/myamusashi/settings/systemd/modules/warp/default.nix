{pkgs, ...}: let
  warpCliPath = "${pkgs.cloudflare-warp}/bin/warp-cli";
in {
  systemd.user.services.warp-connection = {
    Unit = {
      Description = "Warp connection";
      After = ["network-online.target"];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = ''
        ${pkgs.writeShellScript "check-and-restart-warp" ''
          while true; do
            if ! ${warpCliPath} status | grep -q "Status update: Connected"; then
              echo "Warp-CLI status is not 'Done', attempting to restart..."
              ${warpCliPath} disconnect
              sleep 2 # Give it a moment to disconnect
              ${warpCliPath} connect
            else
              echo "Warp-CLI is connected."
            fi
            sleep 30 # Check every 30 seconds
          done
        ''};
      '';
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
