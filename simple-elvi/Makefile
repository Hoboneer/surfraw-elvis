ELVI_FILE := elvi
OUTPUTS := $(addsuffix .elvis,$(shell cut -d ' ' -f 1 $(ELVI_FILE)))

all: $(OUTPUTS)

%.elvis: $(ELVI_FILE)
	grep '^$(basename $@)' $(ELVI_FILE) | xargs mkelvis
	mv $(basename $@) $@
