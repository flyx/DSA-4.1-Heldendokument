require("stdext")
local data = require("data")
local schema = require("schema")

local common = {}

function common.p(fstr, ...)
  tex.sprint(string.format(string.gsub(fstr, "\n", ""), unpack({...})))
end

function common.row(output_funcs, ...)
  for i, s in ipairs({...}) do
    if i ~= 1 then
      tex.print([[& ]])
    end
    if output_funcs ~= nil and output_funcs[i] ~= nil then
      output_funcs[i](s)
    else
      tex.sprint(-2, s)
    end
  end
end

function common.fixed_length_row(l, prepend_empty)
  return function(output_funcs, v)
    desired_num = prepend_empty and l - 1 or l
    values = {unpack(v, 1, desired_num)}
    while #values < desired_num do
      table.insert(values, "")
    end
    if prepend_empty then
      common.row(output_funcs, "", unpack(values))
    else
      common.row(output_funcs, unpack(values))
    end
  end
end

function common.header_row(height, font, ...)
  tex.sprint(string.format([[\setarstrut{\%s}]], height, height))
  for i, v in ipairs({...}) do
    if i ~= 1 then
      tex.sprint("&")
    end

    if type(v) == "table" then
      tex.sprint(string.format([[\multicolumn{%s}{%s}{]], v[1], v[2]))
      content = v[3]
    else
      content = v
    end
    tex.sprint("\\" .. font .. "{}")
    tex.sprint(-2, content)
    if type(v) == "table" then
      tex.sprint("}")
    end
  end
  tex.sprint([[\\ \restorearstrut]])
end

local function pad_value(t, i)
  tex.sprint([[\parbox[c][1.67em]{\textwidth-\tabcolsep}{\normalfont ]])
  if i <= #t then
    tex.sprint(-2, t[i])
  end
  tex.sprint[[}]]
end

function common.padded_values(t, max_items, name)
  local items = {unpack(t, 1, max_items)}
  if #items + #t.Magisch <= max_items then
    for i,v in ipairs(t.Magisch) do
      table.insert(items, v)
    end
  end
  for i=1,max_items do
    if i ~= 1 then
      tex.sprint([[\\ \hline]])
    end
    pad_value(items, i)
  end
end

function common.inner_rows(v, num_items, num_rows, output_funcs)
  if num_rows == nil then
    num_rows = #v
  end
  if num_rows > 0 then
    local my_row = num_items > 1 and common.fixed_length_row(num_items, false) or common.row
    for i=1,num_rows do
      if i > #v then
        for j=2,num_items do
          tex.sprint("&")
        end
      else
        my_row(output_funcs, v[i])
      end
      if i ~= num_rows then
        tex.sprint([[\\ \hline\relax]])
      end
    end
  end
end

function common.segnungen(items)
  local first = true
  for _, s in ipairs(items) do
    if getmetatable(s).name == "Segnung" then
      if first then
        first = false
      else
        tex.sprint(-2, ", ")
      end
      tex.sprint(-2, s.Name)
      if s.Seite ~= "" then
        tex.sprint([[ {\tiny ]])
        tex.sprint(-2, tostring(s.Seite))
        tex.sprint("}")
      end
    end
  end
end

local grad_disp = {"0", "I", "II", "III", "IV", "V", "VI"}

function common.liturgien(items, num_rows)
  local actual_rows = 0
  for _, l in ipairs(items) do
    if getmetatable(l).name == "Liturgie" then
      actual_rows = actual_rows + 1
    end
  end

  local printed = 0
  for _, l in ipairs(items) do
    if getmetatable(l).name ~= "Liturgie" then
      goto continue
    end
    printed = printed + 1
    tex.sprint(-2, l.Seite)
    tex.sprint("&")
    tex.sprint(-2, l.Name)
    tex.sprint("&")
    for j, g in ipairs(l.Grade) do
      if j > 1 then
        tex.sprint(-2, ", ")
      end
      tex.sprint(-2, grad_disp[g + 1])
    end
    if printed ~= actual_rows then
      tex.sprint([[\\ \hline]])
    end
    ::continue::
  end
  for i = actual_rows + 1, num_rows do
    tex.sprint([[\\ \hline &&]])
  end
end

-- spec = {
--   name="whatev", rows = 23, cols = 42, col="", baselinestretch=1.35,
--   preamble="", hspace="10pt", fontsize={8,12}
-- }
function common.multiline_content(spec, ...)
  if spec.cols ~= nil and spec.cols > 1 then
    tex.sprint([[\multicolumn{]])
    tex.sprint(spec.cols)
    tex.sprint("}{")
    tex.sprint(spec.col)
    tex.sprint("}{")
  end
  if spec.rows > 1 then
    tex.sprint([[\multirow[t]{]])
    tex.sprint(spec.rows)
    tex.sprint([[}{=}{\renewcommand{\baselinestretch}{]])
    tex.sprint(spec.baselinestretch)
    tex.sprint([[}\normalfont]])
  end
  if spec.fontsize ~= nil then
    tex.sprint([[\normalfont\fontsize{]])
    tex.sprint(spec.fontsize[1])
    tex.sprint([[}{]])
    tex.sprint(spec.fontsize[2])
    tex.sprint([[}\selectfont]])
  end
  if spec.preamble ~= nil and spec.preamble ~= "" then
    tex.sprint([[\textmansontt{\textbf{]])
    tex.sprint(spec.preamble)
    tex.sprint([[}}\hspace{]])
    tex.sprint(spec.hspace)
    tex.sprint("}")
  end

  local first = true
  local seen_empty = false
  for _, values in ipairs {...} do
    if type(values) == "table" then
      for i,container in ipairs(values.value) do
        local v = container:get()
        local is_table = type(v) == "table"
        if is_table and getmetatable(v) == nil then
          if #v ~= 0 then
            tex.error("nested table in '" .. spec.name .. "' is not empty!")
          end
          if seen_empty or first then
            tex.sprint([[\newline]])
          else
            seen_empty = true
          end
        elseif (not is_table) or (not v.skip) then
          if not first then
            if seen_empty then
              tex.sprint([[\newline]])
            else
              tex.sprint(", ")
            end
          end
          first = (v == "")
          seen_empty = false
          if (not is_table) and getmetatable(container) ~= values.inner then
            tex.sprint(-2, container.label or container.name)
            tex.sprint(" ")
          end
          tex.sprint(-2, tostring(v))
        end
      end
    elseif values ~= nil then
      if not first then
        tex.sprint(", ")
      end
      first = (values == "")
      tex.sprint(-2, values)
    end
  end
  if spec.rows > 1 then tex.sprint("}") end
  if spec.cols ~= nil and spec.cols > 1 then tex.sprint("}") end
  for i=2,spec.rows do
    tex.sprint([[\\\hline ]])
    tex.sprint(empty_line)
  end
  tex.sprint([[\\]])
end

function common.checkbox(checked)
  tex.sprint(checked and [[$\boxtimes$]] or [[$\square$]])
end

function common.checkboxlist(items)
  for i, item in ipairs(items) do
    if type(item[1]) == "table" then
      for j = 1, #item[1] do
        common.checkbox(item[2][j])
        tex.sprint(-2, " " .. item[1][j])
        if j ~= #item[1] then
          tex.sprint("/ ")
        end
      end
    else
      common.checkbox(item[2])
      tex.sprint(-2, " " .. item[1])
    end
    if i ~= #items then
      tex.sprint([[,\hspace{5pt}]])
    end
  end
end

function common.round(v, down)
  local delta = down and -0.0001 or 0.0001 -- round up at 0.5 unless down given
  return tonumber(string.format("%.0f", v + delta))
end

function common.ritualkenntnis(items, count)
  tex.sprint([[{\normalfont\normalsize\setlength{\arrayrulewidth}{1pt}
    \begin{NiceTabular}{p{3.7cm}@{(}x{3.2cm}@{):\hspace{2pt}}x{0.7cm}x{0.5cm}}]])
  for i,v in ipairs(items) do
    tex.sprint(string.format([[\large\mansontt\bfseries Ritualkenntnis & %s & %s & \color{gray}\bfseries %s \\ \cline{3-3} ]], v.Name, v.Wert, v.Steigerung))
    if i ~= count then
      tex.sprint([[\multicolumn{3}{c}{}\\[-12pt] ]])
    end
  end
  for i=#items+1,count do
    tex.sprint([[\large\mansontt\bfseries Ritualkenntnis & & & \\ \cline{3-3} ]])
    if i ~= count then
      tex.sprint([[\multicolumn{3}{c}{}\\[-9pt] ]])
    end
  end
  tex.sprint([[\end{NiceTabular}}]])
end

local value_line = {
  labels = {
    AT = "AT-Basiswert", PA = "PA-Basiswert", FK = "FK-Basiswert",
    eGS = "Effektive GS", BE = "BE",
    AP_Gesamt = {"Gesamt", data.AP.Gesamt},
    AP_Eingesetzt = {"Eingesetzt", data.AP.Eingesetzt},
    AP_Guthaben = {"Guthaben", data:cur("AP")}
  }
}

setmetatable(value_line.labels, {
  __call = function(self, name)
    res = self[name]
    return res ~= nil and res or name
  end
})

function value_line.render(self, items, hspace, v_len)
  if v_len == nil then
    v_len = "1cm"
  end
  tex.sprint([[\bgroup\setlength{\tabcolsep}{0pt}\begin{tabular}{]])
  for i=1,#items do
    tex.sprint("lx{" .. v_len .. "}")
  end
  tex.sprint("}")
  for i, p in ipairs(items) do
    if i ~= 1 then
      tex.sprint([[&\hspace{]] .. hspace .. "}")
    end
    tex.sprint([[\textmansontt{\bfseries ]])
    local info = self.labels(p)
    local label = type(info) == "table" and info[1] or info

    tex.sprint(-2, label)
    tex.sprint(":} &")
    if type(info) == "table" then
      tex.sprint(-2, info[2])
    else
      tex.sprint(-2, data:cur(p))
    end
  end
  tex.print([[\end{tabular}\egroup]])
end

common.value_line = value_line

local pages_source = {
  Front             = "frontseite.tex",
  Talentliste       = "talentbogen.tex",
  Kampfbogen        = "kampfbogen.tex",
  Ausruestungsbogen = "ausruestung.tex",
  Liturgiebogen     = "liturgien.tex",
  Zauberdokument    = "zauberdokument.tex",
  Zauberliste       = "zauberliste.tex",
  Ereignisliste     = "ereignisse.tex",
}

function common.pages()
  for i,p in ipairs(data.Layout.value) do
    local pKind = getmetatable(p).name
    tex.print([[\directlua{common.current_page = data.Layout[]] .. tostring(i) .. "]}")
    tex.print("\\input{" .. pages_source[pKind] .. "}")
  end
end

function common.render_delta(input)
  if type(input) == "number" then
    local sign
    if input >= 0.5 then
      sign = "+"
    elseif input <= -0.5 then
      sign = "−"
    else
      sign = ""
    end
    input = string.format("%s%d", sign, math.round(math.abs(input)))
  end
  tex.sprint(-2, input)
end

function common.merkmalliste(input, zauber)
  local first = true
  local ret = ""
  if zauber ~= nil then
    for _, v in ipairs(zauber) do
      if first then
        first = false
      else
        ret = ret .. ", "
      end
      ret = ret .. v
    end
  end
  for _, v in ipairs(input) do
    if first then
      first = false
    else
      ret = ret .. ", "
    end
    local mt = getmetatable(v)
    if mt.name == "Daemonisch" or mt.name == "Elementar" then
      ret = ret .. (mt.name == "Daemonisch" and "Dämonisch" or "Elementar")
      if #v > 0 then
        ret = ret .. " ("
        local f = true
        for _, s in ipairs(v) do
          if f then f = false else ret = ret .. ", " end
          ret = ret .. s
        end
        ret = ret .. ")"
      end
    else
      ret = ret .. v
    end
  end
  return ret
end

local function merge(l, d)
  for i=1,2 do
    if d ~= nil and #d >= i then
        table.insert(l, d[i])
    else
        table.insert(l, "")
    end
  end
end

function common.proviant_vermoegen()
  local content = {}
  for i=1,common.current_page.ProviantVermoegen.Gezaehlt do
      local l = {}
      merge(l, data.Proviant[i])
      merge(l, data.Vermoegen[i])
      table.insert(content, l)
  end

  common.inner_rows(content, 4)
end

-- Truncating integer division
function common.div_trunc(numerator, denominator)
  local quotient = numerator // denominator
  if quotient < 0 and numerator % denominator ~= 0 then
    quotient = quotient + 1
  end
  return quotient
end


common.schaden = {}

function common.schaden.parse(input)
  local orig = input
  local n_start, n_end = string.find(input, "^[0-9]+")
  local num = nil
  if n_start ~= nil then
    num = string.sub(input, n_start, n_end)
    input = string.sub(input, n_end + 1)
  end
  if string.len(input) == 0 then
    if num == nil then
      return {num = 0}
    else
      return {num = num}
    end
  end
  local ret = {dice = num}
  local first = string.sub(input, 1, 1)
  if first == "W" or first == "w" then
    input = string.sub(input, 2)
    n_start, n_end = string.find(input, "^[0-9]+")
    if n_start == nil then
      ret.die = 6
    else
      ret.die = tonumber(string.sub(input, n_start, n_end))
      input = string.sub(input, n_end + 1)
    end
  else
    tex.error("ungültige TP: '" .. orig .. "' (W/w erwartet bei '" .. first .. "')")
  end
  if #input == 0 then
    ret.num = 0
    return ret
  end
  first = string.sub(input, 1, 1)
  if first ~= "+" and first ~= "-" then
    tex.error("ungültige TP: '" .. orig .. "' (+/- erwartet bei '" .. first .. "')")
  end
  ret.num = tonumber(input)
  if ret.num == nil then
    tex.error("ungültige TP: '" .. orig .. "' (ungültiger Summand: '" .. input .. "')")
  end
  return ret
end

function common.schaden.render(tp)
  if tp.dice ~= nil then
    tex.sprint(-2, tp.dice)
  end
  if tp.die ~= nil then
    if tp.die == 6 then
      tex.sprint([[\hspace{1pt}\faDiceD6\hspace{1pt}]])
    elseif tp.die == 20 then
      tex.sprint([[\hspace{1pt}\faDiceD20\hspace{1pt}]])
    else
      tex.sprint(-2, "W" .. tp.die)
    end
  end
  if tp.num ~= 0 then
    if tp.num < 0 then
      tex.sprint(-2, "−")
    elseif tp.die ~= nil then
      tex.sprint(-2, "+")
    end
    tex.sprint(-2, math.round(math.abs(tp.num)))
  end
end

function common.schaden.mod(tp, schwelle, schritt)
  local cur_kk = data:cur("KK")
  if cur_kk == "" then
    return nil
  end
  if schwelle ~= nil and schritt ~= nil and schritt > 0 then
    tp.num = tp.num + common.div_trunc(cur_kk - schwelle, schritt)
  end
  return tp
end

return common
