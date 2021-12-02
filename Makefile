include env-vars

# Functions:

# Download a file
define gen_dl
$(GEN_DATA_DIR)/$(strip $(1)).gen:
	wget --no-verbose --output-document $$@ $(2)
endef



OBJECTS := $(wildcard $(SRCDIR)/*.in $(SRCDIR)/*.sh-in $(SRCDIR)/*.opensearch-in)

# Files converted to .gen-in first, and then .elvis
GEN_OBJECTS :=

MEDIAWIKI_OBJ := $(wildcard $(SRCDIR)/*.mediawiki-in)
GEN_OBJECTS += $(MEDIAWIKI_OBJ:.mediawiki-in=.gen-in)

OBJECTS += $(GEN_OBJECTS)

OUTPUTS := $(OBJECTS:%.in=%)
OUTPUTS := $(OUTPUTS:%.sh-in=%)
OUTPUTS := $(OUTPUTS:%.gen-in=%)
OUTPUTS := $(OUTPUTS:%.opensearch-in=%)

OBJECTS := $(sort $(OBJECTS))
GEN_OBJECTS := $(sort $(GEN_OBJECTS))
OUTPUTS := $(addprefix $(ELVI_DIR)/, $(notdir $(sort $(OUTPUTS))))

# Don't want to delete any intermediate files (by treating all targets as intermediate files that *aren't* deleted)
.SECONDARY:



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

# `wordtranslate` elvis:

$(eval $(call gen_dl, wordhippo.html, https://www.wordhippo.com))

$(GEN_DATA_DIR)/wordhippo-languages.gen: $(GEN_DATA_DIR)/wordhippo.html.gen
	tidy -q -asxml 2>/dev/null $< | hxselect -s '\n' -c '#translateLanguage > option::attr(value)' | sort >$@

$(ELVI_DIR)/wordtranslate: $(GEN_DATA_DIR)/wordhippo-languages.gen

# `stack` elvis:

$(eval $(call gen_dl, stackexchange-sites.html, https://stackexchange.com/sites))

$(GEN_DATA_DIR)/stackexchange-sites.gen: $(GEN_DATA_DIR)/stackexchange-sites.html.gen
	tidy -q -asxml 2>/dev/null $< | hxselect 'div.grid-view-container' | hxselect -s '\n' -c 'a::attr(href)' | sort >$@

$(ELVI_DIR)/stack: $(GEN_DATA_DIR)/stackexchange-sites.gen

# `pirate` elvis:

$(GEN_DATA_DIR)/pirate-types.gen: $(GEN_DATA_DIR)/pirate-types-in
	grep -v '^[[:space:]]*\#' $< | tr -s '\n' | sort -n -k 2 >$@

$(ELVI_DIR)/pirate: $(GEN_DATA_DIR)/pirate-types.gen

# `github`-related elvi:

$(eval $(call gen_dl, github-search.html, https://github.com/search/advanced))

$(GEN_DATA_DIR)/github-languages.gen: $(GEN_DATA_DIR)/github-search.html.gen
	hxclean $< | \
		hxselect -cs '\n' '#search_language > optgroup > option::attr(value)' | \
		hxunent | \
		awk -v OFS='\t' '\
			{ \
				search_term = $$0; \
				$$0 = tolower($$0); \
				gsub(/#/, "-sharp"); \
				gsub(/\*/, "-star"); \
				gsub(/ /, "-"); \
				# strip out parens, periods, and single quotes \
				gsub(/[.)('\'']/, ""); \
				# format: enum value, string to go in search query \
				print $$0, search_term; \
			}' | \
		sort -k1 -t'	' | \
		awk -v OFS="\t" '\
			# 'any' language should be the first option shown \
			BEGIN {print "any", ""} \
			{print}' >$@

# They all depend on the same file
$(ELVI_DIR)/github $(ELVI_DIR)/ghrepos $(ELVI_DIR)/ghissues: $(GEN_DATA_DIR)/github-languages.gen

