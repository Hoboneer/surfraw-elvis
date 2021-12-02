$(eval $(call gen_dl, mightyape.html, https://www.mightyape.co.nz))

$(GEN_DATA_DIR)/mightyape-departments.gen: $(GEN_DATA_DIR)/mightyape.html.gen
	hxclean < $< | hxselect '#headerSearchIn option' | hxpipe | \
		awk -v OFS='\t' '/^Avalue CDATA/{val=$$3;next} /^-All Departments$$/{print val, "all";next} /^-/{gsub(",[[:space:]]*","-");gsub("[[:space:]]","-");gsub("&amp;","and");sub("^-","");print val, tolower($$0)}' > $@

$(ELVI_DIR)/mightyape: $(GEN_DATA_DIR)/mightyape-departments.gen
