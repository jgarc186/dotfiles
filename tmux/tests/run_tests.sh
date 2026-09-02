#!/usr/bin/env bash
#
# Regression tests for the tmux config's theming.
#
# tmux follows the desktop's light/dark mode with a catppuccin flavour - latte
# or mocha - the same way nvim does. matugen writes only the mode into
# tmux/colors.conf; .tmux.conf turns that into @catppuccin_flavor, and the
# plugin supplies every colour.
#
# tmux is present locally (unlike Hyprland/Wayland), so the last section runs a
# real server on a private socket with the repo's own config and asserts on the
# options it ends up with. The earlier sections are source-level, guarding the
# ways this wiring has actually broken:
#
#   1. the generated file being orphaned - no [templates.tmux] in
#      matugen/config.toml, nothing sourcing colors.conf - which is the state
#      tmux was in;
#   2. the mode being read after catppuccin has already loaded, leaving the
#      flavour a mode behind;
#   3. a reload leaving the previous flavour's baked module colours in place,
#      which makes a live re-theme look half-applied.
#
# Run: tmux/tests/run_tests.sh
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEMPLATE="$ROOT/matugen/templates/tmux-colors.conf"
GENERATED="$ROOT/tmux/colors.conf"
CONF="$ROOT/tmux/.tmux.conf"
MATUGEN_CONF="$ROOT/matugen/config.toml"
THEMES="$ROOT/tmux/plugins/catppuccin/tmux/themes"

passed=0
failed=0

pass() {
    passed=$((passed + 1))
    printf 'PASS  %s\n' "$1"
}

