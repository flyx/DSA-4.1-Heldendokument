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
  {"Ruestung", Zeilen, 6})

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
  {"Liturgien", Zeilen, 23},
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
  {"Notizen", Zeilen, 6})

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

schema.Vorteile.Magisch = d:singleton(d.Multivalue, {name = "Vorteile.Magisch", description = "Liste von magischen Vorteilen."}, String, {
  -- TODO: Astrale Regeneration
  Eigeboren = "Eigeboren",
  BegabungFuerMerkmal = d.Multivalue:def({name = "BegabungFuerMerkmal", description = "Begabung für ein oder mehrere Merkmale.", label = "Begabung für Merkmal"}, String, {
    Elementar = Elementar,
    Daemonisch = Daemonisch
  }),
  BegabungFuerRitual = d.List:def({name = "BegabungFuerRitual", description = "Begabung für ein oder mehrere Rituale", label = "Begabung für Ritual"}, {String}),
  BegabungFuerZauber = d.List:def({name = "BegabungFuerZauber", description = "Begabung für einen oder mehrere Zauber", label = "Begabung für Zauber"}, {String}),
  Meisterhandwerk = d.List:def({name = "Meisterhandwerk", description = "Liste von Talenten, für die ein Meisterhandwerk existiert."}, {String}),
}) {}

d:singleton(d.Multivalue, {name = "Nachteile", description = "Liste von nicht-magischen Nachteilen"}, String, {
  Glasknochen = "Glasknochen",
  Behaebig = "Behäbig",
  Kleinwuechsig = "Kleinwüchsig",
  Zwergenwuchs = "Zwergenwuchs",
  UnfaehigkeitFuerTalentgruppe = d.List:def({name = "UnfaehigkeitFuerTalentgruppe", description = "Unfähigkeit für eine oder mehrere Talentgruppen", label = "Unfähigkeit für Talentgruppe"}, {Talentgruppe}),
  UnfaehigkeitFuerTalent = d.List:def({name = "UnfaehigkeitFuerTalent", description = "Unfähigkeit für ein oder mehrere bestimmte Talente", label = "Unfähigkeit für Talent"}, {String}),
  Unstet = "Unstet",
})

schema.Nachteile.Magisch = d:singleton(d.Multivalue, {name = "Nachteile.Magisch", description = "Liste von magischen Nachteilen."}, String, {
  -- TODO: Schwache Ausstrahlung
  UnfaehigkeitFuerMerkmal = d.Multivalue:def({name = "UnfaehigkeitFuerMerkmal", description = "Unfähigkeit für ein oder mehrere Merkmale.", label = "Unfähigkeit für Merkmal"}, String, {
    Elementar = Elementar,
    Daemonisch = Daemonisch
  }),
}) {}

local Ganzzahl = d.Primitive:def({name = "Ganzzahl", description = "Eine Zahl in Dezimalschreibweise."}, "number", false, 0)


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

d:singleton(d.Record, {name = "AP", description = "Abenteuerpunkte."},
  {"Gesamt", OptNum, {}},
  {"Eingesetzt", OptNum, {}},
  {"Guthaben", OptNum, {}})

local SteigSpalte = d.Matching:def({name = "SteigSpalte", description = "Eine Steigerungsspalte."}, "A%*?", "B", "C", "D", "E", "F", "G", "H")
local Behinderung = d.Matching:def({name = "Behinderung", description = "Behinderung."}, "%-", "BE", "BE%-[1-9]", "BEx[2-9]")
local BasisEig = d.Matching:def({name = "BasisEig", description = "Name einer Basis-Eigenschaft, oder ** in seltenen Fällen."}, "%*%*", "MU", "KL", "IN", "CH", "FF", "GE", "KO", "KK")
local Spezialisierungen = d.Multivalue:def({name = "Spezialisierungen", description = "Liste von Spezialisierungen. Leere tables {} können als Zeilenumbruch benutzt werden."}, String)

