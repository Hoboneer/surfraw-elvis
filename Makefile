# Directory for:
#   1. Input files for elvi (and their completions)
#   2. Output elvi and completions
ELVI_DIR := elvi
# Directory for non-elvi-input data files needed to build
GEN_DATA_DIR := gen-data

OBJECTS := $(wildcard $(ELVI_DIR)/*.in $(ELVI_DIR)/*.sh-in)
OUTPUTS := $(OBJECTS:.in=.elvis)
OUTPUTS := $(OUTPUTS:.sh-in=.elvis)
COMPLETIONS := $(OUTPUTS:.elvis=.completion)

.PHONY: all
all: elvi completions

.PHONY: elvi
elvi: $(OUTPUTS)

.PHONY: completions
completions: $(COMPLETIONS)

# `stack` elvis:

$(GEN_DATA_DIR)/stackexchange-sites.html.gen:
	wget --no-verbose --output-document $@ https://stackexchange.com/sites

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
	env GEN_DATA_DIR='$(GEN_DATA_DIR)' ./$< | grep -v '^[[:space:]]*\#' | xargs mkelvis $(notdir $(basename $@))
	mv $(notdir $(basename $@)) $@

$(ELVI_DIR)/%.completion: $(ELVI_DIR)/%.in
	grep -v '^[[:space:]]*\#' $< | xargs mkelviscomps $(notdir $(basename $@))
	mv $(notdir $@) $@

$(ELVI_DIR)/%.completion: $(ELVI_DIR)/%.sh-in
	env GEN_DATA_DIR='$(GEN_DATA_DIR)' ./$< | grep -v '^[[:space:]]*\#' | xargs mkelviscomps $(notdir $(basename $@))
	mv $(notdir $@) $@

.PHONY: install
install:
	./install.sh $(OUTPUTS)

.PHONY: uninstall
uninstall:
	./install.sh -u $(OUTPUTS)

.PHONY: clean
clean:
	-rm -f -- $(wildcard $(ELVI_DIR)/*.elvis $(ELVI_DIR)/*.completion)

# Clean non-elvis generator files
.PHONY: clean-gen
clean-gen:
	-rm -f -- $(wildcard $(GEN_DATA_DIR)/*.gen)

.PHONY: clean-all
clean-all: clean clean-gen
