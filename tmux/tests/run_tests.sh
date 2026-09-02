#!/usr/bin/env bash
#
# Regression tests for the tmux config's matugen theming.
#
# tmux is present locally (unlike Hyprland/Wayland), so the last section runs a
# real tmux server on a private socket with the repo's own config and asserts on
# the options it ends up with. The earlier sections are source-level, guarding
# the three ways this wiring has actually broken:
#
#   1. the template pinning one mode (`.dark.hex`), so a light-mode run writes
#      dark colours - the bug kitty and nvim shipped with;
#   2. the generated file being orphaned - no [templates.tmux] in
#      matugen/config.toml, nothing sourcing colors.conf - which is the state
#      tmux was in;
#   3. the template setting @thm_* names the catppuccin plugin doesn't read, so
#      the colours land in variables nothing consumes.
#
# Run: tmux/tests/run_tests.sh
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEMPLATE="$ROOT/matugen/templates/tmux-colors.conf"
GENERATED="$ROOT/tmux/colors.conf"
CONF="$ROOT/tmux/.tmux.conf"
MATUGEN_CONF="$ROOT/matugen/config.toml"
THEME="$ROOT/tmux/plugins/catppuccin/tmux/themes/catppuccin_mocha_tmux.conf"

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

check() { # name, condition-output (empty = pass), detail
    if [[ -z $2 ]]; then
        pass "$1"
    else
        fail "$1" "$2"
    fi
}

# --- 1. Template is mode-agnostic ------------------------------------------
# `default` is whatever --mode the run used; a hardcoded mode renders the wrong
# palette into half the desktop's files.
bad_mode="$(grep -n '\.\(dark\|light\)\.hex' "$TEMPLATE" || true)"
check "template uses .default.hex only" "$bad_mode"

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
    grep -q "post_hook" <<<"$tmux_block" || detail="no post_hook - a running tmux server would keep the old colours"
    check "  post_hook reloads the server" "$detail"
fi

# --- 3. Sourced before the catppuccin plugin run ---------------------------
# catppuccin sets its palette with `set -ogq` (only if unset) and bakes some
# module colours at load time with -ogqF, so the matugen values have to already
# be in place when it runs. Sourcing afterwards leaves the baked ones wrong.
src_line="$(grep -n 'colors\.conf' "$CONF" | head -1 | cut -d: -f1)"
run_line="$(grep -n 'catppuccin\.tmux' "$CONF" | head -1 | cut -d: -f1)"

if [[ -z $src_line ]]; then
    fail ".tmux.conf sources colors.conf" "colors.conf is never sourced - the generated palette is dead weight"
elif [[ -z $run_line ]]; then
    fail ".tmux.conf sources colors.conf" "no catppuccin.tmux run line found to order against"
elif ((src_line < run_line)); then
    pass ".tmux.conf sources colors.conf before the catppuccin run"
else
    fail ".tmux.conf sources colors.conf before the catppuccin run" \
        "sourced at line $src_line, catppuccin runs at line $run_line - the -ogqF module colours are already baked by then"
fi

# --- 4. Every palette name catppuccin reads is set -------------------------
# The template shipped setting @thm_primary / @thm_surface_low / @thm_bar_bg,
# none of which this plugin reads: the colours went into variables nothing
# consumed, leaving the bar on catppuccin mocha.
# Both sides are read from `set` lines only: these files discuss @thm_* names
# in their comments, and matching those would let a name pass on a mention.
template_sets() { grep '^set ' "$TEMPLATE" | grep -o '@thm_[a-z0-9_]*' | sort -u; }
plugin_sets() { grep '^set ' "$THEME" | grep -o '@thm_[a-z0-9_]*' | sort -u; }

if [[ -r $THEME ]]; then
    missing="$(comm -23 <(plugin_sets) <(template_sets) | tr '\n' ' ')"
    check "template sets every @thm_* the plugin defines" \
        "${missing:+not set by the template: $missing}"

    unused="$(comm -13 <(plugin_sets) <(template_sets) | tr '\n' ' ')"
    check "template sets no @thm_* the plugin ignores" \
        "${unused:+set but never read: $unused}"
else
    printf 'SKIP  @thm_* coverage (catppuccin submodule not checked out)\n'
fi

# The status line is deliberately transparent, so the terminal (also
# matugen-themed) shows through. A style statement in the generated file would
# fight that - and window-active-style in particular would make panes opaque.
bad_styles="$(grep -vn '^[[:space:]]*#' "$TEMPLATE" | grep 'window-active-style\|status-bg' || true)"
check "template sets palette variables only, no styles" "$bad_styles"

