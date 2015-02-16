DSA Heldendokument
==================

Dies ist eine Portierung des Original DSA Heldendokuments nach LaTeX. Am
Aufbau wurden einige kleinere Änderungen vorgenommen, aber der Großteil des
Layouts ist mit dem Original identisch.

Neben den unten aufgeführten Abweichungen vom Original ist der Vorteil dieses
Dokuments vor allem, dass es auf die Bedürfnisse einzelner Charaktere angepasst
werden kann. So können beim Erstellen des Dokuments etwa die Anzahl Zeilen bei
den einzelnen Talentkategorien angepasst werden, ebenso bei Nah- und
Fernkampfwaffen und so weiter.

Da nicht davon ausgegangen wird, dass der durchschnittliche DSA-Spieler mit
LaTeX umgehen kann, wird der Einfachheit halber ein Klickibunti-Tool beigelegt,
in dem man die einzelnen Einstellungen tätigen kann und welches dann das
Dokument automatisch erstellt. Dieses ist momentan allerdings noch nicht
fertig.

Um das Dokument manuell zu erstellen, braucht man eine POSIX-Umgebung.
Windows-Nutzer könnten es mit [babun][1] / [Cygwin][2] probieren, ob das tut,
weiß ich nicht. Weiterhin müssen folgende Werkzeuge verfügbar sein:

 * Make
 * [TeX Live][3] (andere TeX-Distributionen habe ich nicht getestet)
 * [acrotex][4] (nicht in TeX Live enthalten)
 * [Python][5] 2.7 oder höher; 3.x habe ich nicht getestet.
 * [pystache][6]
 * [PyYAML][7]
 * [ImageMagick][8]
 * [poppler-utils][9]
 * Die Schriftart [Garamond No. 8][10]
 * Die Schriftart Manson. Diese ist im Internet verfügbar, jedoch macht die
   Quelle einen etwas fragwürdigen Eindruck, deshalb möchte ich sie hier
   nicht verlinken. Google hilft.

Das PDF kann mit folgendem Befehl im Stammverzeichnis erstellt werden:

    $ make

Wer diese Werkzeuge auf seinem System nicht installieren kann oder will, der
kann sich statt dessen auch mit der mitgelieferten Definition eine
virtuelle Maschine bauen, auf der alles Notwendige direkt verfügbar ist;
näheres dazu siehe unten.

Änderungen gegenüber dem ursprünglichen Dokument
------------------------------------------------

### Allgemein

 * Die Texteingabe benutzt durchgängig eine einheitliche Schriftart,
   nämliche [Garamond No. 8][10]. Die Texteingaben sitzen auch ordentlich
   in der Zeile im Dokument und hängen nicht wie im Original oben am
   Trennstrich.
 * Das Hintergrundbild ist etwas heller. Das kommt daher, dass das
   Original-Hintergrundbild nicht Teil des von Ulisses veröffentlichten
   Fanpakets ist und nicht roh aus einer PDF von Ulisses extrahiert werden
   kann. Das verwendete Hintergrundbild wird aus den Handouts zu WdS, die
   Ulisses online zur Verfügung stellt, extrahiert, und dort ist das Bild
   etwas heller. Es besteht auch die Möglichkeit, das Dokument mit alternativem
   oder ganz ohne Hintergrund zu generieren.

### Frontseite:

 * Fanprodukt-Logo statt DSA-Logo
 * Modifikationen entfernt, die stehen eh bei den Eigenschaften unten dran
 * Tsatag (Geburtstag) statt Alter, denn der ändert sich nicht.
 * Genug Platz für den Titel, damit auch der eitle Magier seinen Titel
   unterbringen kann.
 * Familie / Herkunft / Hintergrund entfernt; der Platz reicht dafür sowieso
   nicht. Gehört auf einen eigenen Zettel.
 * Wappen / Portrait entfernt. Ist auch sinnvoller auf einem eigenen Zettel.
 * Aussehen in eigene Box, damit mehr Platz dafür ist
 * Vorteile und Nachteile getrennt
 * Statt **Max. Zug.** gibt es eine Spalte **Permanent**, in der man die
   verlorenen permanenten AsP, KaP, LeP und AuP dokumentieren kann. Das Maximum
   der zukaufbaren Punkte lässt sich aus dem Startwert errechnen, bei den
   Eigenschaften steht das ja auch nicht dabei.

