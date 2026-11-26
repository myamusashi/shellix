# Nix code style
- Never violated the `4 spaces indentation`; always formatting with experimental configs at .alejandra.toml: `alejandra --experimental-config .alejandra.toml`
- Always run statix everytime you change the code
- Always test eval toplevel everytime you change the code

# Prefetch hash files from git services
- Use `nix store prefetch-file --hash-type sha256 --json <url>` to get the hash value

# Resources
zen-browser programns options: `https://zen-browser-flake.nshard.com`
