# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/). This repo
*is* the chezmoi source directory — files here only take effect on the
machine after `chezmoi apply`.

## What's here

- **Shell**: fish config (`dot_config/fish/`) — split into `conf.d/` (path,
  exports, abbreviations) and `functions/`, plus starship prompt config.
- **Git**: `dot_gitconfig.tmpl` (templated with your name/email) and a global
  `dot_config/git/ignore`.
- **Terminal/editor**: Ghostty (`dot_config/ghostty/`), VSCodium settings,
  Claude Code settings (`dot_claude/`).
- **macOS**: Karabiner key remapping, plus bootstrap scripts that install
  Homebrew packages and set `defaults write` system preferences.
- **Bootstrap scripts** (`run_once_*`, `run_onchange_*`): install the
  toolchain, set fish as the default shell, and apply macOS packages/defaults
  — run automatically by chezmoi, in order, on `apply`.

Linux gets its packages from `run_once_before_install-tools.sh.tmpl` (apt);
macOS gets its packages from the Brewfile in
`run_onchange_before_install-packages-darwin.sh.tmpl`. These two lists are
kept in sync manually, on purpose.

## Bootstrap a new machine

No chezmoi installed yet:

```
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply TheNilesh
```

chezmoi already installed:

```
chezmoi init --apply TheNilesh
```

## Everyday use

```
chezmoi diff      # preview what would change in $HOME
chezmoi apply     # install source state into $HOME
chezmoi cd        # jump into this source directory
chezmoi add <path> # start managing an existing $HOME file
```

After editing a file in `$HOME` that's already managed, re-import it with
`chezmoi add <path>`, then commit and push from `chezmoi cd`.

See `CLAUDE.md` for the full architecture notes and known gaps.
