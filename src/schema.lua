local d = require("schemadef")

local standalone = false
local gendoc = false
local curarg = 1
while string.sub(arg[curarg], 1, 1) == "-" do
  if arg[curarg] == "--standalone" then
    standalone = true
  else
    io.stderr:write("unknown option: " .. arg[curarg] .. "\n")
  end
  curarg = curarg + 1
end
if arg[curarg] == "gendoc" then
  gendoc = true
elseif arg[curarg] ~= nil then
  io.stderr:write("unknown command: " .. arg[curarg] .. "\n")
end

local schema = d(gendoc)
local Simple = schema.Simple
local String = schema.String
local Multiline = schema.Multiline

local Zeilen = d.Number("Zeilen", "Anzahl Zeilen in einem Feld oder einer Tabelle", 0, 100)

local Front = d.Record("Front", "Frontseite",
  {"Aussehen", Zeilen, 3},
  {"Vorteile", Zeilen, 7},
  {"Nachteile", Zeilen, 7})

local Talentliste = d.MixedList("Talentliste", "Sonderfertigkeiten & Talente. Der Inhalt dieses Werts definiert die Reihenfolge der Untergruppen und die Anzahl Zeilen jeder Untergruppe.", "Gruppe",
  d.Number("Sonderfertigkeiten", "Zeilen für Sonderfertigkeiten", 0, 100),
  d.Number("Gaben", "Zeilen für Gaben", 0, 100),
  d.Number("Begabungen", "Zeilen für Übernatürliche Begabungen", 0, 100),
  d.Number("Kampf", "Zeilen für Kampftalente", 0, 100),
  d.Number("Koerper", "Zeilen für Körperliche Talente", 0, 100),
  d.Number("Gesellschaft", "Zeilen für Gesellschaftstalente", 0, 100),
  d.Number("Natur", "Zeilen für Naturtalente", 0, 100),
  d.Number("Wissen", "Zeilen für Wissenstalente", 0, 100),
  d.Number("Sprachen", "Zeilen für Sprachen & Schriften", 0, 100),
  d.Number("Handwerk", "Zeilen für Handwerkstalente", 0, 100)
)

local Kampfbogen = d.Record("Kampfbogen", "Kampfbogen.",
  {"Nahkampf", d.Record("NahkampfWaffenUndSF", "Zeilen für Nahkampfwaffen und -SF.",
    {"Waffen", Zeilen, 5},
    {"SF", Zeilen, 3}), {}},
  {"Fernkampf", d.Record("FernkampfWaffenUndSF", "Zeilen für Fernkampfwaffen und -SF.",
    {"Waffen", Zeilen, 3},
    {"SF", Zeilen, 3}), {}},
  {"Waffenlos", d.Record("Waffenlos", "Zeilen für waffenlose Manöver.",
    {"SF", Zeilen, 3}), {}},
  {"Schilde", Zeilen, 2},
  {"Ruestung", Zeilen, 6})

local Ausruestungsbogen = d.Record("Ausruestungsbogen", "Ausrüstungsbogen.",
  {"Kleidung", Zeilen, 5},
  {"Gegenstaende", Zeilen, 33},
  {"Proviant", Zeilen, 8},
  {"Vermoegen", d.Record("Vermoegensbox", "Zeilen in der Vermögensbox.", {"Muenzen", Zeilen, 4}, {"Sonstiges", Zeilen, 7}), {}},
  {"Verbindungen", Zeilen, 9},
  {"Notizen", Zeilen, 7},
  {"Tiere", Zeilen, 4})

local Liturgiebogen = d.Record("Liturgiebogen", "Bogen für Liturgien & Ausrüsung.",
  {"Kleidung", Zeilen, 5},
  {"Liturgien", Zeilen, 27},
  {"Gegenstaende", Zeilen, 29},
  {"ProviantVermoegen", d.Record("ProviantVermoegen", "Zeilen für Proviant & Vermögen Box.", {"Gezaehlt", Zeilen, 4}, {"Sonstiges", Zeilen, 5}), {}},
  {"VerbindungenNotizen", Zeilen, 9},
  {"Tiere", Zeilen, 4})

