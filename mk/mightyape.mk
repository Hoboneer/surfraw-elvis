$(eval $(call gen_dl, mightyape.html, https://www.mightyape.co.nz))

$(GEN_DATA_DIR)/mightyape-departments.gen: $(GEN_DATA_DIR)/mightyape.html.gen
	hxclean < $< | hxselect '#headerSearchIn option' | hxpipe | \
		awk -v OFS='\t' '/^Avalue CDATA/{val=$$3;next} /^-All Departments$$/{print val, "all";next} /^-/{gsub(",[[:space:]]*","-");gsub("[[:space:]]","-");gsub("&amp;","and");sub("^-","");print val, tolower($$0)}' | sort -k2 > $@.tmp
	@# Ensure the "all" option argument is listed first.
	awk -v FS='\t' -v OFS='\t' '$$2 == "all" {print; exit}' $@.tmp > $@.all-department.tmp
	awk -v FS='\t' -v OFS='\t' '$$2 != "all" {print; next}' $@.tmp > $@.rest.tmp
	cat $@.all-department.tmp $@.rest.tmp > $@
	rm -f -- $@.tmp $@.all-department.tmp $@.rest.tmp

$(ELVI_DIR)/mightyape: $(GEN_DATA_DIR)/mightyape-departments.gen
