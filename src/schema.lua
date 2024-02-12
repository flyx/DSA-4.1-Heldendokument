local d = require("schemadef")

local gendoc = ...

local schema = d(gendoc)
local OptNum = schema.OptNum
local String = schema.String
local Multiline = schema.Multiline

local Zeilen = d.Primitive:def({name = "Zeilen", description = "Anzahl Zeilen in einem Feld oder einer Tabelle"}, "number", false, 0, 0)

local Front = d.Record:def({name = "Front", description = "Frontseite"},
  {"Aussehen", Zeilen, 3},
  {"Vorteile", Zeilen, 7},
  {"Nachteile", Zeilen, 7})

local Talentliste = d.List:def({name = "Talentliste", item_name = "Gruppe"}, {
  d.Primitive:def({name = "Sonderfertigkeiten", description = "Zeilen für Sonderfertigkeiten"}, "number", false, 0, 0),
  d.Primitive:def({name = "Gaben", description = "Zeilen für Gaben"}, "number", false, 0, 0),
  d.Primitive:def({name = "Begabungen", description = "Zeilen für Übernatürliche Begabungen"}, "number", false, 0, 0),
  d.Primitive:def({name = "Kampf", description = "Zeilen für Kampftalente"}, "number", false, 0, 0),
  d.Primitive:def({name = "Koerper", description = "Zeilen für Körperliche Talente"}, "number", false, 0, 0),
  d.Primitive:def({name = "Gesellschaft", description = "Zeilen für Gesellschaftstalente"}, "number", false, 0, 0),
  d.Primitive:def({name = "Natur", description = "Zeilen für Naturtalente"}, "number", false, 0, 0),
  d.Primitive:def({name = "Wissen", description = "Zeilen für Wissenstalente"}, "number", false, 0, 0),
  d.Primitive:def({name = "SprachenUndSchriften", description = "Zeilen für Sprachen & Schriften"}, "number", false, 0, 0),
  d.Primitive:def({name = "Handwerk", description = "Zeilen für Handwerkstalente"}, "number", false, 0, 0),
})
function Talentliste:documentation(printer)
  printer:p("Sonderfertigkeiten & Talente. Der Inhalt dieses Werts definiert die Reihenfolge der Untergruppen und die Anzahl Zeilen jeder Untergruppe.")
end

local Kampfbogen = d.Record:def({name = "Kampfbogen", description = "Kampfbogen."},
  {"Nahkampf", d.Record:def({name = "NahkampfWaffenUndSF", description = "Zeilen für Nahkampfwaffen und -SF."},
    {"Waffen", Zeilen, 5},
    {"SF", Zeilen, 3}), {}},
  {"Fernkampf", d.Record:def({name = "FernkampfWaffenUndSF", description = "Zeilen für Fernkampfwaffen und -SF."},
    {"Waffen", Zeilen, 3},
    {"SF", Zeilen, 3}), {}},
  {"Waffenlos", d.Record:def({name = "Waffenlos", description = "Zeilen für waffenlose Manöver."},
    {"SF", Zeilen, 3}), {}},
  {"Schilde", Zeilen, 2},
  {"Ruestung", Zeilen, 6},
  {"Regenbogen", schema.Boolean, false})

local Ausruestungsbogen = d.Record:def({name = "Ausruestungsbogen", description = "Ausrüstungsbogen."},
  {"Kleidung", Zeilen, 5},
  {"Gegenstaende", Zeilen, 33},
  {"Proviant", Zeilen, 8},
  {"Vermoegen", d.Record:def({name = "Vermoegensbox", description = "Zeilen in der Vermögensbox."}, {"Muenzen", Zeilen, 4}, {"Sonstiges", Zeilen, 7}), {}},
  {"Verbindungen", Zeilen, 9},
  {"Notizen", Zeilen, 7},
  {"Tiere", Zeilen, 4})

local Liturgiebogen = d.Record:def({name = "Liturgiebogen", description = "Bogen für Liturgien & Ausrüsung."},
  {"Kleidung", Zeilen, 5},
  {"Liturgien", Zeilen, 24},
  {"Gegenstaende", Zeilen, 29},
  {"ProviantVermoegen", d.Record:def({name = "ProviantVermoegen", description = "Zeilen für Proviant & Vermögen Box."}, {"Gezaehlt", Zeilen, 4}, {"Sonstiges", Zeilen, 5}), {}},
  {"VerbindungenNotizen", Zeilen, 9},
  {"Tiere", Zeilen, 4})

local Zauberdokument = d.Record:def({name = "Zauberdokument", description = "Zauberdokument."},
  {"VorUndNachteile", Zeilen, 5},
  {"Sonderfertigkeiten", Zeilen, 5},
  {"Rituale", Zeilen, 30},
  {"Ritualkenntnis", Zeilen, 2},
  {"Artefakte", Zeilen, 9},
  {"Notizen", Zeilen, 7})

local Zauberliste = d.Primitive:def({name = "Zauberliste", description = "Zauberliste."}, "void", true)
local Ereignisliste = d.Primitive:def({name = "Ereignisliste", description = "Ereignisliste."}, "void", true)

d:singleton(d.List, {name = "Layout", item_name = "Seite"}, {
  Front, Talentliste, Kampfbogen, Ausruestungsbogen, Liturgiebogen,
  Zauberdokument, Zauberliste, Ereignisliste
}) {
  Front {},
  Talentliste {
    schema.Sonderfertigkeiten(6),
    schema.Gaben(2),
    schema.Kampf(13),
    schema.Koerper(17),
    schema.Gesellschaft(9),
    schema.Natur(7),
    schema.Wissen(17),
    schema.SprachenUndSchriften(10),
    schema.Handwerk(15)
  },
  Kampfbogen {},
  Ausruestungsbogen {},
  Liturgiebogen {},
  Zauberdokument {},
  Zauberliste {}
}
function schema.Layout:documentation(printer)
  printer:p([[Definiert, welche Seiten in welcher Reihenfolge generiert werden.
Für die einzelnen Seiten können weitere Spezifikationen vorgenommen werden, dies ist bei den Typen der
einzelnen Seiten beschrieben.]])
end
function schema.Layout.example(printer)
  printer:highlight([[Layout {
  Front {},
  Talentliste {
    Sonderfertigkeiten(6),
    Gaben(2),
    Kampf(13),
    Koerper(17),
    Gesellschaft(9),
    Natur(10),
    Wissen(16),
    SprachenUndSchriften(10),
    Handwerk(13)
  },
  Kampfbogen {},
  Ausruestungsbogen {},
  Liturgiebogen {},
  Zauberdokument {},
  Zauberliste {}
}]])
end

d:singleton(d.Record, {name = "Held", description = [[Grundlegende Daten des Helden.]]},
  {"Name", String, ""},
  {"GP", OptNum, {}},
  {"Rasse", String, ""},
  {"Kultur", String, ""},
  {"Profession", String, ""},
  {"Geschlecht", String, ""},
  {"Tsatag", String, ""},
  {"Groesse", String, ""},
  {"Gewicht", String, ""},
  {"Haarfarbe", String, ""},
  {"Augenfarbe", String, ""},
  {"Stand", String, ""},
  {"Sozialstatus", OptNum, {}},
  {"Titel", Multiline, ""},
  {"Aussehen", Multiline, ""})
function schema.Held.example(printer)
  printer:highlight([[Held {
  Name         = "Fette Alrike",
  GP           = 110,
  Rasse        = "Mittelländerin",
  Kultur       = "Mittelländische Landbevölkerung",
  Profession   = "Söldnerin",
  Geschlecht   = "weiblich",
  Tsatag       = "3. Rondra 1020 BF",
  Groesse      = "1,78 Schritt",
  Gewicht      = "78 Stein",
  Haarfarbe    = "braun",
  Augenfarbe   = "grün",
  Sozialstatus = 4,
  -- Aussehen ist eine mehrzeilige Box. Grundsätzlich wird Text darin
  -- automatisch umgebrochen, mit {} kann ein Zeilenumbruch an einer bestimmten
  -- Stelle forciert werden.
  Aussehen     = {"Narbe an der rechten Wange", {}, "kurz geschnittene Haare"}
  -- Stand und Titel sind nicht gegeben und erhalten daher ihren default-Wert.
}]])
end

