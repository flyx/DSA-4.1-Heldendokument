all: profan.pdf geweiht.pdf magier.pdf

SOURCES = src/ausruestung.tex src/common.lua src/common.tex src/dsa.cls \
          src/frontseite.lua src/frontseite.tex src/heldendokument.tex \
					src/kampfbogen.lua src/kampfbogen.tex \
					src/liturgien.tex src/misc-macros.tex \
					src/talentbogen.lua src/talentbogen.tex src/values.lua \
					src/zauberdokument.lua src/zauberdokument.tex \
					src/zauberliste.lua src/zauberliste.tex

*.pdf: templates/profan.lua ${SOURCES}
	cd src && latexmk -lualatex='lualatex %O %S ../$<' heldendokument.tex
	mv src/heldendokument.pdf $@

docker-bare: ${SOURCES} docker/bare.dockerfile docker/held.sh
	@test -f "Manson Bold.otf" || (echo "'Manson Bold.otf' missing, download from https://fontsgeek.com/manson-font and extract here" && exit 1)
	@test -f "Manson Regular.otf" || (echo "'Manson Regular.otf' missing, download from https://fontsgeek.com/manson-font and extract here" && exit 1)
	docker build -f docker/bare.dockerfile -t dsa-4.1-heldendokument .

docker-server: docker/server.dockerfile docker/index.html docker/serve.go
	docker build -f docker/server.dockerfile -t dsa-4.1-heldendokument-generator .

doc: docs/index.html

docs/index.html: src/schemadef.lua src/schema.lua
	cd src && texlua schema.lua --standalone gendoc > ../docs/index.html

.PHONY: docker-bare docker-server doc