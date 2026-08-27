# tmux Plugin Cheatsheet

Config: `dot_config/tmux/tmux.conf` → installed at `~/.config/tmux/tmux.conf`
Prefix key: default tmux prefix, **Ctrl-b**. Every binding below marked
`prefix` is pressed as `Ctrl-b`, release, then the key shown.

## Plugin manager (TPM)

| Keys | Action |
|---|---|
| `prefix` `I` (capital i) | Install any new plugins listed in `tmux.conf` |
| `prefix` `U` | Update all installed plugins |
| `prefix` `Alt-u` | Uninstall/remove plugins no longer listed in `tmux.conf` |

**Verify it works:** press `prefix I`. A message briefly flashes at the bottom
("TMUX plugins installed" or similar) and returns you to your pane — no
errors. Nothing to look at otherwise; it's a background installer, not an
interactive tool.

## Three ways to grab text — which one to reach for

- **tmux-thumbs** (`prefix Space`) — fastest, but only matches structured
  patterns (IPs, paths, table cells, dotted names, MACs) visible in the pane.
- **tmux-fingers** (`prefix F`) — same idea, a curated/precise pattern set,
  inserts directly at the cursor (no "copy vs paste" choice to make).
- **extrakto** (`prefix Tab`) — fuzzy fallback over up to 500 lines of
  scrollback across the whole window, for anything the pattern matchers miss.

## tmux-thumbs — quick copy by highlighting matches

Scans the visible pane for matches, overlays a short hint next to each, and
acts on your pick when you type the hint.

| Keys | Action |
|---|---|
| `prefix` `Space` | Start thumbs — highlights matches in the current pane |
| *(while active)* lowercase hint | Paste that match directly at the cursor |
| *(while active)* uppercase hint | Save that match to the tmux buffer only (no paste) |
| `Esc` | Cancel without copying |

Config tweaks in `tmux.conf`:
- `@thumbs-reverse` — shortest hints go to matches nearest the cursor.
- `@thumbs-unique` — repeated values on screen share a single hint.

### Custom match patterns (`@thumbs-regexp-1` .. `-5`)

tmux-thumbs' built-in patterns (URLs, paths, IPs, SHAs, UUIDs, hex colors,
etc.) don't cover bare identifiers like pod/namespace names or table output,
so `tmux.conf` adds five custom patterns, in order:

1. **Table cells** — a lowercase identifier-like value (≥5 chars) preceded
   and followed by 2+ spaces or a tab, e.g. the pod name in
   `nginx-deployment-7db9...    1/1    Running`. Deliberately does not match
   every hyphenated word — only things that look like a table column.
2. **Dotted names** — e.g. `api.internal`, `controller.platform9.localnet`,
   `main.go`, `deployment.apps`. The last component must start with a letter,
   so plain IPv4 addresses don't match here (there's already a builtin/custom
   IP pattern for those).
3. **IPv4 with port/CIDR** — `10.10.11.217:6443`, `10.10.11.0/24`. Preferred
   over thumbs' built-in plain-IPv4 match because it captures the
   port/prefix too. Deliberately doesn't validate octet ranges.
4. **MAC addresses** — `aa:bb:cc:dd:ee:ff` form.
5. **`git status` current branch** — matches the branch name on a line like
   `On branch feature/retry-backoff`.

**Verify it works:**
1. Run something with an obvious match in the pane, e.g. `echo 192.168.1.5`.
2. Press `prefix Space`. You should see the pane dim/overlay with a short
   colored hint label next to `192.168.1.5`.
3. Type the hint label (lowercase to paste it directly). Confirm it landed
   at the cursor.

If instead you see nothing happen (or a pane flashes open and closes), the
compiled `thumbs` binary is missing — see Troubleshooting below.

## tmux-fingers — precise hint picker

Same idea as thumbs — highlight matches, type a hint to grab one — but with a
different (configurable) set of patterns, and selecting always inserts
directly at the cursor rather than choosing paste vs. buffer-only.

| Keys | Action |
|---|---|
| `prefix` `F` (capital f) | Start fingers — highlights matches in the current pane |
| *(while active)* type the hint | Insert that match at the cursor, exit fingers mode |
| `Esc` | Cancel without inserting |

`tmux.conf` configures it to insert-only and leave the system clipboard
alone (`@fingers-main-action ':paste:'`, `@fingers-use-system-clipboard 0`),
and disables the copied-to-clipboard notification.

### Match patterns

Custom patterns:
- **IP** — IPv4, optionally with `:port` or `/CIDR` suffix.
- **Path** — needs ≥5 chars, at least one letter, and at least one `/`, so
  `./foo`, `/etc/hosts`, `src/controller.go` match but `0/1`, `10/20`, `a/b`
  don't (the plugin's builtin path pattern is disabled in favor of this one).
- **Table cell** — the main generic "names" matcher: a lowercase
  identifier-like value (≥5 chars) with 2+ spaces or a tab on both sides.
  Works across Kubernetes, OpenStack, Docker, and `systemctl` output without
  understanding any specific tool's format.
- **Dotted** — plain dotted values like `api.company.internal`, `main.go`,
  `deployment.apps`. Final component must start with a letter, so numeric
  IPv4 addresses don't match here.
- **MAC address**.
- **git current branch** — same `On branch <name>` match as thumbs.

Enabled builtin patterns (`@fingers-enabled-builtin-patterns`): `uuid`,
`sha`, `url`, `hex`, `kubernetes-pod`, `git-status`, `git-status-branch`,
`diff`. Deliberately disabled builtins: `ip`/`path` (replaced by the custom
patterns above), `digit` (too noisy — hints every 4-digit number),
`kubernetes` (broad and unnecessary for this workflow).

