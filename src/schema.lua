local d = require("schemadef")

local schema = d()
local Simple = schema.Simple
local String = schema.String
local Multiline = schema.Multiline

local Zeilen = d.Number("Zeilen", 0, 100)

local Front = d.Record("Front", {
  Aussehen = {Zeilen, 3},
  Vorteile = {Zeilen, 7},
  Nachteile = {Zeilen, 7},
})

local Talentliste = d.MixedList("Talentliste",
  d.Number("Sonderfertigkeiten", 0, 100),
  d.Number("Gaben", 0, 100),
  d.Number("Begabungen", 0, 100),
  d.Number("Kampf", 0, 100),
  d.Number("Koerper", 0, 100),
  d.Number("Gesellschaft", 0, 100),
  d.Number("Natur", 0, 100),
  d.Number("Wissen", 0, 100),
  d.Number("Sprachen", 0, 100),
  d.Number("Handwerk", 0, 100)
)

local Kampfbogen = d.Record("Kampfbogen", {
  Nahkampf = {d.Record("NahkampfWaffenUndSF", {
    Waffen = {Zeilen, 5},
    SF = {Zeilen, 3},
  }), {}},
  Fernkampf = {d.Record("FernkampfWaffenUndSF", {
    Waffen = {Zeilen, 3},
    SF = {Zeilen, 3},
  }), {}},
  Waffenlos = {d.Record("Waffenlos", {
    SF = {Zeilen, 3},
  }), {}},
  Schilde = {Zeilen, 2},
  Ruestung = {Zeilen, 6},
})

local Ausruestungsbogen = d.Record("Ausruestungsbogen", {
  Kleidung = {Zeilen, 5},
  Gegenstaende = {Zeilen, 33},
  Proviant = {Zeilen, 8},
  Vermoegen = {d.Record("Vermoegen", {
    Muenzen = {Zeilen, 4},
    Sonstiges = {Zeilen, 7}
  }), {}},
  Verbindungen = {Zeilen, 9},
  Notizen = {Zeilen, 7},
  Tiere = {Zeilen, 4},
})

local Liturgiebogen = d.Record("Liturgiebogen", {
  Kleidung = {Zeilen, 5},
  Liturgien = {Zeilen, 27},
  Gegenstaende = {Zeilen, 29},
  ProviantVermoegen = {d.Record("ProviantVermoegen", {
    Gezaehlt = {Zeilen, 4},
    Sonstiges = {Zeilen, 5},
  }), {}},
  VerbindungenNotizen = {Zeilen, 9},
  Tiere = {Zeilen, 4},
})

local Zauberdokument = d.Record("Zauberdokument", {
  VorUndNachteile = {Zeilen, 5},
  Sonderfertigkeiten = {Zeilen, 5},
  Rituale = {Zeilen, 30},
  Ritualkenntnis = {Zeilen, 2},
  Artefakte = {Zeilen, 9},
  Notizen = {Zeilen, 6},
})

local Zauberliste = d.Void("Zauberliste")

