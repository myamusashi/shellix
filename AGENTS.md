<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->

# Nix code style
- Never violated the `4 spaces indentation`; always formatting with experimental configs at .alejandra.toml: `alejandra --experimental-config .alejandra.toml`
- Always run statix everytime you change the code
- Always test eval toplevel everytime you change the code

# Prefetch hash files from git services
- Use `nix store prefetch-file --hash-type sha256 --json <url>` to get the hash value

# Resources
zen-browser programns options: `https://zen-browser-flake.nshard.com`
