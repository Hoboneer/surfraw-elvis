OBJECTS := $(wildcard *.in)
OUTPUTS := $(OBJECTS:.in=.elvis)

all: $(OUTPUTS)

# I'm not sure how to have a rule match with the basename of something
%.elvis: %.in
	cat $< | xargs mkelvis
	mv $(basename $@) $@
