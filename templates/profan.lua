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
--  Textuelle Werte müssen von Hochkommas umschlossen werden: "Beispiel".
--  Zahlenwerte können auch ohne Hochkommas eingegeben werden: 42.
--  Tabellenwerte werden von {} umschlossen und enthalten kommagetrennte,
--  möglicherweise benannte Werte. Beim Editieren muss die bestehende
--  Tabellenstruktur beibehalten werden, es dürfen beispielsweise keine
--  Tabellen durch textuelle oder Zahlenwerte ersetzt werden. Auch dürfen die
--  Namen von benamten Werten nicht geändert werden.
--
--  Standardmäßig stehen an vielen Stellen leere textuelle Werte: "".
--  Diese können durch Zahlenwerte ersetzt werden, wenn sinnvoll.
--  In Listen stehen oftmals leere Tabellen: {}.
--  Diese sorgen dafür, dass eine leere Zeile produziert wird. Sie können mit
--  Werten gefüllt werden, die in der Zeile eingezeigt werden sollen.

return {
  dokument = {
    --  Seiten, die gerendert werden sollten. Die Seiten werden in der
    --  Reihenfolge der Nennung gerendert. Verfügbare Seiten sind:
    --    "front"       => Frontseite des Heldenbogens
    --    "talente"     => Talentbogen
    --    "kampf"       => Kampfbogen
    --    "ausruestung" => Ausrüstungsbogen
    --    "liturgien"   => Liturgien & Ausrüstung. Ersetzt den Ausrüstungsbogen für Geweihte.
    --    "zauberdok"   => Zauberdokument
    --    "zauber"      => Zauberliste. Produziert mehrere Seiten wenn nötig.
    seiten = {"front", "talente", "kampf", "ausruestung"},
    --  Talentreihenfolge auf dem Talentbogen. Kann umsortiert werden, falls
    --  die übliche Sortierung ungeschickt ist. Verfügbare Tabellen sind:
    --    "sonderfertigkeiten" => Die Liste von Sonderfertigkeiten (außer Kampf)
    --    "begabungen"         => Übernatürliche Begabungen
    --    "gaben"              => Gaben
    --    "kampf"              => Kampftechniken
    --    "koerper"            => Körperliche Talente
    --    "gesellschaft"       => Gesellschaftliche Talente
    --    "natur"              => Naturtalente
    --    "wissen"             => Wissenstalente
    --    "sprachen"           => Sprachen & Schriften
    --    "handwerk"           => Handwerkliche Talente
    --  Die Tabellen werden automatisch auf zwei Seiten verteilt, so dass auf
    --  beiden Seiten möglichst gleich viel Platz verwendet wird.
    --  Enthält eine Tabelle keine Zeilen (standardmäßig beispielsweise
    --  talente.begabungen), so wird diese Tabelle nicht ins Dokument
    --  geschrieben.
    talentreihenfolge = {
      "sonderfertigkeiten", "gaben", "begabungen", "kampf", "koerper",
      "gesellschaft", "natur", "wissen", "sprachen", "handwerk"
    },
  },

  -- Grundsätzliche Informationen zum Helden.
  held = {
    name         = "",
    gp           = "",
    rasse        = "",
    kultur       = "",
    profession   = "",
    geschlecht   = "",
    tsatag       = "",
    groesse      = "",
    gewicht      = "",
    haarfarbe    = "",
    augenfarbe   = "",
    stand        = "",
    sozialstatus = "",
    --  Der Titel hat vier Zeilen, jeder Wert wird in eine Zeile geschrieben.
    titel        = {"", "", "", ""},
    --  Das Aussehen hat drei Zeilen, jeder Wert in eine Zeile geschrieben.
    aussehen     = {"", "", ""},
  },
  --  Die Vorteile sind in allgemeine und magische Vorteile getrennt.
  --  Jeder Wert ist eine Zeile. Wenn noch genug Zeilen übrig sind, werden auch
  --  alle die magischen Vorteile auf die Frontseite geschrieben. Dies geschieht
  --  nicht, wenn nur ein Teil der magischen Vorteile hineinpassen würde.
  --  In jedem Fall finden sich die magischen Vorteile auf dem Zauberdokument.
  --  Um zu verhindern, dass magische Vorteile auf der Frontseite stehen,
  --  einfach oft genug "" in die allgemeinen Voretile schreiben.
  vorteile = {
    "", "", "",
    eisern = false,
    magisch = {
      "", "", ""
    }
  },
  --  Nachteile werden analog zu Vorteilen behandelt.
  nachteile = {
    "", "",
    "", "",
    glasknochen = false,
    magisch = {
      "", ""
    }
  },
  --  Eigenschaften. Der erste Wert ist der Modifikator.
  --  Bei Basis-Eigenschaften ist der zweite Wert der Startwert, der dritte Wert
  --  der aktuelle Wert.
  --  Bei abgeleiteten Eigenschaften ist der zweite Wert der zugekauft-Wert, der
  --  dritte Wert die permanent verlorenen Punkte.
  --  Werte die 0 sind, werden nicht ausgegeben; abgeleitete Werte, die von
  --  Basiseigenschaften abhängen, die 0 sind, werden ebenfalls nicht ausgegeben.
  eig = {
    MU  = {0, 0, 0},
    KL  = {0, 0, 0},
    IN  = {0, 0, 0},
    CH  = {0, 0, 0},
    FF  = {0, 0, 0},
    GE  = {0, 0, 0},
    KO  = {0, 0, 0},
    KK  = {0, 0, 0},
    GS  = {0, 0, 0},
    LE  = {0, 0, 0},
    AU  = {0, 0, 0},
    AE  = {0, 0, 0},
    MR  = {0, 0, 0},
    --  Die zugekauften und permanenten Werte von Karmaenergie werden nicht in
    --  den Bogen eingetragen, da sie regeltechnisch ebenso in den Modifikator
    --  eingerechnet werden können und keine zusätzlichen Auswirkungen haben.
    --  Werden hier Werte ungleich 0 eingegeben, fließen sie dennoch in den
    --  aktuellen Wert mit ein.
    KE  = {0, 0, 0},
    --  INI hat ausschließlich den Modifikator, der von der Rasse kommen kann.
    --  Der Modifikator von Kampfgespür und Kampfreflexe sollte hier nicht
    --  eingetragen werden, dieser wird bereits mit eingerechnet, wenn die
    --  Sonderfertigkeiten angekreuzt sind.
    INI = {0},
    --  Die restlichen Werte werden komplett automatisch berechnet.
  },
  --  Abenteuerpunkte.
  ap = {
    gesamt = "",
    eingesetzt = "",
    guthaben = ""
  },
  --  Kann auf true gesetzt werden, um allen Talenten eine Spalte betitelt mit
  --  M hinzuzufügen. Diese ist dafür gedacht, benutzt zu werden, um
  --  Meisterhandwerk-Talente zu markieren sowie Mirakel+ und Mirakel-.
  --  Die M-Spalte ist gerade breit genug für ein Zeichen.
  --  Soll ein Talent einen Eintrag in der M-Spalte haben, muss hinter dem
  --  Talentwert ein mit `m` benamter Eintrag hinzugefügt werden. Beispiel:
  --
  --      {"Athletik",           "GE", "KO", "KK", "BEx2", 0, m = "+"},
  m_spalte = false,
  talente = {
    --  Gaben. Jeder Wert erzeugt eine Zeile. Die Wertreihenfolge ist:
    --    Name - Probe (3 Eigenschaften) - TaW
    --  Wenn nicht benötigt, kann `gaben = {}` gesetzt werden – dies verhindert,
    --  dass die Tabelle überhaupt ins Dokument geschrieben wird.
    gaben = {
      {}, {}
    },
    --  Für übernatürliche Begabungen. Wird genauso behandelt wie gaben.
    begabungen = {},
    --  Jeder Wert erzeugt eine Zeile.
    sonderfertigkeiten = {
      "", "", "", "", "", ""
    },
    --  Kampftechniken. Jeder Wert erzeugt eine Zeile. Die Wertreihenfolge ist:
    --    Name - Steigerungsspalte - Behinderung - AT - PA - TaW
    kampf = {
      {"Dolche",                "D", "BE-1", "", "", ""},
      {"Hiebwaffen",            "D", "BE-4", "", "", ""},
      {"Raufen",                "C", "BE",   "", "", ""},
      {"Ringen",                "D", "BE",   "", "", ""},
      {"Wurfmesser",            "C", "BE-3", "", "", ""},
      {}, {}, {}, {}, {}, {}, {}, {}
    },
    --  Körperliche Talente. Jeder Wert erzeugt eine Zeile. Die Reihenfolge ist:
    --    Name - Probe (3 Eigenschaften) - Behinderung - TaW
    koerper = {
      {"Athletik",           "GE", "KO", "KK", "BEx2", ""},
      {"Klettern",           "MU", "GE", "KK", "BEx2", ""},
      {"Körperbeherrschung", "MU", "IN", "GE", "BEx2", ""},
      {"Schleichen",         "MU", "IN", "GE", "BE",   ""},
      {"Schwimmen",          "GE", "KO", "KK", "BEx2", ""},
      {"Selbstbeherrschung", "MU", "KO", "KK", "–",    ""},
      {"Sich Verstecken",    "MU", "IN", "GE", "BE-2", ""},
      {"Singen",             "IN", "CH", "CH", "BE-3", ""},
      {"Sinnesschärfe",      "KL", "IN", "IN", "–",    ""},
      {"Tanzen",             "CH", "GE", "GE", "BEx2", ""},
      {"Zechen",             "IN", "KO", "KK", "–",    ""},
      {}, {}, {}, {}, {}, {},
    },
    --  Gesellschaftliche Talente. Jeder Wert erzeugt eine Zeile:
    --    Name - Probe (3 Eigenschaften) - TaW
    gesellschaft = {
      {"Menschenkenntnis", "KL", "IN", "CH", ""},
      {"Überreden",        "MU", "IN", "CH", ""},
      {}, {}, {}, {}, {}, {}, {}
    },
    --  Naturtalente. Jeder Wert erzeugt eine Zeile:
    --    Name - Probe (3 Eigenschaften) - TaW
    natur = {
      {"Fährtensuchen", "KL", "IN", "IN", ""},
      {"Orientierung",  "KL", "IN", "IN", ""},
      {"Wildnisleben",  "IN", "GE", "KO", ""},
      {}, {}, {}, {}
    },
    --  Wissenstalente. Jeder Wert erzeugt eine Zeile:
    --    Name - Probe (3 Eigenschaften) - TaW
    wissen = {
      {"Götter / Kulte",            "KL", "KL", "IN", ""},
      {"Rechnen",                   "KL", "KL", "IN", ""},
      {"Sagen / Legenden",          "KL", "IN", "CH", ""},
      {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
    },
    --  Sprachen und Schriften. Jeder Wert erzeugt eine Zeile:
    --    Name - Komplexität - TaW
    sprachen = {
      {"Muttersprache: ", "", ""},
      {}, {}, {}, {}, {}, {}, {}, {}, {}
    },
    --  Handwerkliche Talente. Jeder Wert erzeugt eine Zeile:
    --    Name - Probe (3 Eigenschaften) - TaW
    handwerk = {
      {"Heilkunde Wunden", "KL", "CH", "FF", ""},
      {"Holzbearbeitung",  "KL", "FF", "KK", ""},
      {"Kochen",           "KL", "IN", "FF", ""},
      {"Lederarbeiten",    "KL", "FF", "FF", ""},
      {"Malen / Zeichnen", "KL", "IN", "FF", ""},
      {"Schneidern",       "KL", "FF", "FF", ""},
      {}, {}, {}, {}, {}, {}, {}, {}, {}
    }
  },
  --  Sonderfertigkeiten. Diese werden an verschiedene Stellen im Dokument
  --  verteilt.
  sf = {
    --  Nahkampf-Sonderfertigkeiten. Jeder Wert erzeugt eine Zeile.
    nahkampf = {
      "", "", ""
    },
    --  Fernkampf-Sonderfertigkeiten. Jeder Wert erzeugt eine Zeile.
    fernkampf = {
      "", "", ""
    },
    --  Waffenlose Sonderfertigkeiten. Jeder Wert erzeugt eine Zeile.
    waffenlos = {
      "", ""
    },
    --  Magische Sonderfertigkeiten. Jeder Wert erzeugt eine Zeile.
    --  Dieser SFs werden ausschließlich auf dem Zauberdokument ausgegeben!
    magisch = {
      "", "", "", "", ""
    },
    --  Kampfgespür und Kampfreflexe sind Boolean-Werte (true oder false).
    --  Sind sie true, wird die entsprechende Box auf der Frontseite angekreuzt.
    kampfreflexe = false,
    kampfgespuer = false
  },
  --  Nahkampfwaffen.
  nahkampf = {
  -- Name, [Typ/eBE], DK, TP, [TP/KK], INI, WM:[AT/PA], AT, PA, TP, [ BF ]
    {"",    "", "",   "", "",  "","",  "",      "","",  "", "", "", "", ""},
    {}, {}, {}, {}
  },
  --  Fernkampfwaffen
  fernkampf = {
  -- Name, [Typ/eBE], TP, [  Entfernungen  ], [  TP/Entfernung ], FK, [ Geschosse  ]
    {"",    "", "",   "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""},
    {}, {},
  },
  --  Waffenloser Kampf
  waffenlos = {
    --        AT, PA, TP
    raufen = {"", "", ""},
    ringen = {"", "", ""},
  },
  --  Schilde und Parierwaffen
  schilde = {
  -- Name, Typ, INI, WM:[AT/PA], PA, [  BF  ]
    {"",   "",  "",      "","",  "",  "", ""},
    {},
    --  Die folgenden SF sind Boolean-Werte (true oder false). Bei true wird die
    --  entsprechende Box angekreuzt.
    linkhand = false,
    --  Zwei Werte für Schildkampf I und II.
    schildkampf = {false, false},
    --  Zwei Werte für Parierwaffen I und II.
    parierwaffen = {false, false}
  },
  --  Rüstung
  --  Der RS und die BE der Rüstungsteile werden automatisch aufsummiert und in
  --  die Zeile Summe geschrieben.
  --  Dies geschieht nicht, wenn kein einziges Rüstungsteil einen Zahlenwert hat
  --  oder wenn mindestens ein Rüstungsteil einen Wert hat, der keine Zahl ist.
  --  In diesen Fällen bleiben die Felder leer.
  --
  --  Jedes Rüstungsstück hat Namen, gRS und gBE.
  --  Kommazahlen benutzen den Punkt statt das Komma für die Dezimalziffern.
  --  Beispiel:
  --    {"Garether Platte", 4.7, 3.7}
  ruestung = {
    {}, {}, {}, {}, {}, {},
    --  Rüstungsgewöhnung I, II und III
    gewoehnung = {false, false, false},
    --  Resultierende Behinderung. Wird nicht automatisch berechnet, ergibt sich
    --  üblicherweise aus gBE - Rüstungsgewöhnung, aber kann auch zusätzliche
    --  Werte wie natürliche Rüstung beinhalten.
    be = "",
    --  Es folgen die Rüstungswerte an den einzelnen Körperteilen.
    kopf = "",
    brust = "",
    ruecken = "",
    bauch = "",
    linker_arm = "",
    rechter_arm = "",
    linkes_bein = "",
    rechtes_bein = ""
  },
  ausweichen = {
    --  Der berechnete Ausweichenwert
    "",
    --  Die Sonderfertigkeiten Ausweichen I, II und III
    sf = {false, false, false}
  },

  --  Jeder Wert generiert eine Zeile.
  kleidung = {
    "", "", "", "", ""
  },
  --  Jeder Wert generiert eine Zeile.
  --  Die Menge der hier definierten Werde ist für die Verwendung des
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
    --  Jeder Wert generiert eine Zeile.
    sonstiges = {
      "", "", "", ""
    }
  },
  --  Verbindungen. Jeder Wert generiert eine Zeile.
  verbindungen = {
    "", "", "", "", "", ""
  },
  --  Notizen. Jeder Wert generiert eine Zeile.
  notizen = {
    "", "", "", "", "", "", "",
    --  Magische Notizen werden in das Zauberdokument geschrieben.
    magisch = {"", "", "", ""}
  },
  --  Tiere. Jeder Wert generiert eine Zeile.
  tiere = {
  -- Name, Art, INI, AT, PA, TP, LE, RS, KO, GS, AU, MR, LO, TK, ZK
    {"",   "",  "",  "", "", "", "", "", "", "", "", "", "", "", ""},
    {}, {}, {}
  },
  --  Ende der Werte für profane Charaktere. Für Geweihte oder Magier bitte die
  --  anderen Vorlagen verwenden.
}