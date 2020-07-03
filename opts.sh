#!/bin/sh
# Print options of each elvis
for elvis in elvi/*; do
	printf "%s:%s\n" $elvis "$(./$elvis --local-help |
		# Only get options
		sed -E -e '1,/^Local options:/d' -e 's/(^[[:space:]]*)|(\|.*$)//g' |
		grep '^-' |
		# Minimise option help lines
		tr -s ' ' |
		sed 's/, /,/g' |
		# Get only option names
		cut -f 1 -d ' ' |
		# Place all on one line
		tr '\n' ' ')"
# Globbing does not guarantee sorted order.
done | sort
