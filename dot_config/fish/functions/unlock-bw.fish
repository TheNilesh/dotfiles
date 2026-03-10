function unlock-bw --description 'Unlock Bitwarden and set session key'
    set -gx BW_SESSION (bw unlock --raw)
end
