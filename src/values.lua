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
  sf = {
    Allgemein = schema.SF:instance(),
    Nahkampf = schema.SF.Nahkampf:instance(),
    Fernkampf = schema.SF.Fernkampf:instance(),
    Waffenlos = schema.SF.Waffenlos:instance(),
    Magisch = schema.SF.Magisch:instance(),
  },
  Waffen = {
    N = schema.Waffen.Nahkampf:instance(),
    F = schema.Waffen.Fernkampf:instance(),
    S = schema.Waffen.Schilde:instance(),
    R = schema.Waffen.Ruestung:instance(),
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

values.Vorteile.magisch = schema.Vorteile.magisch:instance()
values.Vorteile.magisch.asp = #values.Vorteile.magisch > 0
values.Nachteile.magisch = schema.Nachteile.magisch:instance()
for k,v in pairs(schema.Talente) do
  values.Talente[k] = v:instance()
end
for k,v in pairs(schema.Magie) do
  values.Magie[k] = v:instance()
end
values.Vermoegen.Sonstiges = schema.Vermoegen.Sonstiges:instance()

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
      if data.Vorteile.magisch.asp then
        if data.sf.Magisch.GefaessDerSterne then
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
        x = data.eig.KE[1]()
      else
        x = data.eig[v][3]()
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
      val = val + data.eig["INI"]()
      if data.sf.kampfreflexe then
        val = val + 4
      end
      if data.sf.kampfgespuer then
        val = val + 2
      end
    else
      local others = data.eig[name]
      if others then
        -- Modifikator, Zugekauft, Permanent
        val = val + others[1]() + others[2]() - others[3]()
      end
    end
    return getter_map.sparse(val)
  end
})

function values:cur(name, div)
  div = div or 1
  local kind = getter_map[name]
  if kind == "basic" then
    return getter_map.sparse(self.eig[name][3](), div)
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
        gsmod = gsmod + self.Vorteile.Flink()
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
    return sum_and_round(self.Waffen.R, 2)
  elseif kind == "be" or kind == "be_voll" then
    local val = sum_and_round(self.Waffen.R, 3)
    if val == "" then
      return val
    end
    if kind == "be" then
      if self.sf.Nahkampf.Ruestungsgewoehnung[3] then
        val = val - 2
      elseif self.sf.Nahkampf.Ruestungsgewoehnung[1] then
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
    min = math.min(min, repr_malus_between(repr, v()))
  end
  return min
end

function values:lernschwierigkeit(zaubername, komp, merkmale, repr, haus)
  if math.min(string.len(komp), string.len(repr)) == 0 then
    return ""
  end
  index = skt.spalte:num(komp)
  for i, merkmal in ipairs(merkmale) do
    index = index + merkmal_mod_from(merkmal, self.Magie.Merkmalskenntnis, -1)
    index = index + merkmal_mod_from(merkmal, self.Magie.Begabungen.Merkmale, -1)
    index = index + merkmal_mod_from(merkmal, self.Magie.Unfaehigkeiten, 1)
  end
  for _, name in ipairs({"Elementar", "Daemonisch"}) do
    index = index + merkmal_submod_from(name, merkmale[name], self.Magie.Merkmalskenntnis[name], -1)
    index = index + merkmal_submod_from(name, merkmale[name], self.Magie.Begabungen[name], -1)
    index = index + merkmal_submod_from(name, merkmale[name], self.Magie.Unfaehigkeiten[name], 1)
  end
  for _, name in ipairs(self.Magie.Begabungen.Zauber) do
    if name == zaubername then
      index = index - 1
      break
    end
  end
  index = index + (haus and -1 or 0)
  index = index + repr_malus(repr, data.Magie.Repraesentationen)
  return skt.spalte:name(index)
end

function values:tgruppe_schwierigkeit(gruppe)
  if gruppe == "Gaben" then
    return "F"
  elseif gruppe == "Koerper" then
    return "D"
  else
    return "B"
  end
end

-- Ereignisse auf Charakter applizieren

for _, e in ipairs(schema.Ereignisse:instance()) do
  local mt = getmetatable(e)
  local event = {""}
  if mt.name == "SteigerTalent" then
    event[1] = "Talentsteigerung (" .. e.Name .. ") von "
    for _, g in ipairs({"Gaben", "Kampf", "Koerper", "Gesellschaft", "Natur", "Wissen", "Sprachen", "Handwerk"}) do
      for _, t in ipairs(values.Talente[g]) do
        if t.Name == e.Name then
          if type(t.TaW) ~= "number" then
            tex.error("\n[SteigerTalent] Kann '" .. e.Name .. "' nicht steigern: hat keinen Zahlenwert, sondern " .. type(t.TaW))
          end
          event[1] = event[1] .. tonumber(t.TaW) .. " auf " .. tonumber(e.Zielwert)
          local spalte
          if g == "Kampf" then
            spalte = t.Steigerungsspalte
          elseif g == "Sprachen" then
            -- TODO
            spalte = "B"
          else
            spalte = values:tgruppe_schwierigkeit(g)
          end
          local ap = 0
          while t.TaW < e.Zielwert do
            t.TaW = t.TaW + 1
            ap = ap + skt:kosten(spalte, t.TaW)
          end
          if type(values.AP.Eingesetzt()) == "number" then
            values.AP.Eingesetzt[1] = values.AP.Eingesetzt() + ap
          end
          if type(values.AP.Guthaben()) == "number" then
            values.AP.Guthaben[1] = values.AP.Guthaben() - ap
            event[4] = values.AP.Guthaben()
          else
            event[4] = ""
          end
          event[2] = -1 * ap
          event[3] = ""
          goto found
        end
      end
    end
    tex.error("\n[SteigerTalent] unbekanntes Talent: '" .. e.Name .. "'")
    ::found::
  else
    tex.error("\n[Ereignisse] unbekannter Ereignistyp: '" .. mt.name .. "'")
  end
  table.insert(values.Ereignisse, event)
end

return values