local Talentgruppe = d.Matching:def({name = "Talentgruppe", description = "Eine der existierenden Talentgruppen"}, "Kampf", "Nahkampf", "Fernkampf", "Koerper", "Gesellschaft", "Natur", "Wissen", "SprachenUndSchriften", "Handwerk")

local Element = d.Matching:def({name = "Element", description = "Name eines Elements, oder 'gesamt'."}, "gesamt", "Eis", "Humus", "Feuer", "Wasser", "Luft", "Erz")
local Elementar = d.List:def({name = "Elementar", description = "Spezifikation elementarer Merkmale."}, {Element})
local Domaene = d.Matching:def({name = "Domaene", description = "Name einer Domäne, oder 'gesamt'"}, "gesamt", "Blakharaz", "Belhalhar", "Charyptoroth", "Lolgramoth", "Thargunitoth", "Amazeroth", "Belshirash", "Asfaloth", "Tasfarelel", "Belzhorash", "Agrimoth", "Belkelel")
local Daemonisch = d.List:def({name = "Daemonisch", description = "Spezifikation dämonischer Merkmale."}, {Domaene})
local Ausbildungsname = d.Matching:def({name = "Ausbildungsname", description = "Name einer akademischen Ausbildung"}, "Gelehrter?", "Magier", "Magierin", "Krieger", "Kriegerin")

local EigName = d.Matching:def({name = "EigName", description = "Name einer steigerbaren Eigenschaft"}, "MU", "KL", "IN", "CH", "FF", "GE", "KO", "KK", "LE", "AU", "AE", "MR")

d:singleton(d.Multivalue, {name = "Vorteile", description = "Liste von nicht-magischen Vorteilen."}, String, {
  AkademischeAusbildung = d.List:def({name = "AkademischeAusbildung", description = "Akademische Ausbildung", label = "Akademische Ausbildung"}, {Ausbildungsname}, 0, 1),
  BegabungFuerEigenschaft = d.List:def({name = "BegabungFuerEigenschaft", description = "Begabung für eine oder mehrere Eigenschaften. Üblicherweise nicht frei wählbar, kommt aber etwa in 7G vor.", label = "Begabung für Eigenschaft"}, {EigName}),
  BegabungFuerTalent = d.List:def({name = "BegabungFuerTalent", description = "Begabung für ein oder mehrere Talente", label = "Begabung für Talent"}, {String}),
  BegabungFuerTalentgruppe = d.List:def({name = "BegabungFuerTalentgruppe", description = "Begabung für eine oder mehrere Talentgruppen.", label = "Begabung für Talentgruppe"}, {Talentgruppe}),
  EidetischesGedaechtnis = "Eidetisches Gedächtnis",
  Eisern = "Eisern",
  Flink = d.Primitive:def({name = "Flink", description = "Flink(2) ist exklusiv für Goblins, die es zweimal wählen dürfen."}, "number", false, 0, 1, 2),
  GutesGedaechtnis = "Gutes Gedächtnis",
})
function schema.Vorteile.example(printer)
  printer:highlight([[Vorteile {
  "Balance", BegabungFuerTalentgruppe {"Nahkampf"}, "Eisern", Flink(1), "Verbindungen 5"
}]])
end

schema.Vorteile.Magisch = d:singleton(d.Multivalue, {name = "Vorteile.Magisch", description = "Liste von magischen Vorteilen."}, String, {
  AstraleRegeneration = d.Primitive:def({name = "AstraleRegeneration", description = "Astrale Regeneration I, II oder III", label = "Astrale Regeneration"}, "number", false, 0, 1, 3),
  Eigeboren = "Eigeboren",
  Viertelzauberer = "Viertelzauberer",
  Halbzauberer = "Halbzauberer",
  Vollzauberer = "Vollzauberer",
  BegabungFuerMerkmal = d.Multivalue:def({name = "BegabungFuerMerkmal", description = "Begabung für ein oder mehrere Merkmale.", label = "Begabung für Merkmal"}, String, {
    Elementar = Elementar,
    Daemonisch = Daemonisch
  }),
  BegabungFuerRitual = d.List:def({name = "BegabungFuerRitual", description = "Begabung für ein oder mehrere Rituale", label = "Begabung für Ritual"}, {String}),
  BegabungFuerZauber = d.List:def({name = "BegabungFuerZauber", description = "Begabung für einen oder mehrere Zauber", label = "Begabung für Zauber"}, {String}),
  Meisterhandwerk = d.List:def({name = "Meisterhandwerk", description = "Liste von Talenten, für die ein Meisterhandwerk existiert."}, {String}),
  UebernatuerlicheBegabung = d.List:def({name = "UebernatuerlicheBegabung", description = "Liste von Talenten, für die eine Übernatürliche Begabung existiert.", label = "Übernatürliche Begabung"}, {String}),
}) {}
function schema.Vorteile.Magisch.example(printer)
  printer:highlight([[Vorteile.Magisch {
  BegabungFuerMerkmal {"Antimagie", Elementar {"Eis"}},
  Meisterhandwerk {"Alchimie"}, "Feste Matrix", "Vollzauberer"
}]])
end

d:singleton(d.Multivalue, {name = "Nachteile", description = "Liste von nicht-magischen Nachteilen (außer schlechten Eigenschaften)"}, String, {
  Glasknochen = "Glasknochen",
  Behaebig = "Behäbig",
  Kleinwuechsig = "Kleinwüchsig",
  Lahm = "Lahm",
  Zwergenwuchs = "Zwergenwuchs",
  UnfaehigkeitFuerTalentgruppe = d.List:def({name = "UnfaehigkeitFuerTalentgruppe", description = "Unfähigkeit für eine oder mehrere Talentgruppen", label = "Unfähigkeit für Talentgruppe"}, {Talentgruppe}),
  UnfaehigkeitFuerTalent = d.List:def({name = "UnfaehigkeitFuerTalent", description = "Unfähigkeit für ein oder mehrere bestimmte Talente", label = "Unfähigkeit für Talent"}, {String}),
  Unstet = "Unstet",
})
function schema.Nachteile.example(printer)
  printer:highlight([[Nachteile {
  "Impulsiv", "Zwergenwuchs", UnfaehigkeitFuerTalent {"Schwimmen"}
}]])
end

local Ganzzahl = d.Primitive:def({name = "Ganzzahl", description = "Eine Zahl in Dezimalschreibweise."}, "number", false, 0)

local GPjeStufe = d.Primitive:def({name="GPjeStufe", description="GP pro Stufe in der schlechten Eigenschaft (positiv). Wird verwendet, um die Kosten von Senkungen zu berechnen."}, "number", false, 1, 0.5, 2)

local SchlechteEigenschaft = d.Row:def({name="SchlechteEigenschaft", description="Eine schlechte Eigenschaft, die die GP pro Stufe (0.5, 1, 1.5 oder 2) definert sowie den aktuellen Stufenwert."},
  {"Name", String},
  {"GP", GPjeStufe},
  {"Wert", Ganzzahl})

schema.Nachteile.Eigenschaften = d:singleton(d.List, {name = "Nachteile.Eigenschaften", description="Liste von Schlechten Eigenschaften"}, {SchlechteEigenschaft}) {}
function schema.Nachteile.Eigenschaften.example(printer)
  printer:highlight([[Nachteile.Eigenschaften {
  {"Angst vor Wasser", 1.5, 6},
  {"Dunkelangst", 2, 7},
  {"Neid", 0.5, 8},
  {"Vorurteile gegen Menschen", 1, 9}
}]])
end

schema.Nachteile.Magisch = d:singleton(d.Multivalue, {name = "Nachteile.Magisch", description = "Liste von magischen Nachteilen."}, String, {
  AstralerBlock = "Astraler Block",
  UnfaehigkeitFuerMerkmal = d.Multivalue:def({name = "UnfaehigkeitFuerMerkmal", description = "Unfähigkeit für ein oder mehrere Merkmale.", label = "Unfähigkeit für Merkmal"}, String, {
    Elementar = Elementar,
    Daemonisch = Daemonisch
  }),
}) {}
function schema.Nachteile.Magisch.example(printer)
  printer:highlight([[Nachteile.Magisch {
  "Körpergebundene Kraft", UnfaehigkeitFuerMerkmal {Daemonisch {"gesamt"}},
  "Lästige Mindergeister"
}]])
end

