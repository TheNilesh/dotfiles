if status is-interactive
# Commands to run in interactive sessions can go here
end

direnv hook fish | source
starship init fish | source

~/.local/bin/mise activate fish | source # added by https://mise.run/fish
