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

.PRECIOUS: $(GEN_OBJECTS)



.PHONY: all
.DEFAULT_GOAL := all
all: elvi

.PHONY: elvi
elvi: $(OUTPUTS)

.PHONY: check
check:
	./opts.sh | ./lint.sh



# Include submakefiles that process the data files to generate certain elvi
$(foreach makefile,$(wildcard $(INCLUDE_DIR)/*.mk),$(eval include $(makefile)))

# Data files that each build multiple elvi

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

# OpenSearch data files should remain on disk.
.PRECIOUS: $(GEN_DATA_DIR)/%.opensearch.url.gen $(GEN_DATA_DIR)/%.opensearch.xml.gen
# Retrieve OpenSearch url of site (refresh with `touch *.opensearch-in`)
$(GEN_DATA_DIR)/%.opensearch.url.gen: $(SRCDIR)/%.opensearch-in
	rm -f $@ $@.tmp
	opensearch-discover $(file <$<) >$@.tmp
	mv $@.tmp $@
# Retrieve OpenSearch description (refresh with `touch *.opensearch.url.gen`)
$(GEN_DATA_DIR)/%.opensearch.xml.gen: $(GEN_DATA_DIR)/%.opensearch.url.gen
	rm -f $@ $@.tmp
	wget --no-verbose --output-document $@.tmp $(file <$<)
	mv $@.tmp $@
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
