# DSA 4.1 Heldendokument

Ein DSA 4.1 Heldendokument, das sich am original Heldendokument orientiert.
Es kann bei der Erstellung optional mit Werten befüllt werden und berechnet dann abgeleitete Werte automatisch.
Helden aus der Heldensoftware können importiert werden.
Das Heldendokument wird als PDF mit LuaLaTeX erstellt.

Für ein leeres Heldendokument (zum Ausdrucken) kann eines der gegebenen Templates benutzt werden.
Jedes der Templates befüllt die Talentliste mit den Basis-Talenten (lässt aber natürlich den TaW frei).
Abhängig vom Charakter werden verschiedene Seiten erstellt (so hat etwa nur der Magier die Zauberliste).

Um das Heldendokument mit vollständigen Charakterdaten zu befüllen, müssen diese als Datei eingegeben werden.
Das erstellte PDF ist dann endgültig; ändern sich die Werte, müssen die Daten angepasst und ein neues PDF erstellt werden.
Die Daten werden in einem vorgegebenen Format eingegeben.
Es ist möglich, in den Daten die Startwerte des Helden und die Steigerungsaktionen einzugeben; das erstellte Dokument führt diese Steigerungsaktionen dann durch und gibt die resultierenden Werte aus.

Es ist möglich, aus einem exportierten Charakter aus der Heldensoftware eine Eingabedatei für das Heldendokument zu erstellen.
Nach dieser Konvertierung kann der Held auch durch Updaten jener Eingabedatei gesteigert werden statt in der Heldensoftware.
Das Heldendokument beherrscht im Wesentlichen dieselben Steigerungsregeln wie die Heldensoftware.

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

