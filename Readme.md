# DSA 4.1 Heldendokument

Ein DSA 4.1 Heldendokument, das sich am original Heldendokument orientiert.
Es kann bei der Erstellung mit Werten befüllt werden und berechnet dann abgeleitete Werte automatisch.
Helden aus der Heldensoftware können importiert werden.

Das Heldendokument wird als PDF mit LuaLaTeX erstellt.
Daten müssen zum Zeitpunkt der Erstellung eingegeben werden.
Ändern sich die Daten, muss ein neues PDF erstellt werden.
Das Dokument bietet keine interaktiven Features wie Heldenerstellung oder Steigerung.

## Features

### Allgemein

 * Da das erstellte PDF keine interaktiven Features hat, kann es in allen verbreiteten PDF-Readern korrekt angezeigt werden, insbesondere auf Tablets.
 * Alternierender Hintergrund pro Zeile bei vielen Tabellen für bessere Lesbarkeit.
   Das schließt beispielsweise Talente, Liturgien, Rituale und Zauber ein.
 * Hochformat-Zaubertabelle mit nur den wesentlichsten Informationen und einer Spalte, in der man die Seite im Liber Cantiones angeben kann.
   Niemand braucht die Querformat-Tabelle.
   Außerdem wird automatisch eine zweite, dritte, … Seite erzeugt wenn man viele Zauber hat.
 * Frei und quelloffen: Der Quellcode ist unter einer freien Lizenz verfügbar und das Dokument kann komplett mit Open-Source-Software gebaut werden.
   Nur die verwendeten Bilder und Schriftarten unterliegen urheberrechtlichen Beschränkungen.
 * Dynamische Größe von Tabellen:
   Die meisten Tabellen haben eine variable Anzahl an Zeilen.
   Man kann beispielsweise mehr Zeilen in gesellschaftlichen Talenten haben und dafür weniger Zeilen bei den Körperlichen – oder die „Gaben“-Tabelle komplett entfernen, wenn man sie nicht braucht.
   Dies kann in der Eingabe-Textdatei definiert werden.

### Werteingabe

 * Die Werte des Helden können in einer Textdatei gespeichert werden, aus der bei Änderungen immer wieder ein neues Dokument erstellt werden kann.
   Eine Textdatei hat einige Vorzüge gegenüber der PDF: Sie ist kleiner, man kann Änderungen besser nachvollziehen und sie kann besser in ein Versionskontrollsystem abgelegt werden.
   Die PDF kann aus der Textdatei mit den Daten immer wieder neu generiert werden.
 * Berechnung abgeleiteter Werte:
   Abgeleitete Eigenschaften und berechenbare Werte werden automatisch ausgefüllt, wenn die zugrundeliegenden Werte verfügbar sind.
   Dies schließt abgeleitete Eigenschaften, Kampfwerte und Lernschwierigkeiten von Zaubern ein.
 * Blanko-Generierung:
   Für Spieler, die den Bogen lieber von Hand ausfüllen, kann ein leerer Bogen generiert werden.
   Die berechneten Werte werden leer gelassen, wenn die zugrundeliegenden Werte leer sind.
   Die Definition von Tabellengrößen ist unabhängig von den enthaltenen Daten und kann auch für einen leeren Bogen spezifiziert werden.
 * Ein Import-Werkzeug steht bereit, um einen Helden aus der Heldensoftware in eine Eingabedatei für das Heldendokument umzuwandeln.

## Wie generiere ich das Dokument?

