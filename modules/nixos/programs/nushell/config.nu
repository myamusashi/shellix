source ($nu.cache-dir | path join "carapace.nu")

source ~/.config/nushell/zoxide.nu

alias ls = eza --icons always
alias lla = eza -a --icons always

# --- abbr / aliases ---
alias ll = ls -lah
alias lg = lazygit
alias cat = bat
alias df = duf
alias top = btop
# mkdir in nu already creates parents, no -p needed
alias cp = cp -iv
alias mv = mv -iv
alias rm = rm -iv
alias copy = wl-copy
alias paste = wl-paste
alias gifplay = mpv --loop-file=inf
alias nrun = nix run nixpkgs#
alias nsh = nix shell nixpkgs#
alias emu = emulator -avd pixel_api35 -no-snapshot -gpu host

# --- functions ---

def url-looks-like-archive [url: string]: nothing -> bool {
    let path = ($url | split row "?" | first | split row "#" | first)
    let lower = ($path | str lowercase)

    let archive_exts = [
        ".tar" ".tar.gz" ".tgz" ".tar.bz2" ".tbz2" ".tar.xz" ".txz"
        ".tar.zst" ".tzst" ".zip" ".7z"
    ]

    # Single-file formats that must NEVER be unpacked, checked first so
    # they short-circuit before archive-extension logic below.
    let single_file_exts = [".appimage"]

    if ($single_file_exts | any {|ext| $lower | str ends-with $ext }) {
        return false
    }

    if ($archive_exts | any {|ext| $lower | str ends-with $ext }) {
        return true
    }

    let is_github_host = (
        ($lower | str starts-with "https://codeload.github.com/")
        or ($lower | str starts-with "http://codeload.github.com/")
        or ($lower | str starts-with "https://github.com/")
        or ($lower | str starts-with "http://github.com/")
    )

    if not $is_github_host {
        return false
    }

    let is_codeload_archive = ($lower =~ 'codeload\.github\.com/[^/]+/[^/]+/(tar\.gz|zip|legacy\.tar\.gz|legacy\.zip)/')
    let is_github_archive_path = ($lower =~ 'github\.com/[^/]+/[^/]+/archive/')

    $is_codeload_archive or $is_github_archive_path
}

def nbc [
    file: path           
    --args (-a): string  
] {
    let path = ($file | path expand)
    let call_args = ($args | default "{}")

    ^nix-build -E $"with import <nixpkgs> {}; callPackage ($path) ($call_args)"
}

def prefetch-hash [
    url: string
    --unpack (-u)      # force --unpack on
    --no-unpack (-n)   # force --unpack off, overrides detection
] {
    let should_unpack = if $no_unpack {
        false
    } else if $unpack {
        true
    } else {
        (url-looks-like-archive $url)
    }

    let args = if $should_unpack {
        [--unpack --hash-type sha256 --json $url]
    } else {
        [--hash-type sha256 --json $url]
    }

    print $"(ansi grey)prefetching ($url) \(unpack: ($should_unpack)\)(ansi reset)"

    let result = (nix store prefetch-file ...$args | from json)
    $result.hash
}

def kiss [host: string] {
    ^kitty + kitten ssh $host
}

def img [file: string] {
    ^img2sixel $file
}

def icat [file: string] {
    ^kitten icat $file
}

def ws [path: string] {
    ^qs -c lock ipc call img set $path
}

def fontlist [pattern: string] {
    ^fc-list --format='%{family}\n' | ^rg $pattern
}

def --env yy [...args] {
    let tmp = (mktemp -t "yazi-cwd.XXXXX")
    ^yazi ...$args --cwd-file $tmp
    let cwd = (open $tmp | str trim)
    if $cwd != "" and $cwd != $env.PWD {
        cd $cwd
    }
    rm -fp $tmp
}

def --env nvim [...args] {
    with-env { NVIM_APPNAME: "nvim" } {
        ^nvim -u ($env.HOME | path join ".config" "muvim" "init.lua") ...$args
    }
}

# --- media compression ---

def vidcompress [
    input: string
    crf: int = 28
    preset: string = "slow"
] {
    let output = ($input | str replace --regex '\.[^.]+$' '_compressed.mp4')
    ^ffmpeg -hwaccel vaapi -hwaccel_output_format vaapi -i $input -c:v h264_vaapi -qp $crf -preset $preset -c:a aac -b:a 128k $output
    print $"→ ($output)"
}

def vidtowebm [input: string] {
    let output = ($input | str replace --regex '\.[^.]+$' '.webm')
    ^ffmpeg -hwaccel vaapi -hwaccel_output_format vaapi -i $input -c:v libvpx-vp9 -crf 33 -b:v 0 -c:a libopus $output
}

def vidtogif [
    input: string
    start: int = 0
    dur: int = 5
    fps: int = 15
    width: int = 800
] {
    let output = ($input | str replace --regex '\.[^.]+$' '.gif')
    let vf = $"hwdownload,format=nv12,fps=($fps),scale=($width):-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse"
    ^ffmpeg -hwaccel vaapi -hwaccel_output_format vaapi -ss $start -t $dur -i $input -vf $vf -loop 0 $output
    print $"→ ($output)"
}

