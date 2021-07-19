local d = require("schemadef")

local gendoc = ...

local schema = d(gendoc)
local Simple = schema.Simple
local String = schema.String
local Multiline = schema.Multiline

local Zeilen = d.Number:def({name = "Zeilen", documentation = "Anzahl Zeilen in einem Feld oder einer Tabelle"}, 0, 100, 0)

local Front = d.Record:def({name = "Front", documentation = "Frontseite"},
  {"Aussehen", Zeilen, 3},
  {"Vorteile", Zeilen, 7},
  {"Nachteile", Zeilen, 7})

local Talentliste = d.MixedList:def({name = "Talentliste", item_name = "Gruppe"},
  d.Number:def({name = "Sonderfertigkeiten", documentation = "Zeilen für Sonderfertigkeiten"}, 0, 100, 0),
  d.Number:def({name = "Gaben", documentation = "Zeilen für Gaben"}, 0, 100, 0),
  d.Number:def({name = "Begabungen", documentation = "Zeilen für Übernatürliche Begabungen"}, 0, 100, 0),
  d.Number:def({name = "Kampf", documentation = "Zeilen für Kampftalente"}, 0, 100, 0),
  d.Number:def({name = "Koerper", documentation = "Zeilen für Körperliche Talente"}, 0, 100, 0),
  d.Number:def({name = "Gesellschaft", documentation = "Zeilen für Gesellschaftstalente"}, 0, 100, 0),
  d.Number:def({name = "Natur", documentation = "Zeilen für Naturtalente"}, 0, 100, 0),
  d.Number:def({name = "Wissen", documentation = "Zeilen für Wissenstalente"}, 0, 100, 0),
  d.Number:def({name = "SprachenUndSchriften", documentation = "Zeilen für Sprachen & Schriften"}, 0, 100, 0),
  d.Number:def({name = "Handwerk", documentation = "Zeilen für Handwerkstalente"}, 0, 100, 0)
)
function Talentliste:documentation(printer)
  printer:p("Sonderfertigkeiten & Talente. Der Inhalt dieses Werts definiert die Reihenfolge der Untergruppen und die Anzahl Zeilen jeder Untergruppe.")
end

local Kampfbogen = d.Record:def({name = "Kampfbogen", documentation = "Kampfbogen."},
  {"Nahkampf", d.Record:def({name = "NahkampfWaffenUndSF", documentation = "Zeilen für Nahkampfwaffen und -SF."},
    {"Waffen", Zeilen, 5},
    {"SF", Zeilen, 3}), {}},
  {"Fernkampf", d.Record:def({name = "FernkampfWaffenUndSF", documentation = "Zeilen für Fernkampfwaffen und -SF."},
    {"Waffen", Zeilen, 3},
    {"SF", Zeilen, 3}), {}},
  {"Waffenlos", d.Record:def({name = "Waffenlos", documentation = "Zeilen für waffenlose Manöver."},
    {"SF", Zeilen, 3}), {}},
  {"Schilde", Zeilen, 2},
  {"Ruestung", Zeilen, 6})

local Ausruestungsbogen = d.Record:def({name = "Ausruestungsbogen", documentation = "Ausrüstungsbogen."},
  {"Kleidung", Zeilen, 5},
  {"Gegenstaende", Zeilen, 33},
  {"Proviant", Zeilen, 8},
  {"Vermoegen", d.Record:def({name = "Vermoegensbox", documentation = "Zeilen in der Vermögensbox."}, {"Muenzen", Zeilen, 4}, {"Sonstiges", Zeilen, 7}), {}},
  {"Verbindungen", Zeilen, 9},
  {"Notizen", Zeilen, 7},
  {"Tiere", Zeilen, 4})

local Liturgiebogen = d.Record:def({name = "Liturgiebogen", documentation = "Bogen für Liturgien & Ausrüsung."},
  {"Kleidung", Zeilen, 5},
  {"Liturgien", Zeilen, 27},
  {"Gegenstaende", Zeilen, 29},
  {"ProviantVermoegen", d.Record:def({name = "ProviantVermoegen", documentation = "Zeilen für Proviant & Vermögen Box."}, {"Gezaehlt", Zeilen, 4}, {"Sonstiges", Zeilen, 5}), {}},
  {"VerbindungenNotizen", Zeilen, 9},
  {"Tiere", Zeilen, 4})

local Zauberdokument = d.Record:def({name = "Zauberdokument", documentation = "Zauberdokument."},
  {"VorUndNachteile", Zeilen, 5},
  {"Sonderfertigkeiten", Zeilen, 5},
  {"Rituale", Zeilen, 30},
  {"Ritualkenntnis", Zeilen, 2},
  {"Artefakte", Zeilen, 9},
  {"Notizen", Zeilen, 6})

