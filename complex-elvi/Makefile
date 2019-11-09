OBJECTS := $(wildcard *.in)
OUTPUTS := $(OBJECTS:.in=.elvis)
COMPLETIONS := $(OBJECTS:.in=.completion)

.PHONY: all
all: elvi completions

.PHONY: elvi
elvi: $(OUTPUTS)

.PHONY: completions
completions: $(COMPLETIONS)

# I'm not sure how to have a rule match with the basename of something
# Line comments are permitted
%.elvis: %.in
	grep -v '^[[:space:]]*\#' $< | xargs mkelvis $(basename $@)
	mv $(basename $@) $@

%.completion: %.in
	grep -v '^[[:space:]]*\#' $< | xargs mkelviscomps $(basename $@)

.PHONY: install
install:
	../install.sh $(OUTPUTS)

.PHONY: uninstall
uninstall:
	../install.sh -u $(OUTPUTS)

.PHONY: clean
clean:
	-rm -f -- $(OUTPUTS) $(COMPLETIONS)
