# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal dotfiles repository managed with **chezmoi**. This directory *is* the
chezmoi source directory (`chezmoi source-path` resolves to this repo) — files
here are the source state; the live configuration lives under `$HOME` and only
picks up changes after `chezmoi apply`. See `.claude/skills/chezmoi/SKILL.md`
for the full editing workflow (naming conventions, apply/diff, templates,
ignore/remove files, secrets) — read it before editing any `dot_*`/`run_*`
file if you haven't already internalized chezmoi's source-state model.

## Commands

There is no build/lint/test suite. The only "commands" are chezmoi operations,
run from this directory:

```
chezmoi diff              # preview what applying the source state would change in $HOME
chezmoi apply              # install source state into $HOME
chezmoi apply -v           # same, verbose (shows each change)
chezmoi target-path <src>  # show what a given source file maps to in $HOME
```

Bootstrapping a new machine (not something to run against the developer's own
machine without confirmation — it clones into the chezmoi source dir and
mutates the real system):

```
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply TheNilesh
```

## Architecture

### Source layout maps to `$HOME` via chezmoi naming rules

- `dot_` prefix → leading `.` in the target path (e.g. `dot_tmux.conf.local` → `~/.tmux.conf.local`).
- `private_` prefix → target gets restricted permissions.
- `.tmpl` suffix → file is rendered through Go templates before install, using
  data from `.chezmoi.toml.tmpl` (prompted once via `promptStringOnce`, e.g.
  `git_identity.name`/`git_identity.email`) plus chezmoi built-ins like
  `.chezmoi.os`.
- `run_once_*` scripts execute once per content-hash on `apply`;
  `run_onchange_*` scripts re-run whenever their own rendered content changes.
- Files that live in the source repo but must never be installed into `$HOME`
  are listed in `.chezmoiignore` (currently `README.md`, `TODO.md`, and an
  OS-conditional VSCodium settings path so only one OS's copy is applied).
- `.chezmoiremove` lists target paths chezmoi should actively delete on apply
  (used to retire a previously-managed file, e.g. `.gitignore` after it moved
  to `dot_config/git/ignore`).
- `.claude/` at the repo root (no `dot_` prefix, literal leading dot) is
  **not** chezmoi source state — chezmoi treats literal dot-prefixed entries
  like `.git`/`.github` as non-managed, the same way it ignores its own
  tooling files. It holds project-scoped Claude Code config (skills) for
  working in this repo only; it is intentionally kept separate from
  `dot_claude/` (which *is* managed and installs to `~/.claude/`).

### OS-conditional bootstrap scripts run in sequence on `chezmoi apply`

1. `run_once_before_install-tools.sh.tmpl` — installs the base toolchain.
   Branches on `.chezmoi.os`: `apt`-based install list plus GitHub CLI,
   chezmoi, starship, mise, zed, and vscodium repos/binaries on Linux;
   Homebrew bootstrap only on Darwin (package installation itself is a
   separate step below).
2. `run_onchange_before_install-packages-darwin.sh.tmpl` — macOS-only,
   `brew bundle` against an inline Brewfile. Re-runs automatically whenever
   the Brewfile content in this script changes (that's the point of
   `run_onchange_`). This is the single source of truth for macOS packages —
   see the note below on Linux/macOS parity.
3. `run_once_after_set-default-shell.sh.tmpl` — adds fish to `/etc/shells` and
   `chsh`s to it if not already the login shell.
4. `run_onchange_after_set-macos-defaults.sh.tmpl` — macOS-only, sets
   `defaults write` preferences (keyboard, trackpad, Finder, Dock,
   screenshots) and restarts the affected system services. Re-runs whenever
   this script's content changes, so new defaults added here take effect on
   the next `chezmoi apply` without a version bump.
5. `run_once_after_bootstrap.fish` — installs `fisher` (fish plugin manager)
   if missing and syncs plugins from `dot_config/fish/fish_plugins`.

### Fish shell config structure

`dot_config/fish/config.fish` is the entry point (interactive-only hooks:
direnv, starship, mise) plus a `set-secret` helper for exporting an env var
without it appearing in shell history. Everything else is split by concern
under `dot_config/fish/conf.d/` (`path.fish`, `exports.fish`, `abbr.fish` —
loaded automatically by fish, no explicit sourcing needed) and
`dot_config/fish/functions/` (one file per autoloaded function, e.g.
`unlock-bw.fish` for Bitwarden CLI session unlock).

## Known constraints

- **Cross-platform package lists are intentionally maintained manually, not
  synced.** Linux packages live in `run_once_before_install-tools.sh.tmpl`
  (apt); macOS packages live in the Brewfile embedded in
  `run_onchange_before_install-packages-darwin.sh.tmpl`. Do not build
  automation to keep these two lists in parity — that's a deliberate choice,
  not an oversight.
- `TODO.md` records known gaps: no unified bootstrap entry point across
  shells yet, no flag to skip templated dotfiles that don't apply to a given
  environment (e.g. devcontainers), and devcontainer compatibility is
  unvalidated.
