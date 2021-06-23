local my_source = debug.getinfo(1).source
local string_metatable = getmetatable("")

local Poison = {
  name = "Poison",
  count = 0
}
setmetatable(Poison, Poison)

local schema = {}

local context = {}

function context:push(name)
  table.insert(self, name)
end

function context:pop()
  table.remove(self)
end

local function err(v, msg, ...)
  local i = 1
  local info
  repeat
    i = i + 1
    info = debug.getinfo(i)
  until info == nil or info.source ~= my_source
  if info == nil then
    i = 2
    info = debug.getinfo(i)
    repeat
      io.stderr:write(string.format("%s(%d)\n", info.short_src, info.currentline))
      i = i + 1
      info = debug.getinfo(i)
    until info == nil
    io.stderr:write("error:")
  else
    io.stderr:write(string.format("%s(%d):", info.short_src, info.currentline))
  end
  for i,b in ipairs(context) do
    if i == 1 then
      io.stderr:write(" ")
    else
      io.stderr:write("->")
    end
    io.stderr:write(b)
  end
  io.stderr:write(string.format(" [%s] " .. msg .. "\n", v.name, ...))
  Poison.count = Poison.count + 1
  return Poison
end

local function geterr(self, key)
  if key == "err" then
    return err
  end
  return nil
end

local Type = {
  __call = function(self, ...)
    return self:def(...)
  end
}

local MetaType = {
  __call = function(self, base, def, construct)
    local ret = {
      def = function(self, name, ...)
        local ret = def(...)
        ret.name = name
        ret.instance = function(self)
          --  only used on singleton types
          if self.value == nil then
            return self(self.default)
          else
            return self.value
          end
        end
        setmetatable(ret, self)
        schema[name] = ret
        return ret
      end,
      __call = function(self, value)
        if base ~= nil and type(value) ~= base then
          return self:err("%s als Argument erwartet, bekam %s", base, type(value))
        end
        local ret = construct(self, value)
        if ret ~= Poison then
          setmetatable(ret, self)
          if self.singleton then
            if self.value ~= nil then
              self:err("doppelt: wurde bereits in Zeile %d gegeben", self.valueline)
            else
              self.value = ret
              local i = 1
              local info
              repeat
                i = i + 1
                info = debug.getinfo(i)
              until info == nil or info.source ~= my_source
              self.valueline = info.currentline
            end
          end
        end
        return ret
      end,
      __index = geterr
    }
    setmetatable(ret, Type)
    return ret
  end
}

setmetatable(Type, MetaType)

local MixedList = Type("table",
  function(...)
    return {...}
  end,
  function(self, value)
    local errors = false
    for _,v in ipairs(value) do
      local mt = getmetatable(v)
      if mt ~= Poison then
        local found = false
        for _,t in ipairs(self) do
          if mt == t then
            found = true
            break
          end
        end
        if not found then
          local e = "("
          for i,t in ipairs(self) do
            if i > 1 then
              e = e .. ","
            end
            e = e .. t.name
          end
          self:err("enthält unerwarteten Inhalt: %s. Erlaubt sind: %s)", mt.name, e)
          errors = true
        end
      end
    end
    return errors and Poison or value
  end
)

local Record = Type("table",
  function(defs)
    return {defs = defs}
  end,
  function(self, value)
    local errors = false
    for k,v in pairs(value) do
      local mt = getmetatable(v)
      local expected = self.defs[k]
      context:push(self.name .. "->" .. k)
      if expected == nil then
        self:err("unbekannter Wert")
        errors = true
      else
        if mt == nil or mt == string_metatable then
          v = expected[1](v)
          mt = getmetatable(v)
          value[k] = v
        end
        if mt ~= Poison and mt ~= expected[1] then
          self:err("falscher Typ: erwartete %s, bekam %s", expected[1].name, mt.name)
          errors = true
        end
      end
      context:pop()
    end
    for k,v in pairs(self.defs) do
      if value[k] == nil then
        value[k] = v[1](v[2])
      end
    end
    return errors and Poison or value
  end
)

