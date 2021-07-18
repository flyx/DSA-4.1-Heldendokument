local d = require("schemadef")
local schema = loadfile("schema.lua", "t")(false)
local skt = require("skt")

local i = 1
while i <= #arg do
  local name = arg[i]
  i = i + 1

  if name == "heldendokument.tex" then
    break
  end
end

if i < #arg then
  tex.error("zu viele Argumente. Erstes überflüssiges Argument: '" .. tostring(arg[i+1]) .. "'")
end

if i == #arg then
  local f, errmsg = loadfile(arg[i], "t", schema)
  if f == nil then
    tex.error(errmsg)
  end
  f()
  if d.Poison.count > 0 then
    tex.error("Fehler beim Laden der Heldendefinition!")
  end
end

local values = {
  Layout = schema.Layout:instance(),
  Held = schema.Held:instance(),
  Vorteile = schema.Vorteile:instance(),
  Nachteile = schema.Nachteile:instance(),
  eig = schema.Eigenschaften:instance(),
  AP = schema.AP:instance(),
  Talente = {},
  SF = {
    Allgemein = schema.SF:instance(),
    Nahkampf = schema.SF.Nahkampf:instance(),
    Fernkampf = schema.SF.Fernkampf:instance(),
    Waffenlos = schema.SF.Waffenlos:instance(),
    Magisch = schema.SF.Magisch:instance(),
  },
  Waffen = {
    Nahkampf = schema.Waffen.Nahkampf:instance(),
    Fernkampf = schema.Waffen.Fernkampf:instance(),
    Schilde = schema.Waffen.Schilde:instance(),
    Ruestung = schema.Waffen.Ruestung:instance(),
  },
  Kleidung = schema.Kleidung:instance(),
  Ausruestung = schema.Ausruestung:instance(),
  Proviant = schema.Proviant:instance(),
  Vermoegen = schema.Vermoegen:instance(),
  Verbindungen = schema.Verbindungen:instance(),
  Notizen = schema.Notizen:instance(),
  Tiere = schema.Tiere:instance(),
  Liturgiekenntnis = schema.Liturgiekenntnis:instance(),
  Liturgien = schema.Liturgien:instance(),
  Magie = {},
  Ereignisse = {},
}

values.Vorteile.Magisch = schema.Vorteile.Magisch:instance()
values.Vorteile.Magisch.asp = #values.Vorteile.Magisch > 0
values.Nachteile.Magisch = schema.Nachteile.Magisch:instance()
for k,v in pairs(schema.Talente) do
  values.Talente[k] = v:instance()
end
for k,v in pairs(schema.Magie) do
  values.Magie[k] = v:instance()
end
values.Vermoegen.Sonstiges = schema.Vermoegen.Sonstiges:instance()
for _,v in ipairs(values.Talente.SprachenUndSchriften) do
  if getmetatable(v) == schema.Muttersprache then
    values.Talente.SprachenUndSchriften.Muttersprache = v
    break
  end
end
if values.Talente.SprachenUndSchriften.Muttersprache == nil then
  tex.error("[Talente.SprachenUndSchriften] Muttersprache fehlt")
end

local function sum_and_round(items, pos)
  local cur = nil
  for i,v in ipairs(items) do
    if #v >= pos then
      local num = tonumber(v[pos]())
      if num == nil then
        return ""
      elseif cur == nil then
        cur = num
      else
        cur = cur + num
      end
    end
  end
  return cur == nil and "" or tonumber(string.format("%.0f", cur + 0.0001)) -- round up at 0.5
end

local getter_map = {
  calc = {
    LE = function() return {"KO", "KO", "KK", div=2} end,
    AU = function() return {"MU", "KO", "GE", div=2} end,
    AE = function()
      if data.Vorteile.Magisch.asp then
        if data.SF.Magisch.GefaessDerSterne then
          return {"MU", "IN", "CH", "CH", div=2}
        else
          return {"MU", "IN", "CH", div=2}
        end
      else
        return {"MU", "IN", "CH", div=2, disabled=true}
      end
    end,
    MR = function() return {"MU", "KL", "KO", div=5} end,
    KE = function() return {"KE", hide_formula = true} end,
    INI = function() return {"MU", "MU", "IN", "GE", div=5} end,
    AT = function() return {"MU", "GE", "KK", div=5} end,
    PA = function() return {"IN", "GE", "KK", div=5} end,
    FK = function() return {"IN", "FF", "KK", div=5} end,
  },
}

