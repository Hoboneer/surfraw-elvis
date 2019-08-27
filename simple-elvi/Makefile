ELVI_FILE := elvi
OUTPUTS := $(addsuffix .elvis,$(shell grep -v '^\#' $(ELVI_FILE) | cut -d ' ' -f 1))

.PHONY: all
all: $(OUTPUTS)

%.elvis: $(ELVI_FILE)
	grep '^$(basename $@)\b' $(ELVI_FILE) | xargs mkelvis
	mv $(basename $@) $@

.PHONY: install
install:
	../install.sh $(OUTPUTS)

.PHONY: uninstall
uninstall:
	../install.sh -u $(OUTPUTS)
