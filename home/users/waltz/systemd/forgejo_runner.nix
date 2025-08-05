{pkgs-stable, ...}: {
  systemd.services.forgejo-runner = {
    description = "Forgejo Actions Runner (Podman)";
    after = ["network.target" "podman.service"];
    wants = ["podman.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/etc/forgejo-runner";
      ExecStartPre = [
        "${pkgs-stable.podman}/bin/podman pull gitea/act_runner:latest"
        "-${pkgs-stable.podman}/bin/podman stop forgejo-runner"
        "-${pkgs-stable.podman}/bin/podman rm forgejo-runner"
      ];
      ExecStart = ''
        ${pkgs-stable.podman}/bin/podman run --rm \
          --name forgejo-runner \
          -v /etc/forgejo-runner:/data:Z \
          -v /var/run/podman/podman.sock:/var/run/docker.sock:Z \
          gitea/act_runner:latest daemon
      '';
      ExecStop = "${pkgs-stable.podman}/bin/podman stop forgejo-runner";
      Restart = "always";
      RestartSec = 15;
    };
  };
}