function getter_map:reg(kind, ...)
  for i,v in ipairs({...}) do
    self[v] = kind
  end
end

function getter_map:formula(name)
  local vals = self.calc[name]()
  if vals.hide_formula then
    return ""
  end
  local res = "("
  for i,v in ipairs(vals) do
    if i ~= 1 then
      res = res .. "+"
    end
    res = res .. v
  end
  return res .. ")/" .. vals.div
end

getter_map:reg("basic", "MU", "KL", "IN", "CH", "FF", "GE", "KO", "KK")
getter_map:reg("calculated", "LE", "AU", "AE", "MR", "KE", "INI", "AT", "PA", "FK")
getter_map:reg("gs_mod", "GS_mod")
getter_map:reg("gs", "GS")
getter_map:reg("rs", "RS")
getter_map:reg("be", "BE")
getter_map:reg("be_voll", "BE_voll")

function getter_map.sparse(val, div)
  div = div or 1
  if val == 0 then
    return ""
  end
  return tonumber(string.format("%.0f", val/div + 0.0001)) -- round up at 0.5
end

values.sparse = getter_map.sparse

setmetatable(getter_map.calc, {
  __call = function(self, data, name)
    local vals = self[name]()
    if vals.disabled then
      return ""
    end
    local div = vals.div and vals.div or 1
    local val = 0
    for i,v in ipairs(vals) do
      local x = 0
      if v == "KE" then
        x = data.eig.KE[1]
      else
        x = data.eig[v][3]
      end
      if x == 0 then
        return ""
      end
      val = val + x
    end
    val = val / div
    if val == 0 then
      return ""
    end

    if name == "INI" then
      val = val + data.eig.INI
      if data.SF.Nahkampf.Kampfreflexe then
        val = val + 4
      end
      if data.SF.Nahkampf.Kampfgespuer then
        val = val + 2
      end
    else
      local others = data.eig[name]
      if others then
        -- Modifikator, Zugekauft, Permanent
        val = val + others[1] + others[2] - others[3]
      end
    end
    return getter_map.sparse(val)
  end
})

function values:cur(name, div)
  div = div or 1
  local kind = getter_map[name]
  if kind == "basic" then
    return getter_map.sparse(self.eig[name][3], div)
  elseif kind == "calculated" then
    return getter_map.calc(self, name)
  elseif kind == "gs_mod" then
    local ge = self:cur("GE")
    if ge ~= "" then
      local gsmod = 0
      for i,v in ipairs({{"Kleinwuechsig", -1}, {"Zwergenwuchs", -2}, {"Behaebig", -1}}) do
        if self.Nachteile[v[1]] then
          gsmod = gsmod + v[2]
        end
      end
      if self.Vorteile.Flink then
        gsmod = gsmod + self.Vorteile.Flink
      end
      if ge < 10 then
        gsmod = gsmod - 1
      elseif ge > 15 then
        gsmod = gsmod + 1
      end
      return gsmod
    else
      return ""
    end
  elseif kind == "gs" then
    local gsmod = self:cur("GS_mod")
    if gsmod == "" then
      return ""
    end
    return 8 + gsmod
  elseif kind == "rs" then
    return sum_and_round(self.Waffen.Ruestung, 2)
  elseif kind == "be" or kind == "be_voll" then
    local val = sum_and_round(self.Waffen.Ruestung, 3)
    if val == "" then
      return val
    end
    if kind == "be" then
      if self.SF.Nahkampf.Ruestungsgewoehnung[3] then
        val = val - 2
      elseif self.SF.Nahkampf.Ruestungsgewoehnung[1] then
        val = val - 1
      end
      if val < 0 then
        val = 0
      end
    end
    return val
  else
    tex.error("queried unknown value: " .. name)
  end
end

function values:formula(name)
  local kind = getter_map[name]
  if kind ~= "calculated" then
    tex.error("requested formula of something not calculated: " .. name)
  end
  return getter_map:formula(name)
