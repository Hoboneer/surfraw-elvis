.PHONY: all
all: simple complex

.PHONY: simple
simple:
	cd simple-elvi/ && $(MAKE)

.PHONY: complex
complex:
	cd complex-elvi/ && $(MAKE)

.PHONY: elvi
elvi:
	cd simple-elvi/ && $(MAKE) elvi
	cd complex-elvi/ && $(MAKE) elvi

.PHONY: completions
completions:
	cd simple-elvi/ && $(MAKE) completions
	cd complex-elvi/ && $(MAKE) completions

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
	cd simple-elvi/ && $(MAKE) clean
	cd complex-elvi/ && $(MAKE) clean
