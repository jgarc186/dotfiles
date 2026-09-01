# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles for a Hyprland-based Arch Linux desktop environment. All configs are symlinked from this repo into `~/.config/` via the `install` script.

## Setup

```bash
./install    # symlinks all configs to their proper locations
```

The install script removes existing configs and creates symlinks. Re-run it after adding new config directories.

## Color Theming (Matugen)

The central theming system is **Matugen** (Material Design 3 color generator). Running it regenerates color files across all apps:

```bash
matugen image <path-to-wallpaper>
```

This reads `matugen/config.toml` and writes generated color files to:
- `hypr/colors.conf` — Hyprland colors
- `waybar/colors.css` — Waybar colors (sends `SIGUSR2` to reload live)
- `rofi/colors.rasi` — Rofi colors
- `ghostty/themes/Matugen` — Ghostty theme (sends `SIGUSR2` to reload live)
- `kitty/themes/Matugen.conf` — Kitty theme (reloads via kitten)
- `nvim/colors/matugen.vim` — Neovim colorscheme
- `quickshell/services/Scheme.qml` — Quickshell M3 palette (Quickshell hot-reloads on file change)

**Never manually edit these generated files** — they are overwritten on next `matugen` run. Edit the templates in `matugen/templates/` instead.

## Architecture

### Configuration Structure

