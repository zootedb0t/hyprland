#!/usr/bin/env sh

# Control wallpaper and theme
# Dependencies: matugen, fd.

set -eu

# Default base directory for wallpapers (can be overridden via env)
: "${BASE_WAL_DIR:=/home/stoney/Pictures/walls}"

SCHEME="scheme-tonal-spot" # fixed scheme
MODE="dark"                # default mode

usage() {
	echo "Usage: $0 [-m dark|light] [-s scheme-name] [wallpaper]"
	echo
	echo "Options:"
	echo "  -m, --mode     dark | light"
	echo "  -s, --scheme   matugen scheme (e.g. scheme-tonal-spot)"
	echo "  -h, --help     show help"
	exit 0
}

die() {
	printf "%s\n" "$1" >&2
	exit 1
}

WALL=""

# while [ $# -gt 0 ]; do
# 	case "$1" in
# 	-m | --mode)
# 		shift
# 		[ $# -gt 0 ] || die "--mode requires an argument"
# 		MODE="$1"
# 		;;
# 	-h | --help)
# 		usage
# 		;;
# 	-*)
# 		die "Unknown option: $1"
# 		;;
# 	*)
# 		WALL="$1"
# 		;;
# 	esac
# 	shift
# done

while [ $# -gt 0 ]; do
	case "$1" in
	-m | --mode)
		MODE="${2:-}"
		[ "$MODE" = "dark" ] || [ "$MODE" = "light" ] || die "Mode must be dark or light"
		shift
		;;
	-s | --scheme)
		SCHEME="${2:-}"
		[ -n "$SCHEME" ] || die "Scheme name required"
		shift
		;;
	-h | --help)
		usage
		;;
	-*)
		die "Unknown option: $1"
		;;
	*)
		WALL="$1"
		;;
	esac
	shift
done

# Validate mode
case "$MODE" in
dark | light) ;;
*) die "Invalid mode: $MODE" ;;
esac

# Set WAL_DIR based on validated MODE. Allows BASE_WAL_DIR override from env.
WAL_DIR="$BASE_WAL_DIR/$MODE"

# Pick a random file from $WAL_DIR
pick_random_wall() {
	if command -v fd >/dev/null 2>&1 && command -v shuf >/dev/null 2>&1; then
		fd . "$WAL_DIR" -e jpg -e jpeg -e png -e gif --type f 2>/dev/null | shuf -n1 || true
		return
	fi

	if command -v find >/dev/null 2>&1 && command -v shuf >/dev/null 2>&1; then
		find "$WAL_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' \) -print 2>/dev/null | shuf -n1 2>/dev/null || true
		return
	fi

	# Nothing available
	return 1
}

# Pick random wallpaper if none provided
if [ -z "$WALL" ]; then
	[ -d "$WAL_DIR" ] || die "Directory not found: $WAL_DIR"
	WALL="$(pick_random_wall || true)"
	[ -n "$WALL" ] || die "No wallpapers found in: $WAL_DIR"
fi

# Final sanity: ensure file exists and is readable
[ -r "$WALL" ] || die "Wallpaper not found or not readable: $WALL"

printf "Mode: %s\n" "$MODE"
printf "Wallpaper: %s\n" "$(basename "$WALL")"

# Ensure matugen exists
command -v matugen >/dev/null 2>&1 || die "matugen not found in PATH"

# Generate theme (will exit non-zero if matugen fails)
matugen -t "$SCHEME" -m "$MODE" image "$WALL"

# Set GNOME color-scheme if possible (non-fatal)
if command -v gsettings >/dev/null 2>&1; then
	case "$MODE" in
	dark)
		if gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null; then
			printf "gsettings: set color-scheme to prefer-dark\n"
		else
			printf "gsettings present but couldn't set prefer-dark\n"
		fi
		;;
	light)
		if gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null; then
			printf "gsettings: set color-scheme to prefer-light\n"
		else
			printf "gsettings present but couldn't set prefer-light\n"
		fi
		;;
	esac
else
	printf "gsettings not available — skipping GNOME color-scheme change\n"
fi
