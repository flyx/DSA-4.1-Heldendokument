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
  Ausruestungsbogen {}
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

return {
  --  Kann auf true gesetzt werden, um allen Talenten eine Spalte betitelt mit
  --  M hinzuzufügen. Diese ist dafür gedacht, benutzt zu werden, um
  --  Meisterhandwerk-Talente zu markieren sowie Mirakel+ und Mirakel-.
  --  Die M-Spalte ist gerade breit genug für ein Zeichen.
  --  Soll ein Talent einen Eintrag in der M-Spalte haben, muss hinter dem
  --  Talentwert ein mit `m` benamter Eintrag hinzugefügt werden. Beispiel:
  --
  --      {"Athletik",           "GE", "KO", "KK", "BEx2", 0, m = "+"},
  m_spalte = false,

  --  Sonderfertigkeiten. Diese werden an verschiedene Stellen im Dokument
  --  verteilt.
  sf = {
    --  Drei Werte für Ausweichen I, II und III.
    ausweichen = {false, false, false},
    --  Diese drei Werte werden auf der Frontseite angezeigt.
    gefaess_der_sterne = false,
    kampfgespuer = false,
    kampfreflexe = false,
    --  Auf dem Kampfbogen
    linkhand = false,
    --  Zwei Werte für Parierwaffen I und II.
    parierwaffen = {false, false},
    --  Drei Werte für Rüstungsgewöhnung I, II und III.
    ruestungsgewoehnung = {false, false, false},
    --  Zwei Werte für Parierwaffen I und II.
    schildkampf = {false, false},
    --  Kampfstile. Diese müssen speziell angegeben werden:
    --    kampfstil = {
    --      ["Bornländisch"] = "Ringen",
    --      ["Gladiatorenstil"] = "Raufen",
    --    }
    --  Vorne steht der Name des Kampfstils innerhalb von ["…"].
    --  Hinten steht, bei welchem Talent AT und PA um je 1 verbessert werden.
    --  Dies wird beim Berechnen der waffenlosen AT/PA mit eingerechnet.
    kampfstil = {},

    --  Die weiteren Sonderfertigkeiten werden nicht für Berechnungen benutzt
    --  und können frei als mehrzeilige Werte angegeben werden.

    --  Mehrzeilig, standardmäßig 6 Zeilen.
    allgemein = "",
    --  Mehrzeilig, standardmäßig 3 Zeilen.
    nahkampf = "",
    --  Mehrzeilig, standardmäßig 3 Zeilen.
    fernkampf = "",
    --  Mehrzeilig, standardmäßig 2 Zeilen.
    waffenlos = "",
    --  Mehrzeilig, standardmäßig 5 Zeilen.
    magisch = "",
  },
  --  Nahkampfwaffen. Beispiel:
  --
  --    {"Dolch", "Dolche", "H", "1W+1", 12, 5,  0,    0, -1, 0, 0}
  --     <Name>   <Art>     <DK> <TP>    <TP/KK> <INI> <WM>   <BF>
  --
  --  <Art> muss der Name eines Kampftalents sein. Die restlichen Werte werden
  --  auf Basis der Art berechnet (insbesondere die eBE wird über den BE-Wert
  --  des referenzierten Talents gesetzt und fließt dann auch in AT und PA ein).
  --  Entspricht der gegebene Name der Waffe nicht der Art der Waffe
  --  (beispielsweise wenn der Held die persönliche Axt 'Haarspalter' führt, die
  --  eine Orknase ist), dann kann zum Schluss `art="Orknase"` gesetzt werden.
  --  Die Waffenart wird nicht auf dem Bogen ausgegeben, wird aber verwendet, um
  --  AT/PA-Boni aufgrund von existierender Waffenspezialisierung anzuwenden.
  nahkampf = {
    {}, {}, {}, {}, {}
  },
  --  Fernkampfwaffen. Beispiel: TODO
  --  Wie bei Nahkampfwaffen kann auch bei Fernkampfwaffen der benamte Wert
  --  `art="…"` mit angegeben werden.
  --
  --    <Name> <Art> <TP> <Entfernungen> <TP/Entfernung> <Geschosse>
  fernkampf = {
    {}, {}, {},
  },
  --  Hinweis: Waffenloser Kampf wird komplett automatisch berechnet.

  --  Schilde und Parierwaffen.
  --  Der Typ muss entweder "Schild" oder "Parierwaffe" sein. Beispiel:
  --
  --    {"Lederschild", "Schild",  -1,  3, 2, "", ""}
  --     <Name>         <Typ>     <INI> <WM>  <BF>
  schilde = {
    {},
    {},
  },
  --  Rüstung
  --  Der RS und die BE der Rüstungsteile werden automatisch aufsummiert und in
  --  die Zeile Summe geschrieben.
  --  Dies geschieht nicht, wenn kein einziges Rüstungsteil einen Zahlenwert hat
  --  oder wenn mindestens ein Rüstungsteil einen Wert hat, der keine Zahl ist.
  --  In diesen Fällen bleiben die Felder leer.
  --
  --  Jedes Rüstungsstück hat die namenlosen Werte Name, gRS und gBE.
  --  Kommazahlen benutzen den Punkt statt das Komma für die Dezimalziffern.
  --  Dahinter können noch benamte Werte für die einzelnen Zonen stehen.
  --  Zonennamen: kopf, brust, ruecken, l_arm, r_arm, bauch, r_bein, l_bein.
  --
  --  Beispiel:
  --    {"Garether Platte", 4.7, 3.7, brust=6, ruecken=5, bauch=6,
  --     l_arm=5, r_arm=5, l_bein=4, r_bein=4}
  ruestung = {
    {}, {}, {}, {}, {}, {},
  },

  --  Mehrzeilig, standardmäßig 5 Zeilen.
  kleidung = "",
  --  Jeder Wert generiert eine Zeile.
  --  Die Menge der hier definierten Werte ist für die Verwendung des
  --  profanen Ausrüstungsbogens ausgelegt.
  --  Wird statt dessen der Liturgienbogen verwendet, sollte die Liste kürzer
  --  sein, weil dort weniger Platz verfügbar ist.
  ausruestung = {
  -- Name, Gewicht, wo getragen
    {"",   "",      ""},
    {},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}
  },
  --  Proviant und Tränke
  --  Jeder Wert generiert eine Zeile:
  --    Name, (4 Rationswerte)
  proviant = {
    {"", "", "", "", ""},
    {}, {}, {}, {}, {}, {}, {}
  },
  --  In die Vermögenstabelle lassen sich beliebige Währungen eintragen.
  --  Jede Währung generiert eine Zeile.
  vermoegen = {
    {"Dukaten", "", "", "", "", "", "", "", ""},
    {"Silbertaler"},
    {"Heller"},
    {"Kreuzer"},
    --  Mehrzeilig, standardmäßig 4 Zeilen.
    sonstiges = ""
  },
  --  Mehrzeilig, standardmäßig 6 Zeilen.
  verbindungen = "",
  --  Mehrzeilig, standardmäßig 7 Zeilen.
  notizen = "",
  --  Tiere. Jeder Wert generiert eine Zeile.
  tiere = {
  -- Name, Art, INI, AT, PA, TP, LE, RS, KO, GS, AU, MR, LO, TK, ZK
    {"",   "",  "",  "", "", "", "", "", "", "", "", "", "", "", ""},
    {}, {}, {}
  },
  --  Ende der Werte für profane Charaktere. Für Geweihte oder Magier bitte die
  --  anderen Vorlagen verwenden.
}