fail() {
    failed=$((failed + 1))
    printf 'FAIL  %s\n' "$1"
    [[ $# -gt 1 ]] && printf '      %s\n' "$2"
}

check() { # name, detail (empty = pass)
    if [[ -z $2 ]]; then
        pass "$1"
    else
        fail "$1" "$2"
    fi
}

# --- 1. The template carries the mode, and only the mode -------------------
# It used to render a whole @thm_* palette from the wallpaper. Those names are
# catppuccin's own, so any left behind would fight the flavour rather than be
# ignored.
detail=""
grep -q '{{mode}}' "$TEMPLATE" || detail="template never renders {{mode}}"
check "template renders the matugen mode" "$detail"

detail=""
grep -q '^set -gq @theme_mode' "$TEMPLATE" || detail="template does not set @theme_mode"
check "template sets @theme_mode" "$detail"

leftovers="$(grep -v '^[[:space:]]*#' "$TEMPLATE" | grep -o '@thm_[a-z0-9_]*' | sort -u | tr '\n' ' ')"
check "template sets no @thm_* of its own" \
    "${leftovers:+would override the flavour: $leftovers}"

# matugen's engine has no conditionals - `{% if %}` renders verbatim - so a
# flavour name here would be a literal, not a choice.
strays="$(grep -v '^[[:space:]]*#' "$TEMPLATE" | grep -n 'latte\|mocha\|{%' || true)"
check "template leaves the flavour choice to tmux" "$strays"

# --- 2. The generated file is actually wired up ----------------------------
tmux_block="$(sed -n '/^\[templates\.tmux\]/,/^\[/p' "$MATUGEN_CONF")"

if [[ -z $tmux_block ]]; then
    fail "matugen/config.toml has a [templates.tmux] entry" \
        "no [templates.tmux] section - colors.conf would never be regenerated"
else
    pass "matugen/config.toml has a [templates.tmux] entry"

    detail=""
    grep -q "templates/tmux-colors.conf" <<<"$tmux_block" || detail="input_path does not point at templates/tmux-colors.conf"
    check "  input_path" "$detail"

    detail=""
    grep -q "tmux/colors.conf" <<<"$tmux_block" || detail="output_path does not point at tmux/colors.conf"
    check "  output_path" "$detail"

    # tmux has no reload signal; the server has to be told to re-read the config.
    detail=""
    grep -q "post_hook" <<<"$tmux_block" || detail="no post_hook - a running tmux server would keep the old flavour"
    check "  post_hook reloads the server" "$detail"
fi

# --- 3. Mode read, then mapped, then the plugin runs -----------------------
# catppuccin reads @catppuccin_flavor at load time, so both steps have to
# happen before the run line or the flavour is a mode behind.
src_line="$(grep -n 'colors\.conf' "$CONF" | head -1 | cut -d: -f1)"
map_line="$(grep -n '@theme_mode' "$CONF" | grep -v 'colors\.conf' | head -1 | cut -d: -f1)"
run_line="$(grep -n 'catppuccin\.tmux' "$CONF" | head -1 | cut -d: -f1)"

if [[ -z $src_line || -z $map_line || -z $run_line ]]; then
    fail ".tmux.conf sources the mode, maps it, then runs catppuccin" \
        "missing step (source=$src_line map=$map_line run=$run_line)"
elif ((src_line < map_line && map_line < run_line)); then
    pass ".tmux.conf sources the mode, maps it, then runs catppuccin"
else
    fail ".tmux.conf sources the mode, maps it, then runs catppuccin" \
        "out of order: source=$src_line map=$map_line run=$run_line"
fi

# Both arms have to exist: the live checks below only exercise whichever mode
# the desktop happens to be in right now.
detail=""
grep -q 'latte' "$CONF" || detail+="no latte mapping "
grep -q 'mocha' "$CONF" || detail+="no mocha mapping "
check "both flavours are mapped" "$detail"

# --- 4. Real tmux server ---------------------------------------------------
if ! command -v tmux >/dev/null; then
    printf 'SKIP  live server checks (tmux not installed)\n'
elif [[ ! -r $GENERATED ]]; then
    fail "live server checks" "$GENERATED missing - has matugen run since the template changed?"
else
    SOCKET="matugen-tmux-tests-$$"
    cleanup() { tmux -L "$SOCKET" kill-server 2>/dev/null || true; }
    trap cleanup EXIT

    if ! tmux -L "$SOCKET" -f "$CONF" new-session -d -s test 2>/tmp/tmux-test-err; then
        fail "config loads in a real tmux server" "$(head -3 /tmp/tmux-test-err)"
    else
        pass "config loads in a real tmux server"

        get() { tmux -L "$SOCKET" show -gv "$1" 2>/dev/null; }

        mode="$(sed -n 's/^set -gq @theme_mode "\(.*\)".*/\1/p' "$GENERATED")"
        [[ $mode == light ]] && want_flavour="latte" || want_flavour="mocha"
        got_flavour="$(get @catppuccin_flavor)"

        if [[ $got_flavour == "$want_flavour" ]]; then
            pass "flavour follows the mode ($mode -> $got_flavour)"
        else
            fail "flavour follows the mode" \
                "matugen wrote mode=$mode, expected $want_flavour, server has $got_flavour"
        fi

        # The flavour has to have been applied, not merely requested: compare a
        # palette value against that flavour's own theme file.
        theme_file="$THEMES/catppuccin_${want_flavour}_tmux.conf"
        if [[ -r $theme_file ]]; then
            want_sapphire="$(sed -n 's/^set -ogq @thm_sapphire "\(#[0-9a-fA-F]*\)".*/\1/p' "$theme_file")"
            got_sapphire="$(get @thm_sapphire)"

            if [[ ${got_sapphire,,} == "${want_sapphire,,}" ]]; then
                pass "palette comes from the $want_flavour theme ($got_sapphire)"
            else
                fail "palette comes from the $want_flavour theme" \
                    "@thm_sapphire is $got_sapphire, $want_flavour defines $want_sapphire"
            fi

            # The reload path, which is where this last broke: catppuccin sets
            # its options with `set -ogq` (only if unset) and bakes module
            # colours at load, so on a re-source the previous flavour's values
            # survive and win. Plant stale values; a reload has to clear them.
            tmux -L "$SOCKET" set -g @catppuccin_uptime_color "#123456"
            tmux -L "$SOCKET" set -g @thm_sapphire "#123456"
            tmux -L "$SOCKET" source-file "$CONF"

            detail=""
            [[ "$(get @thm_sapphire)" == "$want_sapphire" ]] || detail+="@thm_sapphire stayed $(get @thm_sapphire) "
            [[ "$(get @catppuccin_uptime_color)" == "$want_sapphire" ]] || detail+="@catppuccin_uptime_color stayed $(get @catppuccin_uptime_color) "
            check "re-sourcing re-themes the palette and baked module colours" "$detail"
        else
            printf 'SKIP  palette checks (%s not readable)\n' "$theme_file"
        fi

        status_style="$(get status-style)"
        case "$status_style" in
        *bg=default*) pass "status line stays transparent" ;;
        *) fail "status line stays transparent" "status-style is '$status_style'" ;;
        esac
    fi

    cleanup
    trap - EXIT
fi

printf '\n%d passed, %d failed\n' "$passed" "$failed"
[[ $failed -eq 0 ]]
