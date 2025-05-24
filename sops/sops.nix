{inputs, ...}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    age.keyFile = "/home/waltz/.config/sops/age/keys.txt";

    defaultSopsFile = ./secrets.json;
    defaultSopsFormat = "json";

    secrets.cloudflare_creds = {
      format = "json";
      owner = "cloudflared";
      group = "cloudflared";
      mode = "0400";
    };

    secrets.attic_env = {
      format = "json";
      owner = "atticd";
      group = "atticd";
      mode = "0400";
    };

    secrets.token_rs256_attic = {
      format = "json";
      owner = "atticd";
      group = "atticd";
      mode = "0400";
    };

    secrets.nix-serve_secret = {
      format = "json";
      mode = "0400";
    };
  };
}
