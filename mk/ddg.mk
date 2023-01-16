$(eval $(call gen_dl, duckduckgo-params.html, https://duckduckgo.com/params))

$(GEN_DATA_DIR)/duckduckgo-regions.gen: $(GEN_DATA_DIR)/duckduckgo-params.html.gen
	@# Regions file fields (tab-delimited): region name, url parameter value
	tidy -q -asxml $< 2>/dev/null | \
		hxselect -c -s '\n' '#result-settings + table tbody > tr:first-child > td:nth-child(3) > ul > li' | \
		awk '\
			/No region/ {next} \
			# input format: ISOCODE for COUNTRY (CODE?) \
			# output format: COUNTRY-CODE? TAB ISOCODE \
			/^[a-z]{2}-[a-z]{2} for .*( \([a-z]{2}\))?$$/ { \
				line = ""; \
				for (i=3; i<NF; i++) { \
					line = line tolower($$i) "-"; \
				} \
				line = line tolower($$NF) "\t"; \
				line = line $$1; \
				gsub("[)(]", "", line); \
				print line; \
			}' | \
		sort -k1 | \
		awk -v OFS="\t" '{print} END {print "none", "wt-wt";}' >$@


$(ELVI_DIR)/ddg: $(GEN_DATA_DIR)/duckduckgo-regions.gen
