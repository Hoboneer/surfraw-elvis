OBJECTS := $(wildcard *.in *.sh-in)
OUTPUTS := $(OBJECTS:.in=.elvis)
OUTPUTS := $(OUTPUTS:.sh-in=.elvis)
COMPLETIONS := $(OBJECTS:.in=.completion)
COMPLETIONS := $(COMPLETIONS:.sh-in=.completion)


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
