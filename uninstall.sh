#!/bin/sh

ELVI_DIR=/usr/lib/surfraw/
TARGET_ELVI="${ELVI_DIR}$1"
if [ -z "$TARGET_ELVI" ] || [ ! -x "$TARGET_ELVI" ]; then
	exit 1
fi

./check-elvis.sh "$TARGET_ELVI" || exit 1

rm "$TARGET_ELVI"
