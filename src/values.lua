require("stdext")
local d = require("schemadef")
local schema = assert(loadfile("schema.lua", "t"))(false)
local skt = require("skt")

local input = ...

if input ~= nil then
  local f = function() tex.error(input .. " brauchte zu lange zum Laden!") end
  debug.sethook(f, "", 1e6)
  local f, errmsg = loadfile(input, "t", schema)
  if f == nil then
    tex.error(errmsg)
  end
  f()
  debug.sethook()
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
    SchildeUndParierwaffen = schema.Waffen.SchildeUndParierwaffen:instance(),
    Ruestung = schema.Waffen.Ruestung:instance(),
  },
  Kleidung = schema.Kleidung:instance(),
  Ausruestung = schema.Ausruestung:instance(),
  Proviant = schema.Proviant:instance(),
  Vermoegen = schema.Vermoegen:instance(),
  Verbindungen = schema.Verbindungen:instance(),
  Notizen = schema.Notizen:instance(),
  Tiere = schema.Tiere:instance(),
  Mirakel = {},
  Magie = {},
  Ereignisse = {},
}

values.Vorteile.Magisch = schema.Vorteile.Magisch:instance()
values.Nachteile.Eigenschaften = schema.Nachteile.Eigenschaften:instance()
values.Nachteile.Magisch = schema.Nachteile.Magisch:instance()
for k,v in pairs(schema.Talente) do
  values.Talente[k] = v:instance()
end
for k,v in pairs(schema.Magie) do
  values.Magie[k] = v:instance()
end
for k,v in pairs(schema.Mirakel) do
  values.Mirakel[k] = v:instance()
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