local BasisEig = d.Row:def({name = "BasisEig", description = "Eine Basiseigenschaft mit Modifikator, Startwert und aktuellem Wert."},
  {"Mod", Ganzzahl}, {"Start", Ganzzahl}, {"Aktuell", Ganzzahl})
local AbgeleiteteEig = d.Row:def({name = "AbgeleiteteEig", description = "Eine abgeleitete Eigenschaft mit Modifikator, zugekauften Punkten und permanent verlorenen Punkten."},
  {"Mod", Ganzzahl}, {"Zugekauft", Ganzzahl}, {"Permanent", Ganzzahl})

d:singleton(d.Record, {name = "Eigenschaften", description = "Liste von Basis- und abgeleiteten Eigenschaften"},
  {"MU", BasisEig, {0, 0, 0}},
  {"KL", BasisEig, {0, 0, 0}},
  {"IN", BasisEig, {0, 0, 0}},
  {"CH", BasisEig, {0, 0, 0}},
  {"FF", BasisEig, {0, 0, 0}},
  {"GE", BasisEig, {0, 0, 0}},
  {"KO", BasisEig, {0, 0, 0}},
  {"KK", BasisEig, {0, 0, 0}},
  {"LE", AbgeleiteteEig, {0, 0, 0}},
  {"AU", AbgeleiteteEig, {0, 0, 0}},
  {"AE", AbgeleiteteEig, {0, 0, 0}},
  {"MR", AbgeleiteteEig, {0, 0, 0}},
  {"KE", AbgeleiteteEig, {0, 0, 0}},
  {"INI", Ganzzahl, 0})
function schema.Eigenschaften.example(printer)
  printer:highlight([[Eigenschaften {
  MU = {1, 15, 17},
  KL = {0, 11, 12},
  IN = {0, 13, 16},
  CH = {0, 14, 14},
  FF = {0, 8, 8},
  GE = {0, 12, 12},
  KO = {1, 15, 17},
  KK = {1, 15, 18},
  -- GS wird automatisch berechnet.
  -- ab hier werden Mod, zugekaufte, und permanent verlorene Punkte angegeben.
  LE = {13, 1, 0},
  AU = {14, 0, 0},
  AE = {0, 0, 0},
  MR = {-5, 1, 0},
  KE = {24, 0, 0},
  -- INI hat nur einen Modifikator.
  INI = 0,
}]])
end

d:singleton(d.Record, {name = "AP", description = "Abenteuerpunkte."},
  {"Gesamt", OptNum, {}},
  {"Eingesetzt", OptNum, {}})
function schema.AP.example(printer)
  printer:highlight([[AP {500, 458, 42}]])
end

local SteigSpalte = d.Matching:def({name = "SteigSpalte", description = "Eine Steigerungsspalte."}, "A%*?", "B", "C", "D", "E", "F", "G", "H")
local Behinderung = d.Matching:def({name = "Behinderung", description = "Behinderung."}, "%-", "BE", "BE%-[1-9]", "BEx[2-9]")
local BasisEig = d.Matching:def({name = "BasisEig", description = "Name einer Basis-Eigenschaft, oder ** in seltenen Fällen."}, "%*%*", "MU", "KL", "IN", "CH", "FF", "GE", "KO", "KK")
local Spezialisierungen = d.Multivalue:def({name = "Spezialisierungen", description = "Liste von Spezialisierungen. Leere tables {} können als Zeilenumbruch benutzt werden. Ist der erste Eintrag {}, wird direkt nach dem Talentnamen umgebrochen."}, String)

d.Row:def({name = "Nah", description = "Ein Nahkampf-Talent mit AT/PA Verteilung. Der PA-Wert berechnet sich aus TaW - AT."},
  {"Name", String}, {"Steigerungsspalte", SteigSpalte, ""}, {"BE", Behinderung, ""}, {"AT", OptNum, {}}, {"TaW", OptNum, {}}, {"Spezialisierungen", Spezialisierungen, {}})
d.Row:def({name = "NahAT", description = "Ein Nahkampf-Talent, dessen Wert ausschließlich zur Attacke dient und das keine AT/PA Verteilung hat."},
  {"Name", String}, {"Steigerungsspalte", SteigSpalte, ""}, {"BE", Behinderung, ""}, {"TaW", OptNum, {}}, {"Spezialisierungen", Spezialisierungen, {}})
d.Row:def({name = "Fern", description = "Ein Fernkampf-Talent."},
  {"Name", String}, {"Steigerungsspalte", SteigSpalte, ""}, {"BE", Behinderung, ""}, {"TaW", OptNum, {}}, {"Spezialisierungen", Spezialisierungen, {}})
d.Row:def({name = "KoerperTalent", description = "Ein Talent aus der Gruppe der Körperlichen Talente."},
  {"Name", String}, {"Probe1", BasisEig, ""}, {"Probe2", BasisEig, ""}, {"Probe3", BasisEig, ""}, {"BE", Behinderung, ""}, {"TaW", OptNum, {}}, {"Spezialisierungen", Spezialisierungen, {}})
d.Row:def({name = "Talent", description = "Ein allgemeines Talent."},
  {"Name", String}, {"Probe1", BasisEig, ""}, {"Probe2", BasisEig, ""}, {"Probe3", BasisEig, ""}, {"TaW", OptNum, {}}, {"Spezialisierungen", Spezialisierungen, {}})
d.List:def({name = "Talentreferenzen", description = "Liste von Talenten (referenziert über deren Namen), aus denen sich ein Metatalent zusammensetzt"}, {String})
d.Row:def({name = "Meta", description = "Ein Metatalent."},
  {"Name", String}, {"Probe1", BasisEig, ""}, {"Probe2", BasisEig, ""}, {"Probe3", BasisEig, ""},
  {"Talente", schema.Talentreferenzen, {}})

d.List:def({name = "Familie", description = "Liste von Sprachen oder Schriften in einer Familie."}, {String})
d.Row:def({name = "Muttersprache", description = "Die Muttersprache des Helden. Anders als andere Sprachen definiert eine Muttersprache Listen der verwandten Sprachen und Schriften, welche nicht ausgegeben werden, sondern nur zur Berechnung der Steigerungsschwierigkeit anderer Sprachen und Schriften dienen."},
  {"Name", String}, {"Komplexität", OptNum, {}}, {"TaW", OptNum, {}}, {"Dialekt", Spezialisierungen, {}}, {"Sprachfamilie", schema.Familie, {}}, {"Schriftfamilie", schema.Familie, {}})
d.Row:def({name = "Zweitsprache", description = "Eine Zweitsprache, für die die Grund-Steigerungsschwierigkeit gilt."},
  {"Name", String}, {"Komplexität", OptNum, {}}, {"TaW", OptNum, {}}, {"Dialekt", Spezialisierungen, {}})
schema.Lehrsprache = schema.Zweitsprache
d.Row:def({name = "Sprache", description = "Eine Fremdsprache. Steigerungsschwierigkeit hängt ab davon, ob sie in der Sprachfamilie der Muttersprache enthalten ist."},
  {"Name", String}, {"Komplexität", OptNum, {}}, {"TaW", OptNum, {}}, {"Dialekt", Spezialisierungen, {}})
d.Row:def({name = "Schrift", description = "Eine Schrift. Es sollte die Steigerungsschwierigkeit gemäß WdS angegeben werden; der Bogen modifiziert sie automatisch im Falle einer Begabung oder Unfähigkeit."},
  {"Name", String}, {"Steigerungsspalte", SteigSpalte, ""}, {"Komplexität", OptNum, {}}, {"TaW", OptNum, {}})