Each top-level directory maps to one tool:
- `hypr/` — Hyprland WM; entry point `hypr/hyprland.lua` (Hyprland 0.55+ Lua config, `hl.*` API), modular config split across `hypr/modules/*.lua` (binds, monitors, autostart, animations, input, workspaces, etc.). Legacy hyprlang `hyprland.conf`/`modules/*.conf` have been removed — fully migrated. `hyprlock.conf` and `hyprsunset.conf` are separate tools still on hyprlang, unaffected by this migration.
- `nvim/` — Neovim; entry point `init.lua`, plugins via Lazy.nvim, per-plugin configs in `lua/user/plugins/`
- `waybar/` — Status bar; layout in `config.jsonc`, styling in `style.css`
- `ags/` — TypeScript/TSX custom bar (superseded by `quickshell/`); entry `app.tsx`
- `quickshell/` — Quickshell (QML) shell in the style of [caelestia-dots/shell](https://github.com/caelestia-dots/shell); entry `shell.qml`
- `rofi/` — App launcher; extensive theme collection in `launchers/` and `colors/`
- `ghostty/` + `kitty/` — Terminal emulators with custom cursor shaders in `ghostty/shaders/`
- `tmux/` — Terminal multiplexer; plugins via TPM (git submodules in `tmux/plugins/`)
- `matugen/` — Theme generator config and templates
- `scripts/` — `t`: fzf-based tmux session switcher (symlinked to `~/.local/bin/t`); `roadmap-to-jira`: reads `ROAD_MAP.md` in a git repo, uses Claude Opus to generate tickets, and pushes an Epic + Stories to Jira (requires `atlassian-python-api` and `PyYAML`; needs env vars `JIRA_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN`, `JIRA_PROJECT_KEY`)
- `zshrc/zshrc.conf` — Shell config (Oh-My-Zsh, aliases for git/dotnet/laravel)
- `starship/starship.toml` — Shell prompt (Catppuccin Mocha palette)

### Neovim Plugin Management

Plugins are declared in `nvim/lua/user/plugins.lua` and managed by Lazy.nvim. Individual plugin configurations live in `nvim/lua/user/plugins/`. Lock file: `nvim/lazy-lock.json`.

### Neovim Config Tests

`nvim/tests/` is a regression harness for the config. Unlike `hypr/tests` (which must mock the `hl` global — there's no local Wayland), Neovim IS present, so these load the real config modules inside a real headless Neovim and assert on actual `vim` state. Everything is network-free.

- Run: `nvim --headless -u NONE -i NONE -l nvim/tests/run_tests.lua`
- `nvim/tests/support/` — `assert_util.lua` (assertions) + `harness.lua` (paths, module loading, lazy-spec capture).
- `nvim/tests/test_*.lua` — one concern each, in tiers:
  - **Real state:** `test_options`, `test_keymaps`, `test_init` — `dofile` the module, assert resulting `vim.o` / keymaps / autocmds.
  - **Spec validation:** `test_plugins_spec` — mocks `require('lazy')` to capture the spec (no plugin install), checks for duplicate repos, valid `owner/repo` ids, and that every `require('user/plugins/X')` target file exists.
  - **Source checks:** `test_highlights` — greps `plugins.lua`/config source for highlight-group correctness (e.g. a group DEFINED under a misspelled name silently fails to match the name other configs `highlight link` against). Used when the code can't run headless (catppuccin's config only runs once the plugin loads).
  - **Compile check:** `test_compile` — `loadfile`s every config `.lua` (incl. per-plugin config files whose plugins aren't installed in the headless env), catching syntax regressions without executing anything.

When editing an `nvim/lua/**` file: update its test first (red), then the config (green). Per-plugin config files (`lua/user/plugins/*.lua`) require their plugins at runtime, so they're only compile-checked, not executed. A passing suite doesn't replace opening real Neovim — it guarantees the config is structurally correct and the owned options/keymaps/spec are intact.

### Quickshell Shell (QML)

`quickshell/` is a Material 3 shell for Hyprland modelled on
[caelestia-dots/shell](https://github.com/caelestia-dots/shell). It is a
from-scratch implementation, not a copy: upstream needs `quickshell-git` plus a
C++ plugin (`Caelestia.Config`, `Caelestia.Blobs`, `M3Shapes`), while this runs
on the stock Arch `quickshell` package with no compiled dependencies.

Run it with `qs -p ~/developer/dotfiles/quickshell` (or `qs` once installed, since
the install script symlinks it to `~/.config/quickshell`). It is **not** in
`hypr/modules/autostart.lua` — waybar still is, and running both gives you two
bars. Swap the autostart entry when you're ready to switch.

Layout: a left vertical bar sitting inside a rounded frame drawn around the whole
screen — OS icon, workspaces, spacer, tray, status icons, vertical clock, power.

Structure:
- `config/Appearance.qml` — M3 design tokens (rounding/spacing/padding 4→48, font
  sizes, motion durations and bezier curves). Values match upstream's, so the
  visual rhythm matches. **Inline components can't nest in QML**, so the token
  sub-groups are declared at document level and wired together by wrapper
  components.
- `config/Config.qml` — the knobs worth changing: border thickness/rounding, bar
  entry order, workspace count, per-workspace icons, clock format. Workspace
  indicators have three `displayType`s: `shapes` (morphing Material shapes),
  `text` (numbers), `icons` (a Material Symbols glyph per workspace, from the
  `icons` list, falling back to `defaultIcon`).
- `services/` — singletons wrapping system state: `Colours` (matugen palette plus
  M3 layer/transparency helpers), `Hypr`, `Time`, `Audio` (Pipewire), `Batt`
  (UPower), `Bt`, `Net` (nmcli, driven by `nmcli monitor` rather than polling;
  also scans, connects and disconnects for the Wi-Fi popout), `SysInfo`,
  `ShellState`. `services/Scheme.qml` is matugen output — never edit it.
- `components/` — `StyledRect`/`StyledText`/`MaterialIcon`/`StateLayer` (M3 hover
  + press ripple), `Anim`/`CAnim` (the motion tokens as animation presets),
  `Tooltip`, and `MaterialShape`.
- `modules/` — `border/` (the frame and its exclusion zones), `bar/`, `session/`,
  `network/` (the Wi-Fi popout).

Popouts and tooltips are owned by `modules/ShellWindow.qml`, not by the bar
widget that triggers them: `BarWrapper` sets `clip: true`, so anything a bar
widget drew beside itself would be cut off at the bar's edge. A widget flips a
flag on `ShellState` (`session`, `network` — mutually exclusive) or calls
`ShellState.showTooltip(owner, text, y)` with its own centre in window
coordinates, and `ShellWindow` renders it, adds it to the input `mask`, and
turns on layershell keyboard focus when a popout needs typing.

`components/MaterialShape.qml` replaces upstream's `M3Shapes` C++ plugin: each
shape is a polar radius function sampled at fixed angles, so morphing between two
shapes is elementwise interpolation of the samples. Polygons get rounded corners
from a moving average over the radii. The focused workspace picks a random shape
each time focus lands on it, which is where most of the "expressive" feel lives.

**Gotchas found by running it (the linter can't catch these):**
- `implicitWidth`/`implicitHeight` are read-only on `Text`, so `MaterialIcon` is
  an `Item` wrapping a `StyledText` rather than a `Text` subclass. That's also
  what keeps the bar layout intact when Material Symbols isn't installed and
  glyph *names* render as words.
- Reading `width`/`height` inside a `Shape`'s path binding is a binding loop —
  `Shape` feeds its content bounds back into its implicit size. Derive from an
  explicit size property instead.
- JS `%` keeps the sign of the dividend, which silently collapses every
  odd-sided `MaterialShape` polygon to a sliver. Use a positive modulo.

### Quickshell Config Tests

`quickshell/tests/run_tests.sh` type-checks every QML file with `qmllint`. The
shell can't run headless (it needs a live Wayland compositor and Hyprland), so
unlike `nvim/tests` this asserts nothing about behaviour — it catches the
regressions that actually happen when editing QML: typo'd property names, a
component that no longer exists, a bad enum, an unregistered singleton.

`qmllint` can't resolve `import qs.foo` on its own, because Quickshell
synthesises that module at runtime, so the harness mirrors the tree into a temp
dir and generates the `qmldir` files Quickshell would have generated (marking
every `pragma Singleton` file as a singleton).

- Run: `quickshell/tests/run_tests.sh`
- Requires `qmllint` (ships with `qt6-declarative`, at
  `/usr/lib/qt6/bin/qmllint`; override with `QMLLINT=`).
- The suite must stay at zero warnings. Where a warning is a false positive
  (`PanelWindow` reported as uncreatable, Quickshell's Bluetooth types not being
  declaratively exposed, `Process.onExited` handlers being uncompilable because
  the signal's `exitStatus` is an unregistered `QProcess::ExitStatus`), suppress
  it narrowly with a `// qmllint disable <check>` comment and a note on why.
  Start that note with anything but the word "qmllint" — a comment whose first
  word is `qmllint` is parsed as a directive, and every word in it is then
  reported as an unknown lint category.

Fonts: the shell wants `ttf-material-symbols-variable-git` (icons — without it
every icon renders as its literal name) and `ttf-rubik-vf` (text). Both are in
`arch_linux/pkglist.txt`. `CaskaydiaCove NF` covers the mono font.

### AGS Bar (TypeScript)

The `ags/` directory is a TypeScript project with `node_modules/` and GObject Introspection type definitions in `ags/@girs/`. It uses TSX components and targets GTK4 via the AGS framework.

### Tmux Plugins

TPM and Catppuccin are git submodules under `tmux/plugins/`. To install plugins: `<prefix>I` inside tmux.

### Hyprland Lua Config + Tests

`hypr/hyprland.lua` is a sequence of `require("modules.xxx")` calls. The hyprlang `.conf` originals are gone (migration complete); `hypr/modules/*.lua` is now the source of truth.

`hypr/tests/` is a TDD harness for this config, since there's no local Hyprland/Wayland to run it against:
- `hypr/tests/support/mock_hl.lua` — fake `hl` global that records every call a module makes.
- `hypr/tests/test_<module>.lua` — one per module, asserts the exact calls it should make.
- Run: `luajit hypr/tests/run_tests.lua` (requires `luajit`, e.g. `brew install luajit`).

When editing a `hypr/modules/*.lua` file: update its `test_*.lua` first (red), then the module (green). A passing suite doesn't replace a real `hyprctl reload` check on the actual machine — it only guarantees the Lua is structurally correct.

**Gotchas found via live `hyprctl reload` (mock can't catch these):**
- `hl.bind` key combos: every modifier needs its own `+` — `"Ctrl SHIFT + 4"` fails (`Unknown keysym: "Ctrl SHIFT", did you forget a +?"`). Modifier names are also case-sensitive uppercase — `"Ctrl + SHIFT + 4"` still fails (`Unknown keysym: "Ctrl"`); it must be `"CTRL + SHIFT + 4"`.
- `hl.curve` bezier control point values cap at 2.00 — going over errors at load (`point ...: value X is more than the maximum of 2.00`) rather than clamping silently.

## Key Files

- `hypr/hyprland.lua` — Main Hyprland entry point (requires all `modules/*.lua`)
- `hypr/modules/binds.lua` — All Hyprland keybindings
- `hypr/modules/autostart.lua` — Programs launched on login
- `nvim/init.lua` — Neovim entry point (auto-format on save enabled)
- `nvim/lua/user/keymaps.lua` — Neovim keybindings
- `quickshell/shell.qml` — Quickshell entry point
- `quickshell/config/Appearance.qml` — M3 design tokens for the Quickshell shell
- `quickshell/config/Config.qml` — Quickshell shell settings
- `matugen/config.toml` — Template mapping for color generation
- `arch_linux/pkglist.txt` — Pacman package list for system reproducibility
