# DSA 4.1 Heldendokument

Ein LuaLaTeX-basiertes DSA 4.1 Heldendokument, das sich am original Heldendokument orientiert.
Benutzerdokumentation ist auf [der Homepage des Projekts](https://flyx.github.io/DSA-4.1-Heldendokument/) verfügbar.
Dieses Readme beschreibt die zugrundeliegende Magie.

## Installation und Benutzung mit nix

Der Heldendokument-Generator benutzt [nix Flakes](https://nixos.wiki/wiki/Flakes) als Buildsystem und zum Management von Abhängigkeiten.
`nix` kann auf Linux-Systemen und macOS installiert werden. Es wird mindestens Version 2.4 benötigt, um Flakes benutzen zu können.
Für die Installation sei auf die [offizielle Anleitung](https://nixos.org/guides/install-nix.html) verwiesen.
Wie im oben verlinkten Artikel zu Flakes beschrieben, muss eine `nix.conf`-Datei angepasst werden, um Flakes zu aktivieren.

Ist `nix` installiert und Flakes aktiviert, kann der Generator direkt (ohne manuellen Download) mit diesem Befehl gebaut werden:

    nix build github:flyx/DSA-4.1-Heldendokument#dsa41held

Dies erzeugt ein Skript `result/bin/dsa41held` (und sollte entsprechend in einem schreibbaren Verzeichnis ausgeführt werden).
Dieses Script kann danach benutzt werden, um PDFs aus Eingabedatein zu generieren, etwa:

    result/bin/dsa41held templates/profan.lua

(Das Template kann aus dem Repository bezogen werden.)
Mit `-w` kann ein Dokument mit weißem Hintergrund erstellt werden:

    result/bin/dsa41held -w templates/magier.lua

Die Erstellung eines PDFs dauert auf meinem System (MBP M1 Pro 32GB) etwa 18 Sekunden.
Wer statt der enormen LuaLaTeX-Ausgabe lieber einen Fortschrittsbalken haben möchte, sollte das Webinterface benutzen.

Das Webinterface kann gebaut werden mit

    nix build github:flyx/DSA-4.1-Heldendokument#dsa41held-webui

Danach kann es folgendermaßen gestartet werden:

    result/bin/webui

Es ist dann im Browser unter `http://localhost/` verfügbar.
Beendet wird es mittels Ctrl+C.

Das Docker-Image kann nur auf amd64-Systemen gebaut werden.
Der Befehl dafür ist folgender:

    nix build github:flyx/DSA-4.1-Heldendokument#dsa41held-webui-docker

Dies erzeugt `result`, was ein *tar.gz*-Archiv ist.
Man lädt es in Docker mit

    gunzip -c result | docker load

## Import von Helden aus der Heldensoftware

Der Held muss über in der Heldensoftware über `Datei > Exportieren > Held exportieren` exportiert werden.
Die erstellte XML-Datei (hier als Beispiel `held.xml`) kann dann folgendermaßen in Daten für den Heldenbogen (hier `held.lua`) transformiert werden:

    xsltproc import.xsl held.xml > held.lua

Das Import-Skript ist in XSLT 1.0 geschrieben und sollte mit jeder konformen Implementierung funktionieren, also beispielsweise auch mit der in der Windows Powershell.
Getestet wird es allerdings nur mit `xsltproc`, weshalb zur Benutzung dieses Tools geraten wird.
Windows-Nutzer seien auf das Webinterface verwiesen, welches im Hintergrund `xsltproc` benutzt.

Der Import ist relativ komplex und vermutlich nicht fehlerfrei.
Fehler im resultierenden Dokument oder auftretende Fehlermeldungen können gerne als Issues hier im Repository berichtet werden.

## Sonstige Tools

### Validator

TODO: Mache dies über Nix verfügbar

Will man prüfen, ob eine Heldendatei Fehler enthält, lässt sich dies tun, indem man im Ordner `src` folgenden Befehl ausführt:

    texlua tools.lua validate ../templates/profan.lua

Der Pfad `../templates/profan.lua` muss durch den Pfad zur zu prüfenden Datei ersetzt werden.
Die Erstellung des PDFs führt dies automatisch als ersten Schritt aus.
`texlua` ist ein Werkzeug, das bei jeder TeX-Distribution dabei ist – statt dessen lässt sich auch `lua` verwenden.

### Ereignisse

Benutzt man die Ereignisse in der Eingabedatei, um den Helden zu steigern, will man vermutlich nicht jedes Mal das PDF bauen, um zu sehen, wie viele AP man noch übrig hat.
Das Paket `dsa41held` stellt deshalb neben dem eigentlichen Generator auch ein Tool `ereignisse` zur Verfügung.
Beispiel des Aufrufs nach `nix build github:flyx/DSA-4.1-Heldendokument#dsa41held`:

    result/bin/ereignisse mein_held.lua

Es wird dann auf der Kommandozeile eine Liste aller Ereignisse mit laufendem AP-Guthaben ganz hinten ausgegeben.

## Lizenz

Der in diesem Repository enthaltene Code ist lizensiert unter der [LaTeX Project Public License](https://www.latex-project.org/lppl/).

**Wichtig:** Der Generator lädt bei der Erstellung mehrere Dateien herunter, welche keine freie Lizenz haben!
Dazu zählen die verwendeten Schriftarten und das Hintergrundbild.
Sei dir bewusst, dass daher sowohl das generierte Docker-image wie auch die generierten PDFs technisch gesehen Urheberrechtsbeschränkungen unterliegen und daher nicht verbreitet werden dürfen.
Du selbst darfst beides als Privatkopie verwenden; ich rate aber beispielsweise davon ab, das Webinterface öffentlich auf einem Server verfügbar zu machen.
Ich bin kein Anwalt und diese Anmerkungen stellen keine gültige Rechtsberatung dar.