schema.Talente = {
  Begabungen = d:singleton(d.List, {name = "Talente.Begabungen", description = "Liste übernatürlicher Begabungen."}, {schema.Talent}) {},
  Gaben = d:singleton(d.List, {name = "Talente.Gaben", description = "Liste von Gaben."}, {schema.Talent}) {},
  Kampf = d:singleton(d.List, {name = "Talente.Kampf", description = "Liste von Kampftalenten.", item_name = "Kampftalent"}, {schema.Nah, schema.NahAT, schema.Fern}) {
    schema.Nah {"Dolche",      "D", "BE-1"},
    schema.Nah {"Hiebwaffen",  "D", "BE-4"},
    schema.Nah {"Raufen",      "C", "BE"},
    schema.Nah {"Ringen",      "D", "BE"},
    schema.Fern {"Wurfmesser", "C", "BE-3"},
  },
  Koerper = d:singleton(d.List, {name = "Talente.Koerper", description = "Liste von körperlichen Talenten."}, {schema.KoerperTalent}) {
    {"Athletik",           "GE", "KO", "KK", "BEx2"},
    {"Klettern",           "MU", "GE", "KK", "BEx2"},
    {"Körperbeherrschung", "MU", "IN", "GE", "BEx2"},
    {"Schleichen",         "MU", "IN", "GE", "BE"},
    {"Schwimmen",          "GE", "KO", "KK", "BEx2"},
    {"Selbstbeherrschung", "MU", "KO", "KK", "-"},
    {"Sich Verstecken",    "MU", "IN", "GE", "BE-2"},
    {"Singen",             "IN", "CH", "CH", "BE-3"},
    {"Sinnesschärfe",      "KL", "IN", "IN", "-"},
    {"Tanzen",             "CH", "GE", "GE", "BEx2"},
    {"Zechen",             "IN", "KO", "KK", "-"},
  },
  Gesellschaft = d:singleton(d.List, {name = "Talente.Gesellschaft", description = "Liste von Gesellschaftstalenten."}, {schema.Talent}) {
    {"Menschenkenntnis", "KL", "IN", "CH"},
    {"Überreden",        "MU", "IN", "CH"},
  },
  Natur = d:singleton(d.List, {name = "Talente.Natur", description = "Liste von Naturtalenten und Metatalenten.", item_name = "NaturTalent"}, {schema.Talent, schema.Meta}) {
    {"Fährtensuchen", "KL", "IN", "IN"},
    {"Orientierung",  "KL", "IN", "IN"},
    {"Wildnisleben",  "IN", "GE", "KO"},
  },
  Wissen = d:singleton(d.List, {name = "Talente.Wissen", description = "Liste von Wissenstalenten."}, {schema.Talent}) {
    {"Götter / Kulte",            "KL", "KL", "IN"},
    {"Rechnen",                   "KL", "KL", "IN"},
    {"Sagen / Legenden",          "KL", "IN", "CH"},
  },
  SprachenUndSchriften = d:singleton(d.List, {name = "Talente.SprachenUndSchriften", description = "Liste von Sprachen & Schriften.", item_name = "SpracheOderSchrift"}, {
    schema.Muttersprache, schema.Zweitsprache, schema.Sprache, schema.Schrift
  }) {
    schema.Muttersprache {""},
  },
  Handwerk = d:singleton(d.List, {name = "Talente.Handwerk", description = "Liste von Handwerkstalenten."}, {schema.Talent}) {
    {"Heilkunde Wunden", "KL", "CH", "FF"},
    {"Holzbearbeitung",  "KL", "FF", "KK"},
    {"Kochen",           "KL", "IN", "FF"},
    {"Lederarbeiten",    "KL", "FF", "FF"},
    {"Malen / Zeichnen", "KL", "IN", "FF"},
    {"Schneidern",       "KL", "FF", "FF"},
  },
}
function schema.Talente.Begabungen.example(printer)
  printer:highlight([[Talente.Begabungen {
  {"Axxeleratus Blitzgeschwind", "KL", "GE", "KO", 6}
}]])
end
function schema.Talente.Gaben.example(printer)
  printer:highlight([[Talente.Gaben {
  {"Prophezeien", "IN", "IN", "CH", 7}
}]])
end
function schema.Talente.Kampf.example(printer)
  printer:highlight([[Talente.Kampf {
  -- Spezialisierungen werden vorne in die Namensspalte geschrieben.
  Fern {"Bogen", "E", "BE-3", 17, Spezialisierungen = {"Kurzbogen", "Langbogen"}},
  -- AT=8, TaW=13, PA-Wert von 5 wird berechnet.
  Nah {"Dolche", "D", "BE-1", 8, 13},
  -- Kein AT-Wert, da keine AT/PA-Verteilung.
  NahAT {"Lanzenreiten", "E", "", 4},
  Nah {"Raufen", "C", "BE", 6, 10},
  Nah {"Ringen", "D", "BE", 6, 10},
}]])
end
function schema.Talente.Koerper.example(printer)
  printer:highlight([[Talente.Koerper {
  {"Athletik", "GE", "KO", "KK", "BEx2", 5},
  {"Klettern", "MU", "GE", "KK", "BEx2", 4},
  {"Schleichen", "MU", "IN", "GE", "BE", 9, Spezialisierungen = {"Gebäude"}},
  {"Sinnenschärfe", "KL", "IN", "IN", "", 12},
}]])
end
function schema.Talente.Gesellschaft.example(printer)
  printer:highlight([[Talente.Gesellschaft {
  {"Lehren", "KL", "IN", "CH", 7},
  {"Menschenkenntnis", "KL", "IN", "CH", 11},
  {"Überreden", "MU", "IN", "CH", 9},
}]])
end
function schema.Talente.Natur.example(printer)
  printer:highlight([[Talente.Natur {
  {"Orientierung", "KL", "IN", "IN", 3},
  {"Wildnisleben", "IN", "GE", "KO", 2},
}]])
end
function schema.Talente.Wissen.example(printer)
  printer:highlight([[Talente.Wissen {
  {"Anatomie", "MU", "KL", "FF", 10},
  {"Baukunst", "KL", "KL", "FF", 4},
  {"Götter / Kulte", "KL", "KL", "IN", 10},
}]])
end
function schema.Talente.SprachenUndSchriften.example(printer)
  printer:highlight([[Talente.SprachenUndSchriften {
  -- Die Muttersprache gibt andere Sprachen und Schriften derselben Sprachfamilie an.
  -- Daraus berechnen sich die Steigerungsschwierigkeiten; sind die Sprachen/Schriften
  -- dem Helden bekannt, müssen sie unten separat aufgelistet werden.
  Muttersprache {"Garethi", 18, 8, Dialekt = {"Horathi"},
    Sprachfamilie  = {"Bosparano", "Aureliani", "Zyklopäisch"},
    Schriftfamilie = {"Kusliker Zeichen", "Imperiale Zeichen"}
  },
  Zweitsprache {"Tulamidya", 18, 6},
  Sprache {"Atak", 12, 4},
  Sprache {"Oloarkh", 10, 4},
  Schrift {"Kusliker Zeichen", "A", 10, 6},
}]])
end
function schema.Talente.Handwerk.example(printer)
  printer:highlight([[Talente.Handwerk {
  {"Holzbearbeitung", "KL", "FF", "KK", 12},
  {"Kochen", "KL", "IN", "FF", 0},
  {"Lederarbeiten", "KL", "FF", "FF", 1},
}]])
end

d:singleton(d.Multivalue, {name = "SF", description = "Sonderfertigkeiten (außer Kampf & magischen)"}, String, {
  Kulturkunde = d.Multivalue:def({name = "Kulturkunde", description = "Liste von Kulturen, für die Kulturkunde besteht."}, String),
  Ortskenntnis = d.Multivalue:def({name = "Ortskenntnis", description = "Liste von Orten, für die Ortskenntnis besteht."}, String),
})
function schema.SF.example(printer)
  printer:highlight([[SF {
  "Eiskundig", Kulturkunde {"Horasreich"}, "Nandusgefälliges Wissen",
}]])
end

schema.SF.Nahkampf = d:singleton(d.Multivalue, {name = "SF.Nahkampf", description = "Liste von Nahkampf-Sonderfertigkeiten."}, String, {
  Ausweichen = d.Numbered:def({name = "Ausweichen", description = "Die SF Ausweichen, unterteilt in I, II und III.", skip = true}, 3),
  Kampfgespuer = "Kampfgespür",
  Kampfreflexe = "Kampfreflexe",
  Klingentaenzer = "Klingentänzer",
  Linkhand = "Linkhand",
  Parierwaffen = d.Numbered:def({name = "Parierwaffen", description = "Die SF Parierwaffen, unterteilt in I und II.", skip = true}, 2),
  Ruestungsgewoehnung = d.Numbered:def({name = "Ruestungsgewoehnung", description = "Die SF Rüstungsgewöhnung, unterteilt in I, II und III.", label = "Rüstungsgewöhnung", skip = true}, 3),
  Schildkampf = d.Numbered:def({name = "Schildkampf", description = "Die SF Schildkampf, unterteilt in I und II.", skip = true}, 2)
}) {}
function schema.SF.Nahkampf.example(printer)
  printer:highlight([[SF.Nahkampf {
  "Aufmerksamkeit", Ausweichen {I, II}, "Kampfreflexe", "Wuchtschlag"
}]])
end

