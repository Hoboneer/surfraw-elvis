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
%.elvis: %.in
	cat $< | xargs mkelvis
	mv $(basename $@) $@

%.completion: %.in
	cat $< | xargs mkelviscomps

.PHONY: install
install:
	../install.sh $(OUTPUTS)

.PHONY: uninstall
uninstall:
	../install.sh -u $(OUTPUTS)

.PHONY: clean
clean:
	-rm -f -- $(OUTPUTS) $(COMPLETIONS)
