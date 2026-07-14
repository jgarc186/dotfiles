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

**Never manually edit these generated files** — they are overwritten on next `matugen` run. Edit the templates in `matugen/templates/` instead.

## Architecture

### Configuration Structure

Each top-level directory maps to one tool:
- `hypr/` — Hyprland WM; entry point `hypr/hyprland.lua` (Hyprland 0.55+ Lua config, `hl.*` API), modular config split across `hypr/modules/*.lua` (binds, monitors, autostart, animations, input, workspaces, etc.). Legacy hyprlang `hyprland.conf`/`modules/*.conf` have been removed — fully migrated. `hyprlock.conf` and `hyprsunset.conf` are separate tools still on hyprlang, unaffected by this migration.
- `nvim/` — Neovim; entry point `init.lua`, plugins via Lazy.nvim, per-plugin configs in `lua/user/plugins/`
- `waybar/` — Status bar; layout in `config.jsonc`, styling in `style.css`
- `ags/` — TypeScript/TSX custom bar (in development, replacing waybar); entry `app.tsx`
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
- `matugen/config.toml` — Template mapping for color generation
- `arch_linux/pkglist.txt` — Pacman package list for system reproducibility
