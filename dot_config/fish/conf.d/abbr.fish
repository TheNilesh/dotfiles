
abbr --add k kubectl
abbr --add kgp 'kubectl get pods'
abbr --add kgpa 'kubectl get pods -A'
abbr --add kd 'kubectl describe'
abbr -a t     'tmux new -A -s main'
abbr -a tree  'exa -T'
abbr -a tree2 'exa -T --level 2'
abbr -a tree3 'exa -T --level 3'
if command -q fdfind
    abbr -a fd fdfind
end

# decode secret from k get secret -o json
abbr -a secret-decode "jq '.data | map_values(@base64d)'"
