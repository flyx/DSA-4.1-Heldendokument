local my_source = debug.getinfo(1).source
local string_metatable = getmetatable("")

local d = {
  context = {},
  Poison = {
    name = "Poison",
    count = 0,
  },
  schema = {},
  multi = {
    forbid = 0,
    allow = 1,
    merge = 2
  }
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
  levels = 0,
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

function doc_printer:ref(target)
  if target == nil then
    print(debug.traceback())
    io.write("ERROR: target nil!\n")
  end
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
  io.write([[<a href="#]] .. target.name .. [[">]])
  io.write(target.name)
  io.write("</a>")
end

function doc_printer:meta(s)
  io.write([[<span class="metasym">]] .. s .. [[</span>]])
end

function doc_printer:num(n)
  io.write([[<span class="num">]] .. tostring(n) .. [[</span>]])
end

function doc_printer:comment(c)
  io.write([[<span class="comment">]] .. c .. "</span>")
end

function doc_printer:nl()
  io.write("\n")
  io.write(string.rep("  ", self.levels))
end

function doc_printer:repr(input, indents, named)
  local mt = getmetatable(input)
  if named then
    self:id(mt.name)
    io.write(" ")
  end
  local val = input
  if mt ~= nil and mt ~= string_metatable then
    val = val:get()
  end
  local t = type(val)
  if t == "string" then
    self:sym('"')
    io.write(val)
    self:sym('"')
  elseif t == "number" then
    self:num(val)
  elseif t == "boolean" or t == "nil" then
    self:sym(tostring(val))
  elseif t == "table" then
    self:sym("{")
    if indents > 0 then
      self.levels = self.levels + 1
    end
    local first = true
    if val.value ~= nil then
      for i, v in ipairs(val.value) do
        local child_named = false
        local mmt = getmetatable(mt)
        if mmt == d.List then
          child_named = #mt.items > 1
        elseif mmt == d.Multivalue then
          child_named = getmetatable(v) ~= mt.inner
        end
        if first then first = false else self:sym(", ") end
        if indents > 0 then self:nl() end
        self:repr(v, indents - 1, child_named)
      end
      for k,v in pairs(val.value) do
        if type(k) ~= "number" then
          if first then first = false else self:sym(", ") end
          if indents > 0 then self:nl() end
          self:id(k)
          self:sym(" = ")
          self:repr(v, indents - 1, false)
        end
      end
      if indents > 0 then
        self.levels = self.levels - 1
        if not first then
          self:nl()
        end
      end
    end
    self:sym("}")
  else
    self:err("unexpected type: " .. t .. "\n")
  end
end

function doc_printer:highlight(input)
  while #input > 0 do
    local e
    if input:sub(1, 2) == "--" then
      e = input:find("\n")
      self:comment(input:sub(1, e))
      if e == nil then
        break
      end
    else
      local c = input:sub(1, 1)
      if c:match("[0-9]") then
        _, e = input:find("[0-9]+")
        self:num(input:sub(1, e))
      elseif c:match("[{},=%[%]]") then
        _, e = input:find("[{},=%[%]]+")
        self:sym(input:sub(1, e))
      elseif c == '"' then
        self:sym('"')
        _, e = input:find('"', 2)
        self:meta(input:sub(2, e - 1))
        self:sym('"')
      else
        io.write(c)
        e = 1
      end
    end
    input = input:sub(e + 1)
  end
end

function doc_printer:h(depth, id, label)
  io.write("<h" .. tostring(depth + 2) .. " id=\"" .. id .. "\">")
  io.write(label)
  io.write("</h" .. tostring(depth + 2) .. ">")
end

function doc_printer:p(content)
  io.write("<p>")
  if content == nil then
    print(debug.traceback())
  end
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
--  a set of TypeClass instances, e.g. `Row`, `Matching`.
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
--    proto_param_values: function(self, printer)
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

function TypeClass:tostring()
  local str = self.label ~= nil and self.label or self.name
  if #self > 0 then
    str = str .. " ("
    for i,v in ipairs(self) do
      if i > 1 then
        str = str .. ", "
      end
      str = str .. tostring(v)
    end
    str = str .. ")"
  end
  return str
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
  if self.input_kind == "scalar" then
    local msg = ret:set(value)
    if msg ~= nil then
      self:err("%s", msg)
    end
  elseif type(value) == "table" and getmetatable(value) == nil then
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
  else
    local msg
    if self.input_kind == "unnamed" then
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
function TypeClass:print_documentation(printer, depth)
  printer.known[self] = true
  local proto = "UNKNOWN"
  local mt = getmetatable(self)
  for k,v in pairs(d) do
    if v == mt then
      proto = k
      break
    end
  end
  printer:h(depth, self.name, self.name .. " (<a href=\"#" .. proto .. "\">" .. proto .. "</a>)")
  printer:p("Werte der Prototypenparameter:")
  io.write("<table class=\"protoparam\">")
  self:proto_param_values(printer)
  io.write("</table>\n\n")
  if self.description ~= nil then
    printer:p(self.description)
  end
  if self.documentation ~= nil then
    self:documentation(printer)
  end
  io.write("\n\n")
  if self.example ~= nil then
    io.write([[<div class="example"><h4>Beispiel</h4><pre><code>]])
    self.example(printer)
    io.write("</code></pre></div>\n\n")
  end
end

d.List = TypeClass.new({
  input_kind = "unnamed"
})

function d.List:init(items, min, max)
  self.items, self.min_items, self.max_items = items, min, max
  if #self.items > 1 and self.item_name == nil then
    self:err("List must have item_name defined if giving more than one type")
  end
  self.__index = d.List.getfield
  self.__tostring = TypeClass.tostring
end

function d.List:pre_construct()
  self.value = {}
end

function d.List:append(v, sort)
  local mt = getmetatable(v)
  if mt == nil or mt == string_metatable then
    v = self.items[1](v)
    mt = getmetatable(v)
  end
  if mt == d.Poison then
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
  local min = 0
  local sistart = 1
  if #sort > 0 and sort[1] == "" then
    sistart = 2
    while index >= 1 do
      if getmetatable(self.value[index]).name == mt.name then
        break
      end
      index = index - 1
    end
    if index == 0 then
      min = #self.value
      index = #self.value
    else
      min = index - 1
      while min > 0 do
        if getmetatable(self.value[min]).name ~= mt.name then
          break
        end
        min = min - 1
      end
    end
  end

  while index > min do
    local si = sistart
    while si <= #sort do
      local cur = self.value[index][sort[si]]
      if cur < v[sort[si]] then
        goto sorted
      elseif cur > v[sort[si]] then
        break
      end
      si = si + 1
    end
    if si > #sort then
      break
    end
    index = index - 1
  end
  ::sorted::
  table.insert(self.value, index + 1, v)
end

function d.List:merge(v)
  assert(self ~= v)
  for _, item in ipairs(v.value) do
    local msg = self:append(item)
    if msg ~= nil then
      return msg
    end
  end
end

function d.List:getfield(key)
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

function d.List:proto_param_values(printer)
  io.write("<tr><th>items</th><td>")
  for i,t in ipairs(self.items) do
    if i > 1 then
      io.write(", ")
    end
    printer:ref(t)
  end
  for _, k in ipairs({"min", "max"}) do
    local v = self[k .. "_items"]
    if v ~= nil then
      io.write("<tr><th>" .. k .. "</th><td>" .. tostring(v) .. "</td></tr>")
    end
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

function d.Record:proto_param_values(printer)
  io.write("<tr><th>items</th><td>")
  for i,f in pairs(self.order) do
    local d = self.defs[f]
    io.write([[<ul class="rowitem"><li>]])
    io.write(f)
    io.write("</li><li>")
    if d[1] == nil then
      io.write("<em>beliebig</em>")
    else
      printer:ref(d[1])
    end
    io.write("</li><li>")
    if d[2] == nil then
      io.write("<em>kein default</em>")
    else
      io.write("<code>")
      printer:repr(d[2], 0, false)
      io.write("</code>")
    end
    io.write("</ul>")
  end
  io.write("</td></tr>")
end

d.Row = TypeClass.new({
  input_kind = "named"
})

function d.Row:init(...)
  self.fields = {...}
  self.unnamed_to_named = self.fields
  self.__index = d.Row.getfield
  self.__newindex = d.Row.setfield
end

function d.Row:pre_construct()
  rawset(self, "value", {})
end

function d.Row:put(key, v)
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

function d.Row:post_construct()
  for i=1,#self.fields do
    if self.value[i] == nil then
      local def = self.fields[i]
      if def[3] == nil then
        self:err("Wert #%d (%s) fehlt", i, def[1])
      elseif def[2] == nil then
        if getmetatable(def[3]) ~= nil then
          self.value[i] = def[3]
        end
      else
        self.value[i] = def[2](def[3])
      end
    end
  end
end

-- used as __getindex for the values
function d.Row:getfield(key)
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

function d.Row:setfield(key, value)
  local mt = getmetatable(self)
  local fields = rawget(mt, "fields")
  if type(key) == "string" then
    for i, f in ipairs(fields) do
      if f[1] == key then
        self.value[i]:set(value)
        return
      end
    end
  elseif type(key) == "number" then
    if key >= 1 and key <= #self.value then
      self.value[key]:set(value)
    else
      self:err("index " .. tostring(key) .. " not in interval [0.." .. tostring(#self.value) .. "]")
    end
    return
  end
  self:err("cannot set key: " .. key)
end

function d.Row:proto_param_values(printer)
  io.write("<tr><th>items</th><td>")
  for i,v in ipairs(self.fields) do
    io.write([[<ul class="rowitem"><li>]])
    io.write(v[1])
    io.write("</li><li>")
    if v[2] == nil then
      io.write("<em>beliebig</em>")
    else
      printer:ref(v[2])
    end
    io.write("</li><li>")
    if v[3] == nil then
      io.write("<em>kein default</em>")
    else
      io.write("<code>")
      printer:repr(v[3], 0, false)
      io.write("</code>")
    end
    io.write("</ul>")
  end
  io.write("</td></tr>")
end

d.Numbered = TypeClass.new({
  input_kind = "unnamed"
})

local roman = {"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"}

function d.Numbered:tostring()
  local str = self.label ~= nil and self.label or self.name
  str = str .. " ("
  local first = true
  for i=1,self.max_items do
    if self[i] then
      if first then
        first = false
      else
        str = str .. ", "
      end
      str = str .. roman[i]
    end
  end
  str = str .. ")"
  return str
end

function d.Numbered:init(max)
  self.max_items = max
  self.__index = d.Numbered.getfield
  self.__tostring = d.Numbered.tostring
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

function d.Numbered:proto_param_values(printer)
  io.write("<tr><th>max</th><td>" .. tostring(self.max_items) .. "</td></tr>")
end

d.Primitive = TypeClass.new({input_kind = "scalar"})

function d.Primitive:init(inner, optional, decimals, min, max)
  self.inner, self.optional = inner, optional
  if self.inner == "number" then
    self.min, self.max, self.decimals = min, max, decimals
    if self.decimals == nil then
      self:err("Primitive with inner=number requires `decimals` to be set")
    end
  end
end

function d.Primitive:set(v)
  local t = type(v)
  if t == "table" then
    for key,_ in pairs(v) do
      return string.format("Skalaren Wert oder leere table erwartet, bekam table mit key '%s'", key)
    end
    if not self.optional then
      return string.format("Wert ist nicht optional, {} nicht erlaubt.")
    end
    self.value = nil
  else
    if t ~= self.inner then
      return string.format("%s-Inhalt erwartet, bekam %s", self.inner, t)
    end
    if self.decimals ~= nil then -- identifies numbers
      local after = string.match(string.format("%g", v), "%.(.*)")
      if after ~= nil and #after > self.decimals + 1 then
        return string.format("'%g': Zu viele Dezimalstellen (erlaubt sind maximal %d)", v, self.decimals)
      end
      if (self.min ~= nil and v < self.min) or (self.max ~= nil and v > self.max) then
        local minstr = self.min == nil and "-∞" or tostring(self.min)
        local maxstr = self.max == nil and "∞" or tostring(self.max)
        return string.format("Zahl %g außerhalb des erwarteten Bereichs %s..%s", v, minstr, maxstr)
      end
    end
    self.value = v
  end
end

function d.Primitive:get()
  return self.value
end

function d.Primitive:proto_param_values(printer)
  io.write("<tr><th>inner</th><td>" .. self.inner .. "</td></tr>\n")
  io.write("<tr><th>optional</th><td>" .. tostring(self.optional) .. "</td></tr>\n")
  if self.inner == "number" then
    io.write("<tr><th>decimals</th><td>" .. tostring(self.decimals) .. "</td></tr>\n")
    for _,k in pairs({"min", "max"}) do
      local v = self[k]
      if v ~= nil then
        io.write("<tr><th>" .. k .. "</th><td>" .. tostring(v) .. "</td></tr>\n")
      end
    end
  end
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

function d.Matching:proto_param_values(printer)
  io.write("<tr><th>patterns</th><td>")
  for i,p in ipairs(self.raw) do
    if i > 1 then
      io.write(", ")
    end
    io.write("<code>" .. p .. "</code>")
  end
  io.write("</td></tr>")
end

d.Multivalue = TypeClass.new({
  input_kind = "unnamed"
})

function d.Multivalue:init(inner, known_items)
  if inner == nil then
    self:err("Multivalue ohne `inner` Wert!")
  end
  self.__index = d.Multivalue.getfield
  self.__tostring = TypeClass.tostring
  self.inner = inner
  self.known_items = {}
  if known_items ~= nil then
    for k,v in pairs(known_items) do
      if type(v) == "string" then
        self.known_items[k] = v
      else
        local mt = getmetatable(v)
        if mt == nil then
          if #v ~= 2 or (v[2] ~= d.multi.forbid and v[2] ~= d.multi.allow and v[2] ~= d.multi.merge) then
            self:err("invalid known item `" .. k .. "`")
          end
          self.known_items[k] = v
        else
          self.known_items[k] = {v, v.merge ~= nil and d.multi.merge or d.multi.forbid}
        end
      end
    end
  end
end

function d.Multivalue:pre_construct()
  self.value = {}
  self.named_index = {}
end

function d.Multivalue:append(v)
  if type(v) == "table" then
    local mt = getmetatable(v)
    if mt == nil then
      for l,w in pairs(v) do
        return string.format("%s oder {} in Liste erwartet, bekam nicht-leere table", self.inner.name)
      end
    elseif mt ~= self.inner then
      for key,item in pairs(self.known_items) do
        if type(item) == "table" and mt == item[1] then
          if self.named_index[key] ~= nil then
            if item[2] == d.multi.merge then
              self.named_index[key]:merge(v)
            elseif item[2] == d.multi.allow then
              table.insert(self.named_index[key], v)
              table.insert(self.value, v)
            else
              return string.format("%s darf in %s maximal einmal vorkommen", mt.name, self.name)
            end
          else
            self.named_index[key] = item[2] == d.multi.allow and {v} or v
            table.insert(self.value, v)
          end
          return
        end
      end
      return string.format("%s oder {} erwartet, bekam %s", self.inner.name, mt.name)
    end
  else
    for key,item in pairs(self.known_items) do
      if v == item then
        self.named_index[key] = true
        break
      end
    end
    v = self.inner(v)
  end
  table.insert(self.value, v)
end

function d.Multivalue:merge(v)
  assert(self ~= v)
  for _, item in ipairs(v) do
    local msg = self:append(item)
    if msg ~= nil then
      return msg
    end
  end
end

function d.Multivalue:getfield(key)
  local t = type(key)
  if t == "number" then
    local v = self.value[key]
    if v ~= nil and getmetatable(v) ~= nil then
      v = v:get()
    end
    return v
  elseif t == "string" then
    local v = self.named_index[key]
    if v ~= nil then
      if getmetatable(v) ~= nil then
        v = v:get()
      end
      return v
    end
  end
  return getmetatable(self)[key]
end

function d.Multivalue:getlist(key)
  local v = self.named_index[key]
  return v == nil and {} or v
end

function d.Multivalue:proto_param_values(printer)
  io.write("<tr><th>known</th><td>")
  local first = true
  for k,v in pairs(self.known_items) do
    if first then first = false else io.write(", ") end
    if type(v) == "string" then
      io.write("<code>\"" .. v .. "\"</code>")
    else
      io.write("(")
      printer:ref(v[1])
      if v[2] == d.multi.forbid then
        io.write(", <em>forbid</em>")
      elseif v[2] == d.multi.allow then
        io.write(", <em>allow</em>")
      elseif v[2] == d.multi.merge then
        io.write(", <em>merge</em>")
      end
      io.write(")")
    end
  end
  if first then
    io.write("<em>keine</em>")
  end
  io.write("</td></tr>")
end

function d.Multivalue:documentation(printer)
  printer:p(string.format("Ein einzelner oder eine Liste von Werten, die jeweils entweder den Typ %s oder einen Typen in <i>known</i> haben.", self.inner.name))
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

local function prototype_header(name, params)
  io.write("<section>")
  doc_printer:h(1, name, "Der Prototyp <em>" .. name .. "</em>")
  doc_printer:p("Parameter:")
  io.write("<table class=\"protoparam\">")
  for _,p in ipairs(params) do
    for k,v in pairs(p) do
      io.write("<tr>")
      io.write("<th>" .. k .. "</th>")
      io.write("<td>" .. v .. "</td>")
      io.write("</tr>")
    end
  end
  io.write("</table>")
end

function d:typeclass_docs()
  io.write("<section>")
  doc_printer:h(0, "syntax", "Generelle Syntax")
  doc_printer:p([[
    Die Eingabedatei folgt der Syntax der Programmiersprache <a href="https://www.lua.org">Lua</a>, es sind keine Programmierkenntnisse nötig
    (aber es kann ein Editor mit Lua-Unterstützung verwendet werden, um eine Heldendatei zu schreiben).
    Alle für die Heldendatei nötige Syntax ist in diesem Dokument beschrieben.
    Zwei Gedankenstriche (<code>--</code>) werden verwendet, um einen Kommentar einzuleiten, der bis zum Ende der Zeile geht und keinen Wert darstellt – solche finden sich in den Beispielen.
    Die üblichen Lua-Funktionen sind in der Eingabedatei nicht verfügbar aus Sicherheitsgründen (damit man nicht böswilligen Code in Heldendaten einbetten kann).
  ]])
  doc_printer:p([[
    In der Eingabedatei werden <em>Werte</em> definiert.
    Ein Wert wird mit einer der folgenden Strukturen angegeben:
  ]])
  io.write([[<pre><code>]])
  doc_printer:ph("Skalar")
  doc_printer:nl()
  doc_printer:ph("Zusammengesetzt")
  doc_printer:nl()
  doc_printer:ph("Typ")
  doc_printer:sym("(")
  doc_printer:ph("Skalar")
  doc_printer:sym(")")
  doc_printer:nl()
  doc_printer:ph("Typ")
  io.write(" ")
  doc_printer:ph("Zusammengesetzt")
  io.write("</code></pre>")
  doc_printer:p([[
    Ein Wert hat immer entweder skalaren oder zusammengesetzten Inhalt.
    Außerdem hat er einen Typ, der entweder explizit angegeben werden kann oder sich aus dem Kontext ergibt.
    Die letzten beiden Zeilen zeigen, wie der Typ explizit vor dem Inhalt steht; skalarer Inhalt muss dabei eingeklammert werden.
  ]])
  doc_printer:p([[
    <code><span class="metasym">&lt;Skalar&gt;</span></code> ist skalarer Inhalt.
    Dies kann Textinhalt sein, der durch Hochkommas umschlossen wird (<code><span class="sym">"</span><span class="metasym">&lt;Text&gt;</span><span class="sym">"</span></code>);
    eine Zahl, die falls nötig den Punkt (nicht das Komma) für Dezimalstellen benutzt (Beispiel: <code><span class="num">3.1415</span></code>);
    oder die speziellen Boolean-Werte <code><span class="sym">true</span></code> und <code><span class="sym">false</span></code>.
  ]])
  doc_printer:p([[
    <code><span class="metasym">&lt;Zusammengesetzt&gt;</span></code> ist zusammengesetzter Inhalt und hat folgende Struktur:
  ]])
  io.write("<pre><code>")
  doc_printer:sym("{")
  doc_printer:ph("Wert")
  doc_printer:sym(", ")
  doc_printer:ph("Wert")
  doc_printer:sym(", ")
  doc_printer:meta("...")
  doc_printer:sym(", ")
  doc_printer:ph("Name")
  doc_printer:sym(" = ")
  doc_printer:ph("Wert")
  doc_printer:sym(", ")
  doc_printer:meta("...")
  doc_printer:sym("}")
  io.write("</code></pre>")
  doc_printer:p([[
    Innerhalb der geschweiften Klammern können innere Werte entweder direkt oder mit einem voranstehenden Namen und Gleichheitszeichen angegeben werden.
    Namen bestehen aus Buchstaben.
    Beide Formen können vermischt werden, wobei benamte Werte hinter unbenamten stehen sollten.
    Leerzeichen und Zeilenumbrüche können beliebig zwischen Werten eingefügt werden.
  ]])
  doc_printer:p([[
    Der oberste Typ einer Wertstruktur muss immer angegeben werden, damit klar ist, wozu der Wert dient.
    Werte in zusammengesetzten Strukturen können den Typ weglassen, wenn durch ihre Position der Typ ableitbar ist; ist dies nicht der Fall, muss dort ebenfalls der Typ angegeben werden.
    Der Typ eines Werts definiert, welche Form sein Inhalt haben muss.
    Ein Typ kann verschiedene Arten von Inhalt zulassen.
    Lässt ein Typ zusammengesetzten Inhalt zu, verlangt er von diesem eine bestimmte Struktur.
  ]])
  doc_printer:p([[
    Nachfolgend werden <em>Prototypen</em> beschrieben.
    Prototypen fassen die strukturellen Grundlagen mehrere Typen zusammen.
    Der Prototyp <em>List</em> definiert beispielsweise die grundsätzliche Struktur von Listen, die sowohl für eine Liste von Text wie auch für eine Liste von Zahlen gilt.
    Prototypen haben Parameter; ein Typ wird definiert, indem der verwendete Prototyp angegeben wird und Werte für dessen Parameter.
    Der Prototyp <em>List</em> halt beispielsweise einen Parameter, der den inneren Typ der Liste angibt.
  ]])

  prototype_header("Primitive", {
    {inner = "definiert die Art des Inhalts: <code>string</code> (Textinhalt), <code>number</code> (Zahl), <code>boolean</code> (Boolean-Inhalt), <code>void</code> (kein Inhalt)"},
    {optional = "definiert, ob der Wert optional ist. Falls <code>true</code>, darf statt einem der oben genannten Werte auch <code><span class=\"sym\">{}</span></code> als Indikator für die Abwesenheit eines Werts angegeben werden."},
    {decimals = "definiert für Zahlenwerte, wie viele Nachkommastellen angegeben werden dürfen."},
    {min = "definiert für Zahlenwerte den kleinstmöglichen Wert."},
    {max = "definiert für Zahlenwerte den größtmöglichen Wert."},
  })
  doc_printer:p([[
    Auf der Basis von <em>Primitive</em> werden Typen definiert, die nicht zusammengesetzte Werte annehmen.
    Zahlenwerte können weiter beschränkt werden wie bei den entsprechenden Parametern beschrieben.
    Ist <em>inner</em> <code>void</code>, muss <em>optional</em> <code>true</code> sein – ein solcher Wert hat nie Inhalt.
  ]])
  io.write("</section>")

  prototype_header("Matching", {
    {patterns = "Liste von Patterns, von denen mindestens eines vom Inhalt erfüllt werden muss."}
  })
  doc_printer:p([[
    <em>Matching</em> definiert Typen, die Textinhalt annehmen, welcher einem der gegebenen Pattern entspricht.
    Leerer Text (<code><span class="sym">&quot;&quot;</span></code>) wird immer angenommen.
    Die Pattern werden in der Syntax von <a href="https://www.lua.org/pil/20.2.html">Lua Patterns</a> angegeben.
  ]])
  io.write("</section>")

  prototype_header("Numbered", {
    {max = "Die höchstmögliche enthaltene Zahl"}
  })
  doc_printer:p([[
    <em>Numbered</em> definiert Typen mit zusammengesetzten Inhalt (<code><span class="sym">{</span><span class="metasym">...</span><span class="sym">}</span></code>).
    Der Inhalt darf nur unbenamte Werte enthalten, und alle Werte müssen Ganzzahlen zwischen 1 und <em>max</em> sein.
    Die Ganzzahlen müssen typlos sein.
  ]])
  doc_printer:p([[
    <em>Numbered</em>-Typen werden verwendet für mehrstufige Werte.
    Statt der Dezimalschreibweise kann man auch die römischen Ziffern <code>I</code>, <code>II</code>, <code>III</code>, <code>IV</code>, <code>V</code> und <code>VI</code> verwenden.
    Beispiel:
  ]])
  io.write("<pre><code>")
  doc_printer:id("Ausweichen ")
  doc_printer:sym("{")
  doc_printer:id("I")
  doc_printer:sym(", ")
  doc_printer:id("II")
  doc_printer:sym("}")
  io.write("</code></pre>")
  doc_printer:p([[
    Die Reihenfolge der Zahlenwerte spielt keine Rolle.
    Auch wenn es oft keinen Sinn ergibt, die Stufe <code>II</code> ohne die Stufe <code>I</code> zu aktivieren, ist dies nicht verboten.
  ]])
  io.write("</section>")

  prototype_header("List", {
    {inner = "Einer oder mehrere Typen. Die Liste nimmt innere Werte dieser Typen an."},
    {min = "Minimale Anzahl innerer Werte"},
    {max = "Maximale Anzahl innerer Werte"},
  })
  doc_printer:p([[
    <em>List</em> definiert Listentypen.
    Listentypen haben zusammengesetzten Inhalt.
    Ist <em>inner</em> ein einziger Typ, brauchen innere Werte keinen voranstehenden Typ.
    Enthält <em>inner</em> aber mehrere Typen, müssen alle inneren Werte ihren Typ angeben.
    In jedem Fall dürfen die inneren Werte nicht benamt sein.
  ]])
  doc_printer:p([[
    <em>List</em>-Typen werden vor allem für Tabellen verwendet, wobei <code>inner</code> dann der Typ einer Zeile in der Tabelle ist.
  ]])
  io.write("</section>")

  prototype_header("Row", {
    {items = "Liste von <em>Einträgen</em>. Jeder Eintrag hat einen Namen und einen Typ, möglicherweise außerdem Default-Inhalt."},
  })
  doc_printer:p([[
    <em>Row</em> definiert Typen, die eine Tabellenzeile beschreiben.
    Die Liste von Einträgen korrespondiert nicht unbedingt mit ausgegebenen Spalten – oftmals gibt es Spalten, deren Inhalt automatisch berechnet wird und die daher im zugrundeliegenden <em>Row</em>-Typ keinen Eintrag haben.
  ]])
  doc_printer:p([[
    Der Inhalt von <em>Row</em>-Typen darf sowohl unbenamte wie auch benamte innere Werte beinhalten.
    Unbenamte Werte werden über ihre Position mit einem Eintrag assoziiert (der dritte unbenamte Wert also mit dem dritten Eintrag), benamte Werte müssen einen Namen eines der Einträge haben und werden mit diesem assoziiert.
    Die inneren Werte einer <em>Row</em> müssen nie einen Typen haben.
  ]])
  doc_printer:p([[
    Wird vom Inhalt für einen Eintrag kein Wert gegeben, wird der Default-Inhalt dieses Eintrags als Wert genommen.
    Für Einträge, die keinen Default-Inhalt haben, <em>muss</em> ein Wert gegeben werden..
  ]])
  io.write("</section>")

  prototype_header("Record", {
    {items = "Liste von <em>Einträgen</em>. Jeder Eintrag hat einen Namen und einen Typ."}
  })
  doc_printer:p([[
    <em>Record</em> definiert Typen für zusammengesetzte Werte ähnlich wie <em>Row</em>.
    Allerdings haben die Einträge eines <em>Record</em> nie Default-Werte und der Inhalt darf ausschließlich aus benamten Werten bestehen.
    Wie bei <em>Rows</em> müssen die inneren Werte nie typisiert sein.
  ]])
  doc_printer:p([[
    Records werden üblicherweise für Tabellen mit fester Anzahl an Zeilen benutzt, wie etwa eine Liste von Eigenschaftenwerten.
  ]])
  io.write("</section>")

  prototype_header("Multivalue", {
    {inner = "Innerer Typ", known = "Bekannte Werte und Untertypen"}
  })
  doc_printer:p([[
    <em>Multivalue</em> definiert Typen für Auflistungen von Werten, die meistens im Ausgabedokument mit Kommas getrennt hintereinander geschrieben werden.
    Multivalue-Werte haben zusammengesetzten Inhalt, wobei die inneren Werte unbenamt sein müssen.
    Werte des Typs <em>inner</em> brauchen keinen Typ.
    Daneben ist immer der Wert <code><span class="sym">{}</span></code> erlaubt, der an der Stelle seines Auftretens einen Zeilenumbruch generiert, falls das ausgegebene Dokument das an dieser Stelle zulässt.
  ]])
  doc_printer:p([[
    <em>known</em> definiert eine Liste bekannter Werte und Untertypen.
    Bekannte Werte sind vom Typ <em>inner</em> und sind ein Hinweis an den Benutzer, dass der beschriebene Wert Auswirkungen auf berechnete Werte im Dokument haben kann.
  ]])
  doc_printer:p([[
    Bekannte Untertypen sind zusätzliche Typen, deren Werte ebenfalls – dann mit Typ – als innere Werte auftreten dürfen.
    Sie ermöglichen es, neben textuellen Werten strukturierte Werte anzunehmen, wie etwa eine Sonderfertigkeit, die mehrere Stufen haben kann. Beispiel:
  ]])
  io.write("<pre><code>")
  doc_printer:id("SF.Nahkampf ")
  doc_printer:sym("{")
  doc_printer:sym("\"")
  io.write("Aufmerksamkeit")
  doc_printer:sym("\", ")
  doc_printer:id("Ausweichen ")
  doc_printer:sym("{")
  doc_printer:id("I")
  doc_printer:sym("} }")
  io.write("</code></pre>")
  doc_printer:p([[
    Untertypen haben ein Flag <em>multi</em>, welches eines der Werte <code>forbid</code>, <code>allow</code> oder <code>merge</code> hat.
    Dieses Flag definiert, ob mehrere Werte dieses Untertyps gegeben werden dürfen:
    <code>forbid</code> verbietet es, <code>allow</code> erlaubt es, und <code>merge</code> führt alle weiteren Werte mit dem ersten Wert des Untertyps zusammen.
  ]])
  io.write("</section>")

  io.write("</section>")
end

function d:gendocs()
  io.write("<section>")
  doc_printer:h(0, "Struktur", "Struktur des Eingabedokuments")
  doc_printer:p("Auf der obersten Ebene des Eingabedokuments können Werte der nachfolgend gelisteten Typen angegeben werden:")
  io.write("<pre><code>")
  for _, t in ipairs(self.typelist) do
    io.write([[<a href="#]])
    io.write(t.name)
    io.write([[">]])
    io.write(t.name)
    io.write([[</a>]])
    if t.name == "Magie.Regeneration" then
      doc_printer:meta(" ...")
    else
      doc_printer:sym(" {")
      doc_printer:meta("...")
      doc_printer:sym("}")
    end
    doc_printer:nl()
  end
  io.write([[</code></pre>]])
  doc_printer:p([[
    Jeder dieser Werte ist optional, ihre Reihenfolge beliebig.
    Die Struktur der einzelnen Elemente wird bei dem jeweiligen verlinkten Typen beschrieben.
    Wird ein Element nicht angegeben, erhält es einen Standard-Wert, was in der Regel bedeutet, dass die Daten leer sind; Ausnahmen sind beim Typen angegeben.
  ]])
  for _, t in ipairs(self.typelist) do
    io.write([[</section><section>]])
    t:print_documentation(doc_printer, 0)
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
      cur:print_documentation(doc_printer, depth)
    end
  end
  io.write("</section>")
end

setmetatable(d, {
  __call = function(self, docgen)
    self.schema.Boolean = self.Primitive:def({name = "Boolean"}, "boolean")
    self.schema.String = self.Primitive:def({name = "String"}, "string")
    self.schema.Function = self.Primitive:def({name = "Function"}, "function")
    self.schema.OptNum = self.Primitive:def({name = "OptNum"}, "number", true, 0)
    self.schema.Multiline = self.Multivalue:def({name = "Multiline"}, self.schema.String)
    if docgen then
      self.typelist = {}
    end
    return self.schema
  end
})

return d