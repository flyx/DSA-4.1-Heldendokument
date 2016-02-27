# Diese Makefile baut das Heldendokument zusammen. Jede Seite wird zunächst
# als eigenes PDF generiert, aus mehreren Gründen:
#
#  - Man muss nicht bei jeder Änderung alles neu bauen, sondern nur die Seite,
#    an der man Änderungen vorgenommen hat.
#  - Die Eingabefelder funktionieren nicht korrekt, wenn man sie in der
#    landscape-Umgebung benutzt, deshalb muss die Zauberliste auf jeden Fall
#    als extra PDF generiert werden.

### Kann im Voraus gesetzt werden, um andere Parameter zu benutzen

DATA_FILE ?= data/parameter.yaml
WALLPAPER_FILE ?= /usr/share/texmf/tex/latex/dsa/fanpaket/wallpaper.png

### Definition der Quelldateien

PRIMARY_SUB_SRC_FILES=frontseite.tex \
                      talentbogen.tex \
                      kampfbogen.tex \
                      ausruestung.tex \
                      liturgien.tex \
                      zauberdokument.tex

EXTRA_SRC_FILES=zauberliste.tex vertrautendokument.tex
PRIMARY_SRC_FILES=$(PRIMARY_SUB_SRC_FILES) $(EXTRA_SRC_FILES)
STANDALONE_SRC_FILES=$(PRIMARY_SUB_SRC_FILES:.tex=-standalone.tex)

COMMON_SRC_FILES=common.tex
ADDITIONAL_SRC_FILES=misc-macros.tex
TARGET_SRC_FILE=heldendokument.tex

### Alle Quelldateien liegen im src-Ordner

PRIMARY_SUB_SRCS=$(PRIMARY_SUB_SRC_FILES:%.tex=src/%.tex)
PRIMARY_SRCS=$(PRIMARY_SRC_FILES:%.tex=src/%.tex)
COMMON_SRCS=$(COMMON_SRC_FILES:%.tex=src/%.tex)
ADDITIONAL_SRCS=$(ADDITIONAL_SRC_FILES:%.tex=src/%.tex)
TARGET_SRCS=$(TARGET_SRC_FILE:%.tex=src/%.tex)
STANDALONE_SRCS=$(STANDALONE_SRC_FILES:%.tex=src/%.tex)
EXTRA_SRCS=$(EXTRA_SRC_FILES:%.tex=src/%.tex)

### Alle Quelldateien werden in den build-Ordner kopiert.

PRIMARY_BUILD=$(PRIMARY_SRCS:src/%=build/%)
COMMON_BUILD=$(COMMON_SRCS:src/%=build/%)
ADDITIONAL_BUILD=$(ADDITIONAL_SRCS:src/%=build/%)
STANDALONE_BUILD=$(STANDALONE_SRCS:src/%=build/%)
TARGET_BUILD=$(TARGET_SRCS:src/%=build/%)
EXTRA_BUILD=$(EXTRA_SRCS:src/%=build/%)

### Für jede primär-Quelle gibt es eine Konfigurationsdatei, die aus
### einem Template erstellt wird.

CONFIG_TEMPLATES=$(PRIMARY_SRCS:src/%.tex=templates%-konfig.mustache)
CONFIG_BUILD=$(PRIMARY_SRCS:src/%.tex=build/%-konfig.tex)

### Wallpaper
# Die Makefile kann nicht überprüfen, ob Original, Alternative, ein benutzerdefiniertes oder
# gar kein Wallpaper verwendet wird. Deshalb generieren wir einfach mal alles.
WALLPAPER_BUILD=build/wallpaper.jpg \
				build/wallpaper-landscape.jpg \
				build/wallpaper-alternative.jpg \
				build/wallpaper-alternative-landscape.jpg \
				build/wallpaper-konfig.tex

### Definition generierter Dateien

STANDALONE_PDFS=$(STANDALONE_BUILD:build/%-standalone.tex=%.pdf)
EXTRA_PDFS=$(EXTRA_BUILD:%.tex=%.pdf)
TARGET=$(TARGET_BUILD:build/%.tex=%.pdf)

### Targets zum Bauen der Dokumente

all: $(TARGET)

# Build-Verzeichnis
build:
	mkdir -p build


# Kopieren der Quellen
$(PRIMARY_BUILD) $(COMMON_BUILD) $(ADDITIONAL_BUILD) $(STANDALONE_BUILD) $(TARGET_BUILD): build/%.tex: src/%.tex build
	cp $< $@

# Erstellen von Konfigurationsdateien (static pattern mit $(CONFIG_BUILD) tut hier aus unbekannten Gründen nicht)
build/ausruestung-konfig.tex: templates/ausruestung-konfig.mustache scripts/configure.py build
	/usr/bin/env python scripts/configure.py $< $(DATA_FILE) Ausrüstung $@
