# nixDots

NixOS flake-based dotfiles managing two machines.

## Hosts

| Host | Role | Hardware | User | Focus |
|------|------|----------|------|-------|
| **myamusashi** | Laptop | ThinkPad X270 (i5-6300U) | myamusashi | Hyprland desktop, KDE Plasma apps, dev |
| **waltz** | Server | VM/Server (Intel) | waltz | Self-hosted services, storage |

## Machine details

### myamusashi (laptop)

| Category | Details |
|----------|---------|
| **Kernel** | CachyOS `cachyos-bore-lto` (Bore scheduler + LTO) |
| **CPU** | Intel Core i5-6300U (2 cores, 4 threads) |
| **GPU** | Intel HD Graphics 520 (HD 520) |
| **RAM** | ZRAM swap with lz4, 50% memory, priority 1 |
| **Disk** | SSD — ext4 on `/`, vfat on `/boot` |
| **Hostname** | `nixos` |
| **IP** | Static `192.168.18.2/28` on `enp0s31f6` |
| **VLAN** | `myamusashi` (ID 2, subnet `10.10.10.0/24`) |
| **WireGuard** | `wg0` — `10.88.0.3/32` tunnel via `192.168.18.14` |
| **DNS** | systemd-resolved, Cloudflare + AdGuard upstreams, domain `home.myamusashi.dev` |
| **DE/WM** | Hyprland (Wayland compositor) |
| **Shell** | vast-shell (Quickshell-based), SDDM (Weston) |
| **Display** | SDDM with Weston compositor, auto-login disabled |
| **Audio** | PipeWire (low-latency config, 48kHz, 2048 quantum) |
| **Power** | TLP (performance on AC, powersave on battery), iio-sensor-proxy |
| **Bluetooth** | Enabled, boots on |
| **Theming** | qtengine, Kvantum, Future cursor, SF Pro fonts |
| **Security** | sops-nix + age, PAM greetd, GPG+SSH agent |
| **Backup** | Borg to waltz via WireGuard (weekly, encrypted, pruned) |
| **Services** | networkmanager, systemd-resolved, OpenSSH, Cloudflare WARP, nginx, MySQL (MariaDB) |
| **Programs** | fish, neovim (nightly), yazi, steam, kitty, vscode, spicetify, fastfetch, color-templates, etc. |

### waltz (server)

| Category | Details |
|----------|---------|
| **Kernel** | CachyOS `cachyos-server` |
| **Hostname** | `waltz` |
| **IP** | Static `192.168.18.14/28` on `enp1s0`, `192.168.18.16/28` on `wlp2s0` |
| **VLAN** | `waltz` (ID 2, subnet `10.11.11.0/24`) |
| **WireGuard** | `wg0` server — `10.88.0.1/24`, peers: myamusashi, helium |
| **External storage** | NTFS drive (`/dev/disk/by-label/BACKUP`) mounted with kernel `ntfs3` driver at `/home/waltz/external`, bind-mounted to `/opt/backup` |
| **DNS** | systemd-resolved, Cloudflare + AdGuard upstreams, domain `home.waltz.dev` |
| **SSH** | OpenSSH enabled |
| **Firewall** | TCP: 20,21,22,80,433,2408,5432,3001,3002 / UDP: 5432,3001,3002 |
| **NTP** | chrony with pool.ntp.org |
| **Display** | kmscon (TTY only, no DE) |


| Service | Port | Purpose |
|---------|------|---------|
| **forgejo** | 7597 | Self-hosted Git |
| **ocis** | 9200 | Cloud storage (ownCloud Infinite Scale) |
| **vaultwarden** | 8131 | Password manager |
| **mail** | 25/587/465 | Stalwart mail server |
| **vsftpd** | 21 | FTP file transfer |
| **mysql** | 3306 | MariaDB database |
| **nginx** | 80/443 | Reverse proxy |
| **cloudflared** | — | Cloudflare Tunnel (git, vault, ssh) |
| **netdata** | — | System monitoring |
| **grafana** | 7916 | Monitoring dashboard |
| **prometheus** | 6764 | Metrics collection |
| **Stirling-PDF** | 1298 | PDF manipulation |
| **nix-serve** | 3731 | Binary cache (disabled) |

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
│   │       ├── hardware-configuration.nix
│   │       ├── packages.nix
│   │       ├── graphics.nix
│   │       ├── hardware-features.nix
│   │       ├── security.nix
│   │       ├── services.nix
│   │       ├── virtualization.nix
│   │       └── zram.nix
│   └── waltz/             # Server config
│       ├── configuration.nix
│       ├── env.nix
│       └── hardware/
│           ├── default.nix
│           └── hardware-configuration.nix
├── modules/
│   ├── nixos/
│   │   ├── programs/      # fish, neovim, steam, kitty, yazi, color-templates, etc.
│   │   ├── services/      # audio, mpd, hypridle, display-manager, borg, etc.
│   │   └── packages/custom/ # Custom package derivations (orchis, nordic, etc.)
│   └── server/            # forgejo, ocis, vaultwarden, nginx, wireguard
├── overlays/              # hotfixes, vmware, custom packages
├── shared/Variable.nix    # Shared port definitions
└── sops/                  # sops-nix secrets
```

## Key stacks

- **Desktop**: Hyprland + Quickshell (vast-shell) + qtengine theming
- **Server**: Forgejo, ownCloud Infinite Scale, Vaultwarden, Stalwart Mail, WireGuard VPN
- **Kernel**: CachyOS (bore-lto on laptop, server on server)
- **Secrets**: sops-nix + age
- **Caching**: Cachix + various binary caches (chaotic-nyx, nix-community, ezkea, etc.)
- **Tunneling**: Cloudflared (git.myamusashi.cc, vault.myamusashi.cc, ssh.myamusashi.cc)
- **Backup**: Borg backup from laptop → server over WireGuard, encrypted with repokey-blake2

## Flake inputs

- `nixpkgs` (nixos-unstable) + `nixpkgs-stable` (release-25.11)
- Full Hyprland ecosystem (hyprland, hyprlock, hypridle, hyprpicker, hyprsunset, etc.)
- Hyprland plugins: hy3, hypr-dynamic-cursors, hypr-scroll-overview, Hyprspace
- Custom shells: vast-shell (Quickshell-based), vast-greeter
- Services: sops-nix, nix-cachyos-kernel, spicetify-nix, color-templates, zen-browser, apple-fonts, helium, and more
