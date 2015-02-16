# Diese Makefile baut das Heldendokument zusammen. Jede Seite wird zunächst
# als eigenes PDF generiert, aus mehreren Gründen:
#
#  - Man muss nicht bei jeder Änderung alles neu bauen, sondern nur die Seite,
#    an der man Änderungen vorgenommen hat.
#  - Die Eingabefelder funktionieren nicht korrekt, wenn man sie in der
#    landscape-Umgebung benutzt, deshalb muss die Zauberliste auf jeden Fall
#    als extra PDF generiert werden.

### Definition der Quelldateien

PRIMARY_SRC_FILES=frontseite.tex \
                  talentbogen.tex \
                  kampfbogen.tex \
                  ausruestung.tex \
                  liturgien.tex \
                  zauberliste.tex \
                  zauberdokument.tex

COMMON_SRC_FILES=common.tex
ADDITIONAL_SRC_FILES=misc-macros.tex

### Alle Quelldateien liegen im src-Ordner

PRIMARY_SRCS=$(PRIMARY_SRC_FILES:%.tex=src/%.tex)
COMMON_SRCS=$(COMMON_SRC_FILES:%.tex=src/%.tex)
ADDITIONAL_SRCS=$(ADDITIONAL_SRC_FILES:%.tex=src/%.tex)

### Alle Quelldateien werden in den build-Ordner kopiert.

PRIMARY_BUILD=$(PRIMARY_SRCS:src/%=build/%)
COMMON_BUILD=$(COMMON_SRCS:src/%=build/%)
ADDITIONAL_BUILD=$(ADDITIONAL_SRCS:src/%=build/%)

### Für jede primär-Quelle gibt es eine Konfigurationsdatei, die aus
### einem Template erstellt wird.

CONFIG_TEMPLATES=($PRIMARY_SRCS:src/%.tex=templates%-konfig.mustache)
CONFIG_BUILD=($PRIMARY_SRCS:src/%.tex=build/%-konfig.tex)

### Wallpaper ist optional
# TODO: Wallpaper soll auch per Konfiguration geändert werden, nicht hier in der Makefile
WALLPAPER?=original
WALLPAPER_SRCS=
WALLPAPER_PY_PARAMS="none" "" 
ifeq ($(WALLPAPER),original)
	WALLPAPER_SRCS=build/wallpaper-landscape.png
	WALLPAPER_PY_PARAMS="" "wallpaper-landscape.png"
endif
ifeq ($(WALLPAPER),alternative)
	WALLPAPER_SRCS=img/wallpaper-alternative.png img/wallpaper-alternative-landscape.png
	WALLPAPER_PY_PARAMS="../img/wallpaper-alternative.png" "../img/wallpaper-alternative-landscape.png"
endif

### Definition generierter Dateien

INTERMEDIATE_PDFS=$(PRIMARY_BUILD:.tex=.pdf)

TARGET=heldendokument.pdf

### Targets zum Bauen der Dokumente

all: $(TARGET)

# Build-Verzeichnis
build:
	mkdir -p build


# Kopieren der Quellen
$(PRIMARY_BUILD) $(COMMON_BUILD) $(ADDITIONAL_BUILD): build/%.tex: src/%.tex build
	cp $< $@

# Erstellen von Konfigurationsdateien (static pattern mit $(CONFIG_BUILD) tut hier aus unbekannten Gründen nicht)
build/%-konfig.tex: templates/%-konfig.default build
	cp $< $@

# Erstellen der einzelnen PDF-Seiten
$(INTERMEDIATE_PDFS): build/%.pdf: build/%.tex build/%-konfig.tex $(COMMON_BUILD) build/eingabefelder-extern.tex build/wallpaper-extern.tex
	cd build && xelatex $(<:build/%=%)

# Erstellen von Quellen aus YAML-Daten
build/talentbogen-extern.tex: build scripts/talente.py data/talente.yaml
	scripts/talente.py data/talente.yaml build/talentbogen-extern.tex

build/eingabefelder-extern.tex: build scripts/eingabefelder.py data/eingabefelder.yaml
	scripts/eingabefelder.py data/eingabefelder.yaml build/eingabefelder-extern.tex

# Erstellen des finalen Dokuments
$(TARGET): $(INTERMEDIATE_PDFS)
	pdfunite $^ $(TARGET)

# Erstellen von Wallpaper-Ressourcen
build/wallpaper-landscape.png: build
	convert /usr/share/texmf/tex/latex/dsa/fanpaket/wallpaper.png -rotate 90 build/wallpaper-landscape.png

build/wallpaper-alternative-landscape.png: build
	convert img/wallpaper-alternative.png -rotate 90 build/wallpaper-alternative-landscape.png

build/wallpaper-extern.tex: build scripts/wallpaper.py
	scripts/wallpaper.py $(WALLPAPER_PY_PARAMS)

clean:
	rm -rf build


### Zusätzliche Abhängigkeiten

build/talentbogen.pdf: build/talentbogen-extern.tex
build/liturgien.pdf: build/misc-macros.tex
build/ausruestung.pdf: build/misc-macros.tex
build/kampfbogen.pdf:  img/silhouette.png
build/zauberliste.pdf: $(WALLPAPER_SRCS)
