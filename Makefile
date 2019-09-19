.PHONY: all
all: simple complex

.PHONY: simple
simple:
	cd simple-elvi/ && $(MAKE)

.PHONY: complex
complex:
	cd complex-elvi/ && $(MAKE)

.PHONY: install
install:
	cd simple-elvi/ && $(MAKE) install
	cd complex-elvi/ && $(MAKE) install

.PHONY: uninstall
uninstall:
	cd simple-elvi/ && $(MAKE) uninstall
	cd complex-elvi/ && $(MAKE) uninstall

.PHONY: clean
clean:
	find simple-elvi/ -name '*.elvis' -print0 | xargs -0 rm -f --
	find complex-elvi/ -name '*.elvis' -print0 | xargs -0 rm -f --
