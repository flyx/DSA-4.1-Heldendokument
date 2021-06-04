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

function common.inner_rows(v, num_items, num_rows, optional_addition)
  if num_rows == nil then
    num_rows = #v
  end
  if #v > 0 then
    local my_row = num_items > 1 and common.fixed_length_row(num_items, false) or common.row
    for i=1,num_rows do
      if i > #v then
        if optional_addition ~= nil and #v + #(v[optional_addition]) <= num_rows
            and i <= #v + #(v[optional_addition]) then
          my_row(v[optional_addition][i - #v])
        elseif num_items > 1 then
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

function common.labelled_rows(v, label, size)
  if not size then
    size = "footnotesize"
  end
  for i, item in ipairs(v) do
    if i == 1 then
      tex.sprint(string.format([[\textmansontt{\%s\bfseries ]], size))
      tex.sprint(-2, label)
      tex.sprint([[}\hspace{5pt}]])
    else
      tex.sprint([[\relax]])
    end
    tex.sprint(-2, item)
    if i ~= #v then
      tex.sprint([[\\ \hline]])
    end
  end
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

function common.round(v)
  return string.format("%.0f", v + 0.0001) -- round up at 0.5
end

function common.kenntnis(name, items)
  tex.sprint([[{\normalfont\normalsize\begin{tabular}{p{3.7cm}@{(}x{3.7cm}@{):\hspace{1pt}}x{0.7cm}}]])
  for i, item in ipairs(items) do
    local vals = {unpack(item)}
    while #vals < 2 do
      table.insert(vals, "")
    end
    tex.sprint(string.format([[\large\mansontt\bfseries %s & %s & \cellcolor{white}%s \\]], name, unpack(vals)))
    if i ~= #items then
      tex.sprint([[\multicolumn{3}{c}{}\\[-9pt] ]])
    end
  end
  tex.sprint([[\end{tabular}}]])
end

local value_line = {
  labels = {
    AT = "AT-Basiswert", PA = "PA-Basiswert", FK = "FK-Basiswert",
    INI = "Initiative-Basiswert", BE = {"BE", data.ruestung.be},
    AP_Gesamt = {"Gesamt", data.ap.gesamt},
    AP_Eingesetzt = {"Eingesetzt", data.ap.eingesetzt},
    AP_Guthaben = {"Guthaben", data.ap.guthaben}
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
  front       = "frontseite.tex",
  talente     = "talentbogen.tex",
  kampf       = "kampfbogen.tex",
  ausruestung = "ausruestung.tex",
  liturgien   = "liturgien.tex",
  zauberdok   = "zauberdokument.tex",
  zauber      = "zauberliste.tex"
}

function common.pages()
  for i, p in ipairs(data.dokument.seiten) do
    tex.print("\\input{" .. pages_source[p] .. "}")
  end
end

return common