end

local function merkmal_mod_from(merkmal, merkmale, delta)
  if type(merkmale) ~= "table" then
    tex.error("Folgender Wert muss eine Liste sein, ist aber keine: '" .. merkmale .. "'")
    return 0
  end
  for i, n in ipairs(merkmale) do
    if merkmal == n then
      return delta
    end
  end
  return 0
end

local function merkmal_submod_from(name, sub, merkmale, delta)
  local ret = 0
  if sub ~= nil and merkmale ~= nil then
    if merkmale.gesamt ~= nil then
      ret = ret + delta
    end
    if type(sub) == "table" then
      for _,v in ipairs(sub) do
        if merkmale[v] ~= nil then
          ret = ret + delta
        end
      end
    elseif type(sub) == "string" and merkmale[sub] ~= nil then
      ret = ret + delta
    end
  end
  return ret
end

local function repr_malus_between(repr1, repr2)
  if repr2 == "Srl" or repr2 == "Sch" then
    return repr_malus_between(repr2, repr1)
  end
  if repr1 == repr2 then
    return 0
  elseif repr1 == "Srl" then
    return repr2 == "Mag" and 1 or 2
  elseif repr1 == "Sch" then
    return repr2 == "Srl" and 2 or 3
  else
    return 2
  end
end

local function repr_malus(repr, known)
  local min = 3
  for i,v in ipairs(known) do
    min = math.min(min, repr_malus_between(repr, v))
  end
  return min
end

function values:lernschwierigkeit(z)
  if math.min(string.len(z.Komplexitaet), string.len(z.Repraesentation)) == 0 then
    return ""
  end
  local index = skt.spalte:num(z.Komplexitaet)
  for i, merkmal in ipairs(z.Merkmale) do
    index = index + merkmal_mod_from(merkmal, self.Magie.Merkmalskenntnis, -1)
    index = index + merkmal_mod_from(merkmal, self.Vorteile.Magisch.BegabungFuerMerkmal, -1)
    index = index + merkmal_mod_from(merkmal, self.Nachteile.Magisch.UnfaehigkeitFuerMerkmal, 1)
  end
  for _, name in ipairs({"Elementar", "Daemonisch"}) do
    index = index + merkmal_submod_from(name, z.Merkmale[name], self.Magie.Merkmalskenntnis[name], -1)
    index = index + merkmal_submod_from(name, z.Merkmale[name], self.Vorteile.Magisch.BegabungFuerMerkmal[name], -1)
    index = index + merkmal_submod_from(name, z.Merkmale[name], self.Nachteile.Magisch.UnfaehigkeitFuerMerkmal[name], 1)
  end
  for _, name in ipairs(self.Vorteile.Magisch.BegabungFuerZauber) do
    if name == z.Name then
      index = index - 1
      break
    end
  end
  index = index + (z.Hauszauber and -1 or 0)
  index = index + repr_malus(z.Repraesentation, self.Magie.Repraesentationen)
  return skt.spalte:name(index)
end

function values:tgruppe_schwierigkeit_mod(gruppe)
  local val = 0
  if self.Vorteile.BegabungFuerTalentgruppe == nil then
    tex.error("is nil: BegabungFuerTalentgruppe")
  end
  for _,n in ipairs(self.Vorteile.BegabungFuerTalentgruppe) do
    if n == gruppe then
      val = val - 1
      break
    end
  end
  for _, n in ipairs(self.Nachteile.UnfaehigkeitFuerTalentgruppe) do
    if n == gruppe then
      val = val + 1
      break
    end
  end
  if gruppe == "Nahkampf" or gruppe == "Fernkampf" then
    val = val + self:tgruppe_schwierigkeit_mod("Kampf")
  elseif self.Nachteile.Unstet and (gruppe == "Wissen" or gruppe == "Handwerk") then
    val = val + 1
  end
  return val
end

function values:tgruppe_schwierigkeit(gruppe)
  if gruppe == "Gaben" or gruppe == "Begabungen" then
    return "F"
  end
  local val
  if gruppe == "Koerper" then
    val = skt.spalte:num("D")
  else
    val = skt.spalte:num("B")
  end
  val = val + self:tgruppe_schwierigkeit_mod(gruppe)
  return skt.spalte:name(val)
