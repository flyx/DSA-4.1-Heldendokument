# DSA 4.1 Heldendokument

Ein LuaLaTeX-basiertes DSA 4.1 Heldendokument, das sich am original Heldendokument orientiert.
Benutzerdokumentation ist auf [der Homepage des Projekts](https://flyx.github.io/DSA-4.1-Heldendokument/) verfügbar.
Dieses Readme enthält Entwicklerdokumentation.

## Nix als Buildsystem

Die Datei `flake.nix` definiert das Buildsystem.
Sie macht das Repository zu einer [Nix Flake](https://nixos.wiki/wiki/Flakes).
Dadurch können alle Abhängigkeiten automatisch geladen werden.

Prinzipiell ist es auch möglich, das Heldendokument manuell zu bauen, wenn auf dem System alle Abhängigkeiten verfügbar sind.
Es sei hierfür auf `dsa41held.sh.nix` verwiesen, das Template, aus dem das Skript `dsa41held` gebaut wird.
Dies ist die *single source of truth* dafür, mit welchen Argumenten das Dokument gebaut werden muss.

## Abhängigkeiten

Die offensichtliche Abhängigkeit ist [TeX Live](https://www.tug.org/texlive/), welches LuaLaTeX, `latexmk` und die benutzten LaTeX-Pakete zur Verfügung stellt.
Die Variable `tex` in der Datei `flake.nix` listet alle `tlmgr` Pakete auf, die man installieren muss, wenn man seine TeX Live installation manuell managed.

Darüber hinaus werden die Schriftarten *NewG8*, *Mason* und *Copse* benötigt.
Für den Bezug sei auf die in `flake.nix` gelisteten URLs verwiesen.
Es sei darauf hingewiesen, dass man für die Weiterverbreitung von Werken, die eine Schriftart benutzen, eine Lizenz für diese Schriftart braucht, die dies erlaubt.
Eine solche liegt nur für *Copse* vor, entsprechend wird davon abgeraten, erstellte PDFs weiterzuverbreiten.

Das Hintergrundbild wird aus dem WdS-Handout, das von Ulisses heruntergeladen wird, extrahiert.
Der `pdfimages`-Aufruf, der dies tut, findet sich in der `flake.nix`.
Das Hintergrundbild ist streng genommen eine optionale Abhängigkeit, da das Heldendokument auch mit weißem Hintergrund erzeugt werden kann.

Schließlich wird noch das „Fanprodukt“-Logo benötigt.
Dieses befindet sich im DSA 4.1 Fanpaket, das von Ulisses heruntergeladen wird.
Während das Hintergrundbild offenkundig nicht weiterverbreitet werden kann, hat das Fanpaket eine komplizierte Lizenz.
Da wir ohnehin bereits etabliert haben, dass Weiterverbreitung schon wegen der Schriftarten nicht legal ist, müssen wir uns hierüber keinen Kopf machen.

## Einzelheiten zum Aufbau der LaTeX-Quellen

Alle für das Dokument selbst relevante Quelldateien befinden sich im Ordner `src`.
Der Aufbau des Dokuments funktioniert folgendermaßen:

 * Die eingegebene Heldendatei wird in `values.lua` geladen.
   Dafür wird `schema.lua` verwendet, welches definiert, welche Werte in der Heldendatei stehen dürfen.
   Aus `schema.lua` wird auch die Formatspezifikation auf der Webseite autogeneriert.
 * `values.lua` appliziert alle Steigerungsereignisse.
   Zurückgegeben wird eine Lua-*table*, die neben den eingegebenen Daten auch *getter*-Funktionen für die verschiedenen berechneten Werte enthält (sie werden also nicht *einmal* berechnet, sondern jedes Mal, wenn darauf zugegriffen wird).
   `values.lua` kann auch außerhalb von LuaLaTeX verwenden werden und dies passiert auch, etwa für die Ereignisliste oder die Validierung.
 * Für die Dokumentgenerierung wird die *table*, die von `values.lua` erzeugt wird, über `data.lua` in die LaTeX-Quellen importiert.
   `data.lua` ist ein kleiner Hack, der es ermöglicht, die Heldendatei als zusätzlichen Parameter (neben der Hauptdatei `heldendokument.tex`) an `lualatex` zu übergeben.
   Über Lua wird auf die Kommandozeilenargumente zugegriffen und der Name der Heldendatei an `values.lua` weitergegeben.
 * Jede Seite des Heldendokuments ist eine eigene `.tex` Datei.
   Üblicherweise gehört zu der `.tex`-Datei eine gleichnamige `.lua`-Datei, die `data.lua` importiert und die Seite gemäß der gegebenen Konfiguration anpasst (z.B. Zeilenanzahl für Tabellen) und mit Daten füllt.
 * In `common.lua` importiert die Funktion `pages` die `.tex`-Dateien der gewünschten Seiten gemäß den Heldendaten.
   Dadurch werden nur genau die Seiten erzeugt, die gewünscht werden. 

Da das grafische Layout anspruchsvoll ist, muss LuaLaTeX dreimal über das ganze Dokument laufen, bis alles passt.
Das liegt daran, dass manche Längenwerte im Dokument, wie beispielsweise die Breite einer Tabelle, später feststehen (etwa, nachdem der ganze Inhalt eingefügt wurde) als sie gebraucht würden (der Hintergrund der Tabelle muss gezeichnet werden, bevor der Inhalt verarbeitet wird).
LaTeX legt diese Werte in temporären Dateien ab, sodass sie beim zweiten Durchlauf von dort geladen werden können.
Daher werden Tabellen mit Hintergrundfarbe frühestens beim zweiten Durchlauf korrekt gerendert.
`latexmk` lässt LuaLaTeX so lange das Dokument verarbeiten, bis sich diese Werte nicht mehr ändern.

## Einzelheiten des Heldensoftware-Imports

Das Import-Skript `import.xsl` ist in XSLT 1.0 geschrieben und sollte mit jeder konformen Implementierung funktionieren, also beispielsweise auch mit der in der Windows Powershell.
Getestet wird es allerdings nur mit `xsltproc`, weshalb zur Benutzung dieses Tools geraten wird.

Die Heldensoftware „kennt“ die ganzen Tabellen aus den Regelbüchern.
Das Heldendokument kennt diese nicht; man gibt etwa die Proben für Talente, die Werte von Waffen etc. komplett von Hand ein.
In einem Held der Heldensoftware steht also etwa, dass der Charakter einen Dolch hat, nicht aber die Werte des Dolchs (weil die der Software ja bekannt sind).
Der Import braucht also die ganzen Tabellen, um nachschauen zu können, welche Werte ein Dolch nun hat.
Die Tabellen dafür befinden sich in `heldensoftware-meta.xml`, von dort liest sie der Import aus.

Der Import ist relativ komplex und vermutlich nicht fehlerfrei.
Fehler im resultierenden Dokument oder auftretende Fehlermeldungen können gerne als Issues hier im Repository berichtet werden.

In den XML-Daten eines Helds aus der Heldensoftware stehen alle Steigerungsereignisse drin, theoretisch könnten die Ereignisse also als solche importiert werden.
Anders als in der Lua-Datei stehen im XML allerdings die aktuellen Werte des Helden, nicht die vor den Ereignissen.
Der Import müsste also alle Werte zurückrechnen, wenn Ereignisse importiert werden sollen.
Ich habe derzeit keine Intention, das zu implementieren – es ist schlicht zu viel Aufwand.

## Einzelheiten des Webinterface

Das Webinterface findet sich im Ordner `webui` und ist in Go geschrieben.
Es ruft für die einzelnen Aktionen `dsa41held` mit dem entsprechenden Kommando auf.

Der Fortschrittsbalken wird generiert, indem die LuaLaTeX-Ausgabe gelesen wird und nach den Namen der einzelnen importierten `.tex`-Datein gescannt wird.
Jedes Mal, wenn die nächste `.tex`-Datei eingelesen wird, läuft der Balken weiter.
Da bekannt ist, dass `latexmk` das Dokument drei Mal generiert, kann berechnet werden, wie viele Schritte der Balken hat basierend darauf, wie viele Seiten generiert werden.

## Lizenz

Der in diesem Repository enthaltene Code ist lizensiert unter der [LaTeX Project Public License](https://www.latex-project.org/lppl/).

**Wichtig:** Der Generator lädt bei der Erstellung mehrere Dateien herunter, welche keine freie Lizenz haben!
Dazu zählen die verwendeten Schriftarten und das Hintergrundbild.
Sei dir bewusst, dass daher sowohl das generierte Docker-image wie auch die generierten PDFs technisch gesehen Urheberrechtsbeschränkungen unterliegen und daher nicht verbreitet werden dürfen.
Du selbst darfst beides als Privatkopie verwenden; ich rate aber beispielsweise davon ab, das Webinterface öffentlich auf einem Server verfügbar zu machen.
Ich bin kein Anwalt und diese Anmerkungen stellen keine gültige Rechtsberatung dar.
