# DSA 4.1 Heldendokument

LaTeX-Implementierung des DSA 4.1 Heldendokuments.
Abhängigkeiten:

 * TeXLive 2021
 * img/logo-fanprodukt.png => aus dem offiziellen Fanpaket extrahieren
 * img/wallpaper.jpg => aus dem Handout-PDF von WdS extrahieren
 * Im System müssen die Schriftarten [Manson](https://fontsgeek.com/manson-font) und [NewG8](https://github.com/probonopd/font-newg8/releases/tag/continuous) installiert sein

Mit `make` können die leeren Charakterbögen `profan.pdf` (Keine Zauberdokumente, keine Liturgien), `geweiht.pdf` (Liturgien im Ausrüstungsbogen) und `magier.pdf` (Zauberliste und Zauberdokument) generiert werden.

Um einen ausgefüllten Charakterbogen zu erstellen, muss eines der Templates in `templates` kopiert und mit Werten befüllt werden (siehe die Kommentare dort).
Die resultierende Datei muss in einer Datei (beispielsweise `src/held.lua`) abgelegt werden.
Dann muss im Verzeichnis `src` folgendes Kommando ausgeführt werden:

    latexmk -lualatex='lualatex %O %S held.lua' heldendokument.tex

`held.lua` muss der Pfad zur Heldendatei sein (relativ zum Verzeichnis `src`, oder absolut).
Das Heldendokument liegt nach erfolgreicher Generierung in `src/heldendokument.pdf`.

## Docker

Wem die Installation von TeXLive zu anstrengend ist, kann ein [Docker](https://www.docker.com)-Image erstellen.
Die Voraussetzung dafür ist, dass Docker auf dem System installiert ist und die beiden Dateien `Manson Regular.otf` und `Manson Bold.otf` (Link siehe oben) im Hauptverzeichnis liegen – die Seite, wo man sie laden kann, lässt es nicht zu, sie automatisch zu laden.

Danach lässt sich das Image hiermit bauen:

    make docker

Windows-Nutzer ohne Make machen statt dessen:

    docker build -f docker/Dockerfile -t dsa-4.1-heldendokument .

Ist das Image erstellt, kann ein Charakterbogen folgendermaßen erstellt werden:

    cat held.lua | docker -i  --rm dsa-4.1-heldendokument > held.pdf

Das war ja einfach!

Hinweis: Das Docker-Image verbraucht etwa 559MB auf der Platte. TeXLive zu installieren, wenn man es nicht sowieso hat, wäre kaum kleiner.

## Lizenz

**Wichtig:** Die verwendeten Schriftarten und Grafiken, die nicht Teil des Repositories sind, haben keine Lizenz, die die Weiterverbreitung erlaubt!
Deshalb wird weder ein fertiges Docker-Image noch ein fertiges Heldendokument zur Verfügung gestellt und dem Benutzer wird ebenfalls davon abgeraten, dies zu tun.

Der in diesem Repository enthaltene Code ist lizensiert unter der [LaTeX Project Public License](https://www.latex-project.org/lppl/).
