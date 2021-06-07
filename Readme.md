# DSA 4.1 Heldendokument

Ein DSA 4.1 Heldendokument, das sich am original Heldendokument orientiert.
Es kann über Lua-Quellcode mit Werten befüllt werden und berechnet abgeleitete Werte automatisch.

## Features

 * Kein editierbares PDF – Werte können beim Bauen des Heldendokuments eingegeben werden, das generierte Dokument ist nicht interaktiv.
   Der Vorteil davon ist, dass das Dokument in PDF-Readern, die keine interaktiven Element unterstützen, vollständig angezeigt werden kann.
   Das betrifft viele PDF-Reader auf Tablets.

   Außerdem sieht das Dokument nicht stark unterschiedlich in verschiedenen Readern aus.
 * Die Werte des Helden können in einer Textdatei gespeichert werden, aus der bei Änderungen immer wieder ein neues Dokument erstellt werden kann.
   Dadurch kann der Held beispielsweise einfach in einem Versionskontrollsystem abgelegt werden.
   Warum würde man Versionskontrolle wollen? Naja, um beispielsweise wenn auf einer Convention ein Held mit maximal 5000 AP verlangt wird, man einfach eine frühere Version bauen kann. Alltäglicher Anwendungsfall!
 * Alternierender Hintergrund pro Zeile bei vielen Tabellen für bessere Lesbarkeit.
   Das schließt beispielsweise Talente, Liturgien, Rituale und Zauber ein.
 * Dynamische Größe der meisten Tabellen:
   Die meisten Tabellen, haben eine variable Anzahl an Zeilen.
   Man kann beispielsweise mehr Zeilen in gesellschaftlichen Talenten haben und dafür weniger Zeilen bei den Körperlichen – oder die „Gaben“-Tabelle komplett entfernen, wenn man sie nicht braucht.
   Für all dies muss man nur die Eingabe-Textdatei ändern.
 * Hochformat-Zaubertabelle mit nur den wesentlichsten Informationen und einer Spalte, in der man die Zeile im Liber angeben kann.
   Niemand braucht die Querformat-Tabelle.
   Außerdem wird automatisch eine zweite, dritte, … Seite erzeugt wenn man viele Zauber hat.
 * Frei und quelloffen: Der Quellcode ist unter einer freien Lizenz verfügbar und das Dokument kann komplett mit Open-Source-Software gebaut werden.
   Nur die verwendeten Bilder und Schriftarten unterliegen urheberrechtlichen Beschränkungen.
 * Berechnung abgeleiteter Werte:
   Abgeleitete Eigenschaften und berechenbare Werte auf dem Kampfbogen werden automatisch ausgefüllt, wenn die zugrundeliegenden Werte verfügbar sind.
   Ebenfalls automatisch berechnet wird die Lernschwierigkeit von Zaubern.
 * Blanko-Generierung:
   Für Spieler, die den Bogen lieber von Hand ausfüllen, kann ein leerer Bogen generiert werden.
   Die abgeleiteten Werte werden leer gelassen, wenn die zugrundeliegenden Werte leer sind.

## Wie generiere ich das Dokument?

