local all = require("values")

local function p(fstr, ...)
  tex.sprint(string.format(string.gsub(fstr, "\n", ""), unpack({...})))
end

local function row(...)
  for i, s in ipairs({...}) do
    if i ~= 1 then
      tex.print([[& ]])
    end
    tex.sprint(-2, s)
  end
end

local labels ={
  gesellschaft = "Gesellschaftliche Talente",
  natur = "Naturtalente",
  wissen = "Wissenstalente",
  handwerk = "Handwerkstalente",
  gaben    = "Gaben",
  begabungen = "Übernatürliche Begabungen"
}

local function tgroup_spec(name)
  if name == "sonderfertigkeiten" then
    return "Sonderfertigkeiten (außer Kampf)", 1, 0, 1, "", ""
  elseif name == "kampf" then
    return "Kampftechniken", 3, 4.542, 7,
        [[|x{0.4cm}|x{1cm}|x{0.65cm}@{\dotsep}x{0.65cm}|y{0.55cm}@{\hskip 0.1cm}]],
        [[& \Th{BE} & \Th{AT} & \Th{PA} & \multicolumn{1}{c}{\Th{TaW}}]]
  elseif name == "koerper" then
    return "Körperliche Talente", 5, 4.6, 7,
        [[|x{0.55cm}@{\dotsep}x{0.55cm}@{\dotsep}x{0.55cm}|x{1.0cm}|y{0.55cm}@{\hskip 0.1cm}]],
        [[& \Th{BE} & \multicolumn{1}{c}{\Th{TaW}}]]
  elseif name == "sprachen" then
    return "Sprachen & Schriften", 2, 6.8, 4,
        [[|x{0.9cm}|y{0.55cm}@{\hskip 0.1cm}]],
        [[& \Th{Komp} & \multicolumn{1}{c}{\Th{TaW}}]]
  else
    return labels[name], 5, 5.92, 6,
        [[|x{0.5cm}@{\dotsep}x{0.5cm}@{\dotsep}x{0.5cm}|y{0.55cm}@{\hskip 0.1cm}]],
        [[& \multicolumn{1}{c}{\Th{TaW}}]]
  end
end

local function fixed_length_row(l, prepend_empty)
  return function(v)
    desired_num = prepend_empty and l - 1 or l
    values = {unpack(v, 1, desired_num)}
    while #values < desired_num do
      table.insert(values, "")
    end
    if prepend_empty then
      row("", unpack(values))
    else
      row(unpack(values))
    end
  end
end

local render = {}

local held_labels = {
  name="Name", gp="GP-Basis", rasse="Rasse", kultur="Kultur", profession="Profession",
  geschlecht="Geschlecht", tsatag="Tsatag", groesse="Größe",
  gewicht="Gewicht", haarfarbe="Haarfarbe", augenfarbe="Augenfarbe",
  stand="Stand", sozialstatus="Sozialstatus", titel="Titel"
}

local function local_heading(label)
  tex.sprint([[\textmansontt{\textbf{]])
  tex.sprint(-2, label)
  tex.sprint([[}}]])
end

