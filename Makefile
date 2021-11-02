SOURCES = \
	src/ausruestung.tex src/common.lua src/common.tex src/dsa.cls \
	src/frontseite.lua src/frontseite.tex src/heldendokument.tex \
	src/kampfbogen.lua src/kampfbogen.tex \
	src/liturgien.tex src/misc-macros.tex \
	src/talentbogen.lua src/talentbogen.tex src/values.lua \
	src/zauberdokument.lua src/zauberdokument.tex \
	src/zauberliste.lua src/zauberliste.tex

docker: dsa41held-webui.tar

doc: docs/index.html

dsa41held-webui.tar: build.dockerfile heldensoftware-meta.xml import.xsl flake.nix flake.lock $(shell find templates src webui img -type file)
	docker build -f build.dockerfile -t dsa41held-build .
	docker run --rm dsa41held-build:latest > $@
	docker rmi $(docker images --filter=reference='dsa41held-build' --format "{{.ID}}")

docs/index.html: src/schemadef.lua src/schema.lua src/tools.lua
	cd src && texlua tools.lua --standalone gendoc > ../docs/index.html

.PHONY: doc docker