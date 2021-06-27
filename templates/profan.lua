--------------------------------------------------------------------------------
--  Vorlage Profaner Charakter
--------------------------------------------------------------------------------
--  Allgemeine Hinweise:
--
--  Diese Datei ist eine Eingabe, mit der über heldendokument.tex ein
--  Heldendokument für einen profanen Charakter erstellt werden kann.
--  Alle Felder sind standardmäßig leer, nur die Basis-Talente sind
--  vorausgefüllt. Wenn gewünscht, können die Werte eines Charakters in diese
--  Datei eingegeben werden, um ein Heldendokument für diesen Charakter zu
--  erstellen.
--
--  Diese Datei ist in der Programmiersprache Lua geschrieben. Aller
--  Zeileninhalt, der auf zwei Minusse -- folgt, ist ein Kommentar und für die
--  Programmiersprache nicht relevant.
--
--  Textuelle Werte müssen von Hochkommas oder doppelten eckigen Klammern
--  umschlossen werden: "Beispiel", [[Beispiel2]]
--  Zahlenwerte müssen ohne Hochkommas eingegeben werden: 42.
--  Tabellenwerte werden von {} umschlossen und enthalten kommagetrennte,
--  möglicherweise benannte Werte. Beim Editieren muss die bestehende
--  Tabellenstruktur beibehalten werden, es dürfen beispielsweise keine
--  Tabellen durch textuelle oder Zahlenwerte ersetzt werden. Auch dürfen die
--  Namen von benamten Werten nicht geändert werden.
--
--  Textuelle Werte, die mehrere Zeilen umfassen können, können als einzelner
--  Wert oder als Tabelle eingegeben werden. Folgende beiden Werte fürs Aussehen
--  sind etwa identisch:
--
--    "kurzes Haar, dunkler Teint"
--    {"kurzes Haar", "dunkler Teint"}
--
--  In Tabellenform kann man eine neue Zeile forcieren, indem man eine leere
--  Tabelle vor den Wert, der in einer neuen Zeile stehen soll, schreibt:
--
--    {"kurzes Haar", {}, "dunkler Teint"}
--
--  Ausgabe:
--
--    kurzes Haar
--    dunkler Teint
--
--  Es wird in diesem Fall kein Komma zwischen die Werte gesetzt, so wie es
--  sonst passieren würde. In einer Tabelle kann man außerdem den benamten Wert
--  `zeilen` setzen, um zu beeinflussen, wie viele Zeilen im Dokument erzeugt
--  werden:
--
--    {"kurzes Haar", {}, "dunkler Teint", zeilen=5}
--
--  Dies funktioniert für alle mehrzeiligen Werte außer den Titel des Helden,
--  der immer 4 Zeilen lang ist.
--
--  In Listen (Talentliste, Ausrüstungsliste etc) stehen oftmals leere Tabellen:
--
--    natur = {
--      {"Fährtensuchen", "KL", "IN", "IN", ""},
--      {"Orientierung",  "KL", "IN", "IN", ""},
--      {"Wildnisleben",  "IN", "GE", "KO", ""},
--      {}, {}, {}, {}
--    },
--
--  Jede leere Tabelle {} erzeugt eine leere Zeile. Auf diese Weise kann die
--  Anzahl Zeilen in einer Tabelle bestimmt werden. Mehrzeilige Textwerte
--  (Aussehen, Vorteile, Kleidung etc) haben dagegen eine feste Anzahl Zeilen.

Layout {
  Front {},
  Talentliste {
    Sonderfertigkeiten(6),
    Gaben(2),
    Kampf(13),
    Koerper(17),
    Gesellschaft(9),
    Natur(7),
    Wissen(17),
    Sprachen(10),
    Handwerk(15)
  },
  Kampfbogen {},
  Ausruestungsbogen {},
  Liturgiebogen {},
  Zauberdokument {},
  Zauberliste {}
}

Held {
  Name = "Testos Testeros",
  Stand = "Hoch",
}

Vorteile {
  "Gebildet 5", "Flink"
}

Vorteile.magisch {
  "Nix"
}

Nachteile {
  "Gerechtigkeitswahn 10", "Behäbig", "Glasknochen"
}

Eigenschaften {
  MU = {3, 4, 5},
  KK = {3, 12, 14},
  GE = {-2, 10, 9},
}

AP {
  Gesamt = 42,
  Eingesetzt = 23,
}

Talente.Gaben {
}

Talente.Kampf {
  {"Dolche",                "D", "BE-1", "", "", ""},
  {"Hiebwaffen",            "D", "BE-4", "", "", ""},
  {"Raufen",                "C", "BE",   0, 0, 0},
  {"Ringen",                "D", "BE",   0, 0, 0},
  {"Wurfmesser",            "C", "BE-3", "", "", ""}
}

Talente.Koerper {
  {"Athletik",           "GE", "KO", "KK", "BEx2", ""},
  {"Klettern",           "MU", "GE", "KK", "BEx2", ""},
  {"Körperbeherrschung", "MU", "IN", "GE", "BEx2", ""},
  {"Schleichen",         "MU", "IN", "GE", "BE",   ""},
  {"Schwimmen",          "GE", "KO", "KK", "BEx2", ""},
  {"Selbstbeherrschung", "MU", "KO", "KK", "-",    ""},
  {"Sich Verstecken",    "MU", "IN", "GE", "BE-2", ""},
  {"Singen",             "IN", "CH", "CH", "BE-3", ""},
  {"Sinnesschärfe",      "KL", "IN", "IN", "-",    ""},
  {"Tanzen",             "CH", "GE", "GE", "BEx2", ""},
  {"Zechen",             "IN", "KO", "KK", "-",    ""},
}

