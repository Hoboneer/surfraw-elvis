include env-vars

# Functions:

# Download a file
define gen_dl
$(GEN_DATA_DIR)/$(strip $(1)).gen:
	wget --no-verbose --output-document $$@ $(2)
endef



OBJECTS := $(wildcard $(ELVI_DIR)/*.in $(ELVI_DIR)/*.sh-in)
OUTPUTS := $(OBJECTS:.in=.elvis)
OUTPUTS := $(OUTPUTS:.sh-in=.elvis)



.PHONY: all
all: elvi

.PHONY: elvi
elvi: $(OUTPUTS)

.PHONY: check
check:
	./opts.sh | ./lint.sh



# `ddg` elvis:

$(eval $(call gen_dl, duckduckgo-params.html, https://duckduckgo.com/params))

$(GEN_DATA_DIR)/duckduckgo-regions.gen: $(GEN_DATA_DIR)/duckduckgo-params.html.gen
	@# Regions file fields (tab-delimited): region name, url parameter value
	tidy -q -asxml $< 2>/dev/null | \
		hxselect -c -s '\n' 'td.ctd + td.ctd > ul > li' | \
		grep -E '^[a-z]{2}-[a-z]{2} for .*( \([a-z]{2}\))?$$' | \
		grep -v 'No region' | \
		sed 's/\([a-z][a-z]-[a-z][a-z]\) for \(.*\)$$/\2\t\1/' | \
		tr '[:upper:]' '[:lower:]' | \
		awk 'BEGIN{FS="\t";OFS="\t"} \
			/^(.* \([a-z]{2}\))/{gsub("\\(|\\)","",$$1)} \
			{gsub(" ","-",$$1);print $$1, $$2;next}' | \
		sort -k 1 >$@
	printf 'none\twt-wt\n' >>$@

$(ELVI_DIR)/ddg.sh-in: $(GEN_DATA_DIR)/duckduckgo-regions.gen
	touch $@

# `wordtranslate` elvis:

$(eval $(call gen_dl, wordhippo.html, https://www.wordhippo.com))

$(GEN_DATA_DIR)/wordhippo-languages.gen: $(GEN_DATA_DIR)/wordhippo.html.gen
	tidy -q -asxml 2>/dev/null $< | hxselect -s '\n' -c '#translateLanguage > option::attr(value)' | sort >$@

$(ELVI_DIR)/wordtranslate.sh-in: $(GEN_DATA_DIR)/wordhippo-languages.gen
	touch $@

# `stack` elvis:

$(eval $(call gen_dl, stackexchange-sites.html, https://stackexchange.com/sites))

$(GEN_DATA_DIR)/stackexchange-sites.gen: $(GEN_DATA_DIR)/stackexchange-sites.html.gen
	tidy -q -asxml 2>/dev/null $< | hxselect 'div.grid-view-container' | hxselect -s '\n' -c 'a::attr(href)' >$@

$(ELVI_DIR)/stack.sh-in: $(GEN_DATA_DIR)/stackexchange-sites.gen
	touch $@

# `pirate` elvis:

$(GEN_DATA_DIR)/pirate-types.gen: $(GEN_DATA_DIR)/pirate-types-in
	grep -v '^[[:space:]]*\#' $< | tr -s '\n' | sort -n -k 2 >$@

$(ELVI_DIR)/pirate.sh-in: $(GEN_DATA_DIR)/pirate-types.gen
	touch $@



# General rules:

# I'm not sure how to have a rule match with the basename of something
# Line comments are permitted
$(ELVI_DIR)/%.elvis: $(ELVI_DIR)/%.in
	grep -v '^[[:space:]]*\#' $< | xargs mkelvis $(notdir $(basename $@))
	mv $(notdir $(basename $@)) $@

$(ELVI_DIR)/%.elvis: $(ELVI_DIR)/%.sh-in
	./$< | grep -v '^[[:space:]]*\#' | xargs mkelvis $(notdir $(basename $@))
	mv $(notdir $(basename $@)) $@



# For installing
XDG_CONFIG_HOME ?= $(HOME)/.config
LOCAL_ELVI_DIR := $(XDG_CONFIG_HOME)/surfraw/elvi

# TODO: Install them in one go (remove suffixes....)
.PHONY: install
install:
	install -D -t $(LOCAL_ELVI_DIR) -m 755 -- $(OUTPUTS)
	@# Perl's `rename` command
	rename 's/\b\.elvis$$//' -- $(strip $(foreach elvis, $(OUTPUTS), $(LOCAL_ELVI_DIR)/$(notdir $(elvis))))

.PHONY: uninstall
uninstall: uninstall-partial
	-rm -f -- $(strip $(foreach elvis, $(OUTPUTS), $(LOCAL_ELVI_DIR)/$(notdir $(basename $(elvis)))))

# Delete partially installed elvi as well.
.PHONY: uninstall-partial
uninstall-partial:
	-rm -f -- $(strip $(foreach elvis, $(OUTPUTS), $(LOCAL_ELVI_DIR)/$(notdir $(elvis))))



.PHONY: clean
clean:
	-rm -f -- $(wildcard $(ELVI_DIR)/*.elvis $(ELVI_DIR)/*.completion)

# Clean non-elvis generator files
.PHONY: clean-gen
clean-gen:
	-rm -f -- $(wildcard $(GEN_DATA_DIR)/*.gen)

.PHONY: clean-all
clean-all: clean clean-gen
