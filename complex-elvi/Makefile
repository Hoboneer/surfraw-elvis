OBJECTS := $(wildcard *.in *.sh-in)
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

stackexchange-sites.html:
	wget --output-document $@ https://stackexchange.com/sites

stackexchange-sites: stackexchange-sites.html
	./get-stackexchange-urls.sh $< >$@

stack.sh-in: stackexchange-sites
	touch stack.sh-in

# `pirate` elvis:

pirate-types: pirate-types-in
	grep -v '^[[:space:]]*\#' $< | tr -s '\n' | sort -n -k 2 >$@

pirate.sh-in: pirate-types
	touch $@

# General rules:

# I'm not sure how to have a rule match with the basename of something
# Line comments are permitted
%.elvis: %.in
	grep -v '^[[:space:]]*\#' $< | xargs mkelvis $(basename $@)
	mv $(basename $@) $@

%.elvis: %.sh-in
	./$< | grep -v '^[[:space:]]*\#' | xargs mkelvis $(basename $@)
	mv $(basename $@) $@

%.completion: %.in
	grep -v '^[[:space:]]*\#' $< | xargs mkelviscomps $(basename $@)

%.completion: %.sh-in
	./$< | grep -v '^[[:space:]]*\#' | xargs mkelviscomps $(basename $@)

.PHONY: install
install:
	../install.sh $(OUTPUTS)

.PHONY: uninstall
uninstall:
	../install.sh -u $(OUTPUTS)

.PHONY: clean
clean:
	-rm -f -- $(wildcard *.elvis *.completion)

# Clean non-elvis generator files
.PHONY: clean-gen
clean-gen:
	-rm -f -- stackexchange-sites.html stackexchange-sites pirate-types

.PHONY: clean-all
clean-all: clean clean-gen