local ListWithKnown = Type("table",
  function(known)
    return known
  end,
  function(self, value)
    local ret = {}
    for _,v in ipairs(value) do
      if type(v) ~= "string" then
        return self:err("string in Liste erwartet, bekam %s", type(v))
      end
      local name = self[v]
      if name ~= nil then
        ret[name] = true
      else
        table.insert(ret, v)
      end
    end
    for k,v in pairs(self) do
      if ret[v] == nil then
        ret[v] = false
      end
    end
    return ret
  end
)

local FixedList = Type("table",
  function(inner, length)
    return {inner = inner, length = length}
  end,
  function(self, value)
    for i=1,self.length do
      if #value == i - 1 then
        self:err("zu wenige Werte, %d erwartet, bekam %d", self.length, #v)
        errors = true
      elseif i <= #value then
        local v = value[i]
        local mt = getmetatable(v)
        context:push(self.name .. "[" .. tostring(i) .. "]")
        if mt == nil or mt == string_metatable then
          v = self.inner(v)
          mt = getmetatable(v)
          value[i] = v
        end
        if mt ~= Poison and mt ~= self.inner then
          self:err("falscher Typ: erwartete %s, bekam %s", self.inner.name, mt.name)
          errors = true
        end
        context:pop()
      end
    end
    if #value > self.length then
      self:err("zu viele Werte, %d erwartet, bekam %d", self.length, #v)
      errors = true
    end
    for k,_ in pairs(value) do
      if type(k) == "string" then
        self:err("unbekannter Wert: %s", k)
        errors = true
      end
    end
    return errors and Poison or value
  end
)

local Number = Type("number",
  function(min, max)
    return {min = min, max = max, __call = function(self) return self[1] end}
  end,
  function(self, value)
    if value < self.min or value > self.max then
      return self:err("Zahl %d außerhalb des erwarteten Bereichs %d..%s", value, self.min, self.max)
    end
    return {value}
  end
)

local String = Type("string",
  function()
    return {__call = function(self) return self[1] end}
  end,
  function(self, value)
    return {value}
  end
)

local Simple = Type(nil,
  function()
    return {__call = function(self) return self[1] end}
  end,
  function(self, value)
    if type(value) ~= "string" and type(value) ~= "number" then
      return self:err("string oder number als Argument erwartet, bekam %s", base, type(value))
    end
    return {value}
  end
)("Simple")

local Multiline = Type(nil,
  function()
    return {}
  end,
  function(self, value)
    if type(value) == "string" then
      return {value}
    elseif type(value) == "table" then
      for k,v in pairs(value) do
        if type(k) ~= "number" then
          return self:err("unbekannter Wert in table: %s", k)
        end
        if type(v) == "table" then
          for l,w in pairs(v) do
            return self:err("string oder {} in Liste erwartet, bekam nicht-leere table")
          end
        elseif type(v) ~= "string" then
          return self:err("string oder {} in Liste erwartet, bekam %s", type(v))
        end
      end
      return value
    else
      return self:err("string oder table als Argument erwartet, bekam %s", type(value))
    end
  end
)("Multiline")

local Boolean = Type("bool",
  function()
    return {__call = function(self) return self[1] end}
  end,
  function(self, value)
    return {value}
  end
)

local Void = Type("table",
  function()
    return {}
  end,
  function(self, value)
    for k,v in pairs(value) do
      return self:err("Tabelle muss leer sein, enthält Wert [%s]", k)
    end
    return value
  end
)

local Zeilen = Number("Zeilen", 0, 100)

local Front = Record("Front", {
  Aussehen = {Zeilen, 3},
  Vorteile = {Zeilen, 7},
  Nachteile = {Zeilen, 7},
})
local Talentliste = MixedList("Talentliste",
  Number("Sonderfertigkeiten", 0, 100),
  Number("Gaben", 0, 100),
  Number("Begabungen", 0, 100),
  Number("Kampf", 0, 100),
  Number("Koerper", 0, 100),
  Number("Gesellschaft", 0, 100),
  Number("Natur", 0, 100),
  Number("Wissen", 0, 100),
  Number("Sprachen", 0, 100),
  Number("Handwerk", 0, 100)
)

local WaffenUndSF = Record("WaffenUndSF", {
  Waffen = {Zeilen, 5},

})

local Kampfbogen = Record("Kampfbogen", {
  Nahkampf = {Record("NahkampfWaffenUndSF", {
    Waffen = {Zeilen, 5},
    SF = {Zeilen, 3},
  }), {}},
  Fernkampf = {Record("FernkampfWaffenUndSF", {
    Waffen = {Zeilen, 3},
    SF = {Zeilen, 3},
  }), {}},
  Waffenlos = {Record("Waffenlos", {
    SF = {Zeilen, 3},
  }), {}},
  Schilde = {Zeilen, 2},
  Ruestung = {Zeilen, 6},
})

local Ausruestungsbogen = Record("Ausruestungsbogen", {
  Kleidung = {Zeilen, 5},
  Gegenstaende = {Zeilen, 29},
  Proviant = {Zeilen, 8},
  Vermoegen = {Record("Vermoegen", {
    Muenzen = {Zeilen, 4},
    Sonstiges = {Zeilen, 5}
  }), {}},
  Verbindungen = {Zeilen, 6},
  Notizen = {Zeilen, 7},
  Tiere = {Zeilen, 4},
})

local Liturgiebogen = Record("Liturgiebogen", {
  Kleidung = {Zeilen, 5},
  Gegenstaende = {Zeilen, 29},
  ProviantVermoegen = {Record("ProviantVermoegen", {
    Gezaehlt = {Zeilen, 4},
    Sonstiges = {Zeilen, 5},
  }), {}},
  VerbindungenNotizen = {Zeilen, 8},
  Tiere = {Zeilen, 4},
})

local Zauberdokument = Record("Zauberdokument", {
  Rituale = {Zeilen, 30},
  Ritualkenntnis = {Zeilen, 2},
  Artefakte = {Zeilen, 9},
  Notizen = {Zeilen, 6},
})

local Zauberliste = Void("Zauberliste")

MixedList("Layout",
  Front, Talentliste, Kampfbogen, Ausruestungsbogen, Liturgiebogen,
  Zauberdokument, Zauberliste
)

schema.Layout.singleton = true
schema.Layout.default = {
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

Record("Held", {
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
schema.Held.singleton = true
schema.Held.default = {}

ListWithKnown("Vorteile", {
  Flink = "Flink", Eisern = "Eisern"
})
schema.Vorteile.singleton = true
schema.Vorteile.default = {}

ListWithKnown("Vorteile.magisch", {
  -- TODO: Astrale Regeneration
})
schema["Vorteile.magisch"].singleton = true
schema["Vorteile.magisch"].default = {}
schema.Vorteile.magisch = schema["Vorteile.magisch"]

ListWithKnown("Nachteile", {
  Glasknochen = "Glasknochen",
  ["Behäbig"] = "Behaebig",
  ["Kleinwüchsig"] = "Kleinwuechsig",
  Zwergenwuchs = "Zwergenwuchs"
})
schema.Nachteile.singleton = true
schema.Nachteile.default = {}

ListWithKnown("Nachteile.magisch", {
  -- TODO: Schwache Ausstrahlung
})
schema["Nachteile.magisch"].singleton = true
schema["Nachteile.magisch"].default = {}
schema.Nachteile.magisch = schema["Nachteile.magisch"]

-- TODO: nicht-Ganzzahlen erkennen
local Ganzzahl = Number("Ganzzahl", -1000, 1000)

local BasisEig = FixedList("BasisEig", Ganzzahl, 3)
local AbgeleiteteEig = FixedList("AbgeleiteteEig", Ganzzahl, 3)

Record("Eigenschaften", {
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
schema.Eigenschaften.singleton = true
schema.Eigenschaften.default = {}

return schema