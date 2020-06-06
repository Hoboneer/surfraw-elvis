include env-vars

# Functions:

# Download a file
define gen_dl
$(GEN_DATA_DIR)/$(strip $(1)).gen:
	wget --no-verbose --output-document $$@ $(2)
endef



OBJECTS := $(wildcard $(ELVI_DIR)/*.in $(ELVI_DIR)/*.sh-in)

# Files converted to .gen-in first, and then .elvis
GEN_OBJECTS :=

MEDIAWIKI_OBJ := $(wildcard $(ELVI_DIR)/*.mediawiki-in)
GEN_OBJECTS += $(MEDIAWIKI_OBJ:.mediawiki-in=.gen-in)

OBJECTS += $(GEN_OBJECTS)

OUTPUTS := $(OBJECTS:.in=.elvis)
OUTPUTS := $(OUTPUTS:.sh-in=.elvis)
OUTPUTS := $(OUTPUTS:.gen-in=.elvis)

OBJECTS := $(sort $(OBJECTS))
GEN_OBJECTS := $(sort $(GEN_OBJECTS))
OUTPUTS := $(sort $(OUTPUTS))

# Don't generate then delete them after being used to create elvi
.PRECIOUS: $(GEN_OBJECTS)



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

# `github`-related elvi:

$(eval $(call gen_dl, github-search.html, https://github.com/search/advanced))

$(GEN_DATA_DIR)/github-languages.gen: $(GEN_DATA_DIR)/github-search.html.gen
	hxclean $< | hxselect -cs '\n' '#search_language > optgroup > option::attr(value)' | hxunent >$@.tmp
	@# All of the input must be processed before `sort` writes to file--no messed up files here!
	tr '[:upper:]' '[:lower:]' <$@.tmp | sed -e 's/#/-sharp/' -e 's/*/-star/' -e 's/ /-/g' -e 's/(\|)\|\.\|'"'//g" | paste -d '\t' - $@.tmp | sort -k 1 -t '	' -o $@.tmp
	@# Ensure 'any' language is the first option shown
	printf 'any\t\n' | cat - $@.tmp >$@
	rm -f $@.tmp

# They all depend on the same file
$(ELVI_DIR)/github.sh-in $(ELVI_DIR)/ghrepos.sh-in $(ELVI_DIR)/ghissues.sh-in: $(GEN_DATA_DIR)/github-languages.gen
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

# Generated input files
$(ELVI_DIR)/%.elvis: $(ELVI_DIR)/%.gen-in
	grep -v '^[[:space:]]*\#' $< | xargs mkelvis $(notdir $(basename $@))
	mv $(notdir $(basename $@)) $@

# Nothing too special to do here
# Format of .mediawiki-in files:
#   First line: domain
#   Second line: search url
#   Third line: description
$(ELVI_DIR)/%.gen-in: $(ELVI_DIR)/%.mediawiki-in
	$(GEN_SCRIPTS_DIR)/mediawiki2in $< $@



# For installing
XDG_CONFIG_HOME ?= $(HOME)/.config
LOCAL_ELVI_DIR := $(XDG_CONFIG_HOME)/surfraw/elvi

# TODO: Install them in one go (remove suffixes....)
.PHONY: install
install:
	install -D -t $(LOCAL_ELVI_DIR) -m 755 -- $(OUTPUTS)
	@# Perl's `rename` command
	cd $(LOCAL_ELVI_DIR) && rename 's/\b\.elvis$$//' -- $(notdir $(OUTPUTS))

.PHONY: uninstall
uninstall: uninstall-partial
	-cd $(LOCAL_ELVI_DIR) && rm -f -- $(notdir $(basename $(OUTPUTS)))

# Delete partially installed elvi as well.
.PHONY: uninstall-partial
uninstall-partial:
	-cd $(LOCAL_ELVI_DIR) && rm -f -- $(notdir $(OUTPUTS))



.PHONY: clean
clean:
	-cd $(ELVI_DIR) && rm -f -- $(notdir $(wildcard $(ELVI_DIR)/*.elvis $(ELVI_DIR)/*.completion))

.PHONY: clean-gen-in
clean-gen-in:
	-rm -f -- $(GEN_OBJECTS)

.PHONY: clean-mediawiki-elvi
clean-mediawiki-elvi:
	-cd $(ELVI_DIR) && rm -f -- $(notdir $(MEDIAWIKI_OBJ:.mediawiki-in=.elvis))

# Clean non-elvis generator files
.PHONY: clean-gen
clean-gen:
	-cd $(GEN_DATA_DIR) && rm -f -- $(notdir $(wildcard $(GEN_DATA_DIR)/*.gen))

.PHONY: clean-gen-all
clean-gen-all: clean-gen clean-gen-in

.PHONY: clean-all
clean-all: clean clean-gen-all
