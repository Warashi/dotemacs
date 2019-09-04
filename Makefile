EMACS	?= emacs
.PHONY: clean
clean:
	rm -f init.mk init.el init.elc
all: init.elc
init.mk: init.org
	$(EMACS) -Q -q --batch --eval \
		"(progn \
			(require 'ob-tangle) \
			(org-babel-tangle-file \"$<\" \"$@\" \"makefile\"))"
init.elc: init.mk
	$(MAKE) -f $< $@
