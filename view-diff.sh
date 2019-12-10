#!/bin/sh
# See diff between built-but-not-installed elvi and installed elvi.
for f in complex-elvi/*.elvis simple-elvi/*.elvis; do
	diff --color=always -u ~/.config/surfraw/elvi/$(basename -s .elvis $f) $f
done | less -R