d.Row:def({name = "Nah", description = "Ein Nahkampf-Talent mit AT/PA Verteilung."},
  {"Name", String}, {"Steigerungsspalte", SteigSpalte, ""}, {"BE", Behinderung, ""}, {"AT", OptNum, {}}, {"PA", OptNum, {}}, {"TaW", OptNum, {}}, {"Spezialisierungen", Spezialisierungen, {}})
d.Row:def({name = "NahAT", description = "Ein Nahkampf-Talent, dessen Wert ausschließlich zur Attacke dient und das keine AT/PA Verteilung hat."},
  {"Name", String}, {"Steigerungsspalte", SteigSpalte, ""}, {"BE", Behinderung, ""}, {"TaW", OptNum, {}}, {"Spezialisierungen", Spezialisierungen, {}})
d.Row:def({name = "Fern", description = "Ein Fernkampf-Talent."},
  {"Name", String}, {"Steigerungsspalte", SteigSpalte, ""}, {"BE", Behinderung, ""}, {"TaW", OptNum, {}}, {"Spezialisierungen", Spezialisierungen, {}})
d.Row:def({name = "KoerperTalent", description = "Ein Talent aus der Gruppe der Körperlichen Talente."},
  {"Name", String}, {"Probe1", BasisEig, ""}, {"Probe2", BasisEig, ""}, {"Probe3", BasisEig, ""}, {"BE", Behinderung, ""}, {"TaW", OptNum, {}}, {"Spezialisierungen", Spezialisierungen, {}})
d.Row:def({name = "Talent", description = "Ein allgemeines Talent."},
  {"Name", String}, {"Probe1", BasisEig, ""}, {"Probe2", BasisEig, ""}, {"Probe3", BasisEig, ""}, {"TaW", OptNum, {}}, {"Spezialisierungen", Spezialisierungen, {}})

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
  Natur = d:singleton(d.List, {name = "Talente.Natur", description = "Liste von Naturtalenten."}, {schema.Talent}) {
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

d:singleton(d.Multivalue, {name = "SF", description = "Sonderfertigkeiten (außer Kampf & magischen)"}, String, {
  Kulturkunde = d.Multivalue:def({name = "Kulturkunde", description = "Liste von Kulturen, für die Kulturkunde besteht."}, String),
  Ortskenntnis = d.Multivalue:def({name = "Ortskenntnis", description = "Liste von Orten, für die Ortskenntnis besteht."}, String),
})

schema.SF.Nahkampf = d:singleton(d.Multivalue, {name = "SF.Nahkampf", description = "Liste von Nahkampf-Sonderfertigkeiten."}, String, {
  Ausweichen = d.Numbered:def({name = "Ausweichen", description = "Die SF Ausweichen, unterteilt in I, II und III.", skip = true}, 3),
  Kampfgespuer = "Kampfgespür",
  Kampfreflexe = "Kampfreflexe",
  Linkhand = "Linkhand",
  Parierwaffen = d.Numbered:def({name = "Parierwaffen", description = "Die SF Parierwaffen, unterteilt in I und II.", skip = true}, 2),
  Ruestungsgewoehnung = d.Numbered:def({name = "Ruestungsgewoehnung", description = "Die SF Rüstungsgewöhnung, unterteilt in I, II und III.", label = "Rüstungsgewöhnung", skip = true}, 3),
  Schildkampf = d.Numbered:def({name = "Schildkampf", description = "Die SF Schildkampf, unterteilt in I und II.", skip = true}, 2)
}) {}

schema.SF.Fernkampf = d:singleton(d.Multivalue, {name = "SF.Fernkampf", description = "Liste von Fernkampf-Sonderfertigkeiten."}, String, {
  Scharfschuetze = d.Multivalue:def({name = "Scharfschuetze", description = "Liste von Talenten, für die Scharfschütze gilt.", label = "Scharfschütze"}, String),
  Meisterschuetze = d.Multivalue:def({name = "Meisterschuetze", description = "Liste von Talenten, für die Meisterschütze gilt.", label = "Meisterschütze"}, String),
  Schnellladen = d.Multivalue:def({name = "Schnellladen", description = "Liste von Talenten, für die Schnellladen gilt."}, String),
}) {}

local WaffenlosesKampftalent = d.Matching:def({name = "WaffenlosesKampftalent", description = "Raufen oder Ringen"}, "Raufen", "Ringen")

local Kampfstil = d.Row:def({name = "Kampfstil", description = "Ein erlernter Kampfstil, der AT und PA eines waffenlosen Nahkampftalents um je 1 steigert."},
  {"Name", String}, {"VerbessertesTalent", WaffenlosesKampftalent})

function Kampfstil:__tostring()
  return "Kampfstil " .. self.Name
end

schema.SF.Waffenlos = d:singleton(d.Multivalue, {name = "SF.Waffenlos", description = "Listen waffenloser Sonderfertigkeiten."}, String, {
  Kampfstil = {Kampfstil, d.multi.allow}
}) {}

schema.SF.Magisch = d:singleton(d.Multivalue, {name = "SF.Magisch", description = "Liste magischer Sonderfertigkeiten"}, String, {
  GefaessDerSterne = "Gefäß der Sterne"
}) {}

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
  {"Geschosse1", OptNum, {}}, {"Geschosse2", OptNum, {}}, {"Geschosse3", OptNum, {}}, {"Art", String, ""})
