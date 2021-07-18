local schema = require("schema")
local data = require("values")

local talent = {}

function talent.render(value)
  local mt = getmetatable(value)
  if mt.name == "Nah" then
    talent.nah(value)
  elseif mt.name == "NahAT" or mt.name == "Fern" then
    talent.fern(value, mt.name == "Fern" and [[\faAngleDoubleRight]] or [[\faBahai]])
  elseif mt.name == "KoerperTalent" then
    talent.koerper(value)
  elseif mt.name == "Muttersprache" then
    talent.sprache(value, "Muttersprache: ")
  elseif mt.name == "Zweitsprache" then
    talent.sprache(value, "Zweitsprache: ")
  elseif mt.name == "Sprache" then
    talent.sprache(value, "")
  elseif mt.name == "Schrift" then
    talent.schrift(value)
  else
    talent.sonstige(value)
  end
end

function talent.spez(l)
  if #l > 0 then
    local ret = " ("
    for k, s in ipairs(l) do
      if k > 1 then
        ret = ret .. ", "
      end
      ret = ret .. s
    end
    ret = ret .. ")"
    return ret
  else
    return ""
  end
end

function talent.be(value)
  if value == "-" then
    return "–"
  else
    return string.gsub(string.gsub(value, "x", "×"), "-", "−")
  end
end

function talent.nah(v)
  for j = 1,6 do
    tex.sprint([[& ]])
    local content = v[j]
    if j == 1 then
      content = content .. talent.spez(v.Spezialisierungen)
    elseif j == 2 then
      content = data:kampf_schwierigkeit(v)
    elseif j == 3 then
      content = talent.be(content)
    end
    tex.sprint(-2, content)
  end
end

