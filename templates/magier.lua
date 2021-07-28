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
    SprachenUndSchriften(10),
    Handwerk(15)
  },
  Kampfbogen {},
  Ausruestungsbogen {},
  Zauberdokument {},
  Zauberliste {}
}

Talente.Kampf {
  Nah {"Dolche",                "D", "BE-1", {}, {}, {}},
  Nah {"Hiebwaffen",            "D", "BE-4", {}, {}, {}},
  Nah {"Raufen",                "C", "BE",   {}, {}, {}},
  Nah {"Ringen",                "D", "BE",   {}, {}, {}},
  Fern {"Wurfmesser",           "C", "BE-3", {}},
}

Talente.Koerper {
  {"Athletik",           "GE", "KO", "KK", "BEx2", {}},
  {"Klettern",           "MU", "GE", "KK", "BEx2", {}},
  {"Körperbeherrschung", "MU", "IN", "GE", "BEx2", {}},
  {"Schleichen",         "MU", "IN", "GE", "BE",   {}},
  {"Schwimmen",          "GE", "KO", "KK", "BEx2", {}},
  {"Selbstbeherrschung", "MU", "KO", "KK", "-",    {}},
  {"Sich Verstecken",    "MU", "IN", "GE", "BE-2", {}},
  {"Singen",             "IN", "CH", "CH", "BE-3", {}},
  {"Sinnesschärfe",      "KL", "IN", "IN", "-",    {}},
  {"Tanzen",             "CH", "GE", "GE", "BEx2", {}},
  {"Zechen",             "IN", "KO", "KK", "-",    {}},
}

Talente.Gesellschaft {
  {"Menschenkenntnis", "KL", "IN", "CH", {}},
  {"Überreden",        "MU", "IN", "CH", {}},
}

Talente.Natur {
  {"Fährtensuchen", "KL", "IN", "IN", {}},
  {"Orientierung",  "KL", "IN", "IN", {}},
  {"Wildnisleben",  "IN", "GE", "KO", {}},
}

Talente.Wissen {
  {"Götter / Kulte",            "KL", "KL", "IN", {}},
  {"Rechnen",                   "KL", "KL", "IN", {}},
  {"Sagen / Legenden",          "KL", "IN", "CH", {}},
}

Talente.SprachenUndSchriften {
  Muttersprache {"", {}, {}},
}

Talente.Handwerk {
  {"Heilkunde Wunden", "KL", "CH", "FF", {}},
  {"Holzbearbeitung",  "KL", "FF", "KK", {}},
  {"Kochen",           "KL", "IN", "FF", {}},
  {"Lederarbeiten",    "KL", "FF", "FF", {}},
  {"Malen / Zeichnen", "KL", "IN", "FF", {}},
  {"Schneidern",       "KL", "FF", "FF", {}},
}
