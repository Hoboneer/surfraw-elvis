#!/bin/sh
# This is a script to install elvi

ELVI_DIR=${ELVI_DIR:-$HOME/.config/surfraw/elvi}

usage ()
{
	cat <<EOF
Usage: $0 [--help] [-u] elvis...
Description:
  Install elvi to a specified directory (ELVI_DIR variable).
  The elvis should have a '.elvis' extension and be executable.
Options:
  -u                  Uninstall elvis
  --help, -help, -h   Show this help message
EOF
}

case "$1" in
	--help|-help|-h|'') usage ; exit ;;
esac

if [ "$1" = '-u' ]; then
	# Uninstall elvis.
	shift
	action_type=uninstall
else
	action_type=install
fi

for src in "$@"; do
	[ -z "$src" ] && exit 0

	dest="$ELVI_DIR/$(basename "${src%%.elvis}")"

	if [ "$action_type" = install ]; then
		# Non-executable elvi are useless.
		[ ! -x "$src" ] && { echo file is not executable ; exit 1 ; }
		# Don't want to clobber existing elvi.
		[ -x "$dest" ] && { echo "elvi \"$(basename "$dest")\" already exists in \"$ELVI_DIR\"" ; exit 1 ; }
		echo "Installing \"$src\" as \"$dest\""
		# Make sure clobbering doesn't happen.
		cp --no-clobber "$src" "$dest"
	elif [ "$action_type" = uninstall ]; then
		rm "$dest" && echo "Uninstalled \"$(basename "$src")\" ($(basename "$dest")) from \"$dest\""
	else
		echo "Invalid action type. Got \"$action_type\"."
		exit 1
	fi
done
