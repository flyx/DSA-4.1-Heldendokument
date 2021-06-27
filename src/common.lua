local data = require("values")

local common = {}

function common.p(fstr, ...)
  tex.sprint(string.format(string.gsub(fstr, "\n", ""), unpack({...})))
end

function common.row(...)
  for i, s in ipairs({...}) do
    if i ~= 1 then
      tex.print([[& ]])
    end
    tex.sprint(-2, s)
  end
end

function common.fixed_length_row(l, prepend_empty)
  return function(v)
    desired_num = prepend_empty and l - 1 or l
    values = {unpack(v, 1, desired_num)}
    while #values < desired_num do
      table.insert(values, "")
    end
    if prepend_empty then
      common.row("", unpack(values))
    else
      common.row(unpack(values))
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
  if #items + #t.magisch <= max_items then
    for i,v in ipairs(t.magisch) do
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

function common.inner_rows(v, num_items, num_rows)
  if num_rows == nil then
    num_rows = #v
  end
  if num_rows > 0 then
    local my_row = num_items > 1 and common.fixed_length_row(num_items, false) or common.row
    for i=1,num_rows do
      if i > #v then
        if num_items > 1 then
          my_row({})
        else
          my_row("")
        end
      else
        my_row(v[i])
      end
      if i ~= num_rows then
        tex.sprint([[\\ \hline\relax]])
      end
    end
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
      for i=1,#values do
        local v = values[i]
        if type(v) == "table" then
          if #v ~= 0 then
            tex.error("nested table in '" .. spec.name .. "' is not empty!")
          end
          if seen_empty or first then
            tex.sprint([[\newline]])
          else
            seen_empty = true
          end
        else
          if not first then
            if seen_empty then
              tex.sprint([[\newline]])
            else
              tex.sprint(", ")
            end
          end
          first = (v == "")
          seen_empty = false
          tex.sprint(-2, v)
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

function common.kenntnis(name, items, count)
  tex.sprint([[{\normalfont\normalsize\begin{tabular}{p{3.7cm}@{(}x{3.7cm}@{):\hspace{1pt}}x{0.7cm}}]])
  io.write(name .. " count: " .. tostring(#items))
  for i=1,count do
    local item = items[i]
    local vals
    if item == nil then
      vals = {"", ""}
    else
      vals = {item[1](), item[2]()}
    end
    tex.sprint(string.format([[\large\mansontt\bfseries %s & %s & \cellcolor{white}%s \\]], name, vals[1], vals[2]))
    if i ~= count then
      tex.sprint([[\multicolumn{3}{c}{}\\[-9pt] ]])
    end
  end
  tex.sprint([[\end{tabular}}]])
end

local value_line = {
  labels = {
    AT = "AT-Basiswert", PA = "PA-Basiswert", FK = "FK-Basiswert",
    INI = "Initiative-Basiswert", BE = {"BE", data:cur("BE")},
    AP_Gesamt = {"Gesamt", data.AP.Gesamt()},
    AP_Eingesetzt = {"Eingesetzt", data.AP.Eingesetzt()},
    AP_Guthaben = {"Guthaben", data.AP.Guthaben()}
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
  Zauberliste       = "zauberliste.tex"
}

function common.pages()
  for i,p in ipairs(data.Layout) do
    local pKind = getmetatable(p).name
    tex.print([[\directlua{common.current_page = data.Layout[]] .. tostring(i) .. "]}")
    tex.print("\\input{" .. pages_source[pKind] .. "}")
  end
end

function common.render_delta(input)
  if type(input) == "number" then
    if input < 0 then
      tex.sprint(-2, "−")
    elseif input > 0 then
      tex.sprint(-2, "+")
    end
    tex.sprint(common.round(math.abs(input)))
  else
    tex.sprint(-2, input)
  end
end

function common.list_known(input, known)
  local ret = {}
  for k,v in pairs(known) do
    if input[k] then
      table.insert(ret, v)
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
  for i=1,common.current_page.ProviantVermoegen.Gezaehlt() do
      local l = {}
      merge(l, data.Proviant[i])
      merge(l, data.Vermoegen[i])
      table.insert(content, l)
  end

  common.inner_rows(content, 4)
end

return common