end

function values:tgruppe_faktor(gruppe)
  if gruppe == "SprachenUndSchriften" or gruppe == "Zauber" then
    if self.Vorteile.EidetischesGedaechtnis then
      return skt.faktor["1/2"]
    elseif self.Vorteile.GutesGedaechtnis then
      return skt.faktor["3/4"]
    else
      return skt.faktor["1"]
    end
  elseif gruppe == "Wissen" and self.Vorteile.EidetischesGedaechtnis then
    return skt.faktor["1/2"]
  else
    return skt.faktor["1"]
  end
end

function values:talent_schwierigkeit_mod(talent)
  local name = talent[1]
  local val = 0
  for _,n in ipairs(self.Vorteile.BegabungFuerTalent) do
    if n == name then
      val = val - 1
      break
    end
  end
  for _, n in ipairs(self.Nachteile.UnfaehigkeitFuerTalent) do
    if n == name then
      val = val + 1
      break
    end
  end
  return val
end

function values:talent_schwierigkeit(talent, gruppe)
  return skt.spalte:name(skt.spalte:num(self:tgruppe_schwierigkeit(gruppe)) + self:talent_schwierigkeit_mod(talent))
end

function values:kampf_schwierigkeit(kampftalent)
  local x = skt.spalte:num(kampftalent[2])
  if getmetatable(kampftalent).name == "Fern" then
    x = x + self:tgruppe_schwierigkeit_mod("Fernkampf")
  else
    x = x + self:tgruppe_schwierigkeit_mod("Nahkampf")
  end
  x = x + self:talent_schwierigkeit_mod(kampftalent)
  return skt.spalte:name(x)
end

function values:sprache_schwierigkeit(sprache)
  local mt = getmetatable(sprache)
  local name = sprache.Name
  local x = name == "Asdharia" and 3 or 2
  if mt.name == "Sprache" and name ~= "Atak" and name ~= "Füchsisch" then
    x = x + 1
    for _,s in ipairs(self.Talente.SprachenUndSchriften.Muttersprache.Sprachfamilie) do
      if s == name then
        x = x - 1
        break
      end
    end
  end
  return skt.spalte:name(x + self:tgruppe_schwierigkeit_mod("SprachenUndSchriften"))
end

function values:schrift_schwierigkeit(schrift)
  local x = skt.spalte:num(schrift.Steigerungsspalte) + 1
  local name = schrift.Name
  for _, s in ipairs(self.Talente.SprachenUndSchriften.Muttersprache.Schriftfamilie) do
    if s == name then
      x = x - 1
      break
    end
  end
  return skt.spalte:name(x + self:tgruppe_schwierigkeit_mod("SprachenUndSchriften"))
end

function values:ap_mod(kosten)
  if type(self.AP.Eingesetzt) == "number" then
    self.AP.Eingesetzt = self.AP.Eingesetzt + kosten
  end
  if type(self.AP.Guthaben) == "number" then
    self.AP.Guthaben = self.AP.Guthaben - kosten
    return self.AP.Guthaben
  else
    return ""
  end
end

