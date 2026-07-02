# Fish setup (chezmoi)

This repo is laid out as a `chezmoi` source directory (see `.chezmoiroot`).

## Apply

From this repo clone:

```bash
chezmoi -S "$PWD" apply -v
```

Or initialize from the git repo URL:

```bash
chezmoi init --apply <repo>
```

## What gets applied

- Fish config: `~/.config/fish/` (from `home/dot_config/fish/`)
- Bootstrap helper: `~/.local/bin/bootstrap-fish` (from `home/dot_local/bin/executable_bootstrap-fish`)

On first apply, `chezmoi` runs `home/.chezmoiscripts/run_once_after_10-fish-bootstrap.sh` to install Fisher (if missing) and sync plugins from `~/.config/fish/fish_plugins`.