local Zauberdokument = d.Record("Zauberdokument", "Zauberdokument.",
  {"VorUndNachteile", Zeilen, 5},
  {"Sonderfertigkeiten", Zeilen, 5},
  {"Rituale", Zeilen, 30},
  {"Ritualkenntnis", Zeilen, 2},
  {"Artefakte", Zeilen, 9},
  {"Notizen", Zeilen, 6})

local Zauberliste = d.Void("Zauberliste", "Zauberliste.")

d:singleton(d.MixedList, "Layout", [[Definiert, welche Seiten in welcher Reihenfolge generiert werden.
Für die einzelnen Seiten können weitere Spezifikationen vorgenommen werden, dies ist bei den Typen der
einzelnen Seiten beschrieben.]], "Seite",
  Front, Talentliste, Kampfbogen, Ausruestungsbogen, Liturgiebogen,
  Zauberdokument, Zauberliste
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
    schema.Sprachen(10),
    schema.Handwerk(15)
  },
  Kampfbogen {},
  Ausruestungsbogen {},
  Liturgiebogen {},
  Zauberdokument {},
  Zauberliste {}
}

d:singleton(d.Record, "Held", [[Grundlegende Daten des Helden.]],
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

d:singleton(d.ListWithKnown, "Vorteile", "Liste von nicht-magischen Vorteilen.", {
  Flink = d.Number("Flink", "Flink(2) ist exklusiv für Goblins, die es zweimal wählen dürfen.", 1, 2),
  Eisern = "Eisern"
}, { -- optional
  Flink = true
})

schema.Vorteile.magisch = d:singleton(d.ListWithKnown, "Vorteile.magisch", "Liste von magischen Vorteilen.", {
  -- TODO: Astrale Regeneration
}) {}

d:singleton(d.ListWithKnown, "Nachteile", "Liste von nicht-magischen Nachteilen", {
  Glasknochen = "Glasknochen",
  ["Behäbig"] = "Behaebig",
  ["Kleinwüchsig"] = "Kleinwuechsig",
  Zwergenwuchs = "Zwergenwuchs"
})

schema.Nachteile.magisch = d:singleton(d.ListWithKnown, "Nachteile.magisch", "Liste von magischen Nachteilen.", {
  -- TODO: Schwache Ausstrahlung
}) {}

-- TODO: nicht-Ganzzahlen erkennen und Fehler werfen
local Ganzzahl = d.Number("Ganzzahl", "Eine Zahl in Dezimalschreibweise.", -1000, 1000)

local BasisEig = d.FixedList("BasisEig", "Eine Basiseigenschaft mit Modifikator, Startwert und aktuellem Wert.", Ganzzahl, 3)
local AbgeleiteteEig = d.FixedList("AbgeleiteteEig", "Eine abgeleitete Eigenschaft mit Modifikator, zugekauften Punkten und permanent verlorenen Punkten.", Ganzzahl, 3)

d:singleton(d.Record, "Eigenschaften", "Liste von Basis- und abgeleiteten Eigenschaften",
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

d:singleton(d.Record, "AP", "Abenteuerpunkte.",
  {"Gesamt", Simple, ""},
  {"Eingesetzt", Simple, ""},
  {"Guthaben", Simple, ""})

local SteigSpalte = d.Matching("SteigSpalte", "Eine Steigerungsspalte.", "A%*?", "B", "C", "D", "E", "F", "G", "H")
local Behinderung = d.Matching("Behinderung", "Behinderung.", "%-", "BE", "BE%-[1-9]", "BEx[2-9]")
local Eigenschaft = d.Matching("Eigenschaft", "Referenz auf einen Eigenschaftsnamen.", "%*%*", "MU", "KL", "IN", "CH", "FF", "GE", "KO", "KK")
local Spezialisierung = d.Multivalue("Spezialisierung", "Liste von Spezialisierungen. Leere tables {} können als Zeilenumbruch benutzt werden.")

d.HeterogeneousList("KampfTalent", "Ein Talent aus der Gruppe der Kampftalene.",
  {"Name", String, ""}, {"Steigerungsspalte", SteigSpalte, ""}, {"BE", Behinderung, ""}, {"AT", Simple, ""}, {"PA", Simple, ""}, {"TaW", Simple, ""}, {"Spezialisierung", Spezialisierung, {}})
d.HeterogeneousList("KoerperTalent", "Ein Talent aus der Gruppe der Körperlichen Talente.", {"Name", String, ""}, {"Probe1", Eigenschaft, ""}, {"Probe2", Eigenschaft, ""}, {"Probe3", Eigenschaft, ""}, {"BE", Behinderung, ""}, {"Taw", Simple, ""}, {"Spezialisierung", Spezialisierung, {}})
d.HeterogeneousList("Talent", "Ein allgemeines Talent.",
  {"Name", String, ""}, {"Probe1", Eigenschaft, ""}, {"Probe2", Eigenschaft, ""}, {"Probe3", Eigenschaft, ""}, {"TaW", Simple, ""}, {"Spezialisierung", Spezialisierung, {}})
d.HeterogeneousList("Sprache", "Eine Sprache oder ein Schrift.", {"Name", String, ""}, {"Komplexität", Simple, ""}, {"TaW", Simple, ""}, {"Spezialisierung", Spezialisierung, {}})

schema.Talente = {
  Begabungen = d:singleton(d.MixedList, "Talente.Begabungen", "Liste übernatürlicher Begabungen.", schema.Talent) {},
  Gaben = d:singleton(d.MixedList, "Talente.Gaben", "Liste von Gaben.", schema.Talent) {},
  Kampf = d:singleton(d.MixedList, "Talente.Kampf", "Liste von Kampftalenten.", schema.KampfTalent) {
    {"Dolche",                "D", "BE-1", "", "", ""},
    {"Hiebwaffen",            "D", "BE-4", "", "", ""},
    {"Raufen",                "C", "BE",   "", "", ""},
    {"Ringen",                "D", "BE",   "", "", ""},
    {"Wurfmesser",            "C", "BE-3", "", "", ""},
  },
  Koerper = d:singleton(d.MixedList, "Talente.Koerper", "Liste von körperlichen Talenten.", schema.KoerperTalent) {
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
  Gesellschaft = d:singleton(d.MixedList, "Talente.Gesellschaft", "Liste von Gesellschaftstalenten.", schema.Talent) {
    {"Menschenkenntnis", "KL", "IN", "CH", ""},
    {"Überreden",        "MU", "IN", "CH", ""},
  },
  Natur = d:singleton(d.MixedList, "Talente.Natur", "Liste von Naturtalenten.", schema.Talent) {
    {"Fährtensuchen", "KL", "IN", "IN", ""},
    {"Orientierung",  "KL", "IN", "IN", ""},
    {"Wildnisleben",  "IN", "GE", "KO", ""},
  },
  Wissen = d:singleton(d.MixedList, "Talente.Wissen", "Liste von Wissenstalenten.", schema.Talent) {
    {"Götter / Kulte",            "KL", "KL", "IN", ""},
    {"Rechnen",                   "KL", "KL", "IN", ""},
    {"Sagen / Legenden",          "KL", "IN", "CH", ""},
  },
  Sprachen = d:singleton(d.MixedList, "Talente.Sprachen", "Liste von Sprachen & Schriften.", schema.Sprache) {
    {"Muttersprache: ", "", ""},
  },
  Handwerk = d:singleton(d.MixedList, "Talente.Handwerk", "Liste von Handwerkstalenten.", schema.Talent) {
    {"Heilkunde Wunden", "KL", "CH", "FF", ""},
    {"Holzbearbeitung",  "KL", "FF", "KK", ""},
    {"Kochen",           "KL", "IN", "FF", ""},
    {"Lederarbeiten",    "KL", "FF", "FF", ""},
    {"Malen / Zeichnen", "KL", "IN", "FF", ""},
    {"Schneidern",       "KL", "FF", "FF", ""},
  },
}

d:singleton(d.ListWithKnown, "SF", "Sonderfertigkeiten (außer Kampf & magischen)", {})

schema.SF.Nahkampf = d:singleton(d.ListWithKnown, "SF.Nahkampf", "Liste von Nahkampf-Sonderfertigkeiten.", {
  Ausweichen = d.Numbered("Ausweichen", "Die SF Ausweichen, unterteilt in I, II und III.", 3),
  ["Kampfgespür"] = "Kampfgespuer",
  Kampfreflexe = "Kampfreflexe",
  Linkhand = "Linkhand",
  Parierwaffen = d.Numbered("Parierwaffen", "Die SF Parierwaffen, unterteilt in I und II.", 2),
  ["Ruestungsgewoehnung"] = d.Numbered("Ruestungsgewoehnung", "Die SF Rüstungsgewöhnung, unterteilt in I, II und III.", 3),
  Schildkampf = d.Numbered("Schildkampf", "Die SF Schildkampf, unterteilt in I und II.", 2)
}) {}

schema.SF.Fernkampf = d:singleton(d.ListWithKnown, "SF.Fernkampf", "Liste von Fernkampf-Sonderfertigkeiten.", {}) {}

schema.SF.Waffenlos = d:singleton(d.ListWithKnown, "SF.Waffenlos", "Listen waffenloser Sonderfertigkeiten.", {
  Kampfstile = d.MapToFixed("Kampfstile", "Liste bekannter Kampfstile", "Raufen", "Ringen")
}) {}

schema.SF.Magisch = d:singleton(d.ListWithKnown, "SF.Magisch", "Liste magischer Sonderfertigkeiten", {
  ["Gefäß der Sterne"] = "GefaessDerSterne"
}) {}

schema.I = 1
schema.II = 2
schema.III = 3

local Distanzklasse = d.Matching("Distanzklasse", "Eine Distanzklasse.", "[HNSP]*")
local Schaden = d.Matching("Schaden", "Trefferpunkte einer Waffe.", "[0-9]*W[0-9]*", "[0-9]*W[0-9]*[%+%-][0-9]+")

schema.Waffen = {
  Nahkampf = d:singleton(d.MixedList, "Waffen.Nahkampf", "Liste von Nahkampfwaffen.", d.HeterogeneousList("Nahkampfwaffe", "Eine Nahkampfwaffe.",
      {"Name", String, ""}, {"Talent", String, ""}, {"DK", Distanzklasse, ""}, {"TP", Schaden, ""}, {"TP/KK Schwelle", Simple, ""}, {"TP/KK Schritt", Simple, ""}, {"INI", Simple, ""}, {"WM AT", Simple, ""}, {"WM PA", Simple, ""}, {"BF1", Simple, ""}, {"BF2", Simple, ""}, {"Art", String, ""})) {},
  Fernkampf = d:singleton(d.MixedList, "Waffen.Fernkampf", "Liste von Fernkampfwaffen.", d.HeterogeneousList("Fernkampfwaffe", "Eine Fernkampfwaffe.",
      {"Name", String, ""}, {"Talent", String, ""}, {"TP", Schaden, ""}, {"Entfernung1", Simple, ""}, {"Entfernung2", Simple, ""}, {"Entfernung3", Simple, ""}, {"Entfernung4", Simple, ""}, {"Entfernung5", Simple, ""}, {"TP/Entfernung1", Simple, ""}, {"TP/Entfernung2", Simple, ""}, {"TP/Entfernung3", Simple, ""}, {"TP/Entfernung4", Simple, ""}, {"TP/Entfernung5", Simple, ""}, {"Geschosse1", Simple, ""}, {"Geschosse2", Simple, ""}, {"Geschosse3", Simple, ""}, {"Art", String, ""})) {},
  Schilde = d:singleton(d.MixedList, "Waffen.Schilde", "Liste von Schilden und Parierwaffen.", d.HeterogeneousList("Schild", "Ein Schild oder eine Parierwaffe.",
      {"Name", String}, {"Typ", String}, {"INI", Ganzzahl}, {"WM AT", Ganzzahl}, {"WM PA", Ganzzahl}, {"BF1", Simple, ""}, {"BF2", Simple, ""}, {"Art", String, ""})) {},
  Ruestung = d:singleton(d.MixedList, "Waffen.Ruestung", "Liste von Rüstungsteilen.", d.Record("Ruestungsteil", "Ein Rüstungsteil.",
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

d:singleton(d.Multivalue, "Kleidung", "Mehrzeiliger Text für den Kleidungs-Kasten auf dem Ausrüstungsbogen.")
d:singleton(d.MixedList, "Ausruestung", "Liste von Ausrüstungsgegenständen.", d.HeterogeneousList("Gegenstand", "Ein Ausrüstungsgegenstand.", {"Name", String}, {"Gewicht", Simple, ""}, {"Getragen", String, ""}))
d:singleton(d.MixedList, "Proviant", "Liste von Proviant & Tränken.", d.HeterogeneousList("Rationen", "Proviant oder Trank mit Rationen.", {"Name", String}, {"Ration1", Simple, ""}, {"Ration2", Simple, ""}, {"Ration3", Simple, ""}, {"Ration4", Simple, ""}))

local Muenzen = d.HeterogeneousList("Muenzen", "Eine Münzenart mit mehreren Werten.", {"Name", String, ""}, {"Wert1", Simple, ""}, {"Wert2", Simple, ""}, {"Wert3", Simple, ""}, {"Wert4", Simple, ""}, {"Wert5", Simple, ""}, {"Wert6", Simple, ""}, {"Wert7", Simple, ""}, {"Wert8", Simple, ""})

d:singleton(d.MixedList, "Vermoegen", "Liste von Münzenarten.", Muenzen) {
  {"Dukaten", "", "", "", "", "", "", "", ""},
  {"Silbertaler", "", "", "", "", "", "", "", ""},
  {"Heller", "", "", "", "", "", "", "", ""},
  {"Kreuzer", "", "", "", "", "", "", "", ""},
}
schema.Vermoegen.Sonstiges = d:singleton(d.Multivalue, "Vermoegen.Sonstiges", "Sonstiges Vermögen.") {}

d:singleton(d.Multivalue, "Verbindungen", "Verbindungen.")
d:singleton(d.Multivalue, "Notizen", "Notizen auf dem Ausrüstungs / Liturgienbogen.")

local Tier = d.HeterogeneousList("Tier", "Werte eines Tiers.", {"Name", String}, {"Art", String, ""}, {"INI", Simple, ""}, {"AT", Simple, ""}, {"PA", Simple, ""}, {"TP", Schaden, ""}, {"LE", Simple, ""}, {"RS", Simple, ""}, {"KO", Simple, ""}, {"KO", Simple, ""}, {"GS", Simple, ""}, {"AU", Simple, ""}, {"MR", Simple, ""}, {"LO", Simple, ""}, {"TK", Simple, ""}, {"ZK", Simple, ""})
d:singleton(d.MixedList, "Tiere", "Liste von Tieren.", Tier)

d:singleton(d.HeterogeneousList, "Liturgiekenntnis", "Liturgiekenntnis.", {"Gottheit", String, ""}, {"Wert", Simple, ""}) {
  "", ""
}

d:singleton(d.MixedList, "Liturgien", "Liste von Liturgien.", d.HeterogeneousList("Liturgie", "Eine Liturgie.", {"Seite", Simple, ""}, {"Name", String}, {"Grad", String, ""}))

local Element = d.Matching("Element", "Name eines Elements, oder 'gesamt'.", "gesamt", "Eis", "Humus", "Feuer", "Wasser", "Luft", "Erz")
local Elementar = d.MixedList("Elementar", "Spezifikation elementarer Merkmale.", Element)
local Domaene = d.Matching("Domaene", "Name einer Domäne, oder 'gesamt'", "gesamt", "Blakharaz", "Belhalhar", "Charyptoroth", "Lolgramoth", "Thargunitoth", "Amazeroth", "Belshirash", "Asfaloth", "Tasfarelel", "Belzhorash", "Agrimoth", "Belkelel")
local Daemonisch = d.MixedList("Daemonisch", "Spezifikation dämonischer Merkmale.", Domaene)
local Merkmale = d.ListWithKnown("Merkmale", "Liste von Merkmalen eines Zaubers.", {
  Elementar = Elementar,
  Daemonisch = Daemonisch
}, { -- optional
  Elementar = true,
  Daemonisch = true,
})

local function merkmale(name, doc)
  return d:singleton(d.ListWithKnown, name, doc, {
    Elementar = Elementar,
    Daemonisch = Daemonisch
  }, { -- optional
    Elementar = true,
    Daemonisch = true,
  }) {}
end

local Repraesentation = d.Matching("Repraesentation", "Name einer Repräsentation.", "Ach", "Alh", "Bor", "Dru", "Dra", "Elf", "Fee", "Geo", "Gro", "Gül", "Kob", "Kop", "Hex", "Mag", "Mud", "Nac", "Srl", "Sch")

schema.Magie = {
  Rituale = d:singleton(d.MixedList, "Magie.Rituale", "Liste von Ritualen.", d.HeterogeneousList("Ritual", "Ein Ritual.", {"Name", String}, {"Probe1", Eigenschaft, ""}, {"Probe2", Eigenschaft, ""}, {"Probe3", Eigenschaft, ""}, {"Dauer", Simple, ""}, {"Kosten", Simple, ""}, {"Wirkung", Simple, ""})) {},
  Ritualkenntnis = d:singleton(d.MixedList, "Magie.Ritualkenntnis", "Liste von Ritualkenntnissen.", d.HeterogeneousList("RK-Wert", "Ein Ritualkenntnis-Wert.", {"Name", String}, {"Wert", Simple, ""})) {},
  Regeneration = d:singleton(d.Simple, "Magie.Regeneration", "AsP-Regeneration pro Phase.") "",
  Artefakte = d:singleton(d.Multivalue, "Magie.Artefakte", "Artefakte.") {},
  Notizen = d:singleton(d.Multivalue, "Magie.Notizen", "Notizen auf dem Zauberdokument.") {},
  Repraesentationen = d:singleton(d.MixedList, "Magie.Repraesentationen", "Liste beherrschter Repräsentationen.", Repraesentation) {},
  Merkmalskenntnis = merkmale("Magie.Merkmalskenntnis", "Liste gelernter Merkmalskenntnisse"),
  Begabungen = merkmale("Magie.Begabungen", "Liste von Begabungen für Merkmale"),
  Unfaehigkeiten = merkmale("Magie.Unfaehigkeiten", "Liste von Unfähigkeiten für Merkmale"),
  Zauber = d:singleton(d.MixedList, "Magie.Zauber", "Liste von gelernten Zaubern.", d.HeterogeneousList("Zauber", "Ein Zauber.", {"Seite", Simple, ""}, {"Name", String}, {"Probe1", Eigenschaft}, {"Probe2", Eigenschaft}, {"Probe3", Eigenschaft}, {"TaW", Simple, ""}, {"Spalte", SteigSpalte}, {"Merkmale", Merkmale, {}}, {"Repraesentation", Repraesentation, ""}, {"Hauszauber", schema.Boolean, false}, {"Spezialisierung", Spezialisierung, {}})) {}
}

if gendoc then
  if standalone then
    io.write([[
<!doctype html>
<html lang="de" style="background-color: darkslategray;">
  <head>
    <title>DSA 4.1 Heldendokument: Dokumentation Eingabedaten</title>
    <link rel="stylesheet" href="code.css"/>
  </head>
  <body>
]])
  end
  d:gendocs()
  if standalone then
    io.write([[
  </body>
</html>]])
  end
end

return schema