Es gibt zwei Möglichkeiten:

 * Mit [Docker](https://www.docker.com): Dies ist ein Werzeug, um alle nötigen Werkzeuge reproduzierbar zusammenzustellen.
   Installiert man Docker, kann man ein *image* erstellen, in dem die benötigte Software enthalten ist.
   Mit diesem Image kann dann das Heldendokument generiert werden.
   Das Image ist portierbar zwischen Betriebssystemen, insbesondere Windows-Nutzern wird zu dieser Alternative geraten.
   Es liegt auch eine Definition für ein erweitertes Docker-Image bereit, das ein Web-Frontend zur Generierung bereitstellt – für Leute, die die Kommandozeile nicht mögen.

   Obwohl das Docker-Image portierbar ist, wird aus Urheberrechtsgründen kein fertiges Image bereitgestellt – die Lizenzen der Schriftarten und der benutzten Bilder erlauben dies nicht.
   Man kann das Image allerdings selbst ohne großen Aufwand erstellen.
 * Manuell mit [TeX Live](https://www.tug.org/texlive/) (oder einer anderen Tex-Distribution):
   Dies erfordert ein wenig Umgang mit der Kommandozeile.
   Windows-Nutzern wird dazu geraten, hierfür das Windows-Subsystem für Linux zu verwenden.

   Diese Alternative wird vor allem Benutzern empfohlen, die TeX ohnehin installiert haben.
   Muss man es extra dafür installieren, verbraucht man nicht arg viel weniger Speicher als mit der Docker-Variante.

### Docker

Docker muss installiert sein und laufen.
Die Schriftarten `Manson Regular.otf` und `Manson Bold.otf` müssen [hier](https://fontsgeek.com/manson-font) manuell heruntergeladen werden und direkt ins Hauptverzeichnis gelegt werden (ohne die Unterstruktur in der zip-Datei).
Alle anderen Abhängigkeiten werden automatisch heruntergeladen beim Bauen des Docker-Images.

Die Kommandozeilenversion lässt sich bauen mit

    make docker-bare

Dies generiert ein Image namens *dsa-4.1-heldendokument*.
Dieses benutzt man wiefolgt:

    cat templates/profan.lua | docker run -i --rm dsa-4.1-heldendokument > held.pdf

In diesem Beispiel wir als Datengrundlage das Template für einen profanen Helden, `templates/profan.lua` benutzt.
Statt dessen kann natürlich ein eigener Held eingegeben werden.

Das Docker-Image für das Web-Interface setzt voraus, dass *dsa-4.1-heldendokument* existiert.
Es kann folgendermaßen gebaut werden:

    make docker-server

Dies generiert ein Image namens *dsa-4.1-heldendokument-generator*.
Es kann folgendermaßen gestartet werden:

    docker run -p 80:80 --rm dsa-4.1-heldendokument-generator

Läuft dieser Befehl, kann das Webinterface im Browser unter http://localhost/ aufgerufen werden.
Das Webinterface ist minimal und dafür gedacht, den Inhalt der Helden-Datei ins Textfeld einzufügen und dann abzusenden.
Es eignet sich nicht als Editor und speichert die Eingabe nicht ab.
Die Generierung kann mehrere Minuten dauern.

### Manuell

Es muss TeX Live 2021 oder installiert sein.
Ältere Distributionen funktionieren nicht (betrifft aktuelles Debian).
Mac-User können [MacTeX](https://www.tug.org/mactex/) benutzen.

Zusätzlich müssen die Schriftarten [Manson](https://fontsgeek.com/manson-font) und [NewG8](https://github.com/probonopd/font-newg8/releases/tag/continuous) im System installiert sein, so dass sie von LuaTeX gesehen werden.
Für Mac-Nutzer bedeutet dies, dass sie systemweit, nicht nur für den aktuellen Benutzer, installiert sein müssen – dies lässt sich in den Einstellungen von *Font Book* festlegen.

Das Fanprodukt-Logo und der Hintergrund müssen von Ulisses heruntergeladen und an die korrekte Stelle gelegt werden.
Die folgenden Befehle nutzen unzip, curl, ImageMagick und poppler-utils, um dies zu tun – diese Werkzeuge sollten über jeden vernünftigen Paketmanager installierbar sein:

    # WdS-Handout herunterladen
    curl -L -s -o wds.pdf http://www.ulisses-spiele.de/download/468/
    # Hintergrundbild extrahieren
    pdfimages -f 2 -l 2 wds.pdf wds
    # Hintergrundbild in JPG umwandeln
    convert wds-000.ppm img/wallpaper.jpg

    # Fanpaket herunterladen
    curl -L http://www.ulisses-spiele.de/download/889/ -o fanpaket.zip
    # Die eine Datei aus dem Fanpaket entpacken
    unzip -p fanpaket.zip "Das Schwarze Auge - Fanpaket - 2013.07.29/Logo - Fanprodukt.png" >img/logo-fanprodukt.png

Danach kann das Heldendokument generiert werden, indem im `src`-Verzeichnis folgende Befehle ausgeführt wird:

    latexmk -c
    latexmk -lualatex='lualatex %O %S ../templates/profan.lua' heldendokument.tex

Der erste Befehl löscht vorherige Ausgaben und ist nötig, wenn im selben Verzeichnis bereits ein anderer Held generiert wurde.
Dieser Befehl erzeugt die Datei `heldendokument.pdf`.
Der Pfad `../templates/profan.lua` kann durch den Pfad zu einer beliebigen Heldendatei ersetzt werden.

## Eine Helden-Datei erstellen

Die Dateneingabe für den Helden ist eine simple Lua-Datei.
Als Ausgangspunkt sollten die Templates im Ordner `templates` verwendet werden.
Sie sind ausführlich kommentiert und erläutern, wie man Werte einfügt und verändert.

Die Templates selbst können als Eingabe benutzt werden, um leere Heldendokumente zu erstellen – falls man sie einfach ausdrucken und mit Bleistift befüllen will *wie die Barbaren*.
In den Templates sind ausschließlich die Basis-Talente vorausgefüllt.
Unabhängig davon, ob Zeilen in Tabellen ausgefüllt sind oder nicht, lässt sich die Anzahl Zeilen immer dadurch beeinflussen, dass man zusätzliche, möglicherweise leere, Zeilenwerte (meistens `{}`, siehe Templates) einfügt oder löscht.

## Lizenz

Der in diesem Repository enthaltene Code ist lizensiert unter der [LaTeX Project Public License](https://www.latex-project.org/lppl/).

**Wichtig:** Die verwendeten Schriftarten und Grafiken, die nicht Teil des Repositories sind, haben keine Lizenz, die die Weiterverbreitung erlaubt!
Deshalb wird weder ein fertiges Docker-Image noch ein fertiges Heldendokument zur Verfügung gestellt und dem Benutzer wird ebenfalls davon abgeraten, dies zu tun.

