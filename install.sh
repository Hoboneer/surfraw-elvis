#!/bin/sh

ELVI_DIR=/usr/lib/surfraw/

if [ -z "$1" ] || [ ! -x "$1" ]; then
	exit 1
fi

./check-elvis.sh "$1" || exit 1

cp "$1" "$ELVI_DIR"
