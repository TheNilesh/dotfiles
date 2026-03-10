# Dotfiles

Personal development environment managed with **chezmoi** and stored in Git.
The repository tracks shell configuration, terminal tools, and editor settings so the same environment can be reproduced on any machine.

---

## Requirements

* git
* chezmoi

Install chezmoi:

```
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
```

---

## Bootstrap on a New Machine

Clone and apply the configuration in one step:

```
chezmoi init --apply git@github.com:TheNilesh/dotfiles.git
```

This will:

1. Clone the repository into the chezmoi source directory.
2. Install managed configuration files into `$HOME`.
3. Recreate the configured shell environment.

Typical source directory:

```
~/.local/share/chezmoi
```

---

## Repository Layout

Example structure:

```
dot_config/
  fish/
  starship.toml

dot_tmux.conf
dot_gitconfig.tmpl

scripts/
README.md
```

How names map to the real filesystem:

| Source file                   | Installed as                 |
| ----------------------------- | ---------------------------- |
| `dot_tmux.conf`               | `~/.tmux.conf`               |
| `dot_config/fish/config.fish` | `~/.config/fish/config.fish` |
| `dot_gitconfig.tmpl`          | `~/.gitconfig`               |

Prefix meanings:

| Prefix        | Meaning                                     |
| ------------- | ------------------------------------------- |
| `dot_`        | represents a leading `.` in the target path |
| `private_`    | restricts file permissions                  |
| `.tmpl`       | rendered as a template before installation  |
| `executable_` | installed with executable permissions       |

---

## Editing Chezmoi Managed Files

Edit files in the chezmoi source directory:

```shell
chezmoi cd
```

or open it in the editor:

```shell
chezmoi edit ~/.config/fish/config.fish
```

Preview changes:

```
chezmoi diff
```

Apply changes:

```
chezmoi apply
```

---

## Adding New Files to Dotfiles

Example: manage a fish configuration file.

```
chezmoi add ~/.config/fish/config.fish
```

chezmoi converts it into source format:

```
dot_config/fish/config.fish
```

Verify:

```
chezmoi diff
```

Commit changes:

```
chezmoi cd
git add .
git commit -m "add fish config"
git push
```

---

## Updating a Managed File

After editing a file in `$HOME`, re-import it:

```
chezmoi add ~/.config/fish/config.fish
```

Then commit:

```
chezmoi cd
git commit -am "update fish config"
git push
```

---

## Pull Updates on Another Machine

```
chezmoi update
```

This pulls the latest repository changes and applies them.

---

## Managing Secrets

Sensitive files can be encrypted before committing:

```
chezmoi add --encrypt ~/.ssh/config
```

Encrypted files remain safe even if the repository becomes public.

---

## Typical Workflow

Modify configuration:

```
vim ~/.config/fish/config.fish
```

Update chezmoi source:

```
chezmoi add ~/.config/fish/config.fish
```

Apply changes:

```
chezmoi apply
```

Commit and push:

```
chezmoi cd
git commit -am "update shell config"
git push
```

---

## Restoring the Environment

Running the bootstrap command on any machine recreates the same configuration:

```
chezmoi init --apply git@github.com:<username>/dotfiles.git
```

This ensures consistent shell behavior, tools, and editor configuration across systems.