schema.SF.Fernkampf = d:singleton(d.Multivalue, {name = "SF.Fernkampf", description = "Liste von Fernkampf-Sonderfertigkeiten."}, String, {
  Geschuetzmeister = "Geschützmeister",
  Scharfschuetze = d.Multivalue:def({name = "Scharfschuetze", description = "Liste von Talenten, für die Scharfschütze gilt.", label = "Scharfschütze"}, String),
  Meisterschuetze = d.Multivalue:def({name = "Meisterschuetze", description = "Liste von Talenten, für die Meisterschütze gilt.", label = "Meisterschütze"}, String),
  Schnellladen = d.Multivalue:def({name = "Schnellladen", description = "Liste von Talenten, für die Schnellladen gilt."}, String),
}) {}
function schema.SF.Fernkampf.example(printer)
  printer:highlight([[SF.Fernkampf {
  "Geschützmeister", Schnellladen {"Bogen"}
}]])
end

local WaffenlosesKampftalent = d.Matching:def({name = "WaffenlosesKampftalent", description = "Raufen oder Ringen"}, "Raufen", "Ringen")

local Kampfstil = d.Row:def({name = "Kampfstil", description = "Ein erlernter Kampfstil, der AT und PA eines waffenlosen Nahkampftalents um je 1 steigert."},
  {"Name", String}, {"VerbessertesTalent", WaffenlosesKampftalent})

function Kampfstil:__tostring()
  return "Kampfstil " .. self.Name
end

schema.SF.Waffenlos = d:singleton(d.Multivalue, {name = "SF.Waffenlos", description = "Listen waffenloser Sonderfertigkeiten."}, String, {
  Kampfstil = {Kampfstil, d.multi.allow}
}) {}
function schema.SF.Waffenlos.example(printer)
  printer:highlight([[SF.Waffenlos {
  Kampfstil {"Bornländisch", "Ringen"}, "Auspendeln", "Biss", "Block"
}]])
end

schema.SF.Magisch = d:singleton(d.Multivalue, {name = "SF.Magisch", description = "Liste magischer Sonderfertigkeiten"}, String, {
  GefaessDerSterne = "Gefäß der Sterne",
  Matrixregeneration = d.Numbered:def({name = "Matrixregeneration", description = "Die Sonderfertigkeit Matrixregeneration I und II"}, 2),
  MeisterlicheRegeneration = d.Matching:def({name = "MeisterlicheRegeneration", description = "Meisterliche Regeneration; gibt die Leiteigenschaft an, auf deren Basis die nächtliche Regeneration berechnet wird.", label = "Meisterliche Regeneration"}, "KL", "IN", "CH"),
  Regeneration = d.Numbered:def({name = "Regeneration", description = "Die Sonderfertigkeit Regenetation I und II"}, 2),
}) {}
function schema.SF.Magisch.example(printer)
  printer:highlight([[SF.Magisch {
  "Gefäß der Sterne", Regeneration {I}, "Simultanzaubern", "Zauberroutine"
}]])
end

schema.I = 1
schema.II = 2
schema.III = 3
schema.IV = 4
schema.V = 5
schema.VI = 6

local Distanzklasse = d.Matching:def({name = "Distanzklasse", description = "Eine Distanzklasse."}, "[HNSP]*")
local Schaden = d.Matching:def({name = "Schaden", description = "Trefferpunkte einer Waffe."}, "[0-9]*W[0-9]*", "[0-9]*W[0-9]*[%+%-][0-9]+")
local Nahkampfwaffe = d.Row:def({name = "Nahkampfwaffe", description = "Eine Nahkampfwaffe."},
  {"Name", String}, {"Talent", String}, {"DK", Distanzklasse, ""},
  {"TP", Schaden, ""}, {"TP/KK Schwelle", OptNum, {}}, {"TP/KK Schritt", OptNum, {}},
  {"INI", OptNum, {}}, {"WM AT", OptNum, {}}, {"WM PA", OptNum, {}},
  {"BF1", OptNum, {}}, {"BF2", OptNum, {}}, {"Art", String, ""})
local Fernkampfwaffe = d.Row:def({name = "Fernkampfwaffe", description = "Eine Fernkampfwaffe."},
  {"Name", String, ""}, {"Talent", String, ""}, {"TP", Schaden, ""},
  {"Entfernung1", OptNum, {}}, {"Entfernung2", OptNum, {}}, {"Entfernung3", OptNum, {}}, {"Entfernung4", OptNum, {}}, {"Entfernung5", OptNum, {}},
  {"TP/Entfernung1", OptNum, {}}, {"TP/Entfernung2", OptNum, {}}, {"TP/Entfernung3", OptNum, {}}, {"TP/Entfernung4", OptNum, {}}, {"TP/Entfernung5", OptNum, {}},
  {"Ladezeit", OptNum, {}}, {"Geschosse", OptNum, {}}, {"VerminderteWS", schema.Boolean, false},
  {"Art", String, ""})
local Schild = d.Row:def({name = "Schild", description = "Ein Schild."},
  {"Name", String}, {"INI", OptNum, {}}, {"WM AT", OptNum, {}}, {"WM PA", OptNum, {}}, {"BF1", OptNum, {}}, {"BF2", OptNum, {}}, {"Art", String, ""})
local Parierwaffe = d.Row:def({name = "Parierwaffe", description = "Eine Parierwaffe."},
  {"Name", String}, {"INI", OptNum, {}}, {"WM AT", OptNum, {}}, {"WM PA", OptNum, {}}, {"BF1", OptNum, {}}, {"BF2", OptNum, {}}, {"Art", String, ""})
local Zonenruestung = d.Primitive:def({name = "Zonenruestung", description = "Zonenrüstungswert eines Rüstungsteils mit bis zu zwei Dezimalstellen"}, "number", false, 2, 0)
local Ruestungsverarbeitung = d.Primitive:def({name = "Ruestungsverarbeitung", description="Wie gut die Rüstung verarbeitet ist. Entspricht den Sternen in der Zonenrüstungstabelle, WdS 110."}, "number", false, 0, 0)
local Ruestungsteil = d.Row:def({name = "Ruestungsteil", description = "Ein Rüstungsteil."},
  {"Name", String},
  {"Kopf", Zonenruestung, 0}, {"Brust", Zonenruestung, 0}, {"Ruecken", Zonenruestung, 0},
  {"Bauch", Zonenruestung, 0}, {"LArm", Zonenruestung, 0}, {"RArm", Zonenruestung, 0},
  {"LBein", Zonenruestung, 0}, {"RBein", Zonenruestung, 0}, {"Z", schema.Boolean, false},
  {"Sterne", Ruestungsverarbeitung, 0})

schema.Waffen = {
  Nahkampf = d:singleton(d.List, {name = "Waffen.Nahkampf", description = "Liste von Nahkampfwaffen."}, {Nahkampfwaffe}) {},
  Fernkampf = d:singleton(d.List, {name = "Waffen.Fernkampf", description = "Liste von Fernkampfwaffen."}, {Fernkampfwaffe}) {},
  SchildeUndParierwaffen = d:singleton(d.List, {name = "Waffen.SchildeUndParierwaffen", description = "Liste von Schilden und Parierwaffen.", item_name = "Eintrag"}, {Schild, Parierwaffe}) {},
  Ruestung = d:singleton(d.List, {name = "Waffen.Ruestung", description = "Liste von Rüstungsteilen."}, {Ruestungsteil}) {},
}
function schema.Waffen.Nahkampf.example(printer)
  printer:highlight([[Waffen.Nahkampf {
  {"Kurzschwert", "Dolche", "HN", "1W+2", 11, 4, 0, 0, -1, 1},
  -- Steht nicht die Art der Waffe sondern ihr Name vornan, muss die Art extra angegeben werden,
  -- damit etwaige Talentspezialisierungen mit eingerechnet werden können.
  {"Stich", "Dolche", "H", "1W+2", 12, 5, 0, 0, -1, 1, Art="Borndorn"},
}]])
end
function schema.Waffen.Fernkampf.example(printer)
  printer:highlight([[Waffen.Fernkampf {
  {"Langbogen", "Bogen", "1W+6", 10, 25, 50, 100, 200, 3, 2, 1, 0, -1, VerminderteWS=true}
}]])
end
function schema.Waffen.SchildeUndParierwaffen.example(printer)
  printer:highlight([[Waffen.SchildeUndParierwaffen {
  Schild {"Thorwaler Rundschild", -1, -2, 4, 3},
  Parierwaffe {"Buckler (Vollmetall)", 0, 0, 2, -2}
}]])
end
function schema.Waffen.Ruestung.example(printer)
  printer:highlight([[Waffen.Ruestung {
  {"Leichte Platte", Brust=5, Ruecken=4, LBein=2, RBein=2, Sterne=1},
  {"Panzerhandschuhe (Paar)", LArm=2, RArm=2, Z=true},
}]])
end

