# Client's TERM (e.g. xterm-ghostty, xterm-kitty) may lack a terminfo entry
# on this host, which breaks tmux; only override it for incoming ssh sessions
# so local terminal capabilities (truecolor, undercurl, ...) are unaffected.
if set -q SSH_TTY
    set -gx TERM xterm-256color
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    direnv hook fish | source
    starship init fish | source
    mise activate fish | source
end

# Helper for setting env variables without entering on terminal
function set-secret
    if test (count $argv) -lt 1
        echo "Usage: set-secret VAR_NAME" >&2
        return 1
    end
    read --silent --prompt-str="Enter value for $argv[1]: " value </dev/tty
    set --export --global $argv[1] $value
end

# Added for orbstack
if test -f ~/.orbstack/shell/init2.fish
    source ~/.orbstack/shell/init2.fish
end
