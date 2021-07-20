local my_source = debug.getinfo(1).source
local string_metatable = getmetatable("")

local d = {
  context = {},
  Poison = {
    name = "Poison",
    count = 0,
  },
  schema = {}
}
d.Poison.__metatable = d.Poison
setmetatable(d.Poison, d.Poison)

function d.context:push(name)
  table.insert(self, name)
end

function d.context:pop()
  table.remove(self)
end

local doc_printer = {
  levels = {},
  refs = {},
  known = {},
}

function doc_printer:id(name)
  io.write([[<span class="id">]])
  io.write(name)
  io.write([[</span>]])
end

function doc_printer:sym(s)
  io.write([[<span class="sym">]])
  io.write(s)
  io.write([[</span>]])
end

function doc_printer:ph(name)
  io.write([[<span class="metasym">&lt;]])
  io.write(name)
  io.write([[&gt;</span>]])
end

function doc_printer:ref(target, name)
  if self.known[target] == nil then
    local found = false
    for _,v in ipairs(self.refs) do
      if v == target then
        found = true
        break
      end
    end
    if not found then
      table.insert(self.refs, target)
    end
  end
  if name ~= nil then
    self:meta("&lt;" .. name .. ":")
  end
  if target ~= nil then
    io.write([[<a href="#]] .. target.name .. [[">]])
  end
  if name == nil then
    io.write([["&lt;]])
  end
  if target == nil then
    io.write("Any")
  else
    io.write(target.name)
  end
  if name == nil then
    io.write("&gt;")
  end
  if target ~= nil then
    io.write("</a>")
  end
  if name ~= nil then
    self:meta("&gt;")
  end
end

function doc_printer:meta(s)
  io.write([[<span class="metasym">]] .. s .. [[</span>]])
end

function doc_printer:choice(...)
  self:meta("[ ")
  for i, v in ipairs({...}) do
    if i > 1 then
      self:meta(" | ")
    end
    self:id(v)
  end
  self:meta(" ]")
end

function doc_printer:num(n)
  io.write([[<span class="num">]] .. tostring(n) .. [[</span>]])
end

function doc_printer:nl()
  io.write("\n")
  io.write(string.rep("  ", #self.levels))
end

function doc_printer:open(name)
  table.insert(self.levels, {named = (name ~= nil)})
  if name ~= nil then
    self:id(name)
    io.write(" ")
    self:sym("{")
    self:nl()
  else
    self:sym("{")
  end
end

function doc_printer:close()
  local lvl = table.remove(self.levels)
  if lvl.named then
    self:nl()
  end
  self:sym("}")
end

function doc_printer:h(depth, id, label)
  io.write("<h" .. tostring(depth + 2) .. ">")
  io.write(label)
  io.write("</h" .. tostring(depth + 2) .. ">")
end

function doc_printer:p(content)
  io.write("<p>")
  io.write(content)
  io.write("</p>")
end

local TypeClass = {}

function TypeClass:__index(key)
  local v = rawget(self, key)
  if v ~= nil then
    return v
  end
  return TypeClass[key]
end

function TypeClass:value_len(key)
  return #self.value
end

--  TypeClass ist the root of the schemadef's type system. The schemadef defines
--  a set of TypeClass instances, e.g. `HeterogeneousList`, `Matching`.
--  A schema then defines a set of types, each based on one of the type classes,
--  which define the structures a schema instance can contain.
--
--  o must be a table. It will become the definition of the type class. It must
--  contain the following fields:
--
--    input_kind: string
--        defines what kind of value any type of this class may receive when
--        creating an object: "scalar" means exactly one single value,
--        "named" means a table with string-typed keys,
--        "unnamed" means a table with numeric keys.
--
--  The following functions are to be defined on every type class:
--
--    print_syntax: function(self, printer, named)
--        will be called on types to render a schema's documentation.
--
--    init: function(self, ...)
--        called when defining a new type of this class. Receives arguments
--        that were supplied for <type class>:def() after o.
--
--  The following functions are to be defined on a type class based on the
--  value of input_kind:
--
--    set: function(value)
--        to be defined iff input_kind == "scalar". Sets the value of an
--        instance. Must return nil on success, an error string on failure.
--
--    append: function(value)
--        to be defined iff input_kind == "unnamed". Appends the value to the
--        existing values. Must return nil on success, an error string on
--        failure.
--
--    put: function(key, value)
--        to be defined iff input_kind == "named". Sets the item identified by
--        the given key to the given value. Must return nil on success, an error
--        string on failure.
--
--    pre_construct, post_construct: function()
--        optional. If defined, gets called on an instance before/after the
--        constructor call processes the given value(s).
function TypeClass.new(o)
  setmetatable(o, TypeClass)
  if o.input_kind ~= "scalar" and o.input_kind ~= "named" and
      o.input_kind ~= "unnamed" then
    return o:err("invalid input_kind: '" .. tostring(o.input_kind) .. "'")
  end
  o.__index = o
  o.__call = TypeClass.construct_instance
  return o
end

function TypeClass:err(msg, ...)
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
  for i,b in ipairs(d.context) do
    if i == 1 then
      io.stderr:write(" ")
    else
      io.stderr:write("->")
    end
    io.stderr:write(b)
  end
  io.stderr:write(string.format(" " .. msg .. "\n", ...))
  d.Poison.count = d.Poison.count + 1
  return d.Poison
end

--  Defines a type of the given class from the given table o.
--  o must contain the following values:
--
--    name: string
--      The name of the type. Used for registering the type with the schema.
--
--  o may contain the following values:
--
--    unnamed_to_named: table (list)
--        can optionally be defined when input_kind == "named". If it is, the
--        constructor allows a table with unnamed values and looks up the name
--        of each via this list.
--        if unnamed_to_named[i] is a string, that is the name to be used; if
--        it's a table, the table's first value is used as name instead.
--    min_items, max_items: number
--        can each optionally be defined when input_kind == "unnamed". Defines
--        the minimal and maximal number of items that may be given.
--
--  The following functions are to be defined on every type:
--
--    documentation: function(self, printer)
--      Writes documentation in HTML format for the type.
--      Usually writes one or more paragraphs.
--
--    init: function(self, ...)
function TypeClass:def(o, ...)
  if type(o.name) ~= "string" then
    return self:err("invalid type definition, name is " .. type(o.name))
  end
  setmetatable(o, self)
  o:init(...)
  d.schema[o.name] = o
  if rawget(o, "__index") == nil then
    o.__index = o
  end
  o.__len = TypeClass.value_len
  o.singleton = false
  return o
end

--  Called on types iff they are defined as being singleton.
--  Returns either the value given to the type, or the default value.
function TypeClass:instance()
  -- only used on singleton types
  return rawget(self, "constructed") == nil and self(self.default) or self.constructed
end

function TypeClass:construct_instance(value)
  local ret = {}
  setmetatable(ret, self)

  d.context:push("[" .. self.name .. "]")
  if self.pre_construct ~= nil then
    self.pre_construct(ret)
  end
  if type(value) == "table" and getmetatable(value) == nil then
    if self.input_kind == "scalar" then
      self:err("erwartete einzelnen Wert, bekam table")
    else
      if #value > 0 then
        if self.input_kind == "named" then
          if self.unnamed_to_named == nil then
            self:err("enthält unerwartete benamte Werte")
          else
            for i, v in ipairs(value) do
              d.context:push(" [" .. tostring(i) .. "]")
              if i == #self.unnamed_to_named + 1 then
                self:err("zu viele Werte: erwartete %d, bekam %d", #self.unnamed_to_named, #value)
              elseif i <= #self.unnamed_to_named then
                local item = self.unnamed_to_named[i]
                if type(item) == "table" then
                  item = item[1]
                end
                local msg = ret:put(item, v)
                if msg ~= nil then
                  self:err(msg)
                end
              end
              d.context:pop()
            end
          end
        else
          for i, v in ipairs(value) do
            d.context:push(" [" .. tostring(i) .. "]")
            if self.max_items ~= nil and i == self.max_items + 1 then
              self:err("zu viele Werte: erwartete maximal %d, bekam %d", self.max_items, #value)
            elseif self.max_items == nil or i <= self.max_items then
              local msg = ret:append(v)
              if msg ~= nil then
                self:err(msg)
              end
            end
            d.context:pop()
          end
          if self.min_items ~= nil and #value < self.min_items then
            self:err("zu wenige Werte: erwartete mindestens %d, bekam %d", self.min_items, #value)
          end
        end
      end
      for k, v in pairs(value) do
        if type(k) ~= "number" then
          d.context:push("\"" .. k .. "\"")
          if self.input_kind == "named" then
            local msg = ret:put(k, v)
            if msg ~= nil then
              self:err(msg)
            end
          else
            self:err("unerwarteter benamter Wert")
          end
          d.context:pop()
        end
      end
    end
  else
    local msg
    if self.input_kind == "scalar" then
      msg = ret:set(value)
    elseif self.input_kind == "unnamed" then
      msg = ret:append(value)
    else
      msg = "erwartete table mit benamten Werten, bekam einzelnen Wert '" .. tostring(value) .. "'"
    end

    if msg ~= nil then
      self:err("%s", msg)
    end
    if self.input_kind == "unnamed" and self.min_items ~= nil and self.min_items > 1 then
      self:err("zu wenige Werte: erwartete mindestens %d, bekam 1", self.min_items)
    end
  end
  if self.post_construct ~= nil then
    self.post_construct(ret)
  end
  d.context:pop()
  if self.singleton then
    self.constructed = ret
  end
  return ret
end

--  Generic value getter. Containers of simple values want to override this to
--  return the contained value instead.
function TypeClass:get()
  return self
end

--  Called on a type to generate the HTML documentation
function TypeClass:print_documentation(printer, depth, named)
  printer:h(depth, self.name, self.name)
  io.write("\n\n<pre><code>")
  if self.input_kind == "scalar" then
    if named then
      printer:id(self.name)
      printer:sym("(")
    end
    self:print_syntax(printer)
    if named then printer:sym(")") end
  else
    if named then
      printer:open(self.name)
    else
      printer:open()
    end
    self:print_syntax(printer)
    printer:close()
  end
  io.write("</code></pre>\n\n")
  if type(self.documentation) == "string" then
    printer:p(self.documentation)
  else
    self:documentation(printer)
  end
  io.write("\n\n")
end

d.MixedList = TypeClass.new({
  input_kind = "unnamed"
})

function d.MixedList:init(...)
  self.items = {...}
  if #self.items > 1 and self.item_name == nil then
    self:err("MixedList must have item_name defined if giving more than one type")
  end
  self.__index = d.MixedList.getfield
end

function d.MixedList:pre_construct()
  self.value = {}
end

function d.MixedList:append(v, sort)
  local mt = getmetatable(v)
  if (mt == nil or mt == string_metatable) and #self.items == 1 then
    v = self.items[1](v)
    mt = getmetatable(v)
  end
  if mt == nil or mt == string_metatable then
    local e = "("
    for i,t in ipairs(self.items) do
      if i > 1 then
        e = e .. ","
      end
      e = e .. t.name
    end
    e = e .. ')'
    return string.format("unerlaubter Wert ohne Typ. erlaubt sind: %s", e)
  elseif mt == d.Poison then
    return
  end

  local found = false
  for _,t in ipairs(self.items) do
    if mt == t then
      found = true
      break
    end
  end
  if not found then
    local e = "("
    for i,t in ipairs(self.items) do
      if i > 1 then
        e = e .. ","
      end
      e = e .. t.name
    end
    return string.format("unerwarteter Inhalt: %s. Erlaubt sind: %s)", mt.name, e)
  end
  if sort == nil then sort = {} end
  local index = #self.value
  while index >= 1 do
    local si = 1
    while si <= #sort do
      local cur = self.value[index][sort[si]]
      if cur < v[sort[si]] then
        goto sorted
      elseif cur > v[sort[si]] then
        break
      end
    end
    if si > #sort then
      break
    end
    index = index - 1
  end
  ::sorted::
  table.insert(self.value, index + 1, v)
end

function d.MixedList:getfield(key)
  if type(key) == "number" then
    local v = self.value[key]
    if v ~= nil then
      v = v:get()
    end
    return v
  else
    return getmetatable(self)[key]
  end
end

function d.MixedList:print_syntax(printer)
  if #self.items > 1 then
    printer:meta("&lt;" .. self.item_name .. ': [ ')
    for i,t in ipairs(self.items) do
      if i > 1 then
        printer:meta(" | ")
      end
      printer:ref(t)
    end
    printer:meta(" ]&gt;")
    printer:sym(", ...")
  else
    printer:ref(self.items[1])
    printer:sym(", ...")
  end
end

d.Record = TypeClass.new({
  input_kind = "named"
})

function d.Record:init(...)
  self.defs = {}
  self.order = {}
  for _,f in ipairs({...}) do
    self.defs[f[1]] = {f[2], f[3]}
    table.insert(self.order, f[1])
  end
  self.__index = d.Record.getfield
end

function d.Record:pre_construct()
  self.value = {}
end

function d.Record:put(name, v)
  local mt = getmetatable(v)
  local expected = self.defs[name]
  if expected == nil then
    self:err("unbekannter Wert")
  else
    if mt == nil or mt == string_metatable then
      v = expected[1](v)
      mt = getmetatable(v)
    end
    if mt ~= d.Poison and mt ~= expected[1] then
      self:err("falscher Typ: erwartete %s, bekam %s", expected[1].name, mt.name)
    end
  end
  self.value[name] = v
end

function d.Record:post_construct()
  local value = self.value
  for k,v in pairs(self.defs) do
    if value[k] == nil then
      value[k] = v[1](v[2])
    end
  end
end

function d.Record:getfield(key)
  local v = getmetatable(self)[key]
  if v == nil then
    v = self.value[key]
    if v ~= nil then
      v = v:get()
    end
  end
  return v
end

function d.Record:print_syntax(printer)
  local first = true
  for _,f in pairs(self.order) do
    if first then
      first = false
    else
      printer:sym(",")
      printer:nl()
    end
    printer:id(f)
    printer:sym(" = ")
    printer:ref(self.defs[f][1])
  end
end

d.ListWithKnown = TypeClass.new({
  input_kind = "unnamed"
})

function d.ListWithKnown:init(known, optional)
  self.optional = optional or {}
  self.known = known
  self.__index = d.ListWithKnown.getfield
  self.__pairs = d.ListWithKnown.iterate
end

function d.ListWithKnown:pre_construct()
  self.value = {}
end

function d.ListWithKnown:append(v)
  if type(v) == "string" then
    local name = self.known[v]
    if name ~= nil then
      if type(name) == "string" then
        self.value[name] = true
      elseif name.input_kind == "scalar" then
        return string.format("der Wert %s muss mit einem Konstructor `%s(…)` angegeben werden.", v, v)
      else
        return string.format("der Wert %s muss mit einem Konstructor `%s {…}` angegeben werden.", v, v)
      end
    else
      table.insert(self.value, v)
    end
  else
    local mt = getmetatable(v)
    if mt == nil then
      return string.format("string in Liste erwartet, bekam %s", type(v))
    else
      local def = self.known[mt.name]
      if def == nil then
        return string.format("string in Liste erwartet, bekam %s", mt.name)
      elseif type(def) == "string" then
        return string.format("string in Liste erwartet, bekam %s", type(v))
      elseif def ~= mt then
        return string.format("%s erwartet, bekam %s", def.name, mt.name)
      else
        local cur = self.value[mt.name]
        if cur == nil then
          self.value[mt.name] = v
        elseif cur.merge ~= nil then
          cur:merge(v)
        else
          return string.format("%s: Doppelt, kann nur einmal gegeben werden", mt.name)
        end
      end
    end
  end
end

function d.ListWithKnown:post_construct()
  for k,v in pairs(self.known) do
    if not self.optional[k] then
      if type(v) == "string" then
        if self.value[v] == nil then
          self.value[v] = false
        end
      elseif self.value[k] == nil then
        self.value[k] = v {}
      end
    end
  end
end

function d.ListWithKnown:getfield(key)
  local v = self.value[key]
  if v == nil then
    v = getmetatable(self)[key]
  elseif type(v) == "table" then
    v = v:get()
  end
  return v
end

function d.ListWithKnown:iterate()
  return next, self.value, nil
end

function d.ListWithKnown:print_syntax(printer)
  d.String:print_syntax(printer)
  printer:sym(", ")
  printer:meta("...")
  for k,v in pairs(self.known) do
    if type(v) ~= "string" then
      printer:sym(",")
      printer:nl()
      printer:meta("(optional) ")
      printer:id(v.name .. " ")
      v:print_syntax(printer)
    end
  end
end

d.FixedList = TypeClass.new({
  input_kind = "unnamed"
})

function d.FixedList:init(inner, min, max)
  self.inner = inner
  self.min_items = min
  self.max_items = max
  self.__index = d.FixedList.getfield
end

function d.FixedList:pre_construct()
  self.value = {}
end

function d.FixedList:append(v)
  local mt = getmetatable(v)
  if mt == nil or mt == string_metatable then
    v = self.inner(v)
    mt = getmetatable(v)
  end
  if mt ~= d.Poison and mt ~= self.inner then
    return string.format("falscher Typ: erwartete %s, bekam %s", self.inner.name, mt.name)
  end
  table.insert(self.value, v)
end

function d.FixedList:getfield(key)
  local v = nil
  if type(key) == "number" then
    v = self.value[key]
    if v ~= nil then
      v = v:get()
    end
  else
    v = getmetatable(self)[key]
  end
  return v
end

function d.FixedList:print_syntax(printer)
  if self.max_items ~= nil then
    for i=1,self.max_items do
      if i > 1 then
        printer:sym(", ")
      end
      self.inner:print_syntax(printer)
    end
  else
    self.inner:print_syntax(printer)
    printer:sym(", ")
    printer:meta("...")
  end
end

d.HeterogeneousList = TypeClass.new({
  input_kind = "named"
})

function d.HeterogeneousList:init(...)
  self.fields = {...}
  self.unnamed_to_named = self.fields
  self.__index = d.HeterogeneousList.getfield
  self.__newindex = d.HeterogeneousList.setfield
end

function d.HeterogeneousList:pre_construct()
  rawset(self, "value", {})
end

function d.HeterogeneousList:put(key, v)
  for i,def in ipairs(self.fields) do
    if def[1] == key then
      local mt = getmetatable(v)
      if mt == nil or mt == string_metatable then
        if def[2] ~= nil then
          v = def[2](v)
          mt = getmetatable(v)
        end
      end
      if mt ~= d.Poison and def[2] ~= nil and mt ~= def[2] then
        return string.format("falscher Typ: erwartete %s, bekam %s", def[2].name, mt.name)
      end
      self.value[i] = v
      return
    end
  end
  return "unbekannter Wert"
end

function d.HeterogeneousList:post_construct()
  for i=1,#self.fields do
    if self.value[i] == nil then
      local def = self.fields[i]
      if def[3] == nil then
        self:err("Wert #%d (%s) fehlt", i, def[1])
      else
        self.value[i] = def[2](def[3])
      end
    end
  end
end

-- used as __getindex for the values
function d.HeterogeneousList:getfield(key)
  local mt = getmetatable(self)
  local v = mt[key]
  if v == nil then
    if type(key) == "string" then
      local fields = mt.fields
      if fields ~= nil then
        for i, f in ipairs(fields) do
          if f[1] == key then
            v = self.value[i]
            if f[2] ~= nil then
              v = v:get()
            end
            break
          end
        end
      end
    elseif type(key) == "number" and key <= #self.value then
      v = self.value[key]:get()
    end
  end
  return v
end

function d.HeterogeneousList:setfield(key, value)
  local mt = getmetatable(self)
  local fields = rawget(mt, "fields")
  local svalue = rawget(self, "value")
  if type(key) == "string" then
    for i, f in ipairs(fields) do
      if f[1] == key then
        svalue[i]:set(value)
        return
      end
    end
  elseif type(key) == "number" and key < #svalue then
    svalue[key]:set(value)
    return
  end
  self:err("cannot set key: " .. key)
end

function d.HeterogeneousList:print_syntax(printer)
  for i,v in ipairs(self.fields) do
    if i > 1 then
      printer:sym(", ")
    end
    if v[2] == nil then
      io.write("HL[" .. self.name .. "]:ps(): " .. v[1] .. " is nil!\n")
    end
    printer:ref(v[2], v[1])
  end
end

d.Numbered = TypeClass.new({
  input_kind = "unnamed"
})

function d.Numbered:init(max)
  self.max_items = max
  self.__index = d.Numbered.getfield
end

function d.Numbered:pre_construct()
  self.value = {}
  for i=1,self.max_items do
    table.insert(self.value, false)
  end
end

function d.Numbered:append(v)
  if type(v) ~= "number" then
    return string.format("falscher Typ: erwartete number, bekam %s", type(v))
  elseif v < 1 or v > self.max_items then
    return string.format("Wert %d außerhalb des erlaubten Bereichs 1..%d", v, self.max_items)
  else
    self.value[v] = true
  end
end

function d.Numbered:getfield(key)
  if type(key) == "number" then
    return self.value[key]
  else
    return getmetatable(self)[key]
  end
end

function d.Numbered:merge(v)
  for i=1,self.max_items do
    if v.value[i] then
      self.value[i] = true
    end
  end
end

function d.Numbered:print_syntax(printer)
  printer:meta("[ ")
  for i=1,self.max_items do
    if i > 1 then
      printer:meta(" | ")
    end
    printer:id(string.rep("I", i))
  end
  printer:meta(" ]")
end

d.MapToFixed = TypeClass.new({
  input_kind = "named"
})

function d.MapToFixed:init(...)
  self.target_set = {...}
  self.__pairs = d.MapToFixed.iterate
end

function d.MapToFixed:pre_construct()
  self.value = {}
end

function d.MapToFixed:put(key, v)
  local found = false
  for _,e in ipairs(self.target_set) do
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
    return string.format("Unbekannter Wert '%s', erwartete %s')", v, l)
  end
  self.value[key] = v
end

function d.MapToFixed:iterate()
  return next, self.value, nil
end

function d.MapToFixed:merge(v)
  for k,v in pairs(v.value) do
    local msg = self:put(k, v)
    if msg ~= nil then
      return msg
    end
  end
end

function d.MapToFixed:print_syntax(printer)
  printer:sym("[ ")
  printer:ref(d.schema.String, "Kampfstil")
  printer:sym(" ] = ")
  printer:ref(d.schema.String, "VerbessertesTalent")
  printer:sym(", ")
  printer:meta("...")
end

d.Number = TypeClass.new({
  input_kind = "scalar"
})

function d.Number:init(min, max, decimals)
  self.min = min
  self.max = max
  self.decimals = decimals
end

function d.Number:set(v)
  if v < self.min or v > self.max then
    return string.format("Zahl %d außerhalb des erwarteten Bereichs %d..%s", v, self.min, self.max)
  else
    local x = v * 10 ^ self.decimals
    if x ~= math.floor(x) then
      return string.format("Zu viele Dezimalstellen (erlaubt sind maximal %d)", self.decimals)
    end
  end
  self.value = v
end

function d.Number:get()
  return self.value
end

function d.Number:print_syntax(printer)
  printer:meta("[")
  printer:num(self.min)
  printer:meta("..")
  printer:num(self.max)
  printer:meta("]")
end

d.String = TypeClass.new({
  input_kind = "scalar"
})

function d.String:init()
end

function d.String:set(v)
  self.value = v
end

function d.String:get()
  return self.value
end

function d.String:print_syntax(printer)
  printer:sym("\"")
  printer:ph("Text")
  printer:sym("\"")
end

function d.String:documentation(printer)
  printer:p("Beliebiger Text.")
end

d.Matching = TypeClass.new({
  input_kind = "scalar"
})

function d.Matching:init(...)
  self.raw = {...}
  self.patterns = {}
  for _, p in ipairs(self.raw) do
    table.insert(self.patterns, "^" .. p .. "$")
  end
end

function d.Matching:set(v)
  if v == "" then
    self.value = v
    return
  end
  for _, p in ipairs(self.patterns) do
    local pos, _ = string.find(v, p)
    if pos ~= nil then
      self.value = v
      return
    end
  end
  local l = "('"
  for i, p in ipairs(self.raw) do
    if i > 1 then
      l = l .. "', '"
    end
    l = l .. p
  end
  l = l .. "')"
  return string.format("Inhalt '%s' illegal, erwartet: %s", v, l)
end

function d.Matching:get()
  return self.value
end

function d.Matching:print_syntax(printer)
  printer:sym("\"")
  if #self.raw == 1 then
    printer:id(self.raw[1])
  else
    printer:choice(unpack(self.raw))
  end
  printer:sym("\"")
end

d.Simple = TypeClass.new({
  input_kind = "scalar"
})

function d.Simple:init()
end

function d.Simple:set(v)
  if type(v) ~= "string" and type(v) ~= "number" then
    return string.format("string oder number als Wert erwartet, bekam %s", type(value))
  end
  self.value = v
end

function d.Simple:get()
  return self.value
end

function d.Simple:print_syntax(printer)
  printer:meta("[ ")
  d.String:print_syntax(printer)
  printer:meta(" | &lt;Zahl&gt; ]")
end

function d.Simple:documentation(printer)
  printer:p("Zahl oder Text (letzter primär, um ein leeres Feld zu bekommen).")
end

d.Multivalue = TypeClass.new({
  input_kind = "unnamed"
})

function d.Multivalue:init(inner)
  if inner == nil then
    self:err("Multivalue ohne `inner` Wert!\n")
  end
  self.__index = d.Multivalue.getfield
  self.inner = inner
end

function d.Multivalue:pre_construct()
  self.value = {}
end

function d.Multivalue:append(v)
  if type(v) == "table" then
    local mt = getmetatable(v)
    if mt == nil then
      for l,w in pairs(v) do
        return string.format("%s oder {} in Liste erwartet, bekam nicht-leere table", self.inner.name)
      end
    elseif mt ~= self.inner then
      return string.format("%s oder {} in Liste erwartet, bekam %s", self.inner.name, mt.name)
    end
  else
    v = self.inner(v)
  end
  table.insert(self.value, v)
end

function d.Multivalue:merge(v)
  for _, item in ipairs(v) do
    local msg = self:append(item)
    if msg ~= nil then
      return msg
    end
  end
end

function d.Multivalue:getfield(key)
  if type(key) == "number" then
    local v = self.value[key]
    if v ~= nil then
      v = v:get()
    end
    return v
  else
    return getmetatable(self)[key]
  end
end

function d.Multivalue:print_syntax(printer)
  printer:meta("[ ")
  printer:ref(self.inner)
  printer:meta(" | ")
  printer:sym("{ ")
  printer:meta("[ ")
  printer:ref(self.inner)
  printer:meta(" | ")
  printer:sym("{}")
  printer:meta(" ]")
  printer:sym(", ")
  printer:meta("...")
  printer:sym(" }")
  printer:meta(" ]")
end

function d.Multivalue:documentation(printer)
  printer:p(string.format("Ein einzelner oder eine Liste von %s-Werten. Die Liste darf `{}` enthalten, die zu Zeilenumbrüchen werden.", self.inner.name))
end

d.Boolean = TypeClass.new({
  input_kind = "scalar"
})

function d.Boolean:init()
end

function d.Boolean:set(v)
  if type(v) ~= "boolean" then
    return string.format("erwartete boolean, bekam %s", type(v))
  end
  self.value = v
end

function d.Boolean:get()
  return self.value
end

function d.Boolean:print_syntax(printer)
  printer:choice("true", "false")
end

function d.Boolean:documentation(printer)
  printer:p("<code>true</code> oder <code>false</code>")
end

d.Void = TypeClass.new({
  input_kind = "unnamed"
})

function d.Void:init()
end

function d.Void:set(v)
  return "Unerwarteter Wert"
end

function d.Void:get()
  return nil
end

function d.Void:print_syntax(printer)
  printer:sym("{}")
end

function d:singleton(tc, o, ...)
  local type = tc:def(o, ...)
  type.singleton = true
  type.default = {}
  if self.typelist ~= nil then
    table.insert(self.typelist, type)
  end
  return function(default)
    type.default = default
    return type
  end
end

function d:gendocs()
  io.write("<article class=\"doc\">\n\n<section><h1>DSA 4.1 Heldendokument: Dokumentation Eingabedaten</h1>\n\n")
  io.write("<p>Grundsätzliche Struktur:</p>\n\n<pre><code>")
  for _, t in ipairs(self.typelist) do
    io.write([[<a href="#]])
    io.write(t.name)
    io.write([[">]])
    io.write(t.name)
    io.write([[</a>]])
    if t.name == "Magie.Regeneration" then
      doc_printer:sym("(")
      doc_printer:meta("...")
      doc_printer:sym(")")
    else
      doc_printer:sym(" {")
      doc_printer:meta("...")
      doc_printer:sym("}")
    end
    doc_printer:nl()
  end
  io.write([[</code></pre><p>
  Jedes Element auf der obersten Ebene ist optional, ihre Reihenfolge beliebig.
  Die Struktur der einzelnen Elemente wird bei dem jeweiligen verlinkten Typen beschrieben.
  Wird ein Element nicht angegeben, erhält es einen Standard-Wert, was in der Regel bedeutet, dass die Daten leer sind.
  Die Ausnahme ist <code>Layout</code>, dessen Standardwert alle verfügbaren Seiten generiert.
  Dies eignet sich als Kopiervorlage, aber für einen spezifischen Helden ist es eher unnütz, da man kaum sowohl Ausrüstungs- wie auch Liturgiebogen benötigt.</p>]])
  io.write([[</section><section><h2>Grundlegende Typen</h2>

  <p>
  Die im Folgenden definierten Typen werden an vielen Stellen für Werte benutzt.</p>]])
  for _, n in ipairs({"String", "Ganzzahl", "Simple", "Boolean", "Multiline"}) do
    self.schema[n]:print_documentation(doc_printer, 1, false)
  end
  for _, t in ipairs(self.typelist) do
    io.write([[</section><section>]])
    t:print_documentation(doc_printer, 0, true)
    local refs = {}
    while true do
      if #doc_printer.refs > 0 then
        table.insert(refs, doc_printer.refs)
        doc_printer.refs = {}
      end
      if #refs == 0 then
        break
      end
      local cur = table.remove(refs[#refs], 1)
      local depth = #refs
      if #refs[depth] == 0 then
        table.remove(refs)
      end
      doc_printer.known[cur] = true
      cur:print_documentation(doc_printer, depth, false)
    end
  end
  io.write("</section></article>")
end

setmetatable(d, {
  __call = function(self, docgen)
    self.schema.Boolean = self.Boolean:def({name = "Boolean"})
    self.schema.String = self.String:def({name = "String"})
    self.schema.Simple = self.Simple:def({name = "Simple"})
    self.schema.Multiline = self.Multivalue:def({name = "Multiline"}, self.schema.String)
    if docgen then
      self.typelist = {}
    end
    return self.schema
  end
})

return d