local Schild = d.Row:def({name = "Schild", description = "Ein Schild."},
  {"Name", String}, {"INI", Ganzzahl}, {"WM AT", Ganzzahl}, {"WM PA", Ganzzahl}, {"BF1", OptNum, {}}, {"BF2", OptNum, {}}, {"Art", String, ""})
local Parierwaffe = d.Row:def({name = "Parierwaffe", description = "Eine Parierwaffe."},
  {"Name", String}, {"INI", Ganzzahl}, {"WM AT", Ganzzahl}, {"WM PA", Ganzzahl}, {"BF1", OptNum, {}}, {"BF2", OptNum, {}}, {"Art", String, ""})
local Zonenruestung = d.Primitive:def({name = "Zonenruestung", description = "Zonenrüstungswert eines Rüstungsteils mit bis zu zwei Dezimalstellen"}, "number", false, 2, 0)
local Ruestungsteil = d.Row:def({name = "Ruestungsteil", description = "Ein Rüstungsteil."},
  {"Name", String}, {"gRS", Zonenruestung}, {"gBE", Zonenruestung},
  {"Kopf", Zonenruestung, 0}, {"Brust", Zonenruestung, 0}, {"Ruecken", Zonenruestung, 0},
  {"LArm", Zonenruestung, 0}, {"RArm", Zonenruestung, 0}, {"Bauch", Zonenruestung, 0},
  {"LBein", Zonenruestung, 0}, {"RBein", Zonenruestung, 0})

schema.Waffen = {
  Nahkampf = d:singleton(d.List, {name = "Waffen.Nahkampf", description = "Liste von Nahkampfwaffen."}, {Nahkampfwaffe}) {},
  Fernkampf = d:singleton(d.List, {name = "Waffen.Fernkampf", description = "Liste von Fernkampfwaffen."}, {Fernkampfwaffe}) {},
  SchildeUndParierwaffen = d:singleton(d.List, {name = "Waffen.SchildeUndParierwaffen", description = "Liste von Schilden und Parierwaffen.", item_name = "Eintrag"}, {Schild, Parierwaffe}) {},
  Ruestung = d:singleton(d.List, {name = "Waffen.Ruestung", description = "Liste von Rüstungsteilen."}, {Ruestungsteil}) {},
}

local Gegenstand = d.Row:def({name = "Gegenstand", description = "Ein Ausrüstungsgegenstand."}, {"Name", String}, {"Gewicht", OptNum, {}}, {"Getragen", String, ""})
local Rationen = d.Row:def({name = "Rationen", description = "Proviant oder Trank mit Rationen."}, {"Name", String}, {"Ration1", OptNum, {}}, {"Ration2", OptNum, {}}, {"Ration3", OptNum, {}}, {"Ration4", OptNum, {}})