### Talentbogen

 * Es gibt eine zusätzliche Spalte **M**, in der Magiedilletanten ihr
   Meisterhandwerk markieren können und Geweihte ihre Mirakel+ / Mirakel-
   Talente.
 * Alle Zeilen sind editierbar, auch die mit den vorausgefüllten Basistalenten.
 * Der TaW hat nur noch eine Spalte, der Sinn der zweiten Spalte ist unbekannt.
 * Die drei Eigenschaften für die Talentprobe sind nun einzelne Felder; die
   Trennpunkte sind Teil des PDFs.

### Kampfbogen
 
 * Weniger Kästchen für Bruchfaktor und Geschosse, die ursprüngliche Anzahl
   erschien etwas viel.
 * Keine Zeile für Initiative, da sich die BE je nach Situation ändern kann
   und dem Spieler zuzutrauen ist, in einem Kampf die zutreffende BE im Kopf
   von seinem Initiativewert abzuziehen.

### Ausrüstungsbogen

 * Layout ein wenig geändert

### Ausrüstung und Liturgien

 * Layout ein wenig geändert

### Zauberliste

 * Name / Rasse / Kultur / Profession entfernt (was sollten die da?)
 * AE / AU / LE entfernt; gibts schon auf dem Kampfbogen und wird eh meist
   auf eigenem Blatt notiert
 * Die furchtbar widerliche „2“ durch ein ordentlich gesetztes „Seite 2“
   ersetzt. Davon bekam man Augenkrebs!

### Zauberdokument

 * Hochkant statt Querformat
 * AE und MR Berechnung entfernt, das kann man wie alles andere auch auf der
   Frontseite machen, wenn sie Eigenschaften / Sonderfertigkeiten ändern und
   braucht man in diesem Detail nicht notiert.

Benutzung
---------

Das Dokument lässt sich befüllen, wenn man es mit dem [Adobe Reader][11]
öffnet. Auch wenn es bessere und freiere Alternativen gibt, ist der Adobe
Reader universal verfügbar und damit das primäre Zielsystem. Andere
PDF-Betrachter stellen die Eingabefelder möglicherweise geringfügig anders
dar; das Vorschau-Programm von OSX etwa setzt den eingegebenen Text seit
OSX 10.10 überall etwas zu hoch.

Wenn man den Charakterbogen auf einem mobilen Gerät (Tablet etc.) benutzen
will, empfiehlt es sich, ihn nach dem Ausfüllen auf einem PDF-Drucker zu
drucken und das gedruckte PDF auf das Tablet zu übertragen, denn viele
mobile PDF-Betrachter haben Probleme mit ausfüllbaren PDFs.

Es ist theoretisch möglich, die Textfelder automatisch aus einer anderen
Quelle, zum Beispiel dem Heldenprogramm, zu befüllen. Wer so etwas realisieren
will, findet in der Datei `data/eingabefelder.yaml` eine Liste mit den Namen
aller Eingabefelder im Dokument.

Erstellung mit einer VM
-----------------------

Um die virtuelle Maschine auf deinem System erstellen zu können, brauchst du:

 * [VirtualBox][15]: VirtualBox Laufzeitumgebung, in der die virtuelle Maschine
   ausgeführt wird. Bei der Installation empfehle ich, die Option 
   „Bridged Networking” zu deaktivieren - die installiert dir nur einen
   unnötigen Netzwerkadapter. Auch USB-Unterstützung brauchst du nicht.
 * [Vagrant][16]: Das Tool, das die virtuelle Maschine zusammenbaut.
 * [PuTTY][17]: Nur Windows-User. Brauchst du, um auf der VM was zu machen.
   Es reicht, `putty.exe` herunterzuladen.
 * Die Schriftart Manson, genauer gesagt diese beiden Dateien:
   - `MansonRegular.ttf`
   - `MansonBold.ttf`
   Google hilft. Lege sie in den Ordner `vagrant-vm`.