local Gegenstand = d.Row:def({name = "Gegenstand", description = "Ein Ausrüstungsgegenstand."}, {"Name", String}, {"Gewicht", OptNum, {}}, {"Getragen", String, ""})
local Rationen = d.Row:def({name = "Rationen", description = "Proviant oder Trank mit Rationen."}, {"Name", String}, {"Ration1", OptNum, {}}, {"Ration2", OptNum, {}}, {"Ration3", OptNum, {}}, {"Ration4", OptNum, {}})

d:singleton(d.Multivalue, {name = "Kleidung", description = "Mehrzeiliger Text für den Kleidungs-Kasten auf dem Ausrüstungsbogen."}, String)
function schema.Kleidung.example(printer)
  printer:highlight([[Kleidung {
  "Reisegewand, Konventsgewand",
}]])
end

d:singleton(d.List, {name = "Ausruestung", description = "Liste von Ausrüstungsgegenständen."}, {Gegenstand})
function schema.Ausruestung.example(printer)
  printer:highlight([[Ausruestung {
  {"Tusche"},
  {"Gänsekiele"},
  {"Federmesser"}
}]])
end

d:singleton(d.List, {name = "Proviant", description = "Liste von Proviant & Tränken."}, {Rationen})
function schema.Proviant.example(printer)
  printer:highlight([[Proviant {
  {"Pökelfleisch", 3}
}]])
end

local Muenzen = d.Row:def({name = "Muenzen", description = "Eine Münzenart mit mehreren Werten."}, {"Name", String, ""}, {"Wert1", OptNum, {}}, {"Wert2", OptNum, {}}, {"Wert3", OptNum, {}}, {"Wert4", OptNum, {}}, {"Wert5", OptNum, {}}, {"Wert6", OptNum, {}}, {"Wert7", OptNum, {}}, {"Wert8", OptNum, {}})

d:singleton(d.List, {name = "Vermoegen", description = "Liste von Münzenarten."}, {Muenzen}) {
  {"Dukaten"},
  {"Silbertaler"},
  {"Heller"},
  {"Kreuzer"},
}
function schema.Vermoegen.example(printer)
  printer:highlight([[Vermoegen {
  {"Dukaten", 10},
  {"Silbertaler", 24},
  {"Heller", 56},
  {"Kreuzer", 42},
}]])
end

schema.Vermoegen.Sonstiges = d:singleton(d.Multivalue, {name = "Vermoegen.Sonstiges", description = "Sonstiges Vermögen."}, String) {}
function schema.Vermoegen.Sonstiges.example(printer)
  printer:highlight([[Vermoegen.Sonstiges {
  "Schuldschein 100 Dukaten Nordlandbank"
}]])
end

d:singleton(d.Multivalue, {name = "Verbindungen", description = "Verbindungen."}, String)
function schema.Verbindungen.example(printer)
  printer:highlight([[Verbindungen {
  "Alte Gilde (Gareth)", "Madabasari (Aranien)"
}]])
end

d:singleton(d.Multivalue, {name = "Notizen", description = "Notizen auf dem Ausrüstungs / Liturgienbogen."}, String)
function schema.Notizen.example(printer)
  printer:highlight([[Notizen {
  "Lorem ipsum", "dolor sit amet"
}]])
end

local Tier = d.Row:def({name = "Tier", description = "Werte eines Tiers."},
  {"Name", String}, {"Art", String, ""}, {"INI", OptNum, {}}, {"AT", OptNum, {}}, {"PA", OptNum, {}}, {"TP", Schaden, ""}, {"LE", OptNum, {}}, {"RS", OptNum, {}}, {"KO", OptNum, {}}, {"GS", OptNum, {}}, {"AU", OptNum, {}}, {"MR", OptNum, {}}, {"LO", OptNum, {}}, {"TK", OptNum, {}}, {"ZK", OptNum, {}})
d:singleton(d.List, {name = "Tiere", description = "Liste von Tieren."}, {Tier})
function schema.Tiere.example(printer)

end

local Segnung = d.Row:def({name = "Segnung", description = "Eine der zwölf kleinen Segnungen"},
  {"Seite", OptNum, {}}, {"Name", String})
local Grade = d.Multivalue:def({name = "Grade", description = "Liste von Graden einer Liturgie"}, d.Primitive:def({name = "Grad", description = "Der Grad einer Liturgie (0 - VI)"}, "number", false, 0, 0, 6))
local Liturgie = d.Row:def({name = "Liturgie", description = "Eine Liturgie, die keine der zwölf kleinen Segnungen ist."},
{"Seite", OptNum, {}}, {"Name", String}, {"Grade", Grade, 1})

schema.Mirakel = {
  Liturgiekenntnis = d:singleton(d.Row, {name = "Mirakel.Liturgiekenntnis", description = "Liturgiekenntnis."}, {"Name", String, ""}, {"Wert", OptNum, {}}) {
    "", {}
  },
  Plus = d:singleton(d.List, {name = "Mirakel.Plus", description = "Der Gottheit wohlgefällige Talente"}, {String}) {},
  Minus = d:singleton(d.List, {name = "Mirakel.Minus", description = "Talente, die der Gottheit zuwider sind"}, {String}) {},
  Liturgien = d:singleton(d.List, {name = "Mirakel.Liturgien", description = "Liste von Liturgien.", item_name = "Liturgie"}, {Segnung, Liturgie}) {},
}
function schema.Mirakel.Liturgiekenntnis.example(printer)
  printer:highlight([[Mirakel.Liturgiekenntnis {"Efferd", 7}]])
end
function schema.Mirakel.Plus.example(printer)
  printer:highlight([[Mirakel.Plus {"Wettervorhersage", "Schifffahrt"}]])
end
function schema.Mirakel.Minus.example(printer)
  printer:highlight([[Mirakel.Minus {"Grobschmied", "Kochen"}]])
end
function schema.Mirakel.Liturgien.example(printer)
  printer:highlight([[Mirakel.Liturgien {
  Segnung {76, "Feuersegen"},
  Segnung {78, "Glückssegen"},
  Segnung {79, "Grabsegen"},
  Segnung {82, "Märtyrersegen"},
  Segnung {83, "Schutzsegen"},
  Segnung {84, "Speisesegen"},
  Segnung {85, "Tranksegen"},
  Liturgie {107, "Bannfluch des Heiligen Khalid", {III}},
  Liturgie {261, "Etilias Zeit der Meditation", {I}}
}]])
end

local Merkmale = d.Multivalue:def({name = "Merkmale", description = "Liste von Merkmalen eines Zaubers."}, String, {
  Elementar = {Elementar, d.multi.merge},
  Daemonisch = {Daemonisch, d.multi.merge}
})

local function merkmale(name, doc)
  return d:singleton(d.Multivalue, {name = name, description = doc}, String, {
    Elementar = {Elementar, d.multi.merge},
    Daemonisch = {Daemonisch, d.multi.merge}
  }) {}
end

local Repraesentation = d.Matching:def({name = "Repraesentation", description = "Name einer Repräsentation."}, "Ach", "Alh", "Bor", "Dru", "Dra", "Elf", "Fee", "Geo", "Gro", "Gül", "Kob", "Kop", "Hex", "Mag", "Mud", "Nac", "Srl", "Sch")
local Ritual = d.Row:def({name = "Ritual", description = "Ein Ritual."},
  {"Name", String}, {"Probe1", BasisEig, ""}, {"Probe2", BasisEig, ""},
  {"Probe3", BasisEig, ""}, {"Dauer", String, ""}, {"Kosten", String, ""},
  {"Wirkung", String, ""}, {"Lernkosten", Ganzzahl, 0})
