if status is-interactive
# Commands to run in interactive sessions can go here
end

direnv hook fish | source
starship init fish | source

~/.local/bin/mise activate fish | source # added by https://mise.run/fish

# Helper for setting env variables without entering on terminal
function set-secret
  if test (count $argv) -lt 1
    echo "Usage: set-secret VAR_NAME" >&2
    return 1
  end
  read --silent --prompt-str="Enter value for $argv[1]: " value </dev/tty
  set --export --global $argv[1] $value
end
