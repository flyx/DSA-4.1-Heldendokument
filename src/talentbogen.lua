local data = require("values")

local talentbogen = {}

local gruppe = {
  labels = {
    gesellschaft = "Gesellschaftliche Talente",
    natur = "Naturtalente",
    wissen = "Wissenstalente",
    handwerk = "Handwerkstalente",
    gaben    = "Gaben",
    begabungen = "Übernatürliche Begabungen"
  }
}

function gruppe.spec(self, name)
  if name == "sonderfertigkeiten" then
    return "Sonderfertigkeiten (außer Kampf)", 1, 0, 1, -1, "", ""
  elseif name == "kampf" then
    return "Kampftechniken", 3, 4.542, 7, 3,
        [[|x{0.4cm}|x{1cm}|x{0.65cm}@{\dotsep}x{0.65cm}|y{0.55cm}@{\hskip 0.1cm}]],
        [[& \Th{BE} & \Th{AT} & \Th{PA} & \multicolumn{1}{c}{\Th{TaW}}]]
  elseif name == "koerper" then
    return "Körperliche Talente", 5, 4.6, 7, 5,
        [[|x{0.55cm}@{\dotsep}x{0.55cm}@{\dotsep}x{0.55cm}|x{1.0cm}|y{0.55cm}@{\hskip 0.1cm}]],
        [[& \Th{BE} & \multicolumn{1}{c}{\Th{TaW}}]]
  elseif name == "sprachen" then
    return "Sprachen & Schriften", 2, 6.8, 4, -1,
        [[|x{0.9cm}|y{0.55cm}@{\hskip 0.1cm}]],
        [[& \Th{Komp} & \multicolumn{1}{c}{\Th{TaW}}]]
  else
    return self.labels[name], 5, 5.92, 6, -1,
        [[|x{0.5cm}@{\dotsep}x{0.5cm}@{\dotsep}x{0.5cm}|y{0.55cm}@{\hskip 0.1cm}]],
        [[& \multicolumn{1}{c}{\Th{TaW}}]]
  end
end

function gruppe.render(self, name, start_white)
  if #(data.talente[name]) == 0 then
    return
  end
  label, title_col_len, item_name_len, num_items, be_col, col_spec, headers = self:spec(name)
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
  tex.sprint(num_items)
  tex.sprint([[}{l}{\multirow{2}{*}{\Large \textmansontt{\bfseries ]])
  tex.sprint(-2, label)
  tex.sprint([[}}} \\ \restorearstrut]])

  tex.sprint([[\multicolumn{]])
  tex.sprint(title_col_len)
  tex.sprint("}{l|}{}")
  tex.sprint(headers)

  tex.sprint([[\\ \hline]])
  for i, v in ipairs(data.talente[name]) do
    local vals = {unpack(v)}
    if be_col ~= -1 and #vals >= be_col then
      -- replace dash with proper minus and x with proper times.
      local be = vals[be_col]
      be = string.gsub(string.gsub(be, "x", "×"), "-", "−")
      vals[be_col] = be
    end
    if v.spez ~= nil then
      vals[1] = vals[1] .. " ("
      for i, s in ipairs(v.spez) do
        if i > 1 then
          vals[1] = vals[1] .. ", "
        end
        vals[1] = vals[1] .. s
      end
      vals[1] = vals[1] .. ")"
    end
    if num_items == 1 then
      common.row(vals)
    else
      common.fixed_length_row(num_items, true)(vals)
    end
    tex.sprint([[\\ \hline]])
  end
  tex.print([[\end{NiceTabular}]])
  tex.print("")
  tex.print([[\vspace{1.9pt}]])
end

function talentbogen.num_rows(name)
  local ret = 6
  if name == "sonderfertigkeiten" then
    if data.sf.allgemein.zeilen ~= nil then
      ret = data.sf.allgemein.zeilen
    end
  else
    ret = #data.talente[name]
  end
  return ret
end

function talentbogen.gruppen()
  local total_rows = 0
  for i, talent in ipairs(data.dokument.talentreihenfolge) do
    local v = talentbogen.num_rows(talent)
    if v > 0 then
      total_rows = total_rows + v + 2
    end
  end
  local col_rows = total_rows / 2
  local total_printed_rows = 0
  local start_white = true
  local swapped = false
  for i, talent in ipairs(data.dokument.talentreihenfolge) do
    local rows_to_print = talentbogen.num_rows(talent)
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

    if talent == "sonderfertigkeiten" then
      tex.print([[\begin{NiceTabular}{p{.5\textwidth-.5\columnsep-.5\fboxsep-1pt}}]])
      if start_white then
        tex.print([[\CodeBefore\rowcolors{3}{white}{gray!30}\Body]])
      else
        tex.print([[\CodeBefore\rowcolors{3}{gray!30}{white}\Body]])
      end
      tex.sprint([[\setarstrut{\scriptsize}\multicolumn{1}{l}{\multirow{2}{*}{\Large \textmansontt{\bfseries Sonderfertigkeiten}}} \\ \restorearstrut]])
      tex.sprint([[\\ \hline]])
      common.multiline_content({
        name="Sonderfertigkeiten", rows=rows_to_print - 2, baselinestretch=1.033}, data.sf.allgemein)
      tex.print([[\hline\end{NiceTabular}]])
      tex.print("")
      tex.print([[\vspace{1.9pt}]])
    else
      gruppe:render(talent, start_white)
    end
    if rows_to_print % 2 == 1 then
      start_white = not start_white
    end

    total_printed_rows = total_printed_rows + rows_to_print
  end
end


return talentbogen