def imgcompress [
    quality: int = 75
    ...files: string
] {
    for f in $files {
        let out = ($f | str replace --regex '\.([^.]+)$' '_compressed.$1')
        ^magick $f -quality $quality $out
        print $"($f) → ($out)"
    }
}

def imgtojpg [...files: string] {
    for f in $files {
        let out = ($f | str replace --regex '\.[^.]+$' '.jpg')
        ^magick $f $out
        print $"($f) → ($out)"
    }
}

def imgtowebp [...files: string] {
    for f in $files {
        let out = ($f | str replace --regex '\.[^.]+$' '.webp')
        ^magick $f -quality 85 $out
        print $"($f) → ($out)"
    }
}

# --- archive extract / compress ---

def extract [file: string] {
    let filesize = (^stat -c%s $file | into int)
    match ($file | path basename) {
        $f if ($f | str ends-with ".tar.gz") or ($f | str ends-with ".tgz") => {
            ^pv -s $filesize $file | ^tar xzf - -C .
        }
        $f if ($f | str ends-with ".tar.bz2") or ($f | str ends-with ".tbz") => {
            ^pv -s $filesize $file | ^tar xjf - -C .
        }
        $f if ($f | str ends-with ".tar.xz") => {
            ^pv -s $filesize $file | ^tar xJf - -C .
        }
        $f if ($f | str ends-with ".tar.zst") => {
            ^pv -s $filesize $file | ^tar --zstd -xf - -C .
        }
        $f if ($f | str ends-with ".zip") => { ^unzip $file }
        $f if ($f | str ends-with ".7z") => { ^7z x $file }
        $f if ($f | str ends-with ".rar") => { ^unrar x $file }
        $f if ($f | str ends-with ".zst") => {
            ^pv -s $filesize $file | ^zstd -d - -o ($file | path parse | update extension "" | path join)
        }
        _ => { print $"Unknown archive: ($file)" }
    }
}

def compress [
    fmt: string
    target: string
    outname?: string
] {
    let name = ($outname | default $target)
    let size = (^du -sb $target | split row "\t" | get 0 | into int)

    match $fmt {
        "tar.xz" | "txz" => {
            let out = $"($name).tar.xz"
            print $"Compressing -> ($out) (xz -9 -T0)"
            ^tar -C ($target | path dirname) -cf - ($target | path basename)
                | ^pv -s $size
                | XZ_OPT="-9 -T0" ^xz > $out
            print $"Done: ($out) ((^du -sh $out | split row "\t" | get 0))"
        }
        "tar.gz" | "tgz" => {
            let out = $"($name).tar.gz"
            print $"Compressing -> ($out)"
            ^tar -C ($target | path dirname) -cf - ($target | path basename)
                | ^pv -s $size
                | ^gzip -9 > $out
            print $"Done: ($out) ((^du -sh $out | split row "\t" | get 0))"
        }
        "tar.zst" | "tzst" => {
            let out = $"($name).tar.zst"
            print $"Compressing -> ($out) (zstd -19 -T0)"
            ^tar -C ($target | path dirname) -cf - ($target | path basename)
                | ^pv -s $size
                | ^zstd -19 -T0 > $out
            print $"Done: ($out) ((^du -sh $out | split row "\t" | get 0))"
        }
        "zip" => {
            let out = $"($name).zip"
            print $"Compressing -> ($out)"
            ^zip -r $out $target
            print $"Done: ($out) ((^du -sh $out | split row "\t" | get 0))"
        }
        _ => { print $"Unknown format: ($fmt)"; print "Available: tar.xz, tar.gz, tar.zst, zip" }
    }
}

def mktgz [target: string] { compress tar.gz $target }
def mkzip [target: string] { compress zip $target }
def mktxz [target: string] { compress tar.xz $target }
def mktzst [target: string] { compress tar.zst $target }

# --- config quick-edit ---

def hyprlua [] { ^nvim ($env.HOME | path join ".config" "hypr" "hyprland.lua") }
def nvimconf [] { ^nvim ($env.HOME | path join ".config" "nvim" "init.lua") }

# --- misc ---

def lssize [] { ^du -sh * | sort-by size | each {|r| print $r} }

def --env mkcd [dir: string] {
    mkdir $dir
    cd $dir
}

# --- kde connect via fzf ---