Das Heldendokument benutzt [nix Flakes](https://nixos.wiki/wiki/Flakes) als Buildsystem und zum Management von Abhängigkeiten.
`nix`-Benutzer, die auf ihrem System Flakes aktiviert haben, können Folgendes in einem Zielverzeichnis ihrer Wahl tun:

    nix build github:flyx/DSA-4.1-Heldendokument#dsa41held

Dies erzeugt ein Skript `result/bin/dsa41held`, das danach benutzt werden kann, um PDFs zu generieren, etwa:

    result/bin/dsa41held templates/profan.lua

Die Erstellung eines PDFs dauert etwas länger, auf meinem System (MBP M1 Pro 32GB) etwa 18 Sekunden.

### Docker & Webinterface

Da nicht jeder `nix` installiert hat, existiert ein einfaches Webinterface, das mit [Docker](https://www.docker.com) betrieben werden kann.
Dies ist insbesondere die empfohlene Herangehensweise für Windows-Nutzer.
Hierfür muss zunächst der Inhalt dieses Repositories heruntergeladen werden (entweder mit `git` oder über den grünen *Code*-Knopf unter *Download ZIP* und dann entpacken).
Außerdem muss Docker installiert sein.

Im Verzeichnis, in dem die heruntergeladenen Quellen liegen, muss dann in der Kommandozeile Folgendes eingegeben werden:

    docker build -f build.dockerfile -t dsa41held-build .
    docker run --rm dsa41held-build:latest > dsa41held-webui.tar
    docker load -i dsa41held-webui.tar

Diese Befehle erzeugen ein *image*, welches danach ähnlich wie eine Anwendung gestartet werden kann.
Für diejenigen, die Details wissen wollen:
Der erste Befehl erzeugt ein build-Image, das die Werkzeuge enthält, die für den Bau des Generators benötigt werden – insbesondere `nix`.
Der zweite Befehl führt im Wesentlichen den `nix`-Befehl, der oben beschrieben wird, im build-Image aus und exportiert das Resultat in die Datei `dsa41held-webui.tar`.
**Der zweite Befehl läuft mitunter einige Minuten, ohne Ausgabe zu produzieren; das ist normal**.
Der dritte Befehl lädt die erzeugte Datei als *image* in das Docker-Repository, sodass es in Zukunft ausgeführt werden kann – die `.tar`-Datei kann danach gelöscht werden.

Nun lässt sich das Webinterface mit folgendem Befehl starten:

    docker run -p 80:80 --rm dsa41held-webui:latest

Läuft dieser Befehl, ist das Webinterface im Browser unter `http://localhost/` verfügbar.

Das Webinterface ist minimal und dafür gedacht, den Inhalt der Helden-Datei ins Textfeld einzufügen und dann abzusenden.
Es eignet sich nicht als Editor und speichert die Eingabe nicht ab.
Die Generierung kann mehrere Minuten dauern, ein simpler Fortschrittsbalken wird währenddessen angezeigt.
Das Webinterface inkludiert die Option, einen Held aus der Heldensoftware zu importieren.

## Import von Helden aus der Heldensoftware

Der Held muss über in der Heldensoftware über `Datei > Exportieren > Held exportieren` exportiert werden.
Die erstellte XML-Datei (hier als Beispiel `held.xml`) kann dann folgendermaßen in Daten für den Heldenbogen (hier `held.lua`) transformiert werden:

    xsltproc import.xsl held.xml > held.lua

Das Import-Skript ist in XSLT 1.0 geschrieben und sollte mit jeder konformen Implementierung funktionieren, also beispielsweise auch mit der in der Windows Powershell.
Getestet wird es allerdings nur mit `xsltproc`, weshalb zur Benutzung dieses Tools geraten wird.
Windows-Nutzer seien auf das Webinterface verwiesen, welches im Hintergrund `xsltproc` benutzt.

Der Import ist relativ komplex und vermutlich nicht fehlerfrei.
Fehler im resultierenden Dokument oder auftretende Fehlermeldungen können gerne als Issues hier im Repository berichtet werden.

## Eine Helden-Datei selbst schreiben

Die Dateneingabe für den Helden geschieht über eine Lua-Datei.
Eine sehr rudimentäre Dokumentation der Struktur der Eingabedatei ist [hier](https://flyx.github.io/DSA-4.1-Heldendokument/) verfügbar.
Im Ordner `templates` finden sich Dateien mit Layouts für einen profanen Charakter (Frontseite, Talentbogen, Kampfbogen, Ausrüstungsbogen), einen geweihten Character (Liturgiebogen statt Ausrüstungsbogen) und einen magischen Character (zusätzlich Zauberdokument und Zauberliste).
Die Templates enthalten zudem die Basis-Talente – löscht man die entsprechenden Definitionen, hat man komplett unausgefüllte Tabellen auf dem Talentbogen.
Will man einen Bogen für einen Helden erstellen, empfiehlt es sich, eines der Templates als Ausgangspunkt zu nehmen.

Will man prüfen, ob eine Heldendatei Fehler enthält, lässt sich dies tun, indem man im Ordner `src` folgenden Befehl ausführt:

    texlua tools.lua validate ../templates/profan.lua

Der Pfad `../templates/profan.lua` muss durch den Pfad zur zu prüfenden Datei ersetzt werden.
Die Erstellung des PDFs führt dies automatisch als ersten Schritt aus.
`texlua` ist ein Werkzeug, das bei jeder TeX-Distribution dabei ist.

## Lizenz

Der in diesem Repository enthaltene Code ist lizensiert unter der [LaTeX Project Public License](https://www.latex-project.org/lppl/).

**Wichtig:** Der Generator lädt bei der Erstellung mehrere Dateien herunter, welche keine freie Lizenz haben!
Dazu zählen die verwendeten Schriftarten und das Hintergrundbild.
Sei dir bewusst, dass daher sowohl das generierte Docker-image wie auch die generierten PDFs technisch gesehen Urheberrechtsbeschränkungen unterliegen und daher nicht verbreitet werden dürfen.
Du selbst darfst beides als Privatkopie verwenden; ich rate aber beispielsweise davon ab, das Webinterface öffentlich auf einem Server verfügbar zu machen.
Ich bin kein Anwalt und diese Anmerkungen stellen keine gültige Rechtsberatung dar.
