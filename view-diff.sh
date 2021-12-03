#!/bin/sh
# See diff between built-but-not-installed elvi and installed elvi.
for f in elvi/* $(sed 's|^|manual-elvi/|' manual-elvi.list); do
	diff --color=always -u ~/.config/surfraw/elvi/$(basename -s .elvis $f) $f
done | less -R
