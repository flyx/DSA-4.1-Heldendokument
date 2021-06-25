local my_source = debug.getinfo(1).source
local string_metatable = getmetatable("")

local d = {
  context = {},
  Poison = {
    name = "Poison",
    count = 0
  },
  schema = {}
}
setmetatable(d.Poison, d.Poison)

function d.context:push(name)
  table.insert(self, name)
end

function d.context:pop()
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
      io.stderr:write(string.format("\n%s(%d)\n", info.short_src, info.currentline))
      i = i + 1
      info = debug.getinfo(i)
    until info == nil
    io.stderr:write("error:")
  else
    io.stderr:write(string.format("\n%s(%d):", info.short_src, info.currentline))
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
  d.Poison.count = d.Poison.count + 1
  return d.Poison
end

local function geterr(self, key)
  if key == "err" then
    return err
  end
  return nil
end

local Type = {
  __call = function(self, name, ...)
    return self:def(name, ...)
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
        d.schema[name] = ret
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

d.MixedList = Type("table",
  function(...)
    return {...}
  end,
  function(self, value)
    local errors = false
    for i,v in ipairs(value) do
      local mt = getmetatable(v)
      d.context:push(" [" .. tostring(i) .. "]")
      if mt == nil or mt == string_metatable then
        if #self == 1 then
          v = self[1](v)
          mt = getmetatable(v)
          value[i] = v
        else
          local e = "("
          for i,t in ipairs(self) do
            if j > 1 then
              e = e .. ","
            end
            e = e .. t.name
          end
          self:err("enthält table ohne Typ. Erlaubt sind: %s", e)
          errors = true
        end
      end
      if mt ~= nil and mt ~= string_metatable and mt ~= Poison then
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
      d.context:pop()
    end
    return errors and Poison or value
  end
)

d.Record = Type("table",
  function(defs)
    return {defs = defs}
  end,
  function(self, value)
    local errors = false
    for k,v in pairs(value) do
      local mt = getmetatable(v)
      local expected = self.defs[k]
      d.context:push(self.name .. "->" .. k)
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
      d.context:pop()
    end
    for k,v in pairs(self.defs) do
      if value[k] == nil then
        value[k] = v[1](v[2])
      end
    end
    return errors and Poison or value
  end
)

d.ListWithKnown = Type("table",
  function(known)
    return {known = known}
  end,
  function(self, value)
    local ret = {}
    for _,v in ipairs(value) do
      if type(v) ~= "string" then
        local mt = getmetatable(v)
        if mt == nil then
          return self:err("string in Liste erwartet, bekam %s", type(v))
        else
          local def = self.known[mt.name]
          if type(def) == "string" then
            return self:err("string in Liste erwartet, bekam %s", type(v))
          elseif def ~= mt then
            return self:err("%s erwartet, bekam %s", def.name, mt.name)
          else
            ret[mt.name] = v
          end
        end
      else
        local name = self.known[v]
        if name ~= nil then
          if type(name) == "string" then
            ret[name] = true
          else
            return self:err("der Wert %s muss mit einem Konstructor `%s {…}` angegeben werden.", v, v)
          end
        else
          table.insert(ret, v)
        end
      end
    end
    for k,v in pairs(self.known) do
      if type(v) == "string" then
        if ret[v] == nil then
          ret[v] = false
        end
      elseif ret[k] == nil then
        ret[k] = v {}
      end
    end
    return ret
  end
)

d.FixedList = Type("table",
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
        d.context:push(self.name .. "[" .. tostring(i) .. "]")
        if mt == nil or mt == string_metatable then
          v = self.inner(v)
          mt = getmetatable(v)
          value[i] = v
        end
        if mt ~= Poison and mt ~= self.inner then
          self:err("falscher Typ: erwartete %s, bekam %s", self.inner.name, mt.name)
          errors = true
        end
        d.context:pop()
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

d.HeterogeneousList = Type("table",
  function(...)
    return {...}
  end,
  function(self, value)
    while #value < #self do
      local def = self[#value + 1]
      if def[3] == nil then
        return self:err("Wert #%d (%s) fehlt", #value + 1, def[1])
      end
      table.insert(value, def[2](def[3]))
    end
    if #value > #self then
      return self:err("zu viele Werte, %d erwartet, bekam %d", #self, #value)
    end
    local errors = false
    for i,v in ipairs(value) do
      local def = self[i]
      local mt = getmetatable(v)
      d.context:push(self.name .. "[" .. tostring(i) .. " (" .. def[1] ..")]")
      if mt == nil or mt == string_metatable then
        v = def[2](v)
        mt = getmetatable(v)
        value[i] = v
      end
      if mt ~= Poison and mt ~= def[2] then
        self:err("falscher Typ: erwartete %s, bekam %s", def[2].name, mt.name)
        errors = true
      end
      d.context:pop()
    end
    return errors and Poison or value
  end
)

d.Numbered = Type("table",
  function(max)
    return {max=max}
  end,
  function(self, value)
    local ret = {}
    for i=1,self.max do
      table.insert(ret, false)
    end
    local errors = false
    for i, v in ipairs(value) do
      d.context:push(self.name .. "[" .. tostring(i) .. "]")
      if type(v) ~= "number" then
        self:err("falscher Typ: erwartete number, bekam %s", type(v))
        errors = true
      elseif v < 1 or v > self.max then
        self:err("Wert %d außerhalb des erlaubten Bereichs 1..%d", v, self.max)
        errors = true
      else
        ret[i] = true
      end
      d.context:pop()
    end
    return errors and Poison or ret
  end
)

d.MapToFixed = Type("table",
  function(...)
    return {...}
  end,
  function(self, value)
    local errors = false
    for k,v in pairs(value) do
      d.context:push(self.name .. "->" .. k)
      local found = false
      for _,e in ipairs(self) do
        if v == e then
          found = true
          break
        end
      end
      if not found then
        local l = "('"
        for i,e in ipairs(self) do
          if i > i then
            l = l .. "','"
          end
          l = l .. e
        end
        self:err("Unbekannter Wert '%s', erwartete %s')", v, l)
        errors = true
      end
      d.context:pop()
    end
    return errors and Poison or value
  end
)

d.Number = Type("number",
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

d.String = Type("string",
  function()
    return {__call = function(self) return self[1] end}
  end,
  function(self, value)
    return {value}
  end
)

d.Matching = Type("string",
  function(...)
    local ret = {patterns = {}, __call = function(self) return self[1] end}
    for _, p in ipairs({...}) do
      table.insert(ret.patterns, "^" .. p .. "$")
    end
    return ret
  end,
  function(self, value)
    if value == "" then
      return {value}
    end
    for _, p in ipairs(self.patterns) do
      local pos, _ = string.find(value, p)
      if pos ~= nil then
        return {value}
      end
    end
    local l = "('"
    for i, p in ipairs(self.patterns) do
      if i > 1 then
        l = l .. "', '"
      end
      l = l .. string.sub(p, 2, string.len(p) - 1)
    end
    l = l .. "')"
    return self:err("Inhalt '%s' illegal, erwartet: %s", value, l)
  end
)

d.Simple = Type(nil,
  function()
    return {__call = function(self) return self[1] end}
  end,
  function(self, value)
    if type(value) ~= "string" and type(value) ~= "number" then
      return self:err("string oder number als Argument erwartet, bekam %s", base, type(value))
    end
    return {value}
  end
)

d.Multiline = Type(nil,
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
)

d.Boolean = Type("bool",
  function()
    return {__call = function(self) return self[1] end}
  end,
  function(self, value)
    return {value}
  end
)

d.Void = Type("table",
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

function d.singleton(TypeClass, name, ...)
  local type = TypeClass(name, ...)
  type.singleton = true
  type.default = {}
  return function(default)
    type.default = default
    return type
  end
end

setmetatable(d, {
  __call = function(self)
    self.schema.String = self.String("String")
    self.schema.Simple = self.Simple("Simple")
    self.schema.Multiline = self.Multiline("Multiline")
    return self.schema
  end
})

return d