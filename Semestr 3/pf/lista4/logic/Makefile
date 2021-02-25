SOURCES = logic.ml logic.mli logic.mllib
CMFILES = logic.cma logic.cmi
.PHONY: all clean build

all: logic.cma logic.cmi

build: $(SOURCES)
	rm -f $(CMFILES)
	ocamlbuild logic.cma

logic.cma: build
	cp _build/$@ $@

logic.cmi: build
	cp _build/$@ $@

clean:
	rm -f $(CMFILES)
	ocamlbuild -clean