Öffne eine Kommandozeile und navigiere in den Ordner `vagrant-vm`. Führe dort
folgenden Befehl aus:

    vagrant up

Beim ersten Aufruf wird dieser Befehl eine virtuelle Maschine erstellen und
alle nötigen Programme darauf installieren. Das kann je nach Rechner eine
Viertel- bis halbe Stunde dauern. Die VM wird 2GB Speicherplatz einnehmen
und wird in dem Ordner angelegt, der in VirtualBox als Standard-Ordner für
VMs angegeben ist.

Wenn der Befehl durchgelaufen ist, läuft die virtuelle Maschine im Hintergrund.
Sie hat keine grafische Oberfläche, du kannst sie nur über die Kommandozeile
erreichen. Alle außer Windows-Nutzer können sich nun mit folgendem Befehl auf
der virtuellen Maschine einloggen:

    vagrant ssh

Windows-Nutzer können das auch, sofern sie [babun][1] / [Cygwin][2] nutzen.
Ansonsten benutzen sie [PuTTY][17]: Der Hostname ist *127.0.0.1*, der Port
*2222*, Benutzername und Passwort jeweils *vagrant*. Wenn die Verbindung
mit der VM erfolgreich war, können nun folgende Befehle ausgeführt werden:

    cd /dsa
    make

Danach sollte die Datei `heldendokument.pdf` erstellt worden sein. Die
Verbindung zur VM kann nun wieder geschlossen werden - und die VM selbst
sollte heruntergefahren werden, weil sie sonst nur unnötig Ressourcen
verbraucht:

    vagrant halt

Wenn sie das nächste Mal wieder hochgefahren wird, geht das deutlich schneller,
weil sie ja nun schon eingerichtet ist. Der Befehl, um sie komplett zu
zerstören und vom System zu entfernen ist:

    vagrant destroy

Lizenz
------

Der komplette Quellcode ist unter der Lizenz
[Creative Commons BY-NC-SA 4.0][12] lizensiert. Die Silhouette, die auf dem
Kampfbogen des Heldendokuments benutzt wird, stammt von [Michael Binder][13]
und steht unter der [Creative Commons BY-SA 3.0 DE][14] Lizenz. **Wer einen
Charakterbogen mit dem Original-Hintergrund erstellt, muss sich im Klaren
darüber sein, dass er diesen nicht öffentlich verbreiten darf, da Ulisses
diese Nutzung nicht erlaubt**. Die Erstellung des Charakterbogens ist natürlich
erlaubt, denn privat darf man mit urheberrechtlich geschütztem Material machen,
was man will, solange man es nicht verbreitet.


 [1]: http://babun.github.io
 [2]: https://www.cygwin.com
 [3]: https://www.tug.org/texlive/
 [4]: https://www.ctan.org/pkg/acrotex
 [5]: https://www.python.org
 [6]: https://github.com/defunkt/pystache
 [7]: http://pyyaml.org
 [8]: http://www.imagemagick.org
 [9]: http://wiki.ubuntuusers.de/poppler-utils
 [10]: http://garamond.org
 [11]: http://get.adobe.com/de/reader/
 [12]: http://creativecommons.org/licenses/by-nc-sa/4.0/
 [13]: https://github.com/thinkingstone
 [14]: https://creativecommons.org/licenses/by-sa/3.0/de/
 [15]: https://www.virtualbox.org/wiki/Downloads
 [16]: http://www.vagrantup.com/downloads.html
 [17]: http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html