local Ritualkenntnis = d.Row:def({name = "Ritualkenntnis", description = "Ein Ritualkenntnis-Wert einer bestimmten Tradition."},
  {"Name", String}, {"Steigerung", SteigSpalte, "E"}, {"Wert", OptNum, {}})
local Zauber = d.Row:def({name = "Zauber", description = "Ein Zauber."},
  {"Seite", OptNum, {}}, {"Name", String}, {"Probe1", BasisEig}, {"Probe2", BasisEig},
  {"Probe3", BasisEig}, {"ZfW", OptNum, {}}, {"Komplexitaet", SteigSpalte},
  {"Merkmale", Merkmale, {}}, {"Repraesentation", Repraesentation, ""},
  {"Hauszauber", schema.Boolean, false}, {"Spezialisierungen", Spezialisierungen, {}})

schema.Magie = {
  Rituale = d:singleton(d.List, {name = "Magie.Rituale", description = "Liste von Ritualen."}, {Ritual}) {},
  Ritualkenntnis = d:singleton(d.List, {name = "Magie.Ritualkenntnis", description = "Liste von Ritualkenntnissen."}, {Ritualkenntnis}) {},
  Artefakte = d:singleton(d.Multivalue, {name = "Magie.Artefakte", description = "Artefakte."}, String) {},
  Notizen = d:singleton(d.Multivalue, {name = "Magie.Notizen", description = "Notizen auf dem Zauberdokument."}, String) {},
  Repraesentationen = d:singleton(d.List, {name = "Magie.Repraesentationen", description = "Liste beherrschter Repräsentationen."}, {Repraesentation}) {},
  Merkmalskenntnis = merkmale("Magie.Merkmalskenntnis", "Liste gelernter Merkmalskenntnisse"),
  Zauber = d:singleton(d.List, {name = "Magie.Zauber", description = "Liste von gelernten Zaubern."}, {Zauber}) {}
}
function schema.Magie.Rituale.example(printer)
  printer:highlight([[Magie.Rituale {
  {"Bindung des Stabes"},
  {"Kraftfokus"},
  {"Hammer des Magus", "MU", "CH", "KK", "3 AsP"},
  {"Seil des Adepten", Kosten = "1 AsP"},
}]])
end
function schema.Magie.Ritualkenntnis.example(printer)
  printer:highlight([[Magie.Ritualkenntnis {
  {"Gildenmagie", "E", 10}
}]])
end
function schema.Magie.Artefakte.example(printer)
  printer:highlight([[Magie.Artefakte {
  "Karfunkelstein; WINKE WINKE KONTINENT VERSINKE (2 Ladungen); Auslöser: Den Meister ärgern"
}]])
end
function schema.Magie.Repraesentationen.example(printer)
  printer:highlight([[Magie.Repraesentationen {"Mag"}]])
end
function schema.Magie.Merkmalskenntnis.example(printer)
  printer:highlight([[Magie.Merkmalskenntnis {"Antimagie", Elementar {"gesamt"}, Daemonisch {"Agrimoth"}}]])
end
function schema.Magie.Zauber.example(printer)
  printer:highlight([[Magie.Zauber {
  {37,  "Balsam Salabunde",          "KL", "IN", "CH", 8,  "C", {"Heilung", "Form"}, "Mag", Hauszauber=true},
  {41,  "Beherrschung brechen",      "KL", "IN", "CH", 10, "D", {"Antimagie", "Herrschaft"}, "Mag", Spezialisierungen={"Erzwingen"}},
  {187, "Nebelwand und Morgendunst", "KL", "FF", "KO", 10, "C", {"Umwelt", Elementar {"Luft", "Wasser"}}, "Mag"},
  {205, "Pentagramma",               "MU", "MU", "CH", 4,  "D", {"Antimagie", "Beschwörung", Daemonisch {}, "Geisterwesen"}, "Mag"},
}]])
end

local SteigerMethode = d.Matching:def({name = "SteigerMethode", description = "Steigerungsmethode"}, "SE", "Lehrmeister", "Gegenseitig", "Selbststudium")
local SFLernmethode = d.Matching:def({name = "SFLernmethode", description = "Lernmethode für eine Sonderfertigkeit"}, "SE", "Lehrmeister")
local EigSteigerMethode = d.Matching:def({name = "EigSteigerMethode", description = "Steigerungsmethode für Eigenschaften"}, "SE", "Standard")
local SenkMethode = d.Matching:def({name = "SenkMethode", description="Methode der Senkung Schlechter Eigenschaften"}, "SE", "Lehrmeister", "Selbststudium")

local TaW = d.Row:def({name = "TaW", description = "Steigerung eines Talentwerts. Heißen verschiedene Talente gleich, kann der Typ angegeben werden (z.B. Sprache Tuladimya vs Schrift Tulamidya). Der Wert AT muss angegeben werden bei Nahkampftalenten mit AT/PA Verteilung und gibt an, um wie viel die AT erhöht wird."},
  {"Name", String}, {"Zielwert", Ganzzahl}, {"Methode", SteigerMethode, "Gegenseitig"}, {"Typ", nil, {}}, {"AT", OptNum, {}})

local ZfW = d.Row:def({name = "ZfW", description = "Steigerung eines Zauberfertigkeitwerts"},
  {"Name", String}, {"Zielwert", Ganzzahl}, {"Methode", SteigerMethode, "Gegenseitig"})

local Spezialisierung = d.Row:def({name = "Spezialisierung", description = "Erlernen einer Talent- oder Zauberspezialisierung"},
  {"Fertigkeit", String}, {"Name", String}, {"Methode", SFLernmethode, "Lehrmeister"})

local ProfaneSF = d.Row:def({name = "ProfaneSF", description = "Erlernen einer Sonderfertigkeit, die nicht Kampf und nicht magisch ist."},
  {"SF", nil}, {"Kosten", Ganzzahl}, {"Methode", SFLernmethode, "Lehrmeister"})

local NahkampfSF = d.Row:def({name = "NahkampfSF", description = "Erlernen einer Nahkampf-Sonderfertigkeit."},
  {"SF", nil}, {"Kosten", Ganzzahl}, {"Methode", SFLernmethode, "Lehrmeister"})

local FernkampfSF = d.Row:def({name = "FernkampfSF", description = "Erlernen einer Fernkampf-Sonderfertigkeit."},
  {"SF", nil}, {"Kosten", Ganzzahl}, {"Methode", SFLernmethode, "Lehrmeister"})

local WaffenlosSF = d.Row:def({name = "WaffenlosSF", description = "Erlernen einer Waffenlosen Sonderfertigkeit."},
  {"SF", nil}, {"Kosten", Ganzzahl}, {"Methode", SFLernmethode, "Lehrmeister"})
  
local MagischeSF = d.Row:def({name = "MagischeSF", descriptiono = "Erlernen einen magischen Sonderfertigkeit."},
  {"SF", nil}, {"Kosten", Ganzzahl}, {"Methode", SFLernmethode, "Lehrmeister"})

local Eigenschaft = d.Row:def({name = "Eigenschaft", description = "Steigern einer Basis-Eigenschaft oder Zukauf von Punkten zu einer abgeleiteten Eigenschaft."},
  {"Eigenschaft", EigName}, {"Zielwert", Ganzzahl}, {"Methode", EigSteigerMethode, "Standard"})

local RkW = d.Row:def({name = "RkW", description = "Steigerung eines Ritualkenntniswerts."},
  {"Name", String}, {"Zielwert", Ganzzahl}, {"Methode", SteigerMethode, "Gegenseitig"})

local LkW = d.Row:def({name = "LkW", description = "Steigerung des Liturgiekenntniswerts."},
  {"Zielwert", Ganzzahl}, {"Methode", SteigerMethode, "Gegenseitig"})

local Sortiere = d.Multivalue:def({name = "Sortiere", description = "Definiert, wie eine neu aktivierte Fähigkeit (Talent, Zauber, …) in die bestehende Liste einsortiert wird. Ein leerer Wert sortiert am Ende der Liste ein, ansonsten wird zuerst nach der Spalte, die vom ersten Wert gegeben wird, sortiert, dann nach der vom zweiten Wert etc. Wenn in der Liste der erste Wert ein leerer String ist, dann wird das Talent in der letzten Gruppe gleichartiger Talente einsortiert (um z.B. Sprachen von Schriften zu trennen)."}, String)

