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
  for i,b in ipairs(d.context) do
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

local syntax_printer = {
  levels = {},
  refs = {},
  known = {},
}

function syntax_printer:id(name)
  io.write([[<span class="id">]])
  io.write(name)
  io.write([[</span>]])
end

function syntax_printer:sym(s)
  io.write([[<span class="sym">]])
  io.write(s)
  io.write([[</span>]])
end

function syntax_printer:ph(name)
  io.write([[<span class="metasym">&lt;]])
  io.write(name)
  io.write([[&gt;</span>]])
end

function syntax_printer:ref(target, name)
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
  if name == nil then
    io.write([[<a href="#]])
    io.write(target.name)
    io.write([[">&lt;]])
    io.write(target.name)
    io.write([[&gt;</a>]])
  else
    self:meta("&lt;" .. name .. ":")
    io.write([[<a href="#]] .. target.name .. [[">]] .. target.name .. [[</a>]])
    self:meta("&gt;")
  end
end

function syntax_printer:meta(s)
  io.write([[<span class="metasym">]] .. s .. [[</span>]])
end

function syntax_printer:choice(...)
  self:meta("[ ")
  for i, v in ipairs({...}) do
    if i > 1 then
      self:meta(" | ")
    end
    self:id(v)
  end
  self:meta(" ]")
end

function syntax_printer:num(n)
  io.write([[<span class="num">]] .. tostring(n) .. [[</span>]])
end

function syntax_printer:nl()
  io.write("\n")
  io.write(string.rep("  ", #self.levels))
end

function syntax_printer:open(name)
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

function syntax_printer:close()
  local lvl = table.remove(self.levels)
  if lvl.named then
    self:nl()
  end
  self:sym("}")
end

local Type = {
  __call = function(self, name, ...)
    return self:def(name, ...)
  end,
  props = function(self, key)
    if key == "err" then
      return err
    elseif key == "print_syntax" then
      return getmetatable(self).print_syntax
    else
      return nil
    end
  end
}

local MetaType = {
  __call = function(self, base, def, construct, syntax)
    local ret = {
      def = function(self, name, doc, ...)
        local ret = def(...)
        ret.name = name
        ret.documentation = doc
        ret.instance = function(self)
          --  only used on singleton types
          if self.value == nil then
            return self(self.default)
          else
            return self.value
          end
        end
        ret.base = base
        setmetatable(ret, self)
        d.schema[name] = ret
        return ret
      end,
      __call = function(self, value)
        if self.base ~= nil and type(value) ~= self.base then
          return self:err("%s als Argument erwartet, bekam %s", self.base, type(value))
        end
        local ret = construct(self, value)
        if ret ~= d.Poison then
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
      __index = Type.props,
      print_syntax = function(self, printer)
        if self.base == "table" then
          if self.singleton or self.force_named then
            printer:open(self.name)
          else
            printer:open()
          end
          syntax(self, printer)
          printer:close()
        elseif self.force_named then
          printer:id(self.name)
          printer:sym("(")
          syntax(self, printer)
          printer:sym(")")
        else
          syntax(self, printer)
        end
      end
    }
    setmetatable(ret, Type)
    return ret
  end
}

setmetatable(Type, MetaType)

d.MixedList = Type("table",
  function(...)
    local args = {...}
    if #args > 1 then
      if args == 2 then
        self:err("MixedList must have itemname iff giving more than one type")
      end
      args.itemname = table.remove(args, 1)
      for _,t in ipairs(args) do
        t.force_named = true
      end
    end
    return args
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
          e = e .. ')'
          self:err("enthält table ohne Typ. Erlaubt sind: %s", e)
          errors = true
        end
      end
      if mt ~= nil and mt ~= string_metatable and mt ~= d.Poison then
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
    return errors and d.Poison or value
  end,
  function(self, printer)
    if #self > 1 then
      printer:meta("&lt;" .. self.itemname .. ': [ ')
      for i,t in ipairs(self) do
        if i > 1 then
          printer:meta(" | ")
        end
        printer:ref(t)
      end
      printer:meta(" ]&gt;")
      printer:sym(", ...")
    else
      printer:ref(self[1])
      printer:sym(", ...")
    end
  end
)

d.Record = Type("table",
  function(...)
    local ret = {defs = {}, order = {}}
    for _,f in ipairs({...}) do
      ret.defs[f[1]] = {f[2], f[3]}
      table.insert(ret.order, f[1])
    end
    return ret
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
        if mt ~= d.Poison and mt ~= expected[1] then
          self:err("falscher Typ: erwartete %s, bekam %s", expected[1].name, mt.name)
          errors = true
        end
      end
      d.context:pop()
    end
    for k,v in pairs(self.defs) do
      if value[k] == nil then
        if v[1] == nil then
          io.write("XXX name=" .. self.name .. ", k=" .. k .. "\n")
        end
        value[k] = v[1](v[2])
      end
    end
    return errors and d.Poison or value
  end,
  function(self, printer)
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
)

d.ListWithKnown = Type("table",
  function(known, optional)
    if optional == nil then
      optional = {}
    end
    return {known = known, optional = optional}
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
          elseif name.base == "table" then
            return self:err("der Wert %s muss mit einem Konstructor `%s {…}` angegeben werden.", v, v)
          else
            return self:err("der Wert %s muss mit einem Konstructor `%s(…)` angegeben werden.", v, v)
          end
        else
          table.insert(ret, v)
        end
      end
    end
    for k,v in pairs(self.known) do
      if not self.optional[k] then
        if type(v) == "string" then
          if ret[v] == nil then
            ret[v] = false
          end
        elseif ret[k] == nil then
          ret[k] = v {}
        end
      end
    end
    return ret
  end,
  function(self, printer)
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
        if mt ~= d.Poison and mt ~= self.inner then
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
    return errors and d.Poison or value
  end,
  function(self, printer)
    for i=1,self.length do
      if i > 1 then
        printer:sym(", ")
      end
      self.inner:print_syntax(printer)
    end
  end
)

d.HeterogeneousList = Type("table",
  function(...)
    local ret = {...}
    ret.__index = function(self, key)
      local t = getmetatable(self)
      for i, f in ipairs(t) do
        if key == f[1] then
          if f[2].__call ~= nil then
            return self[i]()
          else
            return self[i]
          end
        end
      end
      return Type.props(self, key)
    end
    return ret
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
      if mt ~= d.Poison and mt ~= def[2] then
        self:err("falscher Typ: erwartete %s, bekam %s", def[2].name, mt.name)
        errors = true
      end
      d.context:pop()
    end
    return errors and d.Poison or value
  end,
  function(self, printer)
    for i,v in ipairs(self) do
      if i > 1 then
        printer:sym(", ")
      end
      printer:ref(v[2], v[1])
    end
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
    return errors and d.Poison or ret
  end,
  function(self, printer)
    printer:meta("[ ")
    for i=1,self.max do
      if i > 1 then
        printer:meta(" | ")
      end
      printer:id(string.rep("I", i))
    end
    printer:meta(" ]")
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
    return errors and d.Poison or value
  end,
  function(self, printer)
    printer:sym("[ ")
    printer:ref(d.schema.String, "Kampfstil")
    printer:sym(" ] = ")
    printer:ref(d.schema.String, "VerbessertesTalent")
    printer:sym(", ")
    printer:meta("...")
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
  end,
  function(self, printer)
    printer:meta("[")
    printer:num(self.min)
    printer:meta("..")
    printer:num(self.max)
    printer:meta("]")
  end
)

d.String = Type("string",
  function()
    return {__call = function(self) return self[1] end}
  end,
  function(self, value)
    return {value}
  end,
  function(self, printer)
    printer:sym("\"")
    printer:ph("Text")
    printer:sym("\"")
  end
)

d.Matching = Type("string",
  function(...)
    local ret = {patterns = {}, raw = {...}, __call = function(self) return self[1] end}
    for _, p in ipairs(ret.raw) do
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
    for i, p in ipairs(self.raw) do
      if i > 1 then
        l = l .. "', '"
      end
      l = l .. p
    end
    l = l .. "')"
    return self:err("Inhalt '%s' illegal, erwartet: %s", value, l)
  end,
  function(self, printer)
    printer:sym("\"")
    if #self.raw == 1 then
      printer:id(self.raw[1])
    else
      printer:choice(unpack(self.raw))
    end
    printer:sym("\"")
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
  end,
  function(self, printer)
    printer:meta("[ ")
    d.String:print_syntax(printer)
    printer:meta(" | &lt;Zahl&gt; ]")
  end
)

d.Multivalue = Type(nil,
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
  end,
  function(self, printer)
    printer:meta("[ ")
    d.String:print_syntax(printer)
    printer:meta(" | ")
    printer:sym("{ ")
    printer:meta("[ ")
    d.String:print_syntax(printer)
    printer:meta(" | ")
    printer:sym("{}")
    printer:meta(" ]")
    printer:sym(", ")
    printer:meta("...")
    printer:sym(" }")
    printer:meta(" ]")
  end
)

d.Boolean = Type("boolean",
  function()
    return {__call = function(self) return self[1] end}
  end,
  function(self, value)
    return {value}
  end,
  function(self, printer)
    printer:choice("true", "false")
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
  end,
  function(self, printer)
    printer:sym("{}")
  end
)

function d:singleton(TypeClass, name, doc, ...)
  local type = TypeClass(name, doc, ...)
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
      syntax_printer:sym("(")
      syntax_printer:meta("...")
      syntax_printer:sym(")")
    else
      syntax_printer:sym(" {")
      syntax_printer:meta("...")
      syntax_printer:sym("}")
    end
    syntax_printer:nl()
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
    io.write([[<h3 id="]] .. n .. [[">]] .. n .. "</h3>\n\n<pre><code>")
    local t = self.schema[n]
    syntax_printer.known[t] = true
    t:print_syntax(syntax_printer)
    io.write("</code></pre><p>")
    io.write(t.documentation)
    io.write("</p>")
  end
  for _, t in ipairs(self.typelist) do
    io.write([[</section><section><h2 id="]])
    io.write(t.name)
    io.write([[">]])
    io.write(t.name)
    io.write([[</h2>]])
    io.write("\n\n<pre><code>")
    t:print_syntax(syntax_printer)
    io.write("</code></pre>\n\n<p>")
    io.write(t.documentation)
    io.write("</p>\n\n")
    local refs = {}
    while true do
      if #syntax_printer.refs > 0 then
        table.insert(refs, syntax_printer.refs)
        syntax_printer.refs = {}
      end
      if #refs == 0 then
        break
      end
      local cur = table.remove(refs[#refs], 1)
      local depth = #refs
      if #refs[depth] == 0 then
        table.remove(refs)
      end
      syntax_printer.known[cur] = true
      io.write("<h" .. tostring(depth + 2) .. [[ id="]] .. cur.name .. [[">]] .. cur.name .. "</h2>\n\n<pre><code>")
      cur:print_syntax(syntax_printer)
      io.write("</code></pre>\n\n<p>")
      io.write(cur.documentation)
      io.write("</p>\n\n")
    end
  end
  io.write("</section></article>")
end

setmetatable(d, {
  __call = function(self, docgen)
    self.schema.Boolean = self.Boolean("Boolean", "true oder false.")
    self.schema.String = self.String("String", "Beliebiger Text in Hochkommata.")
    self.schema.Simple = self.Simple("Simple", "Zahl oder Text.")
    self.schema.Multiline = self.Multivalue("Multiline", "Text oder Liste von Text.")
    if docgen then
      self.typelist = {}
    end
    return self.schema
  end
})

return d