function talent.fern(v, filler)
  for j = 1,3 do
    tex.sprint([[& ]])
    local content = v[j]
    if j == 1 then
      content = content .. talent.spez(v.Spezialisierungen)
    elseif j == 2 then
      content = data:kampf_schwierigkeit(v)
    elseif j == 3 then
      content = talent.be(content)
    end
    tex.sprint(-2, content)
  end
  tex.sprint([[& \multicolumn{2}{c|}{]] .. filler .. "} & ")
  tex.sprint(-2, v[4])
end

function talent.koerper(v)
  for j = 1,6 do
    tex.sprint([[& ]])
    local content = v[j]
    if j == 1 then
      content = content .. talent.spez(v.Spezialisierungen)
    elseif j == 5 then
      content = talent.be(content)
    end
    tex.sprint(-2, content)
  end
end

function talent.sprache(v, prefix)
  tex.sprint([[& \faComments{} ]] .. prefix)
  tex.sprint(-2, v[1] .. talent.spez(v.Dialekt))
  tex.sprint(" & " .. data:sprache_schwierigkeit(v))
  for i=2,3 do
    tex.sprint("& ")
    tex.sprint(-2, v[i])
  end
end

function talent.schrift(v, mod)
  tex.sprint([[& \faBookOpen{} ]])
  tex.sprint(-2, v[1])
  tex.sprint(" & " .. data:schrift_schwierigkeit(v))
  for i=3,4 do
    tex.sprint("& ")
    tex.sprint(-2, v[i])
  end
end

function talent.sonstige(v)
  for i=1,5 do
    tex.sprint(" & ")
    tex.sprint(-2, v[i])
    if i == 1 then
      tex.sprint(-2, talent.spez(v.Spezialisierungen))
    end
  end
end

local gruppe = {
  labels = {
    Gesellschaft = "Gesellschaftliche Talente",
    Natur = "Naturtalente",
    Wissen = "Wissenstalente",
    Handwerk = "Handwerkstalente",
    Gaben    = "Gaben",
    Begabungen = "Übernatürliche Begabungen"
  }
}

function gruppe.spec(self, name)
  if name == "Sonderfertigkeiten" then
    return "Sonderfertigkeiten (außer Kampf)", nil, 1, 0, 1, "", ""
  elseif name == "Kampf" then
    return "Kampftechniken", nil, 3, 4.542, 7,
        [[|x{0.4cm}|x{1cm}|x{0.65cm}@{\dotsep}x{0.65cm}|y{0.55cm}@{\hskip 0.1cm}]],
        [[& \Th{BE} & \Th{AT} & \Th{PA} & \multicolumn{1}{c}{\Th{TaW}}]]
  elseif name == "SprachenUndSchriften" then
    return "Sprachen & Schriften", nil, 3, 6.245, 5,
        [[|x{0.4cm}|x{0.9cm}|y{0.55cm}@{\hskip 0.1cm}]],
        [[& \Th{Komp} & \multicolumn{1}{c}{\Th{TaW}}]]
  end
  local spalte = data:tgruppe_schwierigkeit(name)
  if name == "Koerper" then
    return "Körperliche Talente", spalte, 5, 4.6, 7,
        [[|x{0.55cm}@{\dotsep}x{0.55cm}@{\dotsep}x{0.55cm}|x{1.0cm}|y{0.55cm}@{\hskip 0.1cm}]],
        [[& \Th{BE} & \multicolumn{1}{c}{\Th{TaW}}]]
  else
    return self.labels[name], spalte, 5, 5.92, 6,
        [[|x{0.5cm}@{\dotsep}x{0.5cm}@{\dotsep}x{0.5cm}|y{0.55cm}@{\hskip 0.1cm}]],
        [[& \multicolumn{1}{c}{\Th{TaW}}]]
  end
end

function gruppe.render(self, g, start_white)
  local name = getmetatable(g).name
  g = g:get()
  if #(data.Talente[name]) == 0 and g == 0 then
    return
  end

  label, spalte, title_col_len, item_name_len, num_items, col_spec, headers = self:spec(name)
  if data.m_spalte and item_name_len > 0 then
    item_name_len = item_name_len - 0.4
    col_spec = col_spec .. "|x{0.4cm}"
    headers = headers .. [[ & \multicolumn{1}{|c}{\Th{M}}]]
    num_items = num_items + 1
  end

  tex.sprint([[\begin{NiceTabular}{p{0.2cm}|p{]])
  tex.sprint(item_name_len .. "cm")
  tex.sprint("}")
  tex.sprint(col_spec)
  tex.print("}")

  if start_white then
    tex.print([[\CodeBefore\rowcolors{3}{white}{gray!30}\Body]])
  else
    tex.print([[\CodeBefore\rowcolors{3}{gray!30}{white}\Body]])
  end

  tex.sprint([[\setarstrut{\scriptsize}\multicolumn{]])
  tex.sprint(spalte == nil and num_items or title_col_len - 1)
  tex.sprint([[}{l}{\multirow{2}{*}{\Large \textmansontt{\bfseries ]])
  tex.sprint(-2, label)
  tex.sprint([[}}}]])
  if spalte ~= nil then
    tex.sprint([[ & \multicolumn{]])
    tex.sprint(num_items - title_col_len + 1)
    tex.sprint([[}{l}{\multirow{2}{*}{\raisebox{-.5em}{\color{gray}\normalsize\bfseries ]])
    tex.sprint(-2, spalte)
    tex.sprint([[}}}]])
  end
  tex.sprint([[ \\ \restorearstrut]])
  tex.sprint([[\multicolumn{]])
  tex.sprint(title_col_len)
  tex.sprint("}{l|}{}")
  tex.sprint(headers)

  tex.sprint([[\\ \hline]])

  for i, v in ipairs(data.Talente[name]) do
    talent.render(v)
    if data.m_spalte and item_name_len > 0 then
      tex.sprint("&")
    end
    tex.sprint([[\\ \hline]])
  end
  for i = #data.Talente[name] + 1, g do
    for j=2,num_items do
      tex.sprint("&")
    end
    tex.sprint([[\\ \hline]])
  end

  tex.print([[\end{NiceTabular}]])
  tex.print("")
  tex.print([[\vspace{1.9pt}]])
end

local talentbogen = {}

function talentbogen.num_rows(g)
  local ret = g:get()
  local name = getmetatable(g).name
  if name ~= "Sonderfertigkeiten" then
    if #data.Talente[name] > ret then
      ret = #data.Talente[name]
    end
  end
  return ret
end

function talentbogen.gruppen()
  local total_rows = 0
  for i=1,#common.current_page.value do
    local g = common.current_page.value[i]
    local v = talentbogen.num_rows(g)
    if v > 0 then
      total_rows = total_rows + v + 2
    end
  end
  local col_rows = total_rows / 2
  local total_printed_rows = 0
  local start_white = true
  local swapped = false
  for i=1,#common.current_page.value do
    local g = common.current_page.value[i]
    local gruppe_id = getmetatable(g).name
    local rows_to_print = talentbogen.num_rows(g)
    --  size of heading
    if rows_to_print > 0 then
      rows_to_print = rows_to_print + 2
    end
    --  check if the table to be printed will be the first in the second column.
    --  if so, force starting with a white column again.
    if not swapped and (col_rows - total_printed_rows) < rows_to_print/2 then
      start_white = true
      swapped = true
    end

    if gruppe_id == "Sonderfertigkeiten" then
      tex.print([[\begin{NiceTabular}{p{.5\textwidth-.5\columnsep-.5\fboxsep-1pt}}]])
      if start_white then
        tex.print([[\CodeBefore\rowcolors{3}{white}{gray!30}\Body]])
      else
        tex.print([[\CodeBefore\rowcolors{3}{gray!30}{white}\Body]])
      end
      tex.sprint([[\setarstrut{\scriptsize}\multicolumn{1}{l}{\multirow{2}{*}{\Large \textmansontt{\bfseries Sonderfertigkeiten}}} \\ \restorearstrut]])
      tex.sprint([[\\ \hline]])
      common.multiline_content({
        name="Sonderfertigkeiten", rows=rows_to_print - 2, baselinestretch=1.033}, data.sf.Allgemein)
      tex.print([[\hline\end{NiceTabular}]])
      tex.print("")
      tex.print([[\vspace{1.9pt}]])
    else
      gruppe:render(g, start_white)
    end
    if rows_to_print % 2 == 1 then
      start_white = not start_white
    end

    total_printed_rows = total_printed_rows + rows_to_print
  end
end


return talentbogen