local Aktiviere = d.Row:def({name = "Aktiviere", description = "Aktiviert ein Talent, einen Zauber, eine Liturgie oder ein Ritual. Ist der gegebene Wert des Talents oder des Zaubers größer 0, wird anschließend eine Steigerung durchgeführt. Für Gesellschafts-, Natur-, Wissens- und Handwerkstalente muss die Talentgruppe angegeben werden; in allen anderen Fällen wird sie ignoriert."},
  {"Subjekt", nil}, {"Methode", SteigerMethode, "Lehrmeister"}, {"Sortierung", Sortiere, "Name"}, {"Talentgruppe", String, ""})

local PermanentEig = d.Matching:def({name = "PermanentEig", description = "Eigenschaft, für die permanente Punkte ausgegeben werden können"}, "AE", "KE")

local Permanent = d.Row:def({name = "Permanent", description = "Permanent ausgegebene AsP oder KaP"},
  {"Subjekt", PermanentEig}, {"Anzahl", Ganzzahl})

local Leiteigenschaft = d.Matching:def({name = "Leiteigenschaft", description = "Leiteigenschaft, aufgrund der sich AE-Zugewinn berechnet."}, "KL", "IN", "CH")

local GrosseMeditation = d.Row:def({name = "GrosseMeditation", description = "Durchführung einer Großen Meditation."},
  {"Leiteigenschaft", Leiteigenschaft}, {"RkP*", Ganzzahl})

local Karmalqueste = d.Row:def({name = "Karmalqueste", description = "Durchführung einer Karmalqueste. Setzt die permanenten KaP zurück auf 0, da sie nicht zurückgekauft werden können, sondern nur als Erleichterung auf die Mirakelprobe für die nächste Karmalqueste gelten."},
  {"LkP*", Ganzzahl}
)

local Spaetweihe = d.Row:def({name = "Spaetweihe", description = "Spätweihe eines Charakters. Die angegebenen Kosten schließen alle gegebenen Segnungen und Liturgien mit ein; SE halbiert die gegebenen Kosten. Liturgiekenntnis wird auf 3 gesetzt."},
  {"Gottheit", String},
  {"Liturgien", d.List:def({name = "Spaetweihe.Liturgien", description = "Liste von Liturgien, die durch die Spätweihe erlernt werden.", item_name = "Liturgie"}, {Segnung, Liturgie}), {}},
  {"Plus", d.List:def({name = "Spaetweihe.Plus", description = "Der Gottheit wohlgefällige Talente"}, {String}), {}},
  {"Minus", d.List:def({name = "Spaetweihe.Minus", description = "Talente, die der Gottheit zuwider sind"}, {String}), {}},
  {"Kosten", Ganzzahl},
  {"Methode", SFLernmethode, "Lehrmeister"})

local MerkmalSF = d.Row:def({name = "MerkmalSF", description = "Erlernen einer oder mehrerer Merkmalskenntnisse. Als Kosten ist die Summe aller Merkmalskenntnisse, die neu gelernt werden, anzugeben."},
  {"Merkmale", Merkmale},
  {"Kosten", Ganzzahl},
  {"Methode", SFLernmethode, "Lehrmeister"})

local Senkung = d.Row:def({name = "Senkung", description = "Senkung einer Schlechten Eigenschaft. Die Schlechte Eigenschaft verschwindet, wenn der Zielwert 0 ist."},
  {"Name", String}, {"Zielwert", Ganzzahl}, {"Methode", SenkMethode, "Lehrmeister"})

local Zugewinn = d.Row:def({name = "Zugewinn", description = "Zugewinn von AP. Kann als Überschrift (fett) formatiert werden."},
  {"Text", String}, {"AP", Ganzzahl}, {"Fett", schema.Boolean, false})

local Frei = d.Row:def({name = "Frei", description = "Freie Modifikation der Charakterdaten. Die Modifikation muss als Lua-Funktion definiert werden, die die aktuellen Charakterdaten erhält und modifiziert."},
  {"Text", String}, {"Modifikation", schema.Function}, {"Kosten", Ganzzahl, 0})

d:singleton(d.List, {name = "Ereignisse", description = "Liste von Ereignissen, die auf den Grundcharakter appliziert werden sollen.", item_name = "Ereignis"}, {
  TaW, ZfW, Spezialisierung, ProfaneSF, NahkampfSF, FernkampfSF, WaffenlosSF, MagischeSF, Eigenschaft, RkW, LkW, Aktiviere, MerkmalSF, Senkung, Permanent, GrosseMeditation, Karmalqueste, Spaetweihe, Zugewinn, Frei
}) {}
function schema.Ereignisse.example(printer)
  printer:highlight([[Ereignisse {
    -- AP-Zugewinn
    Zugewinn {"Ende Jahr des Greifen", 2250,  Fett=true},
    -- steigere MU auf 17
    Eigenschaft {"MU", 17},
    -- steigere Geschichtswissen auf 11 mittels SE
    TaW {"Geschichtswissen", 11, "SE"},
    -- steigere Tanzen auf 4 mittels gegenseitigem Lehren
    TaW {"Tanzen", 4, "Gegenseitig"},
    -- steigere Stäbe auf 11 mittels Lehrmeister. Verteile zwei zusätzliche Punkte auf AT (den Rest auf PA).
    TaW {"Stäbe", 11, "Lehrmeister", AT=2},
    -- aktiviere Wissenstalent Staatskunst und steigere es auf 4 mittels Lehrmeister
    Aktiviere {Talent {"Staatskunst", "KL", "IN", "CH", 4}, "Lehrmeister", Talentgruppe = "Wissen"},
    -- seigere KO auf 12 mittels SE
    Eigenschaft {"KO", 12, "SE"},
    -- aktiviere Sprache Rogolan und steigere sie auf 10 mittels Lehrmeister.
    -- sortiere sie bei den Sprachen ein gemäß ihrem Namen.
    Aktiviere {Sprache {"Rogolan", 21, 10}, "Lehrmeister", Sortierung={"", "Name"}},
    -- aktiviere Sprache Rogolan und steigere sie auf 10 mittels Lehrmeister.
    -- sortiere sie bei den Schriften ein gemäß ihrem Namen.
    Aktiviere {Schrift {"Angram", "A", 21, 10}, "Lehrmeister", Sortierung={"", "Name"}},
    -- aktiviere den Zauber Bannbaladin und steigere ihn auf 10 mittels Lehrmeister
    Aktiviere {Zauber {39, "Bannbaladin", "IN", "CH", "CH", 10, "B", {"Einfluss"}, "Mag"}, "Lehrmeister"},
    -- erlerne die Zauberspezialisierung Erzwingen für den Zauber Horriphobus Schreckgestalt
    Spezialisierung {"Horriphobus Schreckgestalt", "Erzwingen"},
    -- steigere den Zauber Klarum Purum auf 12 mittels Lehrmeister
    ZfW {"Klarum Purum", 12, "Lehrmeister"},
    -- erlerne eine Merkmalskenntnis
    MerkmalSF {{Daemonisch {"Blakharaz"}}, 
    -- senke eine Schlechte Eigenschaft auf 3
    Senkung {"Angst vor Spinnen", 3, "SE"},
    -- gebe drei permanente Karmalpunkte aus.
    Permanent {"KE", -3},
    -- kaufe zwei permanente Astralpunkte zurück (kostet AP)
    Permanent {"AE", 2},
    -- Führe eine Große Meditation mit 12 RkP* durch
    GrosseMeditation {"KL", 12},
    -- Führe eine Karmalqueste mit 7 LkP* durch
    Karmalqueste {7},
    -- erhalte eine Spätweihe
    Spaetweihe {"Boron",
      Plus      = {"Schleichen", "Überzeugen"},
      Minus     = {"Singen", "Überreden"},
      Liturgien = {
        Segnung {76, "Feuersegen"},
        Segnung {78, "Glückssegen"},
        Segnung {79, "Grabsegen"},
        Segnung {82, "Märtyrersegen"},
        Segnung {83, "Schutzsegen"},
        Segnung {84, "Speisesegen"},
        Segnung {85, "Tranksegen"},
        Liturgie {107, "Bannfluch des Heiligen Khalid", {III}},
        Liturgie {261, "Etilias Zeit der Meditation", {I}}
      },
      Kosten  = 2000,
      Methode = "Lehrmeister"
   },
  }]])
end

return schema
