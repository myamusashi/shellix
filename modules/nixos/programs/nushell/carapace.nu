$env.PATH = ($env.PATH | split row (char esep) | where { $in != "/home/myamusashi/.config/carapace/bin" } | prepend "/home/myamusashi/.config/carapace/bin")

def --env get-env [name] { $env | get $name }
def --env set-env [name, value] { load-env { $name: $value } }
def --env unset-env [name] { hide-env $name }

let carapace_completer = {|place|
    let spans = $place.command

    load-env {
        CARAPACE_SHELL_BUILTINS: (help commands | where category != "" | get name | each { split row " " | first } | uniq | str join "\n")
        CARAPACE_SHELL_FUNCTIONS: (help commands | where category == "" | get name | each { split row " " | first } | uniq | str join "\n")
    }

    let expanded_alias = (scope aliases | where name == $spans.0 | $in.0?.expansion?)

    let spans = (if $expanded_alias != null {
        $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
    } else {
        $spans | skip 1 | prepend ($spans.0)
    })

    carapace $spans.0 nushell ...$spans
    | from json
}

mut current = (($env | default {} config).config | default {} completions)
$current.completions = ($current.completions | default {} external)
$current.completions.external = ($current.completions.external
| default true enable
# backwards compatible workaround for default, see nushell #15654
| upsert completer { if $in == null { $carapace_completer } else { $in } })

$env.config = $current