d:singleton(d.Multivalue, {name = "Kleidung", description = "Mehrzeiliger Text für den Kleidungs-Kasten auf dem Ausrüstungsbogen."}, String)
d:singleton(d.List, {name = "Ausruestung", description = "Liste von Ausrüstungsgegenständen."}, {Gegenstand})
d:singleton(d.List, {name = "Proviant", description = "Liste von Proviant & Tränken."}, {Rationen})

local Muenzen = d.Row:def({name = "Muenzen", description = "Eine Münzenart mit mehreren Werten."}, {"Name", String, ""}, {"Wert1", OptNum, {}}, {"Wert2", OptNum, {}}, {"Wert3", OptNum, {}}, {"Wert4", OptNum, {}}, {"Wert5", OptNum, {}}, {"Wert6", OptNum, {}}, {"Wert7", OptNum, {}}, {"Wert8", OptNum, {}})

d:singleton(d.List, {name = "Vermoegen", description = "Liste von Münzenarten."}, {Muenzen}) {
  {"Dukaten"},
  {"Silbertaler"},
  {"Heller"},
  {"Kreuzer"},
}
schema.Vermoegen.Sonstiges = d:singleton(d.Multivalue, {name = "Vermoegen.Sonstiges", description = "Sonstiges Vermögen."}, String) {}

d:singleton(d.Multivalue, {name = "Verbindungen", description = "Verbindungen."}, String)
d:singleton(d.Multivalue, {name = "Notizen", description = "Notizen auf dem Ausrüstungs / Liturgienbogen."}, String)

local Tier = d.Row:def({name = "Tier", description = "Werte eines Tiers."}, {"Name", String}, {"Art", String, ""}, {"INI", OptNum, {}}, {"AT", OptNum, {}}, {"PA", OptNum, {}}, {"TP", Schaden, ""}, {"LE", OptNum, {}}, {"RS", OptNum, {}}, {"KO", OptNum, {}}, {"KO", OptNum, {}}, {"GS", OptNum, {}}, {"AU", OptNum, {}}, {"MR", OptNum, {}}, {"LO", OptNum, {}}, {"TK", OptNum, {}}, {"ZK", OptNum, {}})
d:singleton(d.List, {name = "Tiere", description = "Liste von Tieren."}, {Tier})

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

local Merkmale = d.Multivalue:def({name = "Merkmale", description = "Liste von Merkmalen eines Zaubers."}, String, {
  Elementar = Elementar,
  Daemonisch = Daemonisch
})

local function merkmale(name, doc)
  return d:singleton(d.Multivalue, {name = name, description = doc}, String, {
    Elementar = Elementar,
    Daemonisch = Daemonisch
  }) {}
end

local Repraesentation = d.Matching:def({name = "Repraesentation", description = "Name einer Repräsentation."}, "Ach", "Alh", "Bor", "Dru", "Dra", "Elf", "Fee", "Geo", "Gro", "Gül", "Kob", "Kop", "Hex", "Mag", "Mud", "Nac", "Srl", "Sch")
local Ritual = d.Row:def({name = "Ritual", description = "Ein Ritual."},
  {"Name", String}, {"Probe1", BasisEig, ""}, {"Probe2", BasisEig, ""},
  {"Probe3", BasisEig, ""}, {"Dauer", OptNum, {}}, {"Kosten", OptNum, {}},
  {"Wirkung", OptNum, {}}, {"Lernkosten", Ganzzahl, 0})
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
  Regeneration = d:singleton(d.Primitive, {name = "Magie.Regeneration", description = "AsP-Regeneration pro Phase."}, "string", true) {},
  Artefakte = d:singleton(d.Multivalue, {name = "Magie.Artefakte", description = "Artefakte."}, String) {},
  Notizen = d:singleton(d.Multivalue, {name = "Magie.Notizen", description = "Notizen auf dem Zauberdokument."}, String) {},
  Repraesentationen = d:singleton(d.List, {name = "Magie.Repraesentationen", description = "Liste beherrschter Repräsentationen."}, {Repraesentation}) {},
  Merkmalskenntnis = merkmale("Magie.Merkmalskenntnis", "Liste gelernter Merkmalskenntnisse"),
  Zauber = d:singleton(d.List, {name = "Magie.Zauber", description = "Liste von gelernten Zaubern."}, {Zauber}) {}
}

