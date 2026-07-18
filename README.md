# nixDots

NixOS flake-based dotfiles managing two machines.

## Hosts

| Host | Role | Hardware | User | Focus |
|------|------|----------|------|-------|
| **myamusashi** | Laptop | ThinkPad X270 | myamusashi | Hyprland desktop, KDE Plasma apps |
| **waltz** | Server | VM/Server | waltz | Forgejo, Nextcloud, Vaultwarden, Mail, WireGuard |

## Structure

```
.
├── flake.nix              # Entry point, inputs, outputs
├── lib/                   # mkHost, mkPkgs, mkPkgsStable
├── hosts/
│   ├── myamusashi/        # Laptop config
│   │   ├── configuration.nix
│   │   ├── env.nix        # Packages & session variables
│   │   ├── networking.nix
│   │   ├── nixconfig.nix
│   │   ├── shellix.nix    # Module toggles
│   │   ├── users.nix
│   │   └── hardware/
│   │       ├── default.nix
│   │       ├── bootConfig.nix
│   │       ├── services.nix
│   │       └── virtualization.nix
│   └── waltz/             # Server config
│       ├── configuration.nix
│       ├── env.nix
│       └── hardware/
│           ├── default.nix
│           └── hardware-configuration.nix
├── modules/
│   ├── nixos/
│   │   ├── programs/      # fish, neovim, steam, kitty, yazi, etc.
│   │   ├── services/      # audio, mpd, hypridle, display-manager, etc.
│   │   └── packages/custom/ # Custom package derivations
│   └── server/            # forgejo, nextcloud, vaultwarden, nginx, wireguard
├── overlays/              # hotfixes, vmware, custom packages
├── shared/Variable.nix    # Shared port definitions
└── sops/                  # sops-nix secrets
```

## Key stacks

- **Desktop**: Hyprland + Quickshell + qtengine theming
- **Server**: Forgejo, Nextcloud, Vaultwarden, Mail (Postfix/Dovecot), WireGuard VPN
- **Kernel**: CachyOS (cachyos-bore-lto on laptop, cachyos-server on server)
- **Secrets**: sops-nix + age
- **Caching**: Cachix + various binary caches
- **Tunneling**: Cloudflared

## Flake inputs

- `nixpkgs` (nixos-unstable) + `nixpkgs-stable` (release-25.11)
- Full Hyprland ecosystem (hyprland, hyprlock, hypridle, hyprpicker, etc.)
- Hyprland plugins: hy3, hypr-dynamic-cursors, hypr-scroll-overview, Hyprspace
- Custom shells: vast-shell, vast-greeter
- Services: sops-nix, nix-cachyos-kernel, spicetify-nix, matugen, zen-browser, and more
