#!/bin/sh
# A script to ensure that only the elvi in this repo are installed and
# uninstalled by the `install.sh` and `uninstall.sh` scripts.

while read -r elvis; do
	[ "$elvis" = "$1" ] && exit 0
done < elvi

# No elvi match the elvis in `$1`.
echo elvis \""$1"\" is not an elvis in this repo
exit 1