d.singleton(d.MixedList, "Layout",
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

d.singleton(d.Record, "Held", {
  Name         = {Simple, ""},
  GP           = {Simple, ""},
  Rasse        = {Simple, ""},
  Kultur       = {Simple, ""},
  Profession   = {Simple, ""},
  Geschlecht   = {Simple, ""},
  Tsatag       = {Simple, ""},
  Groesse      = {Simple, ""},
  Gewicht      = {Simple, ""},
  Haarfarbe    = {Simple, ""},
  Augenfarbe   = {Simple, ""},
  Stand        = {Simple, ""},
  Sozialstatus = {Simple, ""},
  Titel        = {Multiline, ""},
  Aussehen     = {Multiline, ""},
})

d.singleton(d.ListWithKnown, "Vorteile", {
  Flink = "Flink", Eisern = "Eisern"
})

schema.Vorteile.magisch = d.singleton(d.ListWithKnown, "Vorteile.magisch", {
  -- TODO: Astrale Regeneration
}) {}

d.singleton(d.ListWithKnown, "Nachteile", {
  Glasknochen = "Glasknochen",
  ["Behäbig"] = "Behaebig",
  ["Kleinwüchsig"] = "Kleinwuechsig",
  Zwergenwuchs = "Zwergenwuchs"
})

schema.Nachteile.magisch = d.singleton(d.ListWithKnown, "Nachteile.magisch", {
  -- TODO: Schwache Ausstrahlung
}) {}

-- TODO: nicht-Ganzzahlen erkennen und Fehler werfen
local Ganzzahl = d.Number("Ganzzahl", -1000, 1000)

local BasisEig = d.FixedList("BasisEig", Ganzzahl, 3)
local AbgeleiteteEig = d.FixedList("AbgeleiteteEig", Ganzzahl, 3)

d.singleton(d.Record, "Eigenschaften", {
  MU = {BasisEig, {0, 0, 0}},
  KL = {BasisEig, {0, 0, 0}},
  IN = {BasisEig, {0, 0, 0}},
  CH = {BasisEig, {0, 0, 0}},
  FF = {BasisEig, {0, 0, 0}},
  GE = {BasisEig, {0, 0, 0}},
  KO = {BasisEig, {0, 0, 0}},
  KK = {BasisEig, {0, 0, 0}},
  LE = {AbgeleiteteEig, {0, 0, 0}},
  AU = {AbgeleiteteEig, {0, 0, 0}},
  AE = {AbgeleiteteEig, {0, 0, 0}},
  MR = {AbgeleiteteEig, {0, 0, 0}},
  KE = {AbgeleiteteEig, {0, 0, 0}},
  INI = {Ganzzahl, 0},
})

d.singleton(d.Record, "AP", {
  Gesamt = {Simple, ""},
  Eingesetzt = {Simple, ""},
  Guthaben = {Simple, ""}
})

local SteigSpalte = d.Matching("SteigSpalte", "A%*?", "B", "C", "D", "E", "F", "G", "H")
local Behinderung = d.Matching("Behinderung", "%-", "BE", "BE%-[1-9]", "BEx[2-9]")
local Eigenschaft = d.Matching("Eigenschaft", "%*%*", "MU", "KL", "IN", "CH", "FF", "GE", "KO", "KK")

d.HeterogeneousList("KampfTalent",
  String, SteigSpalte, Behinderung, Simple, Simple, Simple)
d.HeterogeneousList("KoerperTalent", String, Eigenschaft, Eigenschaft, Eigenschaft, Behinderung, Simple)
d.HeterogeneousList("Talent",
  String, Eigenschaft, Eigenschaft, Eigenschaft, Simple)
d.HeterogeneousList("Sprache", String, Simple, Simple)

schema.Talente = {
  Begabungen = d.singleton(d.MixedList, "Talente.Begabungen", schema.Talent) {},
  Gaben = d.singleton(d.MixedList, "Talente.Gaben", schema.Talent) {},
  Kampf = d.singleton(d.MixedList, "Talente.Kampf", schema.KampfTalent) {
    {"Dolche",                "D", "BE-1", "", "", ""},
    {"Hiebwaffen",            "D", "BE-4", "", "", ""},
    {"Raufen",                "C", "BE",   "", "", ""},
    {"Ringen",                "D", "BE",   "", "", ""},
    {"Wurfmesser",            "C", "BE-3", "", "", ""},
  },
  Koerper = d.singleton(d.MixedList, "Talente.Koerper", schema.KoerperTalent) {
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
  Gesellschaft = d.singleton(d.MixedList, "Talente.Gesellschaft", schema.Talent) {
    {"Menschenkenntnis", "KL", "IN", "CH", ""},
    {"Überreden",        "MU", "IN", "CH", ""},
  },
  Natur = d.singleton(d.MixedList, "Talente.Natur", schema.Talent) {
    {"Fährtensuchen", "KL", "IN", "IN", ""},
    {"Orientierung",  "KL", "IN", "IN", ""},
    {"Wildnisleben",  "IN", "GE", "KO", ""},
  },
  Wissen = d.singleton(d.MixedList, "Talente.Natur", schema.Talent) {
    {"Götter / Kulte",            "KL", "KL", "IN", ""},
    {"Rechnen",                   "KL", "KL", "IN", ""},
    {"Sagen / Legenden",          "KL", "IN", "CH", ""},
  },
  Sprachen = d.singleton(d.MixedList, "Talente.Sprachen", schema.Sprache) {
    {"Muttersprache: ", "", ""},
  },
  Handwerk = d.singleton(d.MixedList, "Talente.Handwerk", schema.Talent) {
    {"Heilkunde Wunden", "KL", "CH", "FF", ""},
    {"Holzbearbeitung",  "KL", "FF", "KK", ""},
    {"Kochen",           "KL", "IN", "FF", ""},
    {"Lederarbeiten",    "KL", "FF", "FF", ""},
    {"Malen / Zeichnen", "KL", "IN", "FF", ""},
    {"Schneidern",       "KL", "FF", "FF", ""},
  },
}

d.singleton(d.ListWithKnown, "SF", {})

schema.SF.Nahkampf = d.singleton(d.ListWithKnown, "SF.Nahkampf", {
  Ausweichen = d.Numbered("Ausweichen", 3),
  ["Kampfgespür"] = "Kampfgespuer",
  Kampfreflexe = "Kampfreflexe",
  Linkhand = "Linkhand",
  Parierwaffen = d.Numbered("Parierwaffen", 2),
  ["Ruestungsgewoehnung"] = d.Numbered("Ruestungsgewoehnung", 3),
  Schildkampf = d.Numbered("Schildkampf", 2)
}) {}

schema.SF.Fernkampf = d.singleton(d.ListWithKnown, "SF.Fernkampf", {}) {}

schema.SF.Waffenlos = d.singleton(d.ListWithKnown, "SF.Waffenlos", {
  Kampfstile = d.MapToFixed("Kampfstile", "Raufen", "Ringen")
}) {}

schema.SF.Magisch = d.singleton(d.ListWithKnown, "SF.Magisch", {
  ["Gefäß der Sterne"] = "GefaessDerSterne"
}) {}

schema.I = 1
schema.II = 2
schema.III = 3

local Distanzklasse = d.Matching("Distanzklasse", "[HNSP]+")
local Schaden = d.Matching("Schaden", "[0-9]*W[0-9]*", "[0-9]*W[0-9]*[%+%-][0-9]+")

schema.Waffen = {
  Nahkampf = d.singleton(d.MixedList, "Waffen.Nahkampf", d.HeterogeneousList("Nahkampfwaffe",
      String, String, Distanzklasse, Schaden, Ganzzahl, Ganzzahl, Ganzzahl, Ganzzahl, Ganzzahl, Simple, Simple)) {},
  Fernkampf = d.singleton(d.MixedList, "Waffen.Fernkampf", d.HeterogeneousList("Fernkampfwaffe",
      String, String, Schaden, Ganzzahl, Ganzzahl, Ganzzahl, Ganzzahl, Ganzzahl, Ganzzahl, Ganzzahl, Ganzzahl, Ganzzahl, Ganzzahl, Simple, Simple, Simple)) {},
  Schilde = d.singleton(d.MixedList, "Waffen.Schilde", d.HeterogeneousList("Schild",
      String, String, Ganzzahl, Ganzzahl, Ganzzahl, Simple, Simple)) {},
  Ruestung = d.singleton(d.MixedList, "Waffen.Ruestung", d.Record("Ruestungsteil", {
    [1] = {String, ""},
    [2] = {Ganzzahl, 0},
    [3] = {Ganzzahl, 0},
    Kopf = {Ganzzahl, 0},
    Brust = {Ganzzahl, 0},
    Ruecken = {Ganzzahl, 0},
    LArm = {Ganzzahl, 0},
    RArm = {Ganzzahl, 0},
    Bauch = {Ganzzahl, 0},
    LBein = {Ganzzahl, 0},
    RBein = {Ganzzahl, 0},
  })) {},
}

d.singleton(d.Multiline, "Kleidung")
d.singleton(d.MixedList, "Ausruestung", d.HeterogeneousList("Gegenstand", String, Simple, String))
d.singleton(d.MixedList, "Proviant", d.HeterogeneousList("Rationen", String, Simple, Simple, Simple))

local Muenzen = d.HeterogeneousList("Muenzen", String, Simple, Simple, Simple, Simple, Simple, Simple, Simple, Simple)

d.singleton(d.MixedList, "Vermoegen", Muenzen) {
  {"Dukaten", "", "", "", "", "", "", "", ""},
  {"Silbertaler", "", "", "", "", "", "", "", ""},
  {"Heller", "", "", "", "", "", "", "", ""},
  {"Kreuzer", "", "", "", "", "", "", "", ""},
}
schema.Vermoegen.Sonstiges = d.singleton(d.Multiline, "Vermoegen.Sonstiges") {}

d.singleton(d.Multiline, "Verbindungen")
d.singleton(d.Multiline, "Notizen")

local Tier = d.HeterogeneousList("Tier", String, String, Ganzzahl, Ganzzahl, Ganzzahl, Schaden, Ganzzahl, Ganzzahl, Ganzzahl, Ganzzahl, Ganzzahl, Ganzzahl, Ganzzahl, Ganzzahl, Ganzzahl)
d.singleton(d.MixedList, "Tiere", Tier)

d.singleton(d.HeterogeneousList, "Liturgiekenntnis", String, Simple) {
  "", ""
}

d.singleton(d.MixedList, "Liturgien", d.HeterogeneousList("Liturgie", Ganzzahl, String, String))

return schema