function values:steigerSF(tname, e, faktorMod, target)
  local name = e.SF
  local descr = name
  if type(name) == "table" then
    name = getmetatable(name).name
    descr = name .. " ("
    local first = true
    for i,v in ipairs(e.SF) do
      local append = nil
      if getmetatable(getmetatable(e.SF)) == d.Numbered then
        if v then
          append = tostring(i)
        end
      else
        append = v
      end
      if append ~= nil then
        if first then
          first = false
        else
          descr = descr .. ", "
        end
        descr = descr .. append
      end
    end
    descr = descr .. ")"
  end

  local faktor = skt.faktor["1"]
  local possible = nil
  local subset = nil
  for _, m in ipairs(faktorMod) do
    if type(m[1]) == "table" then
      local l = self.Vorteile[m[1][1]]
      for i=2,#m[1] do
        for _, item in ipairs(l) do
          if item == m[1][i] then
            possible = skt.faktor[m[2]]
            subset = m[3]
            goto foundmod
          end
        end
      end
    else
      if self.Vorteile[m[1]] then
        possible = skt.faktor[m[2]]
        subset = m[3]
        break
      end
    end
  end
  ::foundmod::
  if possible ~= nil then
    if subset == nil then
      faktor = possible
    else
      for _, v in ipairs(subset) do
        if name:sub(1, #v) == v then
          faktor = possible
          break
        end
      end
    end
  end
  local msg = target:append(e.SF)
  if msg ~= nil then
    tex.error("\n[" .. tname .. "] " .. name .. ": " .. msg)
  end
  local kosten = faktor:apply(e.Kosten)
  return {
    "Sonderfertigkeit (" .. e.Methode .. "): " .. descr,
    -1 * e.Kosten, faktor, -1 * kosten, self:ap_mod(kosten)
  }
end

-- Ereignisse auf Charakter applizieren

for _, e in ipairs(schema.Ereignisse:instance()) do
  local mt = getmetatable(e)
  local event = {""}
  if mt.name == "TaW" then
    event[1] = "Talentsteigerung (" .. e.Name .. ", " .. e.Methode .. ") von "
    for _, g in ipairs({"Gaben", "Kampf", "Koerper", "Gesellschaft", "Natur", "Wissen", "SprachenUndSchriften", "Handwerk"}) do
      for _, t in ipairs(values.Talente[g]) do
        if t.Name == e.Name then
          if type(t.TaW) ~= "number" then
            tex.error("\n[TaW] Kann '" .. e.Name .. "' nicht steigern: hat keinen Zahlenwert, sondern " .. type(t.TaW))
          end
          local mt = getmetatable(t)
          event[1] = event[1] .. tonumber(t.TaW) .. " auf " .. tonumber(e.Zielwert)
          local spalte
          if g == "Kampf" then
            spalte = values:kampf_schwierigkeit(t)
          elseif g == "SprachenUndSchriften" then
            if mt.name == "Schrift" then
              spalte = values:schrift_schwierigkeit(t)
            else
              spalte = values:sprache_schwierigkeit(t)
            end
          else
            spalte = values:talent_schwierigkeit(t, g)
          end
          local faktor = values:tgruppe_faktor(g)
          local ap = 0
          while t.TaW < e.Zielwert do
            t.TaW = t.TaW + 1
            ap = ap + skt:kosten(skt.spalte:effektiv(spalte, t.TaW, e.Methode), t.TaW)
          end
          event[2] = -1 * ap
          event[3] = faktor
          local kosten = faktor:apply(ap)
          event[4] = -1 * kosten
          event[5] = values:ap_mod(kosten)
          goto found
        end
      end
    end
    tex.error("\n[TaW] unbekanntes Talent: '" .. e.Name .. "'")
  elseif mt.name == "ZfW" then
    event[1] = "Zaubersteigerung (" .. e.Name .. ", " .. e.Methode .. ") von "
    for _, z in ipairs(values.Magie.Zauber) do
      if z.Name == e.Name then
        if type(z.ZfW) ~= "number" then
          tex.error("\n[ZfW] Kann '" .. e.Name .. "' nicht steigern: hat keinen Zahlenwert, sondern " .. type(z.ZfW))
        end
        event[1] = event[1] .. tonumber(z.ZfW) .. " auf " .. tonumber(e.Zielwert)
        local spalte = values:lernschwierigkeit(z)
        local faktor = values:tgruppe_faktor("Zauber")
        local ap = 0
        while z.ZfW < e.Zielwert do
          z.ZfW = z.ZfW + 1
          ap = ap + skt:kosten(skt.spalte:effektiv(spalte, z.ZfW, e.Methode), z.ZfW)
        end
        event[2] = -1 * ap
        event[3] = faktor
        local kosten = faktor:apply(ap)
        event[4] = -1 * kosten
        event[5] = values:ap_mod(kosten)
        goto found
      end
    end
    tex.error("\n[ZfW] unbekannter Zauber: '" .. e.Name .. "'")
  elseif mt.name == "Spezialisierung" then
    local ziel = nil
    local faktor = skt.faktor["1"]
    local spalte = nil
    for _, w in ipairs(values.Talente.Kampf) do
      if w.Name == e.Fertigkeit then
        ziel = w
        spalte = values:kampf_schwierigkeit(w)
        if values.Vorteile.AkademischeAusbildung[1] == "Krieger" or
            values.Vorteile.AkademischeAusbildung[1] == "Kriegerin" then
          faktor = skt.faktor["3/4"]
        end
        event[1] = "Waffenspezialisierung ("
        break
      end
    end
    if ziel == nil then
      for _, g in ipairs({"Gaben", "Koerper", "Gesellschaft", "Natur", "Wissen", "Handwerk"}) do
        for _, t in ipairs(values.Talente[g]) do
          if t.Name == e.Fertigkeit then
            ziel = t
            spalte = values:talent_schwierigkeit(t, g)
            if g == "Wissen" then
              if values.Vorteile.EidetischesGedaechtnis then
                faktor = skt.faktor["1/2"]
              elseif values.Vorteile.GutesGedaechtnis then
                faktor = skt.faktor["3/4"]
              end
            end
            event[1] = "Talentspezialisierung ("
            goto talentfund
          end
        end
      end
      ::talentfund::
    end
    if ziel == nil then
      for _, z in ipairs(values.Magie.Zauber) do
        if z.Name == e.Fertigkeit then
          ziel = z
          spalte = values:lernschwierigkeit(z)
          if values.Vorteile.AkademischeAusbildung[1] == "Magier" or
              values.Vorteile.AkademischeAusbildung[1] == "Magierin" then
            if values.Vorteile.EidetischesGedaechtnis then
              faktor = skt.faktor["3/8"]
            elseif values.Vorteile.GutesGedaechtnis then
              faktor = skt.faktor["9/16"]
            else
              faktor = skt.faktor["3/4"]
            end
          elseif values.Vorteile.EidetischesGedaechtnis then
            faktor = skt.faktor["1/2"]
          elseif values.Vorteile.GutesGedaechtnis then
            faktor = skt.faktor["3/4"]
          end
          event[1] = "Zauberspezialisierung ("
          break
        end
      end
    end
    if ziel == nil then
      tex.error("\n[Spezialisierung] unbekannte Fertigkeit: '" .. e.Fertigkeit .. "'")
    end
    event[1] = event[1] .. e.Fertigkeit .. ", " .. e.Methode .. "): " .. e.Name
    table.insert(ziel.Spezialisierungen, e.Name)
    local ap = #ziel.Spezialisierungen * 20 * math.floor(skt.spalte[skt.spalte:num(spalte)].f + 0.5)
    if e.Methode == "SE" then
      ap = math.floor(ap / 2 + 0.5)
    end
    event[2] = -1 * ap
    event[3] = faktor
    local kosten = faktor:apply(ap)
    event[4] = -1 * kosten
    event[5] = values:ap_mod(kosten)
  elseif mt.name == "ProfaneSF" then
    local verbilligt = {"Dschungelkundig", "Eiskundig", "Gebirgskundig", "Höhlenkundig", "Maraskankundig", "Meereskundig", "Steppenkundig", "Sumpfkundig", "Waldkundig, Wüstenkundig", "Kulturkunde", "Nandusgefälliges Wissen", "Ortskenntnis"}
    event = values:steigerSF("ProfaneSF", e, {{"EidetischesGedächtnis", "1/2", verbilligt}, {"GutesGedaechtnis", "3/4", verbilligt}},
      values.SF.Allgemein)
  elseif mt.name == "NahkampfSF" then
    event = values:steigerSF("NahkampfSF", e, {{{"AkademischeAusbildung", "Krieger", "Kriegerin"}, "3/4"}, {{"AkademischeAusbildung", "Magier", "Magierin"}, "3/2", {"Ruestungsgewoehnung"}}}, values.SF.Nahkampf)
  elseif mt.name == "FernkampfSF" then
    event = values:steigerSF("FernkampfSF", e, {{{"AkademischeAusbildung", "Krieger", "Kriegerin"}, "3/4"}}, values.SF.Fernkampf)
  else
    tex.error("\n[Ereignisse] unbekannter Ereignistyp: '" .. mt.name .. "'")
  end
  ::found::
  table.insert(values.Ereignisse, event)
end

return values