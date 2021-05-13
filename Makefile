all: profan.pdf geweiht.pdf magier.pdf

SOURCES = src/ausruestung.tex src/common.tex src/dsa.cls \
          src/frontseite.tex src/heldendokument.tex src/kampfbogen.tex \
					src/liturgien.tex src/misc-macros.tex src/render.lua \
					src/talentbogen.tex src/values.lua src/zauberdokument.tex \
					src/zauberliste.tex

*.pdf: templates/profan.lua ${SOURCES}
	cd src && latexmk -lualatex='lualatex %O %S ../$<' heldendokument.tex
	mv src/heldendokument.pdf $@

docker: ${SOURCES}
	@test -f "Manson Bold.otf" || (echo "'Manson Bold.otf' missing, download from https://fontsgeek.com/manson-font and extract here" && exit 1)
	@test -f "Manson Regular.otf" || (echo "'Manson Regular.otf' missing, download from https://fontsgeek.com/manson-font and extract here" && exit 1)
	docker build -f docker/Dockerfile -t dsa-4.1-heldendokument .

.PHONY: docker