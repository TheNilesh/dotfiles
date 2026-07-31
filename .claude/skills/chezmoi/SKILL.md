---
name: chezmoi
description: Use when editing files in a chezmoi-managed dotfiles repository, adding a new file to chezmoi, deciding whether a change needs `chezmoi apply`, working with chezmoi templates (.tmpl), .chezmoiignore/.chezmoiremove, encrypted secrets, or when the user mentions "chezmoi", "dotfiles repo", "source state", or asks how a config file maps to $HOME.
---

# chezmoi dotfiles conventions

This applies whenever the working directory is a chezmoi source directory
(check with `chezmoi source-path` — if it prints the current repo, you're in
one). Files here are the **source state**; the real config lives in `$HOME`
and only reflects source changes after `chezmoi apply`.

## Naming → target mapping

| Source prefix/suffix | Meaning                                          |
| --------------------- | ------------------------------------------------ |
| `dot_`                | leading `.` in the target path                    |
| `private_`            | target gets restricted permissions (0600/0700)   |
| `executable_`         | target installed with the executable bit set     |
| `.tmpl` suffix        | file is rendered through Go templates before install |
| `run_once_*`          | script runs once (tracked by hash), on `apply`   |
| `run_onchange_*`      | script re-runs whenever its own content changes  |

Read the actual filename before assuming what it maps to — don't guess from
memory; run `chezmoi target-path <source-file>` if unsure.

## Editing workflow

1. Edit the source file directly in this repo (that's what these tools are
   for) — no need for `chezmoi edit` or `chezmoi cd` round-trips when you're
   already sitting in the source directory.
2. After edits, run `chezmoi diff` to preview what would change in `$HOME`
   before applying — especially for `.tmpl` files, since rendering can
   surprise you (missing template vars, conditional `{{ if .chezmoi.os }}`
   blocks, etc.).
3. Run `chezmoi apply` to actually install the change into `$HOME`. Editing
   the source file alone does **not** update the live config — say this
   explicitly if the user expects the change to take effect immediately.
4. If a file was edited directly in `$HOME` instead (bypassing source), use
   `chezmoi re-add` (or `chezmoi add <target>` again) to pull the change back
   into source state before it's lost on the next apply.

## Adding new files

Prefer `chezmoi add <target-path>` over hand-crafting the `dot_`-prefixed
name — it handles the prefix/permission encoding correctly and avoids typos
in the mapping.

## Ignoring / removing files

- `.chezmoiignore` — patterns for source files that should never be applied
  to `$HOME` (e.g. this repo's own `README.md`, `TODO.md`).
- `.chezmoiremove` — target paths that chezmoi should actively delete on
  apply (used for retiring a previously-managed file).

## Secrets

Never commit plaintext credentials into a chezmoi source dir. Use
`chezmoi add --encrypt <path>` for anything sensitive (SSH configs, tokens) —
this repo's encryption backend is whatever `.chezmoi.toml`/`chezmoi.toml.tmpl`
configures. Check that config before assuming a mechanism.

## Templates and prompts

`.tmpl` files render with data from `.chezmoi.toml` (materialized from
`.chezmoi.toml.tmpl` on `chezmoi init`, e.g. `promptStringOnce` calls) plus
built-ins like `.chezmoi.os`, `.chezmoi.hostname`. When editing a `.tmpl`
file, check `.chezmoi.toml.tmpl` for what data is available rather than
inventing new prompted variables without wiring them there first.

## Cross-platform package management

If this repo's `MEMORY.md` records a portability decision (Nix on Linux,
Brewfile on macOS, or similar), don't propose automating package-list sync
between platforms unless the user asks — that's an established manual-parity
preference, not an oversight.
