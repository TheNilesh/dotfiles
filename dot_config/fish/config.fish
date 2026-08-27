# A remote host may not have the client's terminfo (for example,
# xterm-ghostty). Use a widely available type before starting tmux, but keep
# tmux's own TERM value inside panes.
if set -q SSH_TTY; and not set -q TMUX
    set -gx TERM xterm-256color
end

if status is-interactive
    # Homebrew initializes direnv and mise through fish's vendor_conf.d.
    # Keep these fallbacks for installations that do not ship those snippets.
    if not functions -q __direnv_export_eval
        direnv hook fish | source
    end

    starship init fish | source

    if not functions -q __mise_env_eval
        mise activate fish | source
    end
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
