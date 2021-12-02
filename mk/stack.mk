$(eval $(call gen_dl, stackexchange-sites.html, https://stackexchange.com/sites))

$(GEN_DATA_DIR)/stackexchange-sites.gen: $(GEN_DATA_DIR)/stackexchange-sites.html.gen
	tidy -q -asxml 2>/dev/null $< | hxselect 'div.grid-view-container' | hxselect -s '\n' -c 'a::attr(href)' | sort >$@

$(ELVI_DIR)/stack: $(GEN_DATA_DIR)/stackexchange-sites.gen