def kc [] {
    let device = (^kdeconnect-cli -l --id-only err> /dev/null
        | lines | str trim | where {|l| $l != ""}
        | input list --fuzzy "device > ")
    if ($device | is-empty) { return }

    let action = (["send file" "send clipboard"]
        | input list --fuzzy "action > ")
    if ($action | is-empty) { return }

    match $action {
        "send file" => {
            let file = (ls -a **/* | where type == file | get name
                | input list --fuzzy "file > ")
            if ($file | is-empty) { return }
            ^kdeconnect-cli -d $device --share $file
            print $"sent: ($file)"
        }
        "send clipboard" => {
            let content = (^wl-paste)
            if ($content | is-empty) {
                print "clipboard is empty"
                return
            }
            ^kdeconnect-cli -d $device --share-text $content
            print "clipboard sent"
        }
    }
}

# --- keybindings ---

$env.config.keybindings = ($env.config.keybindings? | default [] | append [
    {
        name: fzf_history
        modifier: control
        keycode: char_r
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: ExecuteHostCommand
            cmd: "
                let result = (history | get command | reverse | uniq | str join (char newline) |
                    fzf --height=40% --reverse --border --prompt='History> ' |
                    str trim)
                if ($result | is-not-empty) {
                    commandline edit --replace $result
                }
            "
        }
    }
])

# --- direnv ---

use std/config *

# Initialize the PWD hook as an empty list if it doesn't exist
$env.config.hooks.env_change.PWD = $env.config.hooks.env_change.PWD? | default []

$env.config.hooks.env_change.PWD ++= [{||
  if (which direnv | is-empty) {
    # If direnv isn't installed, do nothing
    return
  }

  direnv export json | from json | default {} | update cells --columns [ PATH ] {
    # If direnv changes the PATH, it will become a string and we need to re-convert it to a list
    do (env-conversions).path.from_string $in
  } | load-env
}]

# -- zoxide --

def "nu-complete zoxide path" [context: string] {
    let parts = $context | str trim --left | split row " " | skip 1 | each { str lowercase }
    let completions = (
        ^zoxide query --list --exclude $env.PWD -- ...$parts
            | lines
            | each { |dir|
                if ($parts | length) <= 1 {
                    $dir
                } else {
                    let dir_lower = $dir | str lowercase
                    let rem_start = $parts | drop 1 | reduce --fold 0 { |part, rem_start|
                        ($dir_lower | str index-of --range $rem_start.. $part) + ($part | str length)
                    }
                    {
                        value: ($dir | str substring $rem_start..),
                        description: $dir
                    }
                }
            })
    {
        options: {
            sort: false,
            completion_algorithm: substring,
            case_sensitive: false,
        },
        completions: $completions,
    }
}

# -- process table --

def clean-name [name: string, cmd: string] {
    let base = $name
        | str replace --regex '^\.' ''
        | str replace --regex '-wrapped$|-wrapper$|_wrapped$' ''
        | str replace --regex '-bin$' ''

    let generic = [qs quickshell node bun python python3 electron chrome bash zsh nu sh]
    if ($base | str lowercase) in $generic {
        let args = $cmd | split row ' ' | skip 1
        let hint = if ($args | is-empty) {
            null
        } else if ($args | any { |a| $a == "-c" }) {
            let i = $args | enumerate | where item == "-c" | first | get index
            $args | get -o ($i + 1)
        } else {
            $args | where { |a| not ($a | str starts-with "-") } | first | default null
        }

        if $hint != null {
            $"($base) \(($hint | path basename)\)"
        } else {
            $base
        }
    } else {
        $base
    }
}

def memu [
    ...targets: any               # PIDs (ints) and/or process name patterns (strings)
    --sort (-s): string = "real"  # Sort by: real, resident, virtual (old names pss/rss/vsz also work)
    --total (-t)                  # Append a total row
    --raw (-r)                    # Show the raw process name from ps
] {
    let sort_col = match $sort {
        "real" | "pss" => "Real Memory",
        "resident" | "rss" => "Resident",
        "virtual" | "vsz" => "Virtual",
        _ => "Real Memory",
    }

    if ($targets | is-empty) {
        error make { msg: "Give at least one PID or process name" }
    }

    let procs = ps --long

    let matched = $targets | each { |t|
        match ($t | describe) {
            "int" => ($procs | where pid == $t),
            _ => {
                let needle = $t | into string
                $procs | where { |p|
                    ($p.name | str contains --ignore-case $needle) or ($p.command | str contains --ignore-case $needle)
                }
            },
        }
    } | flatten | uniq-by pid

    if ($matched | is-empty) {
        error make { msg: $"No process found for: ($targets | str join ', ')" }
    }

    let rows = $matched | each { |p|
        let smaps = $"/proc/($p.pid)/smaps_rollup"

        let real = if ($smaps | path exists) {
            try {
                open --raw $smaps
                | lines
                | where $it =~ '^Pss:'
                | first
                | parse --regex '(\d+)'
                | get capture0.0
                | into int
                | $in * 1024
                | into filesize
            } catch { 0b }
        } else { 0b }

        {
            PID: $p.pid
            Name: (if $raw { $p.name } else { clean-name $p.name $p.command })
            "Real Memory": $real
            Resident: $p.mem
            Virtual: $p.virtual
            "CPU %": $p.cpu
        }
    }

    let sorted = $rows | sort-by { |r| $r | get $sort_col } --reverse

    if $total {
        let sum = {
            PID: "-"
            Name: $"TOTAL \(($sorted | length) procs\)"
            "Real Memory": ($sorted | get Memory | math sum)
            Resident: ($sorted | get Resident | math sum)
            Virtual: ($sorted | get Virtual | math sum)
            "CPU %": ($sorted | get "CPU %" | math sum)
        }
        $sorted | append $sum
    } else {
        $sorted
    }
}