Um das Dokument zu generieren, braucht man eine Umgebung, in der alle benötigten Ressourcen und Programme verfügbar sind.
Es gibt zwei Möglichkeiten, eine solche Umgebung aufzusetzen:

 * Mit [Docker](https://www.docker.com): Dies ist ein Werzeug, um die gesamte Umgebung reproduzierbar einzurichten.
   Hat man Docker installiert, kann man damit ein *image* erstellen, in dem die benötigte Software enthalten ist.
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

Die nachfolgenden Anleitungen gehen davon aus, dass das DSA-4.1-Heldendokument komplett heruntergeladen und in einen Ordner entpackt wurde.

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

Das Docker-Image für das Web-Interface setzt voraus, dass *dsa-4.1-heldendokument* existiert, also der vorherige Schritt ausgeführt wurde.
Es kann folgendermaßen gebaut werden:

    make docker-server

Dies generiert ein Image namens *dsa-4.1-heldendokument-generator*.
Es kann folgendermaßen gestartet werden:

    docker run -p 80:80 --rm dsa-4.1-heldendokument-generator

Läuft dieser Befehl, kann das Webinterface im Browser unter http://localhost/ aufgerufen werden.
Das Webinterface ist minimal und dafür gedacht, den Inhalt der Helden-Datei ins Textfeld einzufügen und dann abzusenden.
Es eignet sich nicht als Editor und speichert die Eingabe nicht ab.
Die Generierung kann mehrere Minuten dauern, ein simpler Fortschrittsbalken wird währenddessen angezeigt.
Das Webinterface inkludiert die Option, einen Held aus der Heldensoftware zu importieren.

### Manuell

Es muss TeX Live 2021 oder neuer installiert sein.
Ältere Distributionen funktionieren nicht (betrifft aktuelles Debian).
Mac-User können [MacTeX](https://www.tug.org/mactex/) benutzen.

Zusätzlich müssen die Schriftarten [Manson](https://fontsgeek.com/manson-font), [NewG8](https://github.com/probonopd/font-newg8/releases/tag/continuous) und [Copse](https://www.fontsquirrel.com/fonts/copse) im System installiert sein, so dass sie von LuaTeX gesehen werden.
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
    latexmk heldendokument.tex

Der erste Befehl löscht vorherige Ausgaben und ist nötig, wenn im selben Verzeichnis bereits ein anderer Held generiert wurde.
Der zweite Befehl erzeugt die Datei `heldendokument.pdf` als leeres Heldendokument.
Um das Dokument mit Daten zu befüllen, muss zusätzlich der Pfad zu einer Heldendatei angegeben werden:

    latexmk -c
    latexmk -lualatex='lualatex %O %S ../templates/profan.lua' heldendokument.tex

Hier wird als Beispiel das Heldendokument aus dem Template für einen profanen Charakter generiert.
Der Pfad kann entsprechend verändert werden, um einen Dokument aus einer eigenen Heldendatei zu generieren.

## Eine Helden-Datei erstellen

Die Dateneingabe für den Helden geschieht über eine Lua-Datei.
Eine sehr rudimentäre Dokumentation der Struktur der Eingabedatei ist [hier](https://flyx.github.io/DSA-4.1-Heldendokument/) verfügbar.
Im Ordner `templates` finden sich Dateien mit Layouts für einen profanen Charakter (Frontseite, Talentbogen, Kampfbogen, Ausrüstungsbogen), einen geweihten Character (Liturgiebogen statt Ausrüstungsbogen) und einen magischen Character (zusätzlich Zauberdokument und Zauberliste).
Die Templates enthalten zudem die Basis-Talente – löscht man die entsprechenden Definitionen, hat man komplett unausgefüllte Tabellen auf dem Talentbogen.
Will man einen Bogen für einen Helden erstellen, empfiehlt es sich, eines der Templates als Ausgangspunkt zu nehmen.

Will man prüfen, ob eine Heldendatei Fehler enthält, lässt sich dies tun, indem man im Ordner `src` folgenden Befehl ausführt:

    texlua tools.lua validate ../templates/profan.lua

Der Pfad `../templates/profan.lua` muss durch den Pfad zur zu prüfenden Datei ersetzt werden.
Das Docker-Webinterface führt diesen Schritt automatisch auf der Eingabe durch.

### Import aus der Heldensoftware

Der Held muss über in der Heldensoftware über `Datei > Exportieren > Held exportieren` exportiert werden.
Die erstellte XML-Datei (hier als Beispiel `held.xml`) kann dann folgendermaßen in Daten für den Heldenbogen (hier `held.lua`) transformiert werden:

    xsltproc import.xsl held.xml > held.lua

Das Import-Skript ist in XSLT 1.0 geschrieben und sollte mit jeder konformen Implementierung funktionieren, also beispielsweise auch mit der in der Windows Powershell.
Getestet wird es allerdings nur mit `xsltproc`, weshalb zur Benutzung dieses Tools geraten wird.

Der Docker-Server bietet diese Funktion auf seinem Webinterface ebenfalls an.

Der Import ist ein Beta-Feature und wenig getestet.
Fehler im resultierenden Dokument oder auftretende Fehlermeldungen können gerne als Issues hier im Repository berichtet werden.

## Lizenz

Der in diesem Repository enthaltene Code ist lizensiert unter der [LaTeX Project Public License](https://www.latex-project.org/lppl/).

**Wichtig:** Die verwendeten Schriftarten und Grafiken, die nicht Teil des Repositories sind, haben keine Lizenz, die die Weiterverbreitung erlaubt!
Deshalb wird weder ein fertiges Docker-Image noch ein fertiges Heldendokument zur Verfügung gestellt und dem Benutzer wird ebenfalls davon abgeraten, dies zu tun.

