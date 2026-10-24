$env.PATH = ($env.PATH | split row (char esep) | append [
    ($env.HOME | path join ".cargo" "bin")
    ($env.HOME | path join "go" "bin")
    ($env.HOME | path join ".npm" "bin")
    ($env.HOME | path join ".local" "bin")
    ($env.HOME | path join ".spicetify")
])

$env.EDITOR = ("nvim -u " + ($env.HOME | path join ".config" "nvim" "init.lua"))

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
