ELVI_FILE := elvi_spec
OUTPUTS := $(addsuffix .elvis,$(shell grep -v '^\#' $(ELVI_FILE) | cut -d ' ' -f 1))
COMPLETIONS := $(addsuffix .completion,$(shell grep -v '^\#' $(ELVI_FILE) | cut -d ' ' -f 1))

.PHONY: all
all: elvi completions

.PHONY: elvi
elvi: $(OUTPUTS)

.PHONY: completions
completions: $(COMPLETIONS)

%.elvis: $(ELVI_FILE)
	grep '^$(basename $@)\b' $(ELVI_FILE) | xargs mkelvis
	mv $(basename $@) $@

%.completion: $(ELVI_FILE)
	grep '^$(basename $@)\b' $(ELVI_FILE) | xargs mkelviscomps

.PHONY: install
install:
	../install.sh $(OUTPUTS)

.PHONY: uninstall
uninstall:
	../install.sh -u $(OUTPUTS)

.PHONY: clean
clean:
	-rm -f -- $(wildcard *.elvis *.completion)