**Verify it works:**
1. Run something with an obvious match, e.g. `echo 192.168.1.5:6443`.
2. Press `prefix F`. Matches in the pane get a short hint label.
3. Type the hint. It should insert directly at your cursor.

## extrakto — fuzzy-pick text from scrollback

Grabs words, lines, or full scrollback history (up to 500 lines, across all
panes in the current window per `@extrakto_grab_area "window 500"`) via an
fzf-style picker, then lets you insert, copy, or open the selection.

| Keys | Action |
|---|---|
| `prefix` `Tab` | Open the extrakto picker over the current window's history |
| *(inside picker)* type to filter | fzf-style fuzzy search |
| `Tab` *(inside picker)* | Insert selection at the cursor, exit picker |
| `Enter` *(inside picker)* | Copy selection to the tmux buffer, exit picker |
| `Ctrl-f` *(inside picker)* | Cycle filter mode: word → all → line (`@extrakto_filter_order`) |
| `Esc` | Cancel |

**Verify it works:**
1. Run `echo hello-world-test-123` in a pane.
2. Press `prefix Tab`. A popup should open showing recent pane output,
   starting in "word" filter mode.
3. Type `test-123`, confirm it's highlighted/filtered in the list, press
   `Tab` to insert it at the cursor (or `Enter` to copy it to the buffer,
   then `prefix ]` to paste and confirm).

## Previous-output field paste (`g` / `G`)

Custom bindings (no `prefix` needed) via
`~/.config/tmux/scripts/paste-prev-field`, for the common case of copying a
field from the line just above your current prompt — e.g. a resource name
from a `kubectl get pods` table — without invoking a picker at all.

| Keys | Action |
|---|---|
| `g` | Paste the first field of the nearest previous non-empty line |
| `G` | Paste the second field of the nearest previous non-empty line |

Example: after `k -n kplane get po` prints
`api-server-7d8c9f-x2abc   1/1   Running`, pressing `g` at the next prompt
pastes `api-server-7d8c9f-x2abc`.

## tmux-digit — fancy window-number glyphs

This plugin has no keybinding of its own — it rewrites `#I` (window index)
wherever it appears in `status-left`, `status-right`, `window-status-format`,
`window-status-current-format`, and `set-titles-string`, replacing the plain
digit with a distinct glyph. The default `circle` style uses Unicode circled
digits (⓪①②③④⑤⑥⑦⑧⑨…), whose inner numerals look small. This configuration
uses the filled Nerd Font `square_inv` glyphs instead, which occupy more of the
terminal cell and appear larger and heavier. The point is to make window
numbers easier to pick out at a glance in the status bar, so the existing tmux
window-switch bindings are faster to use correctly:

| Keys | Action |
|---|---|
| `prefix` `0`–`9` | Jump directly to that window number (default tmux binding, unaffected by this plugin — it only changes how the number is *displayed*) |
| `prefix` `n` | Next window |
| `prefix` `p` | Previous window |
| `prefix` `w` | Interactive window picker (also shows the glyph-rendered numbers) |

Change the glyph style with `@digit-style` (`circle`, `circle_inv`, `square`,
`square_inv`, `layer`, `layer_inv`, `number` — see
`~/.config/tmux/plugins/tmux-digit/digit.tmux` for the exact glyph sets).
`tmux.conf` explicitly selects `square_inv`.

## Optional / currently disabled plugins

These lines exist in `tmux.conf` but are commented out — not installed, no
active bindings:

- `tmux-resurrect` / `tmux-continuum` — session persistence across restarts.
- `tmux-yank` — skipped because native tmux/terminal clipboard support is
  considered sufficient already.

## Everything at once — quick smoke test

```
prefix I        # confirms TPM runs cleanly
echo 10.0.0.1 && echo test-string
prefix Space    # thumbs should highlight 10.0.0.1
<esc>
prefix F        # fingers should highlight 10.0.0.1 too, with its own hints
<esc>
prefix Tab      # extrakto popup should open over the same pane
<esc>
g               # pastes the first field of the line above the prompt
prefix c        # open a second window - status bar should show ①②  circled digits
```

If all five respond, plugins are fully working.

## Troubleshooting

- **`prefix Space` does nothing / flashes a pane and closes it:** the
  `tmux-thumbs` binary wasn't built. Check for it:
  ```
  ls ~/.config/tmux/plugins/tmux-thumbs/target/release/thumbs
  ```
  If missing, re-run `run_once_install-tpm.sh` from this repo (or
  `chezmoi apply`) — it downloads the right binary automatically, including
  on Apple Silicon (via Rosetta 2, since upstream ships no native arm64
  macOS build).
- **`prefix F` does nothing:** check for the compiled fingers binary:
  ```
  ls ~/.config/tmux/plugins/tmux-fingers/bin/tmux-fingers
  ```
  If missing, reinstall via `prefix I` or re-run `run_once_install-tpm.sh`.
- **Window numbers show as boxes/`?` instead of circled digits:** the
  `circle` style uses standard Unicode circled-digit characters, so this
  usually means the terminal font lacks that glyph range. Switching
  `@digit-style` to `square`/`layer`/`number` won't help — those need a Nerd
  Font. Either install a Nerd Font and set it as the terminal font, or leave
  `@digit-style` unset (defaults to `circle`, the most broadly-supported
  option).
- **A binding does nothing at all:** check what's actually bound —
  `tmux list-keys -T prefix | grep -i <key>` from inside a pane (drop into a
  shell, not through tmux, e.g. a second terminal not attached to tmux) shows
  the live prefix-table bindings.
- **After editing `tmux.conf`:** reload without restarting tmux via
  `prefix :` then `source-file ~/.config/tmux/tmux.conf`, or just
  `tmux kill-server` and reattach.