local SteigerMethode = d.Matching:def({name = "SteigerMethode", description = "Steigerungsmethode"}, "SE", "Lehrmeister", "Gegenseitig", "Selbststudium")
local SFLernmethode = d.Matching:def({name = "SFLernmethode", description = "Lernmethode für eine Sonderfertigkeit"}, "SE", "Lehrmeister")
local EigSteigerMethode = d.Matching:def({name = "EigSteigerMethode", description = "Steigerungsmethode für Eigenschaften"}, "SE", "Standard")

local TaW = d.Row:def({name = "TaW", description = "Steigerung eines Talentwerts. Heißen verschiedene Talente gleich, kann der Typ angegeben werden (z.B. Sprache Tuladimya vs Schrift Tulamidya)."},
  {"Name", String}, {"Zielwert", Ganzzahl}, {"Methode", SteigerMethode, "Gegenseitig"}, {"Typ", nil, {}})

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

local Eigenschaft = d.Row:def({name = "Eigenschaft", description = "Steigern einer Basis-Eigenschaft oder Zukauf von Punkten zu einer abgeleiteten Eigenschaft."},
  {"Eigenschaft", EigName}, {"Zielwert", Ganzzahl}, {"Methode", EigSteigerMethode, "Standard"})

local RkW = d.Row:def({name = "RkW", description = "Steigerung eines Ritualkenntniswerts."},
  {"Name", String}, {"Zielwert", Ganzzahl}, {"Methode", SteigerMethode, "Gegenseitig"})

local LkW = d.Row:def({name = "LkW", description = "Steigerung des Liturgiekenntniswerts."},
  {"Zielwert", Ganzzahl}, {"Methode", SteigerMethode, "Gegenseitig"})

local Sortiere = d.Multivalue:def({name = "Sortiere", description = "Definiert, wie eine neu aktivierte Fähigkeit (Talent, Zauber, …) in die bestehende Liste einsortiert wird. Ein leerer Wert sortiert am Ende der Liste ein, ansonsten wird zuerst nach der Spalte, die vom ersten Wert gegeben wird, sortiert, dann nach der vom zweiten Wert etc. Wenn in der Liste der erste Wert ein leerer String ist, dann wird das Talent in der letzten Gruppe gleichartiger Talente einsortiert (um z.B. Sprachen von Schriften zu trennen)."}, String)

local Aktiviere = d.Row:def({name = "Aktiviere", description = "Aktiviert ein Talent, einen Zauber, eine Liturgie oder ein Ritual. Ist der gegebene Wert des Talents oder des Zaubers größer 0, wird anschließend eine Steigerung durchgeführt. Für Gesellschafts-, Natur-, Wissens- und Handwerkstalente muss die Talentgruppe angegeben werden; in allen anderen Fällen wird sie ignoriert."},
  {"Subjekt", nil}, {"Methode", SteigerMethode, "Lehrmeister"}, {"Sortierung", Sortiere, "Name"}, {"Talentgruppe", String, ""})

local Zugewinn = d.Row:def({name = "Zugewinn", description = "Zugewinn von AP. Kann als Überschrift (fett) formatiert werden."},
  {"Text", String}, {"AP", Ganzzahl}, {"Fett", schema.Boolean, false})

d:singleton(d.List, {name = "Ereignisse", description = "Liste von Ereignissen, die auf den Grundcharakter appliziert werden sollen.", item_name = "Ereignis"}, {
  TaW, ZfW, Spezialisierung, ProfaneSF, NahkampfSF, FernkampfSF, WaffenlosSF, Eigenschaft, RkW, LkW, Aktiviere, Zugewinn
}) {}

return schema