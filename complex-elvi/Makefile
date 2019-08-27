OBJECTS := $(wildcard *.in)
OUTPUTS := $(OBJECTS:.in=.elvis)

.PHONY: all
all: $(OUTPUTS)

# I'm not sure how to have a rule match with the basename of something
%.elvis: %.in
	cat $< | xargs mkelvis
	mv $(basename $@) $@

.PHONY: install
install:
	../install.sh $(OUTPUTS)

.PHONY: uninstall
uninstall:
	../install.sh -u $(OUTPUTS)