local getter_map = {
  calc = {
    LE = function() return {"KO", "KO", "KK", div=2} end,
    AU = function() return {"MU", "KO", "GE", div=2} end,
    AE = function()
      if data:has_asp() then
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
getter_map:reg("egs", "eGS")
getter_map:reg("rs", "RS")
getter_map:reg("be", "BE")
getter_map:reg("be_voll", "BE_voll")
getter_map:reg("ap", "AP")

function getter_map.sparse(val, div)
  div = div or 1
  if val == 0 then
    return ""
  end
  return math.round(val / div)
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
        if data.eig.KE.Mod == 0 then
          return ""
        end
      else
        x = data.eig[v][3]
        if x == 0 then
          return ""
        end
      end
      val = val + x
    end
    val = val / div

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

function values:has_asp()
  return #self.Vorteile.Magisch > 0
end

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
      for i,v in ipairs({
        {"Kleinwuechsig", -1},
        {"Zwergenwuchs", -2},
        {"Behaebig", -1},
        {"Lahm", -1},
      }) do
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
  elseif kind == "egs" then
    local gs = self:cur("GS")
    local be = self:cur("BE")
    if type(gs) == "number" and type(be) == "number" then
      gs = gs - be
    end
    return gs
  elseif kind == "rs" or kind == "be" or kind == "be_voll" then
    local rs, be = self:gesamtRuestung(self.Waffen.Ruestung)
    if kind == "rs" then
      if rs == nil then return "" else return rs end
    end
    if kind == "be_voll" or be == nil then
      if be == nil then return "" else return be end
    end
    local rg = self.SF.Nahkampf:getlist("Ruestungsgewoehnung")
    if rg[3] then
      be = be - 2
    elseif rg[1] then
      be = be - 1
    end
    if be < 0 then
      be = 0
    end
    return be
  elseif kind == "ap" then
    if type(self.AP.Gesamt) == "number" and type(self.AP.Eingesetzt) == "number" then
      return self.AP.Gesamt - self.AP.Eingesetzt
    else
      return ""
    end
  else
    tex.error("queried unknown value: " .. name)
  end
end

function values.PA(talent)
  if talent.AT ~= nil and talent.TaW ~= nil then
    return talent.TaW - talent.AT
  else
    return nil
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

local function merkmal_submod_from(sub, merkmale, delta)
  local ret = 0
  if sub ~= nil and merkmale ~= nil then
    for _, v in ipairs(merkmale) do
      if v == "gesamt" then
        ret = ret + delta
        break
      end
    end
    for _, v in ipairs(sub) do
      for _, w in ipairs(merkmale) do
        if v == w then
          ret = ret + delta
          break
        end
      end
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
    local mt = getmetatable(merkmal)
    if mt.name == "Daemonisch" or mt.name == "Elementar" then
      index = index + merkmal_submod_from(merkmal, self.Magie.Merkmalskenntnis[mt.name], -1)
      index = index + merkmal_submod_from(merkmal, self.Vorteile.Magisch:getlist("BegabungFuerMerkmal")[mt.name], -1)
      index = index + merkmal_submod_from(merkmal, self.Nachteile.Magisch:getlist("UnfaehigkeitFuerMerkmal")[mt.name], 1)
    else
      index = index + merkmal_mod_from(merkmal, self.Magie.Merkmalskenntnis, -1)
      index = index + merkmal_mod_from(merkmal, self.Vorteile.Magisch:getlist("BegabungFuerMerkmal"), -1)
      index = index + merkmal_mod_from(merkmal, self.Nachteile.Magisch:getlist("UnfaehigkeitFuerMerkmal"), 1)
    end
  end
  for _, name in ipairs(self.Vorteile.Magisch:getlist("BegabungFuerZauber")) do
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
  for _,n in ipairs(self.Vorteile:getlist("BegabungFuerTalentgruppe")) do
    if n == gruppe then
      val = val - 1
      break
    end
  end
  for _, n in ipairs(self.Nachteile:getlist("UnfaehigkeitFuerTalentgruppe")) do
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
  for _,n in ipairs(self.Vorteile:getlist("BegabungFuerTalent")) do
    if n == name then
      val = val - 1
      break
    end
  end
  for _, n in ipairs(self.Nachteile:getlist("UnfaehigkeitFuerTalent")) do
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

function values:silhouette(page)
  local kind = (self.Held.Geschlecht == "weiblich") and "generic-w" or "generic-m"
  local variant = page.Regenbogen and "Regenbogen" or "Standard"
  return kind, variant
end

local rsFaktor = {
  0, -- Name hat keinen Faktor
  2, 4, 4, 4, 1, 1, 2, 2
}

-- gibt gRS und gBE aller Ruestungsteile in `teile` zurück.
-- decimals == true gibt Dezimalstellen zurück.
function values:gesamtRuestung(teile, decimals)
  local gRS = nil
  local gBE = nil
  local sterne = 0
  for _, teil in ipairs(teile) do
    local sum = nil
    for i=2,9 do
      if teil[i] ~= nil then
        local add = teil[i] * rsFaktor[i]
        if sum == nil then sum = add else sum = sum + add end
      end
    end
    if sum ~= nil then
      if gRS == nil then gRS = sum else gRS = gRS + sum end
      local s = teil.Sterne or 0
      if teil.Z then
        for j=1,s do
          sum = sum / 2
        end
      else
        sterne = sterne + s
      end
      if gBE == nil then gBE = sum else gBE = gBE + sum end
    end
  end
  if gRS == nil then return nil, nil end
  gRS = gRS/20
  gBE = math.max(gBE/20 - sterne, 0)
  if not decimals then
    gRS = math.round(gRS)
    gBE = math.round(gBE)
  end
  return gRS, gBE
end

function values:ap_mod(kosten)
  if type(self.AP.Eingesetzt) == "number" then
    self.AP.Eingesetzt = self.AP.Eingesetzt + kosten
  end
  return self:cur("AP")
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
      if l ~= nil then
        for i=2,#m[1] do
          for _, item in ipairs(l) do
            if item == m[1][i] then
              possible = skt.faktor[m[2]]
              subset = m[3]
              goto foundmod
            end
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
  local ap = e.Kosten
  if e.Methode == "SE" then
    ap = ap / 2
  end
  local kosten = faktor:apply(ap)
  return {
    "Sonderfertigkeit (" .. e.Methode .. "): " .. descr,
    -1 * e.Kosten, faktor, -1 * kosten, self:ap_mod(kosten)
  }
end

-- Ereignisse auf Charakter applizieren

function values:talentsteigerung(e)
  local event = {"Talentsteigerung (" .. e.Name .. ", " .. e.Methode .. ") von "}
  for _, g in ipairs({"Gaben", "Kampf", "Koerper", "Gesellschaft", "Natur", "Wissen", "SprachenUndSchriften", "Handwerk"}) do
    for _, t in ipairs(self.Talente[g]) do
      if t.Name == e.Name and (e.Typ == nil or getmetatable(t).name == e.Typ.name) then
        if type(t.TaW) ~= "number" then
          tex.error("\n[TaW] Kann '" .. e.Name .. "' nicht steigern: hat keinen Zahlenwert, sondern " .. type(t.TaW))
        end
        if getmetatable(t).name == "Nah" then
          if e.AT == nil then
            tex.error("\n[TaW] Steigerung von " .. e.Name .. " benötigt AT-Wert")
          end
        elseif e.AT ~= nil then
          tex.error("\n[Taw] Steigerung von " .. e.Name .. " kann mit einem AT-Wert nichts anfangen")
        end
        local mt = getmetatable(t)
        event[1] = event[1] .. tonumber(t.TaW) .. " auf " .. tonumber(e.Zielwert)
        local spalte
        if g == "Kampf" then
          spalte = self:kampf_schwierigkeit(t)
        elseif g == "SprachenUndSchriften" then
          if mt.name == "Schrift" then
            spalte = self:schrift_schwierigkeit(t)
          else
            spalte = self:sprache_schwierigkeit(t)
          end
        else
          spalte = self:talent_schwierigkeit(t, g)
        end
        local faktor = self:tgruppe_faktor(g)
        local ap = 0
        while t.TaW < e.Zielwert do
          t.TaW = t.TaW + 1
          ap = ap + skt:kosten(skt.spalte:effektiv(spalte, t.TaW, e.Methode), t.TaW)
        end
        if e.AT ~= nil then
          t.AT = t.AT + e.AT
        end
        event[2] = -1 * ap
        event[3] = faktor
        local kosten = faktor:apply(ap)
        event[4] = -1 * kosten
        event[5] = values:ap_mod(kosten)
        return event
      end
    end
  end
  tex.error("\n[TaW] unbekanntes Talent: '" .. e.Name .. "'")
end

function values:zaubersteigerung(e)
  local event = {"Zaubersteigerung (" .. e.Name .. ", " .. e.Methode .. ") von "}
  for _, z in ipairs(self.Magie.Zauber) do
    if z.Name == e.Name then
      if type(z.ZfW) ~= "number" then
        tex.error("\n[ZfW] Kann '" .. e.Name .. "' nicht steigern: hat keinen Zahlenwert, sondern " .. type(z.ZfW))
      end
      event[1] = event[1] .. tonumber(z.ZfW) .. " auf " .. tonumber(e.Zielwert)
      local spalte = self:lernschwierigkeit(z)
      local faktor = self:tgruppe_faktor("Zauber")
      local ap = 0
      while z.ZfW < e.Zielwert do
        z.ZfW = z.ZfW + 1
        ap = ap + skt:kosten(skt.spalte:effektiv(spalte, z.ZfW, e.Methode), z.ZfW)
      end
      event[2] = -1 * ap
      event[3] = faktor
      local kosten = faktor:apply(ap)
      event[4] = -1 * kosten
      event[5] = self:ap_mod(kosten)
      return event
    end
  end
  tex.error("\n[ZfW] unbekannter Zauber: '" .. e.Name .. "'")
end

function values:spezialisierung(e)
  local event = {}
  local ziel = nil
  local faktor = skt.faktor["1"]
  local spalte = nil
  for _, w in ipairs(self.Talente.Kampf) do
    if w.Name == e.Fertigkeit then
      ziel = w
      spalte = self:kampf_schwierigkeit(w)
      if self.Vorteile:getlist("AkademischeAusbildung")[1] == "Krieger" or
          self.Vorteile:getlist("AkademischeAusbildung")[1] == "Kriegerin" then
        faktor = skt.faktor["3/4"]
      end
      event[1] = "Waffenspezialisierung ("
      break
    end
  end
  if ziel == nil then
    for _, g in ipairs({"Gaben", "Koerper", "Gesellschaft", "Natur", "Wissen", "Handwerk"}) do
      for _, t in ipairs(self.Talente[g]) do
        if t.Name == e.Fertigkeit then
          ziel = t
          spalte = self:talent_schwierigkeit(t, g)
          if g == "Wissen" then
            if self.Vorteile.EidetischesGedaechtnis then
              faktor = skt.faktor["1/2"]
            elseif self.Vorteile.GutesGedaechtnis then
              faktor = skt.faktor["3/4"]
            end
          end
          event[1] = "Talentspezialisierung ("
          goto talentfound
        end
      end
    end
    ::talentfound::
  end
  if ziel == nil then
    for _, z in ipairs(self.Magie.Zauber) do
      if z.Name == e.Fertigkeit then
        ziel = z
        spalte = self:lernschwierigkeit(z)
        if self.Vorteile:getlist("AkademischeAusbildung")[1] == "Magier" or
            self.Vorteile:getlist("AkademischeAusbildung")[1] == "Magierin" then
          if self.Vorteile.EidetischesGedaechtnis then
            faktor = skt.faktor["3/8"]
          elseif self.Vorteile.GutesGedaechtnis then
            faktor = skt.faktor["9/16"]
          else
            faktor = skt.faktor["3/4"]
          end
        elseif self.Vorteile.EidetischesGedaechtnis then
          faktor = skt.faktor["1/2"]
        elseif self.Vorteile.GutesGedaechtnis then
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
  ziel.Spezialisierungen:append(e.Name)
  local ap = (
    #ziel.Spezialisierungen * 20
      * math.round(skt.spalte[skt.spalte:num(spalte)].f))
  if e.Methode == "SE" then
    ap = math.round(ap / 2)
  end
  event[2] = -1 * ap
  event[3] = faktor
  local kosten = faktor:apply(ap)
  event[4] = -1 * kosten
  event[5] = self:ap_mod(kosten)
  return event
end

function values:eig_steigerung(e)
  local event = {}
  local spalte = skt.spalte:num("H")
  for _, n in ipairs(self.Vorteile:getlist("BegabungFuerEigenschaft")) do
    if n == e.Eigenschaft then
      spalte = spalte - 1
      break
    end
  end
  if self.Vorteile.Eigeboren and e.Eigenschaft == "CH" then
    spalte = spalte - 1
  end
  if e.Methode == "SE" then
    spalte = spalte - 1
  end
  local ap = 0
  local index = 3
  if e.Eigenschaft == "LE" or e.Eigenschaft == "AU" or e.Eigenschaft == "AE" or e.Eigenschaft == "MR" then
    index = 2
    event[1] = "Zukauf ("
  else
    event[1] = "Eigenschaft ("
  end
  local target = self.eig[e.Eigenschaft]
  event[1] = event[1] .. e.Eigenschaft .. ", " .. e.Methode .. ") von " .. tostring(target[index]) .. " auf " .. tostring(e.Zielwert)
  while target[index] < e.Zielwert do
    local cur = target[index]
    target[index] = cur + 1
    if target[index] == cur then
      tex.error("Fehler: kann Wert nicht steigern, aktuell " .. tostring(cur) .. "(" .. type(cur) .. ") [" .. event[1] .. "]")
    end
    ap = ap + skt:kosten(skt.spalte:name(spalte), target[index])
  end
  event[2] = -1 * ap
  event[3] = skt.faktor["1"]
  event[4] = -1 * ap
  event[5] = self:ap_mod(ap)
  return event
end

function values:rkw_steigerung(e)
  local r = nil
  for _, v in ipairs(self.Magie.Ritualkenntnis) do
    if v.Name == e.Name then
      r = v
      break
    end
  end
  if r == nil then
    tex.error("[RkW] unbekannter Name: " .. e.Name)
  end
  local faktor = skt.faktor["1"]
  if self.Vorteile.EidetischesGedaechtnis then
    faktor = skt.faktor["1/2"]
  elseif self.Vorteile.GutesGedaechtnis then
    faktor = skt.faktor["3/4"]
  end
  local ap = 0
  local event = {"Ritualkenntnis (" .. e.Name .. ", " .. e.Methode .. ") von " .. tostring(r.Wert) .. " auf " .. e.Zielwert}
  while r.Wert < e.Zielwert do
    r.Wert = r.Wert + 1
    ap = ap + skt:kosten(skt.spalte:effektiv(r.Steigerung, r.Wert, e.Methode), r.Wert)
  end
  event[2] = -1 * ap
  event[3] = faktor
  local kosten = faktor:apply(ap)
  event[4] = -1 * kosten
  event[5] = self:ap_mod(kosten)
  return event
end

function values:lkw_steigerung(e)
  local r = self.Mirakel.Liturgiekenntnis
  local faktor = skt.faktor["1"]
  if self.Vorteile.EidetischesGedaechtnis then
    faktor = skt.faktor["1/2"]
  elseif self.Vorteile.GutesGedaechtnis then
    faktor = skt.faktor["3/4"]
  end
  local ap = 0
  local event = {"Liturgiekenntnis (" .. r.Name .. ", " .. e.Methode .. ") von " .. tostring(r.Wert) .. " auf " .. e.Zielwert}
  while r.Wert < e.Zielwert do
    r.Wert = r.Wert + 1
    ap = ap + skt:kosten(skt.spalte:effektiv("F", r.Wert, e.Methode), r.Wert)
  end
  event[2] = -1 * ap
  event[3] = faktor
  local kosten = faktor:apply(ap)
  event[4] = -1 * kosten
  event[5] = self:ap_mod(kosten)
  return event
end

function values:aktiviere(e)
  local smt = getmetatable(e.Subjekt)
  if smt == nil or smt == string_metatable then
    tex.error("\n[Aktiviere] Subjekt muss explizit typisiert sein.")
  end
  local ap
  local faktor = skt.faktor["1"]
  local event = {}
  local ziel_taw = 0
  local ziel_zfw = 0
  if smt.name == "Nah" or smt.name == "NahAT" or smt.name == "Fern" then
    ziel_taw = e.Subjekt.TaW
    e.Subjekt.TaW = 0
    ap = skt:kosten(skt.spalte:effektiv(self:kampf_schwierigkeit(e.Subjekt), 0, e.Methode), 0)
    self.Talente.Kampf:append(e.Subjekt, e.Sortierung)
    event[1] = "Talentaktivierung ("
  elseif smt.name == "KoerperTalent" then
    ziel_taw = e.Subjekt.TaW
    e.Subjekt.TaW = 0
    ap = skt:kosten(skt.spalte:effektiv(self:talent_schwierigkeit(e.Subjekt, "Koerper"), 0, e.Methode), 0)
    self.Talente.Koerper:append(e.Subjekt, e.Sortierung)
    event[1] = "Talentaktivierung ("
  elseif smt.name == "Zweitsprache" or smt.name == "Sprache" then
    ziel_taw = e.Subjekt.TaW
    e.Subjekt.TaW = 0
    ap = skt:kosten(skt.spalte:effektiv(self:sprache_schwierigkeit(e.Subjekt), 0, e.Methode), 0)
    faktor = self:tgruppe_faktor("SprachenUndSchriften")
    self.Talente.SprachenUndSchriften:append(e.Subjekt, e.Sortierung)
    event[1] = "Talentaktivierung ("
  elseif smt.name == "Schrift" then
    ziel_taw = e.Subjekt.TaW
    e.Subjekt.TaW = 0
    ap = skt:kosten(skt.spalte:effektiv(self:schrift_schwierigkeit(e.Subjekt), 0, e.Methode), 0)
    faktor = self:tgruppe_faktor("SprachenUndSchriften")
    self.Talente.SprachenUndSchriften:append(e.Subjekt, e.Sortierung)
    event[1] = "Talentaktivierung ("
  elseif smt.name == "Talent" then
    ziel_taw = e.Subjekt.TaW
    e.Subjekt.TaW = 0
    if e.Talentgruppe == "" then
      tex.error("\n[Aktiviere] für Talent {…} muss eine Talentgruppe angegeben werden.")
    elseif e.Talentgruppe ~= "Gesellschaft" and e.Talentgruppe ~= "Natur" and e.Talentgruppe ~= "Wissen" and e.Talentgruppe ~= "Handwerk" then
      tex.error("\n[Aktiviere] unbekannte Talentgruppe: " .. e.Talentgruppe)
    end
    ap = skt:kosten(skt.spalte:effektiv(self:talent_schwierigkeit(e.Subjekt, e.Talentgruppe), 0, e.Methode), 0)
    faktor = self:tgruppe_faktor(e.Talentgruppe)
    self.Talente[e.Talentgruppe]:append(e.Subjekt, e.Sortierung)
    event[1] = "Talentaktivierung ("
  elseif smt.name == "Zauber" then
    ziel_zfw = e.Subjekt.ZfW
    e.Subjekt.ZfW = 0
    if e.Komplexitaet == "" then
      tex.error("[Aktiviere] " .. e.Name .. ": Zauber muss Komplexität haben!\n")
    elseif e.Repraesentation == "" then
      tex.error("[Aktiviere] " .. e.Name .. ": Zauber muss Repräsentation haben!\n")
    end
    ap = skt:kosten(skt.spalte:effektiv(self:lernschwierigkeit(e.Subjekt), 0, e.Methode), 0)
    faktor = self:tgruppe_faktor("Zauber")
    self.Magie.Zauber:append(e.Subjekt, e.Sortierung)
    event[1] = "Zauberaktivierung ("
  elseif smt.name == "Ritual" then
    ap = e.Subjekt.Lernkosten
    if e.Methode == "SE" then
      ap = math.round(ap / 2)
    end
    faktor = self:tgruppe_faktor("Zauber")
    self.Magie.Rituale:append(e.Subjekt, e.Sortierung)
    event[1] = "Ritual ("
  elseif smt.name == "Liturgie" then
    local existing = nil
    local von_grad = 0
    for _, l in ipairs(self.Mirakel.Liturgien) do
      if getmetatable(l).name == "Liturgie" and l.Name == e.Subjekt.Name then
        existing = l
        for _, g in ipairs(l.Grade) do
          if g > von_grad then
            von_grad = g
          end
        end
        break
      end
    end
    local base = 50
    if e.Methode == "SE" then
      base = 25
    end
    local nach_grad = 0
    for _, g in ipairs(e.Subjekt.Grade) do
      if nach_grad < g then
        nach_grad = g
      end
    end
    ap = base * (nach_grad - von_grad)
    if ap < 0 then
      ap = 0
    end
    if self.Vorteile.EidetischesGedaechtnis then
      faktor = skt.faktor["1/2"]
    elseif self.Vorteile.GutesGedaechtnis then
      faktor = skt.faktor["3/4"]
    end
    if existing == nil then
      self.Mirakel.Liturgien:append(e.Subjekt, e.Sortierung)
    else
      for _, g in ipairs(e.Subjekt.Grade) do
        local found = false
        for _, e in ipairs(existing.Grade) do
          if e == g then
            found = true
            break
          end
        end
        if found == false then
          existing.Grade:append(g)
        end
      end
    end
    event[1] = "Liturgie Grad "
    for i, g in ipairs(e.Subjekt.Grade) do
      if i > 1 then
        event[1] = event[1] .. ", "
      end
      event[1] = event[1] .. tostring(g)
    end
    event[1] = event[1] .. " ("
  end
  event[1] = event[1] .. e.Subjekt.Name .. ", " .. e.Methode .. ")"
  event[2] = -1 * ap
  event[3] = faktor
  local kosten = faktor:apply(ap)
  event[4] = -1 * kosten
  event[5] = self:ap_mod(kosten)
  local insta_steiger = nil
  if ziel_taw > 0 then
    insta_steiger = schema.TaW {e.Subjekt.Name, ziel_taw, e.Methode, getmetatable(e.Subjekt)}
  elseif ziel_zfw > 0 then
    insta_steiger = schema.ZfW {e.Subjekt.Name, ziel_zfw, e.Methode}
  end
  return event, insta_steiger
end

function values:merkmalskenntnis(e)
  local msg = self.Magie.Merkmalskenntnis:merge(e.Merkmale)
  if msg ~= nil then
    tex.error("[Merkmalskenntnis] " .. msg)
  end
  local ap = e.Kosten
  if e.Methode == "SE" then
    ap = ap / 2
  end
  local faktor = skt.faktor["1"]
  if self.Vorteile:getlist("AkademischeAusbildung")[1] == "Magier" or
      self.Vorteile:getlist("AkademischeAusbildung")[1] == "Magierin" then
    faktor = skt.faktor["3/4"]
  end
  local event = {}
  event[1] = "Erlernen von Merkmalskenntnis ("
  for index, merkmal in ipairs(e.Merkmale) do
    if index > 1 then
      event[1] = event[1] .. ", "
    end
    local mt = getmetatable(merkmal)
    if mt.name == "Daemonisch" or mt.name == "Elementar" then
      if mt.name == "Daemonisch" then
        event[1] = event[1] .. "Dämonisch ("
      else
        event[1] = event[1] .. mt.name .. " ("
      end
      for jndex, v in ipairs(merkmal) do
        if jndex > 1 then
          event[1] = event[1] .. ", "
        end
        event[1] = event[1] .. v
      end
    else
      event[1] = event[1] .. merkmal
    end
  end
  event[1] = event[1] .. ") mittels " .. e.Methode
  event[2] = -1 * ap
  event[3] = faktor
  local kosten = faktor:apply(ap)
  event[4] = -1 * kosten
  event[5] = self:ap_mod(kosten)
  return event
end

function values:senkung(e)
  local found = nil
  local found_index = nil
  local event = {"Senkung (" .. e.Name .. ")"}
  for i, eig in ipairs(self.Nachteile.Eigenschaften.value) do
    if eig.Name == e.Name then
      found = eig
      found_index = i
      break
    end
  end
  if found == nil then
    tex.error("\n[Senkung] unbekannte Schlechte Eigenschaft: '" .. e.Name .. "'")
  end
  local ap = math.round((found.Wert - e.Zielwert) * 50 * found.GP)
  if e.Zielwert == 0 then
    event[1] = event[1] .. ": Schlechte Eigenschaft mit Wert " .. found.Wert .. " entfernt"
    table.remove(self.Nachteile.Eigenschaften.value, found_index)
  else
    event[1] = event[1] .. " von " .. found.Wert .. " auf " .. e.Zielwert
    found.Wert = e.Zielwert
  end
  event[1] = event[1] .. " mittels " .. e.Methode
  event[2] = -1 * ap
  event[3] = e.Methode == "Selbststudium" and skt.faktor["3/2"] or skt.faktor["1"]
  local kosten = event[3]:apply(ap)
  event[4] = -1 * kosten
  event[5] = self:ap_mod(kosten)
  return event
end

function values:permanent(e)
  local event = {(e.Anzahl > 0 and "Rückkauf: " or "Verlust: ") .. e.Anzahl .. " " .. e.Subjekt}
  self.eig[e.Subjekt].Permanent = self.eig[e.Subjekt].Permanent - e.Anzahl
  local kosten = 0
  if e.Anzahl > 0 then
    kosten = 50
    local reg = self.SF.Magisch:getlist("Matrixregeneration")
    for i=1,2 do
      if reg[i] then kosten = kosten - 10 end
    end
    kosten = kosten * e.Anzahl
  end
  event[2] = -1 * kosten
  event[3] = skt.faktor["1"]
  event[4] = event[2]
  event[5] = self:ap_mod(kosten)
  return event 
end

function values:grosseMeditation(e)
  local punkte = self.sparse(self.eig[e.Leiteigenschaft].Aktuell, 3) + self.sparse(e["RkP*"], 10)
  self.eig["AE"].Mod = self.eig["AE"].Mod + punkte
  return {"Große Meditation: AE+" .. punkte, -400, skt.faktor["1"], -400, self:ap_mod(400)}
end

local alveranischeGoetter = {
  Praios = true, Rondra = true, Efferd = true, Travia = true,
  Boron = true, Hesinde = true, Firun = true, Tsa = true,
  Phex = true, Peraine = true, Ingerimm = true, Rahja = true  
}

function values:karmalqueste(e)
  local div = alveranischeGoetter[self.Mirakel.Liturgiekenntnis.Name] and 4 or 5
  local punkte = self.sparse(self.eig["IN"].Aktuell, div) + self.sparse(e["LkP*"], 10)
  self.eig["KE"].Mod = self.eig["KE"].Mod + punkte
  local kosten = alveranischeGoetter[self.Mirakel.Liturgiekenntnis.Name] and 300 or 250
  return {"Karmalqueste: KE+" .. punkte, -1 * kosten, skt.faktor["1"], -1 * kosten, self:ap_mod(kosten)}
end

function values:spaetweihe(e)
  self.Mirakel.Liturgiekenntnis.Name = e.Gottheit
  self.Mirakel.Liturgiekenntnis.Wert = 3
  for _, n in ipairs({"Plus", "Minus", "Liturgien"}) do
    for _, v in ipairs(e[n]) do
      self.Mirakel[n]:append(v)
    end
  end
  self.eig.KE.Mod = alveranischeGoetter[e.Gottheit] and 24 or 12
    
  return {"Spätweihe (" .. e.Gottheit .. ")", -1 * e.Kosten, skt.faktor["1"], -1 * e.Kosten, self:ap_mod(e.Kosten)}
end

function values:zugewinn(e)
  local event = {e.Text, e.AP, skt.faktor["1"], e.AP}
  if type(self.AP.Gesamt) == "number" then
    self.AP.Gesamt = self.AP.Gesamt + e.AP
  end
  event[5] = self:cur("AP")
  event[6] = e.Fett
  return event
end

function values:frei(e)
  local event = {e.Text, -1 * e.Kosten, skt.faktor["1"], -1 * e.Kosten}
  local f = function() tex.error(e.Text .. ": Funktion brauchte zu lange zum Verarbeiten!") end
  debug.sethook(f, "", 1e6)
  e.Modifikation(self)
  debug.sethook()
  event[5] = self:cur("AP")
  return event
end

for _, e in ipairs(schema.Ereignisse:instance()) do
  local mt = getmetatable(e)
  local event
  if mt.name == "TaW" then
    event = values:talentsteigerung(e)
  elseif mt.name == "ZfW" then
    event = values:zaubersteigerung(e)
  elseif mt.name == "Spezialisierung" then
    event = values:spezialisierung(e)
  elseif mt.name == "ProfaneSF" then
    local verbilligt = {"Dschungelkundig", "Eiskundig", "Gebirgskundig", "Höhlenkundig", "Maraskankundig", "Meereskundig", "Steppenkundig", "Sumpfkundig", "Waldkundig, Wüstenkundig", "Kulturkunde", "Nandusgefälliges Wissen", "Ortskenntnis"}
    event = values:steigerSF("ProfaneSF", e, {{"EidetischesGedächtnis", "1/2", verbilligt}, {"GutesGedaechtnis", "3/4", verbilligt}},
      values.SF.Allgemein)
  elseif mt.name == "NahkampfSF" then
    event = values:steigerSF("NahkampfSF", e, {{{"AkademischeAusbildung", "Krieger", "Kriegerin"}, "3/4"}, {{"AkademischeAusbildung", "Magier", "Magierin"}, "3/2", {"Ruestungsgewoehnung"}}}, values.SF.Nahkampf)
  elseif mt.name == "FernkampfSF" then
    event = values:steigerSF("FernkampfSF", e, {{{"AkademischeAusbildung", "Krieger", "Kriegerin"}, "3/4"}}, values.SF.Fernkampf)
  elseif mt.name == "WaffenlosSF" then
    event = values:steigerSF("WaffenlosSF", e, {{{"AkademischeAusbildung", "Krieger", "Kriegerin"}, "3/4"}}, values.SF.Waffenlos)
  elseif mt.name == "MagischeSF" then
    event = values:steigerSF("MagischeSF", e, {{{"AkademischeAusbildung", "Magier", "Magierin"}, "3/4"}}, values.SF.Magisch)
  elseif mt.name == "Eigenschaft" then
    event = values:eig_steigerung(e)
  elseif mt.name == "RkW" then
    event = values:rkw_steigerung(e)
  elseif mt.name == "LkW" then
    event = values:lkw_steigerung(e)
  elseif mt.name == "Aktiviere" then
    event, insta_steiger = values:aktiviere(e)
    if insta_steiger ~= nil then
      table.insert(values.Ereignisse, event)
      local imt = getmetatable(insta_steiger)
      if imt.name == "TaW" then
        event = values:talentsteigerung(insta_steiger)
      elseif imt.name == "ZfW" then
        event = values:zaubersteigerung(insta_steiger)
      else
        tex.error("illegal insta_steiger: " .. imt.name)
      end
    end
  elseif mt.name == "Senkung" then
    event = values:senkung(e)
  elseif mt.name == "Permanent" then
    event = values:permanent(e)
  elseif mt.name == "GrosseMeditation" then
    event = values:grosseMeditation(e)
  elseif mt.name == "Karmalqueste" then
    event = values:karmalqueste(e)
  elseif mt.name == "Spaetweihe" then
    event = values:spaetweihe(e)
  elseif mt.name == "MerkmalSF" then
    event = values:merkmalskenntnis(e)
  elseif mt.name == "Zugewinn" then
    event = values:zugewinn(e)
  elseif mt.name == "Frei" then
    event = values:frei(e)
  else
    tex.error("\n[Ereignisse] unbekannter Ereignistyp: '" .. mt.name .. "'")
  end
  table.insert(values.Ereignisse, event)
end

return values
