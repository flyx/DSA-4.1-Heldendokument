local data = require("values")

local talentbogen = {}

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
    return "Sonderfertigkeiten (außer Kampf)", 1, 0, 1, -1, "", ""
  elseif name == "Kampf" then
    return "Kampftechniken", 3, 4.542, 7, 3,
        [[|x{0.4cm}|x{1cm}|x{0.65cm}@{\dotsep}x{0.65cm}|y{0.55cm}@{\hskip 0.1cm}]],
        [[& \Th{BE} & \Th{AT} & \Th{PA} & \multicolumn{1}{c}{\Th{TaW}}]]
  elseif name == "Koerper" then
    return "Körperliche Talente", 5, 4.6, 7, 5,
        [[|x{0.55cm}@{\dotsep}x{0.55cm}@{\dotsep}x{0.55cm}|x{1.0cm}|y{0.55cm}@{\hskip 0.1cm}]],
        [[& \Th{BE} & \multicolumn{1}{c}{\Th{TaW}}]]
  elseif name == "Sprachen" then
    return "Sprachen & Schriften", 2, 6.8, 4, -1,
        [[|x{0.9cm}|y{0.55cm}@{\hskip 0.1cm}]],
        [[& \Th{Komp} & \multicolumn{1}{c}{\Th{TaW}}]]
  else
    return self.labels[name], 5, 5.92, 6, -1,
        [[|x{0.5cm}@{\dotsep}x{0.5cm}@{\dotsep}x{0.5cm}|y{0.55cm}@{\hskip 0.1cm}]],
        [[& \multicolumn{1}{c}{\Th{TaW}}]]
  end
end

function gruppe.render(self, g, start_white)
  local name = getmetatable(g).name
  if #(data.Talente[name]) == 0 and g() == 0 then
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
  while #data.Talente[name] < g() do
    table.insert(data.Talente[name], {})
  end
  for i, v in ipairs(data.Talente[name]) do
    local vals = {}
    for j, w in ipairs(v) do
      local input = w()
      if j == 1 then
        if v.spez ~= nil then
          input = input .. " ("
          for k, s in ipairs(v.spez) do
            if k > 1 then
              input = input .. ", "
            end
            input = input .. s
          end
          input = input .. ")"
        end
      elseif j == be_col then
        if input == "-" then
          input = "–"
        else
          input = string.gsub(string.gsub(input, "x", "×"), "-", "−")
        end
      end
      table.insert(vals, input)
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

function talentbogen.num_rows(g)
  local ret = g()
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
  for i, g in ipairs(common.current_page) do
    local v = talentbogen.num_rows(g)
    if v > 0 then
      total_rows = total_rows + v + 2
    end
  end
  local col_rows = total_rows / 2
  local total_printed_rows = 0
  local start_white = true
  local swapped = false
  for i, g in ipairs(common.current_page) do
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

    local gruppe_id = getmetatable(g).name

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