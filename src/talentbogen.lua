local schema = require("schema")
local data = require("data")
local common = require("common")
require("stdext")

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
  elseif mt.name == "Meta" then
    talent.meta(value)
  else
    talent.sonstige(value)
  end
end

function talent.namecol(name, spez)
  tex.sprint(-2, name)
  if #spez > 0 then
    local i = 1
    if type(spez[i]) == "table" then
      tex.sprint([[\newline\hspace*{-4pt}]])
      i = i + 1
    else
      tex.sprint(" ")
    end
    tex.sprint([[(]])
    local first = true
    while i <= #spez do
      if first then first = false else tex.sprint(", ") end
      while type(spez[i]) == "table" do
        tex.sprint([[\newline]])
        i = i + 1
      end
      if i > #spez then break end
      tex.sprint(-2, spez[i])
      i = i + 1
    end
    tex.sprint(-2, ")")
  end
  tex.sprint([[\hfill]])
  for _, v in ipairs(data.Vorteile.Magisch:getlist("Meisterhandwerk")) do
    if v == name then
      tex.sprint([[\faHandSparkles]])
      break
    end
  end
  for _, v in ipairs(data.Mirakel.Plus) do
    if v == name then
      tex.sprint([[\faPlusCircle]])
      break
    end
  end
  for _, v in ipairs(data.Mirakel.Minus) do
    if v == name then
      tex.sprint([[\faMinusCircle]])
      break
    end
  end
end

function talent.be(value)
  if value == "-" or value == "" then
    return "–"
  else
    --  must use local, dumps second return value
    local s = string.gsub(string.gsub(value, "x", "×"), "-", "−")
    return s
  end
end

function talent.nah(v)
  tex.sprint([[& ]])
  tex.sprint([[\hspace{-8pt}]])
  talent.namecol(v.Name, v.Spezialisierungen)
  tex.sprint([[& ]])
  tex.sprint(-2, data:kampf_schwierigkeit(v))
  tex.sprint([[& ]])
  tex.sprint(-2, talent.be(v.BE))
  tex.sprint([[& ]])
  tex.sprint(-2, v.AT)
  tex.sprint([[& ]])
  local pa = data.PA(v)
  if pa ~= nil then
    tex.sprint(-2, pa)
  end
  tex.sprint([[& ]])
  tex.sprint(-2, v.TaW)
end

function talent.fern(v, filler)
  for j = 1,3 do
    tex.sprint([[& ]])
    local content = v[j]
    if j == 1 then
      tex.sprint([[\hspace{-8pt}]])
      talent.namecol(content, v.Spezialisierungen)
    elseif j == 2 then
      tex.sprint(-2, data:kampf_schwierigkeit(v))
    elseif j == 3 then
      tex.sprint(-2, talent.be(content))
    else
      tex.sprint(-2, content)
    end
  end
  tex.sprint([[& \multicolumn{2}{c|}{]] .. filler .. "} & ")
  tex.sprint(-2, v[4])
end

function talent.koerper(v)
  for j = 1,6 do
    tex.sprint([[& ]])
    local content = v[j]
    if j == 1 then
      tex.sprint([[\hspace{-8pt}]])
      talent.namecol(content, v.Spezialisierungen)
    elseif j == 5 then
      tex.sprint(-2, talent.be(content))
    else
      tex.sprint(-2, content)
    end
  end
end

function talent.sprache(v, prefix)
  tex.sprint([[& \hspace{-8pt}\faComments{} ]] .. prefix)
  talent.namecol(v.Name, v.Dialekt)
  tex.sprint(" & ")
  if string.len(v.Name) > 0 then
    tex.sprint(-2, data:sprache_schwierigkeit(v))
  end
  for i=2,3 do
    tex.sprint("& ")
    tex.sprint(-2, v[i])
  end
end

function talent.schrift(v, mod)
  tex.sprint([[& \hspace{-8pt}\faBookOpen{} ]])
  tex.sprint(-2, v[1])
  tex.sprint(" & ")
  if v.Steigerungsspalte ~= nil then
    tex.sprint(-2, data:schrift_schwierigkeit(v))
  end
  for i=3,4 do
    tex.sprint("& ")
    tex.sprint(-2, v[i])
  end
end

function talent.meta(v)
  tex.sprint([[& \hspace{-8pt}\faShapes{} ]])
  tex.sprint(-2, v[1])
  tex.sprint(" & ")
  for i=2,4 do
    tex.sprint(-2, v[i])
    tex.sprint(" & ")
  end
  local sum = 0
  for _, tn in ipairs(v[5]) do
    for _, g in ipairs({"Gaben", "Kampf", "Koerper", "Gesellschaft", "Natur", "Wissen", "SprachenUndSchriften", "Handwerk"}) do
      for _, t in ipairs(data.Talente[g]) do
        if t.Name == tn then
          if type(t.TaW) == "number" and sum ~= nil then
            sum = sum + t.TaW
          else
            sum = nil
          end
          goto found
        end
      end
    end
    tex.error("[Naturtalente] Metatalent '" .. v[1] .. "' referenziert unbekanntes Talent '" .. tn .. "'")
    ::found::
  end
  if sum ~= nil and #v[5] > 0 then
    tex.sprint(-2, math.round(sum / #v[5]))
  end
end

function talent.sonstige(v)
  for i=1,5 do
    tex.sprint(" & ")
    if i == 1 then
      tex.sprint([[\hspace{-8pt}]])
      talent.namecol(v.Name, v.Spezialisierungen)
    else
      tex.sprint(-2, v[i])
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
        [[Ix{0.4cm}Ix{1cm}Ix{0.65cm}@{\dotsep}x{0.65cm}Iy{0.55cm}@{\hskip 0.1cm}]],
        [[& \Th{BE} & \Th{AT} & \Th{PA} & \multicolumn{1}{c}{\Th{TaW}}]]
  elseif name == "SprachenUndSchriften" then
    return "Sprachen & Schriften", nil, 3, 6.245, 5,
        [[Ix{0.4cm}Ix{0.9cm}Iy{0.55cm}@{\hskip 0.1cm}]],
        [[& \Th{Komp} & \multicolumn{1}{c}{\Th{TaW}}]]
  end
  local spalte = data:tgruppe_schwierigkeit(name)
  if name == "Koerper" then
    return "Körperliche Talente", spalte, 5, 4.6, 7,
        [[Ix{0.55cm}@{\dotsep}x{0.55cm}@{\dotsep}x{0.55cm}Ix{1.0cm}Iy{0.55cm}@{\hskip 0.1cm}]],
        [[& \Th{BE} & \multicolumn{1}{c}{\Th{TaW}}]]
  else
    return self.labels[name], spalte, 5, 5.92, 6,
        [[Ix{0.5cm}@{\dotsep}x{0.5cm}@{\dotsep}x{0.5cm}Iy{0.55cm}@{\hskip 0.1cm}]],
        [[& \multicolumn{1}{c}{\Th{TaW}}]]
  end
end

local talentbogen = {}

function gruppe.render(self, g, start_white)
  local name = getmetatable(g).name
  g = g:get()
  if #(data.Talente[name]) == 0 and g == 0 then
    return
  end

  local label, spalte, title_col_len, item_name_len, num_items, col_spec, headers = self:spec(name)

  tex.sprint([[\begin{NiceTabular}{p{0.2cm}I>{\setlength{\baselineskip}{1.033\baselineskip}\leftskip=8pt}p{]])
  tex.sprint(item_name_len .. "cm")
  tex.sprint("}")
  tex.sprint(col_spec)
  tex.print("}")

  if start_white then
    tex.print([[\CodeBefore\rowcolors{3}{white}{gray!30}]])
  else
    tex.print([[\CodeBefore\rowcolors{3}{gray!30}{white}]])
  end
  tex.sprint([[\Body]])

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
    tex.sprint([[\\ \hline]])
  end
  for i = talentbogen.rows_to_be_rendered(data.Talente[name]) + 1, g do
    for j=2,num_items do
      tex.sprint("&")
    end
    tex.sprint([[\\ \hline]])
  end

  tex.print([[\end{NiceTabular}]])
  tex.print("")
  tex.print([[\vspace{1.9pt}]])
end

function talentbogen.rows_to_be_rendered(l)
  local ret = #l
  for _, t in ipairs(l) do
    local s = t.Spezialisierungen
    if s ~= nil then
      for _, v in ipairs(s) do
        if type(v) == "table" then
          ret = ret + 1
        end
      end
    end
  end
  return ret
end

function talentbogen.num_rows(g)
  local ret = g:get()
  local name = getmetatable(g).name
  if name ~= "Sonderfertigkeiten" then
    local rendered = talentbogen.rows_to_be_rendered(data.Talente[name])
    if rendered > ret then
      ret = rendered
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
        name="Sonderfertigkeiten", rows=rows_to_print - 2, baselinestretch=1.033}, data.SF.Allgemein)
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