# `mightyape` elvis:

$(eval $(call gen_dl, mightyape.html, https://www.mightyape.co.nz))

$(GEN_DATA_DIR)/mightyape-departments.gen: $(GEN_DATA_DIR)/mightyape.html.gen
	hxclean < $< | hxselect '#headerSearchIn option' | hxpipe | \
		awk -v OFS='\t' '/^Avalue CDATA/{val=$$3;next} /^-All Departments$$/{print val, "all";next} /^-/{gsub(",[[:space:]]*","-");gsub("[[:space:]]","-");gsub("&amp;","and");sub("^-","");print val, tolower($$0)}' > $@

$(ELVI_DIR)/mightyape: $(GEN_DATA_DIR)/mightyape-departments.gen



# General rules:

# I'm not sure how to have a rule match with the basename of something
# Line comments are permitted
$(ELVI_DIR)/%: $(SRCDIR)/%.in
	grep -v '^[[:space:]]*\#' $< | xargs mkelvis $(notdir $(basename $@)) -o $@

$(ELVI_DIR)/%: $(SRCDIR)/%.sh-in
	./$< | grep -v '^[[:space:]]*\#' | xargs mkelvis $(notdir $(basename $@)) -o $@

# Generated input files
$(ELVI_DIR)/%: $(SRCDIR)/%.gen-in
	grep -v '^[[:space:]]*\#' $< | xargs mkelvis $(notdir $(basename $@)) -o $@

# Nothing too special to do here
# Format of .mediawiki-in files:
#   First line: domain
#   Second line: search url
#   Third line: description
$(SRCDIR)/%.gen-in: $(SRCDIR)/%.mediawiki-in
	$(GEN_SCRIPTS_DIR)/mediawiki2in $< $@

# Retrieve OpenSearch url of site (refresh with `touch *.opensearch-in`)
$(GEN_DATA_DIR)/%.opensearch.url.gen: $(SRCDIR)/%.opensearch-in
	opensearch-discover $(file <$<) >$@
# Retrieve OpenSearch description (refresh with `touch *.opensearch.url.gen`)
$(GEN_DATA_DIR)/%.opensearch.xml.gen: $(GEN_DATA_DIR)/%.opensearch.url.gen
	wget --no-verbose --output-document $@ $(file <$<)
# Make the elvis
$(ELVI_DIR)/%: $(GEN_DATA_DIR)/%.opensearch.xml.gen
	opensearch2elvis $(notdir $(basename $@)) $< -o $@



# For installing
XDG_CONFIG_HOME ?= $(HOME)/.config
LOCAL_ELVI_DIR := $(XDG_CONFIG_HOME)/surfraw/elvi

.PHONY: install
install:
	install -D -t $(LOCAL_ELVI_DIR) -m 755 -- $(OUTPUTS)

.PHONY: uninstall
uninstall:
	-cd $(LOCAL_ELVI_DIR) && rm -f -- $(notdir $(basename $(OUTPUTS)))



.PHONY: clean
clean:
	-cd $(ELVI_DIR) && rm -f -- $(notdir $(wildcard $(ELVI_DIR)/*))

.PHONY: clean-gen-in
clean-gen-in:
	-rm -f -- $(GEN_OBJECTS)

.PHONY: clean-mediawiki-elvi
clean-mediawiki-elvi:
	-cd $(ELVI_DIR) && rm -f -- $(notdir $(MEDIAWIKI_OBJ:%.mediawiki-in=%))

# Clean non-elvis generator files
.PHONY: clean-gen
clean-gen:
	-cd $(GEN_DATA_DIR) && rm -f -- $(notdir $(wildcard $(GEN_DATA_DIR)/*.gen))

.PHONY: clean-gen-all
clean-gen-all: clean-gen clean-gen-in

.PHONY: clean-all
clean-all: clean clean-gen-all