local Zauberliste = d.Void:def({name = "Zauberliste", documentation = "Zauberliste."})
local Ereignisliste = d.Void:def({name = "Ereignisliste", documentation = "Ereignisliste."})

d:singleton(d.MixedList, {name = "Layout", item_name = "Seite"},
  Front, Talentliste, Kampfbogen, Ausruestungsbogen, Liturgiebogen,
  Zauberdokument, Zauberliste, Ereignisliste
) {
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

d:singleton(d.Record, {name = "Held", documentation = [[Grundlegende Daten des Helden.]]},
  {"Name", Simple, ""},
  {"GP", Simple, ""},
  {"Rasse", Simple, ""},
  {"Kultur", Simple, ""},
  {"Profession", Simple, ""},
  {"Geschlecht", Simple, ""},
  {"Tsatag", Simple, ""},
  {"Groesse", Simple, ""},
  {"Gewicht", Simple, ""},
  {"Haarfarbe", Simple, ""},
  {"Augenfarbe", Simple, ""},
  {"Stand", Simple, ""},
  {"Sozialstatus", Simple, ""},
  {"Titel", Multiline, ""},
  {"Aussehen", Multiline, ""})

local Talentgruppe = d.Matching:def({name = "Talentgruppe", documentation = "Eine der existierenden Talentgruppen"}, "Kampf", "Nahkampf", "Fernkampf", "Koerper", "Gesellschaft", "Natur", "Wissen", "SprachenUndSchriften", "Handwerk")

local Element = d.Matching:def({name = "Element", documentation = "Name eines Elements, oder 'gesamt'."}, "gesamt", "Eis", "Humus", "Feuer", "Wasser", "Luft", "Erz")
local Elementar = d.MixedList:def({name = "Elementar", documentation = "Spezifikation elementarer Merkmale."}, Element)
local Domaene = d.Matching:def({name = "Domaene", documentation = "Name einer Domäne, oder 'gesamt'"}, "gesamt", "Blakharaz", "Belhalhar", "Charyptoroth", "Lolgramoth", "Thargunitoth", "Amazeroth", "Belshirash", "Asfaloth", "Tasfarelel", "Belzhorash", "Agrimoth", "Belkelel")
local Daemonisch = d.MixedList:def({name = "Daemonisch", documentation = "Spezifikation dämonischer Merkmale."}, Domaene)
local Ausbildungsname = d.Matching:def({name = "Ausbildungsname", documentation = "Name einer akademischen Ausbildung"}, "Gelehrter?", "Magier", "Magierin", "Krieger", "Kriegerin")

local EigName = d.Matching:def({name = "EigName", documentation = "Name einer steigerbaren Eigenschaft"}, "MU", "KL", "IN", "CH", "FF", "GE", "KO", "KK", "LE", "AU", "AE", "MR")

d:singleton(d.ListWithKnown, {name = "Vorteile", documentation = "Liste von nicht-magischen Vorteilen."}, {
  AkademischeAusbildung = d.FixedList:def({name = "AkademischeAusbildung", documentation = "Akademische Ausbildung"}, Ausbildungsname, 0, 1),
  BegabungFuerEigenschaft = d.FixedList:def({name = "BegabungFuerEigenschaft", documentation = "Begabung für eine oder mehrere Eigenschaften. Üblicherweise nicht frei wählbar, kommt aber etwa in 7G vor."}, EigName),
  BegabungFuerTalent = d.FixedList:def({name = "BegabungFuerTalent", documentation = "Begabung für ein oder mehrere Talente"}, String),
  BegabungFuerTalentgruppe = d.FixedList:def({name = "BegabungFuerTalentgruppe", documentation = "Begabung für eine oder mehrere Talentgruppen."}, Talentgruppe),
  ["Eidetisches Gedächtnis"] = "EidetischesGedaechtnis",
  Eisern = "Eisern",
  Flink = d.Number:def({name = "Flink", documentation = "Flink(2) ist exklusiv für Goblins, die es zweimal wählen dürfen."}, 1, 2, 0),
  ["Gutes Gedächtnis"] = "GutesGedaechtnis",
}, { -- optional
  Flink = true
})

schema.Vorteile.Magisch = d:singleton(d.ListWithKnown, {name = "Vorteile.Magisch", documentation = "Liste von magischen Vorteilen."}, {
  -- TODO: Astrale Regeneration
  Eigeboren = "Eigeboren",
  BegabungFuerMerkmal = d.ListWithKnown:def({name = "BegabungFuerMerkmal", documentation = "Begabung für ein oder mehrere Merkmale."}, {
    Elementar = Elementar,
    Daemonisch = Daemonisch
  }, { -- optional
    Elementar = true,
    Daemonisch = true,
  }),
  BegabungFuerRitual = d.FixedList:def({name = "BegabungFuerRitual", documentation = "Begabung für ein oder mehrere Rituale"}, String),
  BegabungFuerZauber = d.FixedList:def({name = "BegabungFuerZauber", documentation = "Begabung für einen oder mehrere Zauber"}, String),
}) {}

d:singleton(d.ListWithKnown, {name = "Nachteile", documentation = "Liste von nicht-magischen Nachteilen"}, {
  Glasknochen = "Glasknochen",
  ["Behäbig"] = "Behaebig",
  ["Kleinwüchsig"] = "Kleinwuechsig",
  Zwergenwuchs = "Zwergenwuchs",
  UnfaehigkeitFuerTalentgruppe = d.FixedList:def({name = "UnfaehigkeitFuerTalentgruppe", documentation = "Unfähigkeit für eine oder mehrere Talentgruppen"}, Talentgruppe),
  UnfaehigkeitFuerTalent = d.FixedList:def({name = "UnfaehigkeitFuerTalent", documentation = "Unfähigkeit für ein oder mehrere bestimmte Talente"}, String),
  Unstet = "Unstet",
})

schema.Nachteile.Magisch = d:singleton(d.ListWithKnown, {name = "Nachteile.Magisch", documentation = "Liste von magischen Nachteilen."}, {
  -- TODO: Schwache Ausstrahlung
  UnfaehigkeitFuerMerkmal = d.ListWithKnown:def({name = "UnfaehigkeitFuerMerkmal", documentation = "Unfähigkeit für ein oder mehrere Merkmale."}, {
    Elementar = Elementar,
    Daemonisch = Daemonisch
  }, { -- optional
    Elementar = true,
    Daemonisch = true,
  }),
}) {}

-- TODO: nicht-Ganzzahlen erkennen und Fehler werfen
local Ganzzahl = d.Number:def({name = "Ganzzahl", documentation = "Eine Zahl in Dezimalschreibweise."}, -1000, 1000, 0)

local BasisEig = d.FixedList:def({name = "BasisEig", documentation = "Eine Basiseigenschaft mit Modifikator, Startwert und aktuellem Wert."}, Ganzzahl, 3, 3)
local AbgeleiteteEig = d.FixedList:def({name = "AbgeleiteteEig", documentation = "Eine abgeleitete Eigenschaft mit Modifikator, zugekauften Punkten und permanent verlorenen Punkten."}, Ganzzahl, 3, 3)

d:singleton(d.Record, {name = "Eigenschaften", documentation = "Liste von Basis- und abgeleiteten Eigenschaften"},
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

d:singleton(d.Record, {name = "AP", documentation = "Abenteuerpunkte."},
  {"Gesamt", Simple, ""},
  {"Eingesetzt", Simple, ""},
  {"Guthaben", Simple, ""})

local SteigSpalte = d.Matching:def({name = "SteigSpalte", documentation = "Eine Steigerungsspalte."}, "A%*?", "B", "C", "D", "E", "F", "G", "H")
local Behinderung = d.Matching:def({name = "Behinderung", documentation = "Behinderung."}, "%-", "BE", "BE%-[1-9]", "BEx[2-9]")
local BasisEig = d.Matching:def({name = "BasisEig", documentation = "Name einer Basis-Eigenschaft, oder ** in seltenen Fällen."}, "%*%*", "MU", "KL", "IN", "CH", "FF", "GE", "KO", "KK")
local Spezialisierungen = d.Multivalue:def({name = "Spezialisierungen", documentation = "Liste von Spezialisierungen. Leere tables {} können als Zeilenumbruch benutzt werden."})

d.HeterogeneousList:def({name = "Nah", documentation = "Ein Nahkampf-Talent mit AT/PA Verteilung."},
  {"Name", String, ""}, {"Steigerungsspalte", SteigSpalte, ""}, {"BE", Behinderung, ""}, {"AT", Simple, ""}, {"PA", Simple, ""}, {"TaW", Simple, ""}, {"Spezialisierungen", Spezialisierungen, {}})
d.HeterogeneousList:def({name = "NahAT", documentation = "Ein Nahkampf-Talent, dessen Wert ausschließlich zur Attacke dient und das keine AT/PA Verteilung hat."},
  {"Name", String, ""}, {"Steigerungsspalte", SteigSpalte, ""}, {"BE", Behinderung, ""}, {"TaW", Simple, ""}, {"Spezialisierungen", Spezialisierungen, {}})
d.HeterogeneousList:def({name = "Fern", documentation = "Ein Fernkampf-Talent."},
  {"Name", String, ""}, {"Steigerungsspalte", SteigSpalte, ""}, {"BE", Behinderung, ""}, {"TaW", Simple, ""}, {"Spezialisierungen", Spezialisierungen, {}})
d.HeterogeneousList:def({name = "KoerperTalent", documentation = "Ein Talent aus der Gruppe der Körperlichen Talente."},
  {"Name", String, ""}, {"Probe1", BasisEig, ""}, {"Probe2", BasisEig, ""}, {"Probe3", BasisEig, ""}, {"BE", Behinderung, ""}, {"TaW", Simple, ""}, {"Spezialisierungen", Spezialisierungen, {}})
d.HeterogeneousList:def({name = "Talent", documentation = "Ein allgemeines Talent."},
  {"Name", String, ""}, {"Probe1", BasisEig, ""}, {"Probe2", BasisEig, ""}, {"Probe3", BasisEig, ""}, {"TaW", Simple, ""}, {"Spezialisierungen", Spezialisierungen, {}})

d.FixedList:def({name = "Familie", documentation = "Liste von Sprachen oder Schriften in einer Familie."}, String)
d.HeterogeneousList:def({name = "Muttersprache", documentation = "Die Muttersprache des Helden. Anders als andere Sprachen definiert eine Muttersprache Listen der verwandten Sprachen und Schriften, welche nicht ausgegeben werden, sondern nur zur Berechnung der Steigerungsschwierigkeit anderer Sprachen und Schriften dienen."},
  {"Name", String, ""}, {"Komplexität", Simple, ""}, {"TaW", Simple, ""}, {"Dialekt", Spezialisierungen, {}}, {"Sprachfamilie", schema.Familie, {}}, {"Schriftfamilie", schema.Familie, {}})
d.HeterogeneousList:def({name = "Zweitsprache", documentation = "Eine Zweitsprache, für die die Grund-Steigerungsschwierigkeit gilt."},
  {"Name", String, ""}, {"Komplexität", Simple, ""}, {"TaW", Simple, ""}, {"Dialekt", Spezialisierungen, {}})
schema.Lehrsprache = schema.Zweitsprache
d.HeterogeneousList:def({name = "Sprache", documentation = "Eine Fremdsprache. Steigerungsschwierigkeit hängt ab davon, ob sie in der Sprachfamilie der Muttersprache enthalten ist."},
  {"Name", String, ""}, {"Komplexität", Simple, ""}, {"TaW", Simple, ""}, {"Dialekt", Spezialisierungen, {}})
d.HeterogeneousList:def({name = "Schrift", documentation = "Eine Schrift. Es sollte die Steigerungsschwierigkeit gemäß WdS angegeben werden; der Bogen modifiziert sie automatisch im Falle einer Begabung oder Unfähigkeit."},
  {"Name", String, ""}, {"Steigerungsspalte", SteigSpalte, ""}, {"Komplexität", Simple, ""}, {"TaW", Simple, ""})

schema.Talente = {
  Begabungen = d:singleton(d.MixedList, {name = "Talente.Begabungen", documentation = "Liste übernatürlicher Begabungen."}, schema.Talent) {},
  Gaben = d:singleton(d.MixedList, {name = "Talente.Gaben", documentation = "Liste von Gaben."}, schema.Talent) {},
  Kampf = d:singleton(d.MixedList, {name = "Talente.Kampf", documentation = "Liste von Kampftalenten.", item_name = "Kampftalent"}, schema.Nah, schema.NahAT, schema.Fern) {
    schema.Nah {"Dolche",      "D", "BE-1", "", "", ""},
    schema.Nah {"Hiebwaffen",  "D", "BE-4", "", "", ""},
    schema.Nah {"Raufen",      "C", "BE",   "", "", ""},
    schema.Nah {"Ringen",      "D", "BE",   "", "", ""},
    schema.Fern {"Wurfmesser", "C", "BE-3", ""},
  },
  Koerper = d:singleton(d.MixedList, {name = "Talente.Koerper", documentation = "Liste von körperlichen Talenten."}, schema.KoerperTalent) {
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
  },
  Gesellschaft = d:singleton(d.MixedList, {name = "Talente.Gesellschaft", documentation = "Liste von Gesellschaftstalenten."}, schema.Talent) {
    {"Menschenkenntnis", "KL", "IN", "CH", ""},
    {"Überreden",        "MU", "IN", "CH", ""},
  },
  Natur = d:singleton(d.MixedList, {name = "Talente.Natur", documentation = "Liste von Naturtalenten."}, schema.Talent) {
    {"Fährtensuchen", "KL", "IN", "IN", ""},
    {"Orientierung",  "KL", "IN", "IN", ""},
    {"Wildnisleben",  "IN", "GE", "KO", ""},
  },
  Wissen = d:singleton(d.MixedList, {name = "Talente.Wissen", documentation = "Liste von Wissenstalenten."}, schema.Talent) {
    {"Götter / Kulte",            "KL", "KL", "IN", ""},
    {"Rechnen",                   "KL", "KL", "IN", ""},
    {"Sagen / Legenden",          "KL", "IN", "CH", ""},
  },
  SprachenUndSchriften = d:singleton(d.MixedList, {name = "Talente.SprachenUndSchriften", documentation = "Liste von Sprachen & Schriften.", item_name = "SpracheOderSchrift"}, schema.Muttersprache, schema.Zweitsprache, schema.Sprache, schema.Schrift) {
    schema.Muttersprache {"", "", ""},
  },
  Handwerk = d:singleton(d.MixedList, {name = "Talente.Handwerk", documentation = "Liste von Handwerkstalenten."}, schema.Talent) {
    {"Heilkunde Wunden", "KL", "CH", "FF", ""},
    {"Holzbearbeitung",  "KL", "FF", "KK", ""},
    {"Kochen",           "KL", "IN", "FF", ""},
    {"Lederarbeiten",    "KL", "FF", "FF", ""},
    {"Malen / Zeichnen", "KL", "IN", "FF", ""},
    {"Schneidern",       "KL", "FF", "FF", ""},
  },
}

d:singleton(d.ListWithKnown, {name = "SF", documentation = "Sonderfertigkeiten (außer Kampf & magischen)"}, {
  Kulturkunde = d.Multivalue:def({name = "Kulturkunde", documentation = "Liste von Kulturen, für die Kulturkunde besteht."}),
  Ortskenntnis = d.Multivalue:def({name = "Ortskenntnis", documentation = "Liste von Orten, für die Ortskenntnis besteht."}),
})

schema.SF.Nahkampf = d:singleton(d.ListWithKnown, {name = "SF.Nahkampf", documentation = "Liste von Nahkampf-Sonderfertigkeiten."}, {
  Ausweichen = d.Numbered:def({name = "Ausweichen", documentation = "Die SF Ausweichen, unterteilt in I, II und III."}, 3),
  ["Kampfgespür"] = "Kampfgespuer",
  Kampfreflexe = "Kampfreflexe",
  Linkhand = "Linkhand",
  Parierwaffen = d.Numbered:def({name = "Parierwaffen", documentation = "Die SF Parierwaffen, unterteilt in I und II."}, 2),
  ["Ruestungsgewoehnung"] = d.Numbered:def({name = "Ruestungsgewoehnung", documentation = "Die SF Rüstungsgewöhnung, unterteilt in I, II und III."}, 3),
  Schildkampf = d.Numbered:def({name = "Schildkampf", documentation = "Die SF Schildkampf, unterteilt in I und II."}, 2)
}) {}

schema.SF.Fernkampf = d:singleton(d.ListWithKnown, {name = "SF.Fernkampf", documentation = "Liste von Fernkampf-Sonderfertigkeiten."}, {
  Scharfschuetze = d.Multivalue:def({name = "Scharfschuetze", documentation = "Liste von Talenten, für die Scharfschütze gilt."}),
  Meisterschuetze = d.Multivalue:def({name = "Meisterschuetze", documentation = "Liste von Talenten, für die Meisterschütze gilt."}),
  Schnellladen = d.Multivalue:def({name = "Schnellladen", documentation = "Liste von Talenten, für die Schnellladen gilt."}),
}) {}

schema.SF.Waffenlos = d:singleton(d.ListWithKnown, {name = "SF.Waffenlos", documentation = "Listen waffenloser Sonderfertigkeiten."}, {
  Kampfstile = d.MapToFixed:def({name = "Kampfstile", documentation = "Liste bekannter Kampfstile"}, "Raufen", "Ringen")
}) {}

schema.SF.Magisch = d:singleton(d.ListWithKnown, {name = "SF.Magisch", documentation = "Liste magischer Sonderfertigkeiten"}, {
  ["Gefäß der Sterne"] = "GefaessDerSterne"
}) {}

schema.I = 1
schema.II = 2
schema.III = 3

local Distanzklasse = d.Matching:def({name = "Distanzklasse", documentation = "Eine Distanzklasse."}, "[HNSP]*")
local Schaden = d.Matching:def({name = "Schaden", documentation = "Trefferpunkte einer Waffe."}, "[0-9]*W[0-9]*", "[0-9]*W[0-9]*[%+%-][0-9]+")

schema.Waffen = {
  Nahkampf = d:singleton(d.MixedList, {name = "Waffen.Nahkampf", documentation = "Liste von Nahkampfwaffen."}, d.HeterogeneousList:def({name = "Nahkampfwaffe", documentation = "Eine Nahkampfwaffe."},
      {"Name", String, ""}, {"Talent", String, ""}, {"DK", Distanzklasse, ""}, {"TP", Schaden, ""}, {"TP/KK Schwelle", Simple, ""}, {"TP/KK Schritt", Simple, ""}, {"INI", Simple, ""}, {"WM AT", Simple, ""}, {"WM PA", Simple, ""}, {"BF1", Simple, ""}, {"BF2", Simple, ""}, {"Art", String, ""})) {},
  Fernkampf = d:singleton(d.MixedList, {name = "Waffen.Fernkampf", documentation = "Liste von Fernkampfwaffen."}, d.HeterogeneousList:def({name = "Fernkampfwaffe", documentation = "Eine Fernkampfwaffe."},
      {"Name", String, ""}, {"Talent", String, ""}, {"TP", Schaden, ""}, {"Entfernung1", Simple, ""}, {"Entfernung2", Simple, ""}, {"Entfernung3", Simple, ""}, {"Entfernung4", Simple, ""}, {"Entfernung5", Simple, ""}, {"TP/Entfernung1", Simple, ""}, {"TP/Entfernung2", Simple, ""}, {"TP/Entfernung3", Simple, ""}, {"TP/Entfernung4", Simple, ""}, {"TP/Entfernung5", Simple, ""}, {"Geschosse1", Simple, ""}, {"Geschosse2", Simple, ""}, {"Geschosse3", Simple, ""}, {"Art", String, ""})) {},
  Schilde = d:singleton(d.MixedList, {name = "Waffen.Schilde", documentation = "Liste von Schilden und Parierwaffen."}, d.HeterogeneousList:def({name = "Schild", documentation = "Ein Schild oder eine Parierwaffe."},
      {"Name", String}, {"Typ", String}, {"INI", Ganzzahl}, {"WM AT", Ganzzahl}, {"WM PA", Ganzzahl}, {"BF1", Simple, ""}, {"BF2", Simple, ""}, {"Art", String, ""})) {},
  Ruestung = d:singleton(d.MixedList, {name = "Waffen.Ruestung", documentation = "Liste von Rüstungsteilen."}, d.Record:def({name = "Ruestungsteil", documentation = "Ein Rüstungsteil."},
    {1, String, ""},
    {2, Ganzzahl, 0},
    {3, Ganzzahl, 0},
    {"Kopf", Ganzzahl, 0},
    {"Brust", Ganzzahl, 0},
    {"Ruecken", Ganzzahl, 0},
    {"LArm", Ganzzahl, 0},
    {"RArm", Ganzzahl, 0},
    {"Bauch", Ganzzahl, 0},
    {"LBein", Ganzzahl, 0},
    {"RBein", Ganzzahl, 0})) {},
}

d:singleton(d.Multivalue, {name = "Kleidung", documentation = "Mehrzeiliger Text für den Kleidungs-Kasten auf dem Ausrüstungsbogen."})
d:singleton(d.MixedList, {name = "Ausruestung", documentation = "Liste von Ausrüstungsgegenständen."}, d.HeterogeneousList:def({name = "Gegenstand", documentation = "Ein Ausrüstungsgegenstand."}, {"Name", String}, {"Gewicht", Simple, ""}, {"Getragen", String, ""}))
d:singleton(d.MixedList, {name = "Proviant", documentation = "Liste von Proviant & Tränken."}, d.HeterogeneousList:def({name = "Rationen", documentation = "Proviant oder Trank mit Rationen."}, {"Name", String}, {"Ration1", Simple, ""}, {"Ration2", Simple, ""}, {"Ration3", Simple, ""}, {"Ration4", Simple, ""}))

local Muenzen = d.HeterogeneousList:def({name = "Muenzen", documentation = "Eine Münzenart mit mehreren Werten."}, {"Name", String, ""}, {"Wert1", Simple, ""}, {"Wert2", Simple, ""}, {"Wert3", Simple, ""}, {"Wert4", Simple, ""}, {"Wert5", Simple, ""}, {"Wert6", Simple, ""}, {"Wert7", Simple, ""}, {"Wert8", Simple, ""})

d:singleton(d.MixedList, {name = "Vermoegen", documentation = "Liste von Münzenarten."}, Muenzen) {
  {"Dukaten", "", "", "", "", "", "", "", ""},
  {"Silbertaler", "", "", "", "", "", "", "", ""},
  {"Heller", "", "", "", "", "", "", "", ""},
  {"Kreuzer", "", "", "", "", "", "", "", ""},
}
schema.Vermoegen.Sonstiges = d:singleton(d.Multivalue, {name = "Vermoegen.Sonstiges", documentation = "Sonstiges Vermögen."}) {}

d:singleton(d.Multivalue, {name = "Verbindungen", documentation = "Verbindungen."})
d:singleton(d.Multivalue, {name = "Notizen", documentation = "Notizen auf dem Ausrüstungs / Liturgienbogen."})

local Tier = d.HeterogeneousList:def({name = "Tier", documentation = "Werte eines Tiers."}, {"Name", String}, {"Art", String, ""}, {"INI", Simple, ""}, {"AT", Simple, ""}, {"PA", Simple, ""}, {"TP", Schaden, ""}, {"LE", Simple, ""}, {"RS", Simple, ""}, {"KO", Simple, ""}, {"KO", Simple, ""}, {"GS", Simple, ""}, {"AU", Simple, ""}, {"MR", Simple, ""}, {"LO", Simple, ""}, {"TK", Simple, ""}, {"ZK", Simple, ""})
d:singleton(d.MixedList, {name = "Tiere", documentation = "Liste von Tieren."}, Tier)

d:singleton(d.HeterogeneousList, {name = "Liturgiekenntnis", documentation = "Liturgiekenntnis."}, {"Name", String, ""}, {"Wert", Simple, ""}) {
  "", ""
}

d:singleton(d.MixedList, {name = "Liturgien", documentation = "Liste von Liturgien."}, d.HeterogeneousList:def({name = "Liturgie", documentation = "Eine Liturgie."},
  {"Seite", Simple, ""}, {"Name", String}, {"Grad", Ganzzahl, 1}))

local Merkmale = d.ListWithKnown:def({name = "Merkmale", documentation = "Liste von Merkmalen eines Zaubers."}, {
  Elementar = Elementar,
  Daemonisch = Daemonisch
}, { -- optional
  Elementar = true,
  Daemonisch = true,
})

local function merkmale(name, doc)
  return d:singleton(d.ListWithKnown, {name = name, documentation = doc}, {
    Elementar = Elementar,
    Daemonisch = Daemonisch
  }, { -- optional
    Elementar = true,
    Daemonisch = true,
  }) {}
end

local Repraesentation = d.Matching:def({name = "Repraesentation", documentation = "Name einer Repräsentation."}, "Ach", "Alh", "Bor", "Dru", "Dra", "Elf", "Fee", "Geo", "Gro", "Gül", "Kob", "Kop", "Hex", "Mag", "Mud", "Nac", "Srl", "Sch")

schema.Magie = {
  Rituale = d:singleton(d.MixedList, {name = "Magie.Rituale", documentation = "Liste von Ritualen."}, d.HeterogeneousList:def({name = "Ritual", documentation = "Ein Ritual."},
    {"Name", String}, {"Probe1", BasisEig, ""}, {"Probe2", BasisEig, ""}, {"Probe3", BasisEig, ""}, {"Dauer", Simple, ""}, {"Kosten", Simple, ""}, {"Wirkung", Simple, ""}, {"Lernkosten", Ganzzahl, 0})) {},
  Ritualkenntnis = d:singleton(d.MixedList, {name = "Magie.Ritualkenntnis", documentation = "Liste von Ritualkenntnissen."}, d.HeterogeneousList:def({name = "RK-Wert", documentation = "Ein Ritualkenntnis-Wert."},
    {"Name", String}, {"Steigerung", SteigSpalte, "E"}, {"Wert", Simple, ""})) {},
  Regeneration = d:singleton(d.Simple, {name = "Magie.Regeneration", documentation = "AsP-Regeneration pro Phase."}) "",
  Artefakte = d:singleton(d.Multivalue, {name = "Magie.Artefakte", documentation = "Artefakte."}) {},
  Notizen = d:singleton(d.Multivalue, {name = "Magie.Notizen", documentation = "Notizen auf dem Zauberdokument."}) {},
  Repraesentationen = d:singleton(d.MixedList, {name = "Magie.Repraesentationen", documentation = "Liste beherrschter Repräsentationen."}, Repraesentation) {},
  Merkmalskenntnis = merkmale("Magie.Merkmalskenntnis", "Liste gelernter Merkmalskenntnisse"),
  Zauber = d:singleton(d.MixedList, {name = "Magie.Zauber", documentation = "Liste von gelernten Zaubern."}, d.HeterogeneousList:def({name = "Zauber", documentation = "Ein Zauber."}, {"Seite", Simple, ""}, {"Name", String}, {"Probe1", BasisEig}, {"Probe2", BasisEig}, {"Probe3", BasisEig}, {"ZfW", Simple, ""}, {"Komplexitaet", SteigSpalte}, {"Merkmale", Merkmale, {}}, {"Repraesentation", Repraesentation, ""}, {"Hauszauber", schema.Boolean, false}, {"Spezialisierungen", Spezialisierungen, {}})) {}
}

local SteigerMethode = d.Matching:def({name = "SteigerMethode", documentation = "Steigerungsmethode"}, "SE", "Lehrmeister", "Gegenseitig", "Selbststudium")
local SFLernmethode = d.Matching:def({name = "SFLernmethode", documentation = "Lernmethode für eine Sonderfertigkeit"}, "SE", "Lehrmeister")
local EigSteigerMethode = d.Matching:def({name = "EigSteigerMethode", documentation = "Steigerungsmethode für Eigenschaften"}, "SE", "Standard")

local TaW = d.HeterogeneousList:def({name = "TaW", documentation = "Steigerung eines Talentwerts"},
  {"Name", String}, {"Zielwert", Ganzzahl}, {"Methode", SteigerMethode, "Gegenseitig"})

local ZfW = d.HeterogeneousList:def({name = "ZfW", documentation = "Steigerung eines Zauberfertigkeitwerts"},
  {"Name", String}, {"Zielwert", Ganzzahl}, {"Methode", SteigerMethode, "Gegenseitig"})

local Spezialisierung = d.HeterogeneousList:def({name = "Spezialisierung", documentation = "Erlernen einer Talent- oder Zauberspezialisierung"},
  {"Fertigkeit", String}, {"Name", String}, {"Methode", SFLernmethode, "Lehrmeister"})

local ProfaneSF = d.HeterogeneousList:def({name = "ProfaneSF", documentation = "Erlernen einer Sonderfertigkeit, die nicht Kampf und nicht magisch ist."},
  {"SF", nil}, {"Kosten", Ganzzahl}, {"Methode", SFLernmethode, "Lehrmeister"})

local NahkampfSF = d.HeterogeneousList:def({name = "NahkampfSF", documentation = "Erlernen einer Nahkampf-Sonderfertigkeit."},
  {"SF", nil}, {"Kosten", Ganzzahl}, {"Methode", SFLernmethode, "Lehrmeister"})

local FernkampfSF = d.HeterogeneousList:def({name = "FernkampfSF", documentation = "Erlernen einer Fernkampf-Sonderfertigkeit."},
  {"SF", nil}, {"Kosten", Ganzzahl}, {"Methode", SFLernmethode, "Lehrmeister"})

local WaffenlosSF = d.HeterogeneousList:def({name = "WaffenlosSF", documentation = "Erlernen einer Waffenlosen Sonderfertigkeit."},
  {"SF", nil}, {"Kosten", Ganzzahl}, {"Methode", SFLernmethode, "Lehrmeister"})

local Eigenschaft = d.HeterogeneousList:def({name = "Eigenschaft", documentation = "Steigern einer Basis-Eigenschaft oder Zukauf von Punkten zu einer abgeleiteten Eigenschaft."},
  {"Eigenschaft", EigName}, {"Zielwert", Ganzzahl}, {"Methode", EigSteigerMethode, "Standard"})

local RkW = d.HeterogeneousList:def({name = "RkW", documentation = "Steigerung eines Ritualkenntniswerts."},
  {"Name", String}, {"Zielwert", Ganzzahl}, {"Methode", SteigerMethode, "Gegenseitig"})

local LkW = d.HeterogeneousList:def({name = "LkW", documentation = "Steigerung des Liturgiekenntniswerts."},
  {"Zielwert", Ganzzahl}, {"Methode", SteigerMethode, "Gegenseitig"})

local Sortiere = d.Multivalue:def({name = "Sortiere", documentation = "Definiert, wie eine neu aktivierte Fähigkeit (Talent, Zauber, …) in die bestehende Liste einsortiert wird. Ein leerer Wert sortiert am Ende der Liste ein, ansonsten wird zuerst nach der Spalte, die vom ersten Wert gegeben wird, sortiert, dann nach der vom zweiten Wert etc."})

local Aktiviere = d.HeterogeneousList:def({name = "Aktiviere", documentation = "Aktiviert ein Talent, einen Zauber, eine Liturgie oder ein Ritual. Ist der gegebene Wert des Talents oder des Zaubers größer 0, wird anschließend eine Steigerung durchgeführt. Für Gesellschafts-, Natur-, Wissens- und Handwerkstalente muss die Talentgruppe angegeben werden; in allen anderen Fällen wird sie ignoriert."},
  {"Subjekt", nil}, {"Methode", SteigerMethode, "Lehrmeister"}, {"Sortierung", Sortiere, "Name"}, {"Talentgruppe", String, ""})

local Zugewinn = d.HeterogeneousList:def({name = "Zugewinn", documentation = "Zugewinn von AP. Kann als Überschrift (fett) formatiert werden."},
  {"Text", String}, {"AP", Ganzzahl}, {"Fett", schema.Boolean, false})

d:singleton(d.MixedList, {name = "Ereignisse", documentation = "Liste von Ereignissen, die auf den Grundcharakter appliziert werden sollen.", item_name = "Ereignis"},
  TaW, ZfW, Spezialisierung, ProfaneSF, NahkampfSF, FernkampfSF, WaffenlosSF, Eigenschaft, RkW, LkW, Aktiviere, Zugewinn) {}

return schema