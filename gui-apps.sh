#!/usr/bin/env bash
# List installed GUI apps (those shipping a .desktop launcher).
# By default shows only apps from packages YOU installed (apt-mark showmanual).
#   gui-apps.sh          -> your installed GUI apps
#   gui-apps.sh -a       -> all GUI apps, including OS defaults
#   gui-apps.sh <term>   -> filter by name/command/package

usage() {
    cat <<'EOF'
Usage: gui-apps.sh [-a|--all] [-h|--help] [FILTER]

List installed GUI applications that ship a .desktop launcher.

  (no options)  apps from packages installed manually (apt-mark showmanual)
  -a, --all     every GUI app, including OS defaults
  -h, --help    show this help
  FILTER        only lines matching FILTER (name, command, or package)

Examples:
  gui-apps.sh
  gui-apps.sh -a
  gui-apps.sh firefox
EOF
}

show_all=0
case "${1:-}" in
    -h|--help) usage; exit 0 ;;
    -a|--all) show_all=1; shift ;;
    -*) printf 'Unknown option: %s\n\n' "$1" >&2; usage >&2; exit 2 ;;
esac
filter=${1:-}

manual=
if [ "$show_all" -eq 0 ]; then
    if ! command -v apt-mark >/dev/null 2>&1; then
        echo "Error: apt-mark is required to list manually installed packages." >&2
        echo "Use -a to list all GUI apps instead." >&2
        exit 1
    fi
    manual=$(apt-mark showmanual 2>/dev/null)
fi

for d in /usr/share/applications /usr/local/share/applications \
         "$HOME/.local/share/applications" \
         /var/lib/flatpak/exports/share/applications \
         "$HOME/.local/share/flatpak/exports/share/applications" \
         /var/lib/snapd/desktop/applications; do
  [ -d "$d" ] || continue
  for f in "$d"/*.desktop; do
    [ -f "$f" ] || continue
    grep -qm1 '^NoDisplay=true' "$f" && continue
    grep -qm1 '^Hidden=true' "$f" && continue
    name=$(grep -m1 '^Name=' "$f" | cut -d= -f2-)
    exec=$(grep -m1 '^Exec=' "$f" | cut -d= -f2- | sed 's/ *%[fFuUdDnNickvm]//g')
    pkg=$(dpkg -S "$f" 2>/dev/null | cut -d: -f1)
    [ -z "$pkg" ] && pkg="(local)"
    if [ "$show_all" -eq 0 ] && ! printf '%s\n' "$manual" | grep -qx "$pkg"; then
      continue
    fi
    line=$(printf '%-30s | %-34s | %s' "$name" "$exec" "$pkg")
    case "$line" in *"$filter"*) printf '%s\n' "$line";; esac
  done
done | sort -u
