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
        if type(value) ~= base then
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
local Front = Record("Front", {Aussehen = {Zeilen, 3} })
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

return schema