#!/bin/sh
# Dependencies:
# 	* tidy (html-tidy)
# 	* html-xml-utils
tidy -q -asxml 2>/dev/null "$1" | hxselect 'div.grid-view-container' | hxselect -s '\n' -c 'a::attr(href)'