# --- 5. Accents stay legible on the bar ------------------------------------
# matugen's base16 base08-base0F are identical in light and dark mode (only
# base00-base07 invert), so accents taken from them render near-white on a
# light palette. Anything catppuccin draws as text has to clear the WCAG 3:1
# floor against the surface it sits on.
contrast() { # #rrggbb #rrggbb -> ratio, 2dp
    python3 - "$1" "$2" <<'PYEOF'
import sys

def lum(h):
    h = h.lstrip('#')
    c = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    c = [x / 12.92 if x <= 0.03928 else ((x + 0.055) / 1.055) ** 2.4 for x in c]
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]

a, b = sorted((lum(sys.argv[1]), lum(sys.argv[2])), reverse=True)
print(f'{(a + 0.05) / (b + 0.05):.2f}')
PYEOF
}

value_of() { sed -n "s/^set -gq[[:space:]]*$1[[:space:]]*\"\(#[0-9a-fA-F]*\)\".*/\1/p" "$GENERATED"; }

if ! command -v python3 >/dev/null; then
    printf 'SKIP  accent contrast (python3 not installed)\n'
else
    bg="$(value_of @thm_bg)"
    illegible=""
    for var in @thm_red @thm_green @thm_yellow @thm_blue @thm_mauve @thm_teal \
        @thm_sapphire @thm_lavender @thm_peach @thm_maroon @thm_fg @thm_subtext_0; do
        colour="$(value_of "$var")"
        [[ -z $colour ]] && { illegible+="$var(unset) "; continue; }
        ratio="$(contrast "$colour" "$bg")"
        awk -v r="$ratio" 'BEGIN { exit !(r < 3.0) }' && illegible+="$var($colour, ${ratio}:1) "
    done
    check "accents clear 3:1 against @thm_bg ($bg)" "${illegible:+illegible: $illegible}"
fi

# --- 6. Real tmux server ---------------------------------------------------
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

        # Value from the generated file, so this follows the current wallpaper
        # and mode rather than asserting a hardcoded colour.
        want_bg="$(sed -n 's/^set -gq[[:space:]]*@thm_bg[[:space:]]*"\(#[0-9a-fA-F]*\)".*/\1/p' "$GENERATED")"
        got_bg="$(get @thm_bg)"

        if [[ -z $want_bg ]]; then
            fail "@thm_bg comes from matugen" "no @thm_bg line in $GENERATED"
        elif [[ ${got_bg,,} == "${want_bg,,}" ]]; then
            pass "@thm_bg comes from matugen ($got_bg)"
        else
            fail "@thm_bg comes from matugen" "server has $got_bg, matugen wrote $want_bg (catppuccin won the -ogq race)"
        fi

        # A module colour baked with -ogqF at plugin load: the check that the
        # source ordering actually took effect, not just that it looks right.
        uptime_colour="$(get @catppuccin_uptime_color)"
        want_sapphire="$(sed -n 's/^set -gq[[:space:]]*@thm_sapphire[[:space:]]*"\(#[0-9a-fA-F]*\)".*/\1/p' "$GENERATED")"

        if [[ -z $want_sapphire ]]; then
            fail "baked module colours use the matugen palette" "no @thm_sapphire line in $GENERATED"
        elif [[ ${uptime_colour,,} == "${want_sapphire,,}" ]]; then
            pass "baked module colours use the matugen palette"
        else
            fail "baked module colours use the matugen palette" \
                "@catppuccin_uptime_color is $uptime_colour, expected $want_sapphire"
        fi

        # The reload path, which is where this last broke: @thm_* updated on a
        # re-source but the module colours catppuccin baked with -ogq at the
        # previous load survived, so the bar kept the old palette. Plant a
        # stale value and check a reload actually clears it.
        tmux -L "$SOCKET" set -g @catppuccin_uptime_color "#123456"
        tmux -L "$SOCKET" source-file "$CONF"
        reloaded="$(get @catppuccin_uptime_color)"

        if [[ ${reloaded,,} == "${want_sapphire,,}" ]]; then
            pass "re-sourcing the config re-themes baked module colours"
        else
            fail "re-sourcing the config re-themes baked module colours" \
                "@catppuccin_uptime_color is $reloaded after a reload, expected $want_sapphire"
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
