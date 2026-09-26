fish_add_path /home/myamusashi/.spicetify
set -gx PATH $HOME/go/bin $HOME/.cargo/bin $HOME/.npm/bin $HOME/.local/bin $PATH
set -gx EDITOR 'nvim -u $HOME/.config/nvim/init.lua'
set -g fish_greeting

function __fzf_search_history
    history | fzf \
        --height=40% \
        --reverse \
        --border \
        --prompt='History> ' \
        --preview='echo {}' \
        --preview-window=down:3:wrap \
        --bind='ctrl-y:execute-silent(echo {} | pbcopy)' \
        --color='fg:#d0d0d0,bg:#1c1c1c,hl:#5f87af' \
        | read -l result
    and commandline -- $result

    commandline -f repaint
end

bind \cr __fzf_search_history