Talente.Gesellschaft {
  {"Menschenkenntnis", "KL", "IN", "CH", ""},
  {"Überreden",        "MU", "IN", "CH", ""},
}

Talente.Natur {
  {"Fährtensuchen", "KL", "IN", "IN", ""},
  {"Orientierung",  "KL", "IN", "IN", ""},
  {"Wildnisleben",  "IN", "GE", "KO", ""},
}

Talente.Wissen {
  {"Götter / Kulte",            "KL", "KL", "IN", ""},
  {"Rechnen",                   "KL", "KL", "IN", ""},
  {"Sagen / Legenden",          "KL", "IN", "CH", ""},
}

Talente.Sprachen {
  {"Muttersprache: ", "", ""},
}

Talente.Handwerk {
  {"Heilkunde Wunden", "KL", "CH", "FF", ""},
  {"Holzbearbeitung",  "KL", "FF", "KK", ""},
  {"Kochen",           "KL", "IN", "FF", ""},
  {"Lederarbeiten",    "KL", "FF", "FF", ""},
  {"Malen / Zeichnen", "KL", "IN", "FF", ""},
  {"Schneidern",       "KL", "FF", "FF", ""},
}

SF {
  "Kulturkunde (Almada)"
}

SF.Nahkampf {
  Ausweichen {I, II},
  "Kampfgespür", "Wuchtschlag",
  Schildkampf {I},
}

SF.Fernkampf {
  "Scharfschütze (Bogen)"
}

SF.Waffenlos {
  Kampfstile {
    ["Bornländisch"] = "Ringen",
    ["Gladiatorenstil"] = "Raufen",
  },
  "Griff", "Fußfeger"
}

SF.Magisch {
  "Gefäß der Sterne", "Zauberkontrolle"
}

Waffen.Nahkampf {
  {"Dolch", "Dolche", "H", "1W+1", 12, 5,  0,    0, -1, 0, 0}
}

Waffen.Fernkampf {
  {"Leichte Armbrust", "Armbrust", "1W+6", 1, 0, 0, 0, -1, 1, 0, 0, -1, -2, "", "", ""}
}

Waffen.Schilde {
  {"Lederschild", "Schild",  -1,  3, 2, "", ""}
}

Waffen.Ruestung {
  {"Garether Platte", 4.7, 3.7, Brust=6, Ruecken=5, Bauch=6, LArm=5, RArm=5, LBein=4, RBein=4}
}

Magie.Rituale {
  {[[Schlaf rauben]], "", "", "", "", "", ""},
  {[[Ängste mehren]], "", "", "", "", "", ""},
  {[[Hexensalbe]], "", "", "", "", "", ""},
}

Magie.Ritualkenntnis {
  {"Hexe", 5}
}

Magie.Artefakte {
  "Arr", "Tee", "Fuck", "Tee"
}

Magie.Repraesentationen {
  "Hex"
}

Magie.Merkmalskenntnis {
  "Limbus", "Metamagie"
}

Magie.Zauber {
  {"", [[Abvenenum reine Speise]], "KL", "KL", "FF", 5, "C", {}, "Hex"},
  {"", [[Ängste lindern]], "MU", "IN", "CH", 5, "C", {}, "Hex", true},
  {"", [[Attributo]], "KL", "CH", "**", 2, "B", {}, "Hex"},
  {"", [[Beherrschung brechen]], "KL", "IN", "CH", 3, "C", {}, "Hex"},
  {"", [[Eigenschaft wiederherstellen]], "KL", "IN", "CH", 4, "C", {}, "Hex", true},
  {"", [[Einfluss bannen]], "IN", "CH", "CH", 3, "B", {}, "Hex"},
  {"", [[Harmlose Gestalt]], "KL", "CH", "GE", 3, "C", {}, "Hex"},
  {"", [[Hexenblick]], "IN", "IN", "CH", 7, "B", {"Limbus"}, "Hex", true},
  {"", [[Hexenholz]], "KL", "FF", "KK", 5, "B", {}, "Hex", true},
  {"", [[Hexenknoten]], "KL", "IN", "CH", 2, "C", {}, "Hex"},
  {"", [[Hexenspeichel]], "IN", "CH", "FF", 10, "C", {}, "Hex", true},
  {"", [[Klarum Purum]], "KL", "KL", "CH", 10, "D", {}, "Hex"},
  {"", [[Krähenruf]], "MU", "CH", "CH", 2, "C", {}, "Hex"},
  {"", [[Krötensprung]], "IN", "GE", "KK", 7, "B", {}, "Hex"},
  {"", [[Pestilenz erspüren]], "KL", "IN", "CH", 7, "C", {}, "Hex"},
  {"", [[Radau]], "MU", "CH", "KO", 2, "C", {"Metamagie"}, "Hex"},
  {"", [[Sanftmut]], "MU", "CH", "CH", 7, "B", {}, "Hex", true},
  {"", [[Tiere besprechen]], "MU", "IN", "CH", 7, "C", {}, "Hex", true},
  {"", [[Verwandlung beenden]], "KL", "CH", "FF", 2, "D", {}, "Hex"},
}