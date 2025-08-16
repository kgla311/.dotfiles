if status is-interactive
starship init fish | source
zoxide init fish | source 
if status is-interactive
    if test -z "$NVIM"
        fastfetch
    end
end
set -U fish_greeting
end
