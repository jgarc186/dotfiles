#!/usr/bin/env bash
#
# Static analysis for the Quickshell config.
#
# There's no way to run this shell headless (it needs a Wayland compositor and a
# live Hyprland), so instead of asserting on behaviour we type-check every file
# with qmllint. That catches the regressions that actually happen when editing
# QML: typo'd property names, a component that no longer exists, a bad enum, a
# singleton that isn't registered.
#
# qmllint can't resolve `import qs.foo` on its own, because Quickshell
# synthesises that module at runtime. So we mirror the tree into a temp dir and
# generate the qmldir files Quickshell would have generated, marking every file
# with `pragma Singleton` as a singleton.
#
# Run: quickshell/tests/run_tests.sh
#
set -uo pipefail

QMLLINT="${QMLLINT:-/usr/lib/qt6/bin/qmllint}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -x "$QMLLINT" ]]; then
    echo "qmllint not found at $QMLLINT (set QMLLINT=/path/to/qmllint)" >&2
    exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Mirror the config as the `qs` module, skipping this test dir
mkdir -p "$TMP/qs"
(cd "$ROOT" && tar -cf - --exclude=tests .) | (cd "$TMP/qs" && tar -xf -)

# One qmldir per directory, so `import qs.services` etc. resolve
python3 - "$TMP" <<'PY'
import os
import sys

root = sys.argv[1]
qs = os.path.join(root, "qs")

for dirpath, _, filenames in os.walk(qs):
    qml = sorted(f for f in filenames if f.endswith(".qml"))
    if not qml:
        continue

    rel = os.path.relpath(dirpath, root).replace(os.sep, ".")
    lines = [f"module {rel}"]

    for name in qml:
        with open(os.path.join(dirpath, name)) as f:
            singleton = "pragma Singleton" in f.read()
        type_name = name[:-4]
        prefix = "singleton " if singleton else ""
        lines.append(f"{prefix}{type_name} 1.0 {name}")

    with open(os.path.join(dirpath, "qmldir"), "w") as f:
        f.write("\n".join(lines) + "\n")
PY

failed=0
checked=0

while IFS= read -r file; do
    rel="${file#"$ROOT"/}"
    [[ "$rel" == tests/* ]] && continue

    checked=$((checked + 1))
    # Scheme.qml is matugen output; the shell's own files are what we own
    out="$("$QMLLINT" -I "$TMP" "$TMP/qs/$rel" 2>&1)"

    if [[ -n "$out" ]]; then
        echo "FAIL $rel"
        echo "$out" | sed 's/^/    /'
        failed=$((failed + 1))
    fi
done < <(find "$ROOT" -name '*.qml' | sort)

echo
if (( failed > 0 )); then
    echo "$failed/$checked file(s) failed qmllint"
    exit 1
fi

echo "$checked file(s) OK"