build/frontseite-konfig.tex: templates/frontseite-konfig.mustache scripts/configure.py build
	/usr/bin/env python scripts/configure.py $< $(DATA_FILE) Frontseite $@
build/kampfbogen-konfig.tex: templates/kampfbogen-konfig.mustache scripts/configure.py build
	/usr/bin/env python scripts/configure.py $< $(DATA_FILE) Kampfbogen $@
build/liturgien-konfig.tex: templates/liturgien-konfig.mustache scripts/configure.py build
	/usr/bin/env python scripts/configure.py $< $(DATA_FILE) Liturgien $@
build/talentbogen-konfig.tex: templates/talentbogen-konfig.mustache scripts/configure.py build
	/usr/bin/env python scripts/configure.py $< $(DATA_FILE) Talentbogen $@
build/zauberliste-konfig.tex: templates/zauberliste-konfig.mustache scripts/configure.py build
	/usr/bin/env python scripts/configure.py $< $(DATA_FILE) Zauberliste $@
build/zauberdokument-konfig.tex: templates/zauberdokument-konfig.mustache scripts/configure.py build
	/usr/bin/env python scripts/configure.py $< $(DATA_FILE) Zauberdokument $@
build/vertrautendokument-konfig.tex: templates/vertrautendokument-konfig.mustache scripts/configure.py build
	/usr/bin/env python scripts/configure.py $< $(DATA_FILE) Vertrautendokument $@

# Erstellen der einzelnen PDF-Seiten
$(STANDALONE_PDFS): %.pdf: build/%-standalone.tex build/%.tex build/%-konfig.tex $(COMMON_BUILD) build/eingabefelder-extern.tex $(WALLPAPER_BUILD)
	cd build && xelatex -jobname=$(@:.pdf=) -interaction=batchmode $(<:build/%=%)
	mv build/$@ .

$(EXTRA_PDFS): build/%.pdf: build/%.tex $(COMMON_BUILD) $(WALLPAPER_SRCS) $(WALLPAPER_BUILD) build/eingabefelder-extern.tex
	cd build && xelatex -jobname=$(@:build/%.pdf=%) -interaction=batchmode $(<:build/%=%)

# Zauberliste kann auch einzeln erstellt werden - dann einfach ins Stammverzeichnis kopieren
zauberliste.pdf: build/zauberliste.pdf
	cp $< $@

# Vertrautendokument ist immer extra
vertrautendokument.pdf: build/vertrautendokument.pdf
	cp $< $@

# Erstellen der Zauberliste, die getrennt vom Rest erstellt werden muss, weil Querformat
$()

# Erstellen von Quellen aus YAML-Daten
build/talentbogen-extern.tex: build scripts/talente.py data/talente.yaml
	/usr/bin/env python scripts/talente.py data/talente.yaml build/talentbogen-extern.tex

build/eingabefelder-extern.tex: build scripts/eingabefelder.py data/eingabefelder.yaml
	/usr/bin/env python scripts/eingabefelder.py data/eingabefelder.yaml build/eingabefelder-extern.tex

# Erstellen des finalen Dokuments
build/$(TARGET): $(TARGET_BUILD) $(PRIMARY_BUILD) $(COMMON_BUILD) $(ADDITIONAL_BUILD) $(CONFIG_BUILD) $(WALLPAPER_SRCS) build/eingabefelder-extern.tex $(WALLPAPER_BUILD) build/talentbogen-extern.tex
	cd build && xelatex -jobname=$(@:build/%.pdf=%) -interaction=batchmode $(<:build/%=%)
	# erst das zweite Mal sitzt das „Fanprodukt“-Logo auf der Frontseite richtig.
	cd build && xelatex -jobname=$(@:build/%.pdf=%) -interaction=batchmode $(<:build/%=%)

$(TARGET): build/$(TARGET) build/zauberliste.pdf
	pdfunite $^ $@

# Erstellen von Wallpaper-Ressourcen
build/wallpaper.jpg: build
	convert ${WALLPAPER_FILE} build/wallpaper.jpg
build/wallpaper-landscape.jpg: build
	convert ${WALLPAPER_FILE} -rotate 270 build/wallpaper-landscape.jpg
build/wallpaper-alternative.jpg: build
	convert img/wallpaper-alternative.png build/wallpaper-alternative.jpg
build/wallpaper-alternative-landscape.jpg: build
	convert img/wallpaper-alternative.png -rotate 270 build/wallpaper-alternative-landscape.jpg
build/wallpaper-konfig.tex: templates/wallpaper-konfig.mustache build scripts/wallpaper.py
	/usr/bin/env python scripts/wallpaper.py $< $(DATA_FILE) $@

clean:
	rm -rf build $(STANDALONE_PDFS) $(TARGET)


### Zusätzliche Abhängigkeiten

talentbogen.pdf: build/talentbogen-extern.tex
liturgien.pdf: build/misc-macros.tex
ausruestung.pdf: build/misc-macros.tex
kampfbogen.pdf:  img/silhouette.png
