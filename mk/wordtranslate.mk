$(eval $(call gen_dl, wordhippo.html, https://www.wordhippo.com))

$(GEN_DATA_DIR)/wordhippo-languages.gen: $(GEN_DATA_DIR)/wordhippo.html.gen
	tidy -q -asxml 2>/dev/null $< | hxselect -s '\n' -c '#translateLanguage > option::attr(value)' | sort >$@

$(ELVI_DIR)/wordtranslate: $(GEN_DATA_DIR)/wordhippo-languages.gen
