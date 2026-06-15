{
    lib,
    config,
    ...
}: let
    cfg = config.shellix.server.mailserver;
in {
    imports = [
        (builtins.fetchTarball {
            # Pick a release version you are interested in and set its hash, e.g.
            url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/master/b49ae46f226430854102c207fdcb55e2de8e884e.tar.gz";
            # To get the sha256 of the nixos-mailserver tarball, we can use the nix-prefetch-url command:
            # release="nixos-25.05"; nix-prefetch-url "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz" --unpack
            sha256 = "0rm5f749xakmkqrpkl5ay1pydbnlinr50pvwg1vm795js2infmj5";
        })
    ];

    mailserver = lib.mkIf cfg.enable {
        enable = true;
        stateVersion = 3;
        fqdn = "mail.myamusashi.cc";
        domains = ["myamusashi.cc"];

        # A list of all login accounts. To create the password hashes, use
        # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
        loginAccounts = {
            "admin@myamusashi.cc" = {
                hashedPasswordFile = config.sops.secrets.user1-mail.path;
                aliases = ["postmaster@myamusashi.cc"];
            };
        };

        # Use Let's Encrypt certificates. Note that this needs to set up a stripped
        # down nginx and opens port 80.
        certificateScheme = "acme-nginx";
    };
    security.acme.acceptTerms = true;
    security.acme.defaults.email = "security@myamusashi.cc";
}