function render.held_top()
  for i,n in ipairs({"name", "gp", "rasse", "kultur", "profession"}) do
    local_heading(held_labels[n])
    tex.sprint("&")
    if i == 5 then
      tex.sprint([[\multicolumn{3}{l}{]])
      tex.sprint(-2, all.held[n])
      tex.sprint("}")
    else
      tex.sprint(-2, all.held[n])
    end
    if i % 2 == 0 then
      tex.sprint([[\\ \hline]])
    elseif i < 5 then
      tex.sprint("&")
    end
  end
end

function render.held_links()
  for i,n in ipairs({"geschlecht", "tsatag", "groesse", "gewicht",
                     "haarfarbe", "augenfarbe"}) do
    if i ~= 1 then
      tex.sprint([[\\ \hline]])
    end
    local_heading(held_labels[n])
    tex.sprint("&")
    tex.sprint(-2, all.held[n])
  end
end

function render.held_rechts()
  for i,n in ipairs({"stand", "sozialstatus", "titel"}) do
    if i ~= 1 then
      tex.sprint([[\\ \hline]])
    end
    local_heading(held_labels[n])
    tex.sprint("&")
    local v = all.held[n]
    if type(v) == "table" then
      local vals = {unpack(v, 1, 4)}
      while #vals < 4 do
        table.insert(vals, "")
      end
      for j=1,4 do
        if j > 1 then
          tex.sprint([[\\ \hline\multicolumn{2}{l}{]])
        end
        tex.sprint(-2, vals[j])
        if j > 1 then
          tex.sprint("}")
        end
      end
    else
      tex.sprint(-2, v)
    end
  end
end

local eig_front_label = {
  MU = "Mut", KL = "Klugheit", IN = "Intuition", CH = "Charisma",
  FF = "Fingerfertigkeit", GE = "Gewandtheit", KO = "Konstitution", KK = "Körperkraft",
  GS = "Geschwindigkeit",
  LE = {"Lebensenergie", "(KO+KO+KK)/2"}, AU = {"Ausdauer", "(MU+KO+GE)/2"},
  AE = {"Astralenergie", "(MU+IN+CH)/2"}, KE = {"Karmaenergie", ""},
  MR = {"Magieresistenz", "(MU+KL+KO)/5"}, INI = {"Ini-Basiswert", "(MU+MU+IN+GE)/5"},
  AT = {"AT-Basiswert", "(MU+GE+KK)/5"}, PA = {"PA-Basiswert", "(IN+GE+KK)/5"},
  FK = {"FK-Basiswert", "(IN+FF+KK)/5"}
}

function render.eig_links()
  for i, e in ipairs({"MU", "KL", "IN", "CH", "FF", "GE", "KO", "KK", "GS"}) do
    if i ~= 1 then
      tex.sprint([[\\]])
    end
    tex.sprint((i == 1 or i == 9) and [[\Xhline{2\arrayrulewidth}]] or [[\hline]])
    tex.sprint([[\small\mansontt\bfseries]])
    tex.sprint(-2, eig_front_label[e])
    for j=1,3 do
      tex.sprint("&")
      if j == 3 then
        tex.sprint([[\cellcolor{white}]])
      end
      tex.sprint(-2, all.eig[e][j])
    end
  end
end

function render.eig_rechts()
  for i,e in ipairs({"LE", "AU", "AE", "KE", "MR", "INI", "AT", "PA", "FK"}) do
    if i == 1 then
      tex.sprint([[\Xhline{2\arrayrulewidth}]])
    elseif i < 8 then
      tex.sprint([[\\\hline]])
    else
      tex.sprint([[\\\cline{1-4}]])
    end
    tex.sprint([[\small\bfseries\textmansontt{]])
    local info = eig_front_label[e]
    tex.sprint(-2, info[1])
    tex.sprint([[} \hspace*{\fill} \tiny ]])
    tex.sprint(-2, info[2])
    tex.sprint([[ \hspace{3pt} ]])
    for j=1,5 do
      if i <= 5 or j ~= 5 then
        tex.sprint("&")
      end
      if i > 5 and j > 3 then
        if j == 4 then
          if i == 6 then
            p([[\multicolumn{2}{l}{
              \hspace{0.1cm}\tiny\normalfont\raisebox{2pt}{
              \begin{minipage}{2.3cm}
                  \directlua{r.checkbox(v.sf.kampfreflexe)} Kampfreflexe (INI+4) \\[1.5pt]
                  \directlua{r.checkbox(v.sf.kampfgespuer)} Kampfgespür (INI+2)
              \end{minipage}
            }}]])
          elseif i == 7 then
            tex.sprint([[\multicolumn{2}{c}{\scriptsize \raisebox{-0.45ex}{\textmansontt{\textbf{Wundschwelle}}}}]])
          elseif i == 8 then
            tex.sprint([[\multicolumn{2}{c}{\tiny\normalfont \raisebox{2ex}[0pt]{(KO/2)+Modifikator}}]])
          else
            p([[\multicolumn{2}{c}{\raisebox{0.2cm}[1em]{
              \bgroup\fboxsep=0pt\colorbox{white}{\parbox[t][1.5em]{1cm}{\rule{0pt}{0.9em}\centering]])
            tex.sprint(-2, all.eig.WS)
            tex.sprint([[}}\egroup}}]])
          end
        end
      else
        if j == 3 then
          tex.sprint([[\cellcolor{white}]])
        end
        tex.sprint(-2, all.eig[e][j])
      end
    end
  end
end

function render.header_row(height, font, ...)
  tex.sprint(string.format([[\setarstrut{\%s}]], height))
  for i, v in ipairs({...}) do
    if i ~= 1 then
      tex.sprint("&")
    end

    if type(v) == "table" then
      tex.sprint(string.format([[\multicolumn{%s}{%s|}{]], v[1], v[2]))
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

function render.talentgruppe(name, start_white)
  if #(all.talente[name]) == 0 then
    return
  end
  label, title_col_len, item_name_len, num_items, col_spec, headers = tgroup_spec(name)
  if all.m_spalte and item_name_len > 0 then
    item_name_len = item_name_len - 0.4
    col_spec = col_spec .. "|x{0.4cm}"
    headers = headers .. [[ & \multicolumn{1}{|c}{\Th{M}}]]
    num_items = num_items + 1
  end
  if item_name_len == 0 then
    tex.print([[\begin{NiceTabular}{p{.5\textwidth-.5\columnsep-.5\fboxsep-1pt}}]])
  else
    tex.sprint([[\begin{NiceTabular}{p{0.2cm}|p{]])
    tex.sprint(item_name_len .. "cm")
    tex.sprint("}")
    tex.sprint(col_spec)
    tex.print("}")
  end
  if start_white then
    tex.print([[\CodeBefore\rowcolors{3}{white}{gray!30}\Body]])
  else
    tex.print([[\CodeBefore\rowcolors{3}{gray!30}{white}\Body]])
  end

  tex.sprint([[\setarstrut{\scriptsize}\multicolumn{]])
  tex.sprint(num_items)
  tex.sprint([[}{l}{\multirow{2}{*}{\Large \textmansontt{\bfseries ]])
  tex.sprint(-2, label)
  tex.sprint([[}}} \\ \restorearstrut]])
  if item_name_len > 0 then
    tex.sprint([[\multicolumn{]])
    tex.sprint(title_col_len)
    tex.sprint("}{l|}{}")
    tex.sprint(headers)
  end
  tex.sprint([[\\ \hline]])
  for i, v in ipairs(all.talente[name]) do
    if num_items == 1 then
      row(v)
    else
      fixed_length_row(num_items, true)(v)
    end
    tex.sprint([[\\ \hline]])
  end
  tex.print([[\end{NiceTabular}]])
  tex.print("")
  tex.print([[\vspace{1.9pt}]])
end

function render.talentgruppen()
  local total_rows = 0
  for i, talent in ipairs(all.dokument.talentreihenfolge) do
    local v = all.talente[talent]
    if #v > 0 then
      total_rows = total_rows + #v + 2
    end
  end
  local col_rows = total_rows / 2
  local total_printed_rows = 0
  local start_white = true
  local swapped = false
  for i, talent in ipairs(all.dokument.talentreihenfolge) do
    local rows_to_print = #all.talente[talent]
    if rows_to_print > 0 then
      rows_to_print = rows_to_print + 2
    end
    --  check if the table to be printed will be the first in the second column.
    --  if so, force starting with a white column again.
    if not swapped and (col_rows - total_printed_rows) < rows_to_print/2 then
      start_white = true
      swapped = true
    end

    r.talentgruppe(talent, start_white)
    if rows_to_print % 2 == 1 then
      start_white = not start_white
    end

    total_printed_rows = total_printed_rows + rows_to_print
  end
end

local function pad_value(t, i)
  tex.sprint([[\parbox[c][1.67em]{\textwidth-\tabcolsep}{\normalfont ]])
  if i <= #t then
    tex.sprint(-2, t[i])
  end
  tex.sprint[[}]]
end

function render.padded_values(t, max_items, name)
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

function render.inner_rows(v, num_items, num_rows, optional_addition)
  if num_rows == nil then
    num_rows = #v
  end
  if #v > 0 then
    local my_row = num_items > 1 and fixed_length_row(num_items, false) or row
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

function render.labelled_rows(v, label, size)
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

function render.waffenlos(v)
  render.inner_rows({
    {"Raufen", "10", "3", "+0", unpack(v.raufen)},
    {"Ringen", "10", "3", "+0", unpack(v.ringen)}
  }, 7)
end

function render.checkbox(checked)
  tex.sprint(checked and [[$\boxtimes$]] or [[$\square$]])
end

function render.checkboxlist(items)
  for i, item in ipairs(items) do
    if type(item[1]) == "table" then
      for j = 1, #item[1] do
        render.checkbox(item[2][j])
        tex.sprint(-2, " " .. item[1][j])
        if j ~= #item[1] then
          tex.sprint("/ ")
        end
      end
    else
      render.checkbox(item[2])
      tex.sprint(-2, " " .. item[1])
    end
    if i ~= #items then
      tex.sprint([[,\hspace{5pt}]])
    end
  end
end

local function round(v)
  return string.format("%.0f", v + 0.0001) -- round up at 0.5
end

function render.energieleiste(label, val)
  tex.sprint(-2, label)
  num = tonumber(val)
  if num == nil then
    tex.sprint("&&&&")
  else
    for i=1,4 do
      tex.sprint("&")
      tex.sprint(-2, round(num/i))
    end
  end
  tex.sprint("&")
end

function render.optionalleiste(label, val)
  if val ~= "" and val ~= 0 then
    tex.sprint([[\\ \hline ]])
    tex.sprint(-2, label)
    tex.sprint("&")
    tex.sprint(-2, val)
    tex.sprint([[& \multicolumn{4}{l}{}]])
  end
end

function render.kenntnis(name, items)
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

local eig_labels = {
  AT = "AT-Basiswert", PA = "PA-Basiswert", FK = "FK-Basiswert",
  INI = "Initiative-Basiswert", BE = {"BE", all.ruestung.be},
  AP_Gesamt = {"Gesamt", all.ap.gesamt},
  AP_Eingesetzt = {"Eingesetzt", all.ap.eingesetzt},
  AP_Guthaben = {"Guthaben", all.ap.guthaben}
}
setmetatable(eig_labels, {
  __call = function(self, name)
    res = self[name]
    return res ~= nil and res or name
  end
})

function render.eig_header(items, hspace, v_len)
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
    local info = eig_labels(p)
    local label = type(info) == "table" and info[1] or info

    tex.sprint(-2, label)
    tex.sprint(":} &")
    if type(info) == "table" then
      tex.sprint(-2, info[2])
    else
      tex.sprint(-2, all.eig[p][3])
    end
  end
  tex.print([[\end{tabular}\egroup]])
end

local repr_lang = {
  Ach      = "Kristallomantisch",
  Alh      = "Alhanisch",
  Bor      = "Borbaradianisch",
  Dru      = "Druidisch",
  Dra      = "Drachisch",
  Elf      = "Elfisch",
  Fee      = "Feen",
  Geo      = "Geodisch",
  Gro      = "Grolmisch",
  ["Gül"]  = "Güldenländisch",
  Kob      = "Koboldisch",
  Kop      = "Kophtanisch",
  Hex      = "Hexisch",
  Mag      = "Gildenmagisch",
  Mud      = "Mudramulisch",
  Nac      = "Nachtalbisch",
  Srl      = "Scharlatanisch",
  Sch      = "Schelmisch"
}
setmetatable(repr_lang, {
  __call = function(self, name)
    res = self[name]
    return res ~= nil and res or name
  end
})

function render.reprs(list)
  for i, item in ipairs(list) do
    if i ~= 1 then
      tex.sprint(-2, ", ")
    end
    tex.sprint(-2, repr_lang(item))
  end
end

local merkmal_kurz = {
  Antimagie         = "Anti",
  ["Dämonisch"]     = "Dämon",
  Geisterwesen      = "Geist",
  Metamagie         = "Meta",
}
setmetatable(merkmal_kurz, {
  __call = function(self, name)
    res = self[name]
    return res ~= nil and res or name
  end
})

local schwierigkeit = {"A*", "A", "B", "C", "D", "E", "F", "G", "H"}

function schwierigkeit:num(input)
  for i=1,#self do
    if self[i] == input then
      return i
    end
  end
  tex.error("Unbekannte Komplexität: '" .. input .. "'")
end

function schwierigkeit:name(index)
  if index <= 0 then
    index = 1
  elseif index > #self then
    index = #self
  end
  return self[index]
end

function schwierigkeit:mod_from(merkmal, merkmale, delta)
  if type(merkmale) ~= "table" then
    tex.error("Folgender Wert muss eine Liste sein, ist aber keine: '" .. merkmale .. "'")
    return 0
  end
  for i, n in ipairs(merkmale) do
    if merkmal == n then
      return delta
    end
  end
  return 0
end

function schwierigkeit:malus_from(repr1, repr2)
  if repr2 == "Srl" or repr2 == "Sch" then
    return self:malus_from(repr2, repr1)
  end
  if repr1 == repr2 then
    return 0
  elseif repr1 == "Srl" then
    return repr2 == "Mag" and 1 or 2
  elseif repr1 == "Sch" then
    return repr2 == "Srl" and 2 or 3
  else
    return 2
  end
end

function schwierigkeit:malus_repr(repr, known)
  local min = 3
  for i,v in ipairs(known) do
    min = math.min(min, self:malus_from(repr, v))
  end
  return min
end

function schwierigkeit:mod(input, merkmale, repr, lernmod, haus)
  if math.min(string.len(input), string.len(repr)) == 0 then
    return ""
  end
  index = self:num(input)
  for i, merkmal in ipairs(merkmale) do
    index = index + self:mod_from(merkmal, all.magie.merkmale, -1)
    index = index + self:mod_from(merkmal, all.magie.begabungen, -1)
    index = index + self:mod_from(merkmal, all.magie.unfaehigkeiten, 1)
  end
  index = index + (haus and -1 or 0)
  index = index + (lernmod == nil and 0 or lernmod)
  index = index + self:malus_repr(repr, all.magie.repraesentationen)
  return self:name(index)
end

function render.zauberseite(start)
  for i=start,start+48 do
    local z = {}
    if i <= #all.zauber then
      z = {unpack(all.zauber[i])}
      z.haus = all.zauber[i].haus
      z.lernmod = all.zauber[i].lernmod
    end
    while #z < 9 do
      if #z == 7 then
        table.insert(z, {})
      else
        table.insert(z, "")
      end
    end
    if type(z[8]) ~= "table" then
      tex.error("Zauber '" .. z[2] .. "' hat keine Tabelle als Wert für Merkmale!")
    end
    for j=1,7 do
      tex.sprint(-2, z[j])
      tex.sprint("&")
    end
    for j, m in ipairs(z[8]) do
      if j ~= 1 then
        tex.sprint(-2, ", ")
      end
      tex.sprint(-2, merkmal_kurz(m))
    end
    tex.sprint("&")
    tex.sprint(-2, z[9])
    tex.sprint("&")
    tex.sprint(-2, schwierigkeit:mod(z[7], z[8], z[9], z.lernmod, z.haus))
    if z.haus then
      tex.sprint([[\hfill\faHome]])
    end
    if i ~= start+48 then
      tex.sprint([[\\ \hline]])
    end
  end
end

function render.zauber()
  local num = 1
  while num <= #all.zauber do
    tex.print(string.format([[\Zauberliste{%d}]], num))
    tex.print("")
    num = num + 49
  end
end

function render.asp_regeneration()
  tex.sprint([[\rule{0pt}{1em}]])
  if string.len(v.magie.asp_regeneration) > 0 then
    tex.sprint(-2, v.magie.asp_regeneration .. " AsP")
  end
end

local pages_source = {
  front       = "frontseite.tex",
  talente     = "talentbogen.tex",
  kampf       = "kampfbogen.tex",
  ausruestung = "ausruestung.tex",
  liturgien   = "liturgien.tex",
  zauberdok   = "zauberdokument.tex",
  zauber      = "zauberliste.tex"
}

function render.pages()
  for i, p in ipairs(all.dokument.seiten) do
    tex.print("\\input{" .. pages_source[p] .. "}")
  end
end

return render