ELVI_FILE := elvi
OUTPUTS := $(addsuffix .elvis,$(shell grep -v '^\#' $(ELVI_FILE) | cut -d ' ' -f 1))
COMPLETIONS := $(addsuffix .completion,$(shell grep -v '^\#' $(ELVI_FILE) | cut -d ' ' -f 1))

.PHONY: all
all: $(OUTPUTS) $(COMPLETIONS)

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
	-rm -f -- $(OUTPUTS) $(COMPLETIONS)
