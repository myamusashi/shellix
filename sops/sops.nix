{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    age.keyFile = "/home/waltz/.config/sops/age/keys.txt";

    defaultSopsFile = ./secrets.json;
    defaultSopsFormat = "json";

    secrets.cloudflare_creds = {
      format = "json";
      mode = "0400";
    };

    secrets.nix-serve_secrets = {
      format = "json";
      mode = "0400";
    };

    secrets.gemini_key = {
      path = "/var/lib/gemini/key";
      format = "json";
      owner = "myamusashi";
      mode = "0400";
    };

    secrets.nextcloud_admin_pass = {
      format = "json";
      mode = "0400";
    };

    secrets.netdata-token = {
      owner = config.services.netdata.user;
      inherit (config.services.netdata) group;
      format = "json";
      mode = "0400";
      path = "/var/lib/netdata-token/netdata-token.yaml";
    };
  };
}
