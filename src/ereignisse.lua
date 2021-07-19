local common = require("common")

local ereignisse = {}

local function delta(val)
  tex.sprint([[\texttt{]])
  if val < 0 then
    tex.sprint(-2, "–")
  elseif val > 0 then
    tex.sprint(-2, "+")
  end
  tex.sprint([[}&\texttt{]])
  tex.sprint(math.abs(val))
  tex.sprint([[}]])
end

function ereignisse.seite(start)
  local items = data.Ereignisse
  for i=start,start+57 do
    if items[i] == nil then
      for j=1,3 do
        tex.sprint("&")
      end
    else
      if items[i][6] then
        tex.sprint([[\bfseries]])
      end
      tex.sprint(-2, items[i][1])
      tex.sprint([[&]])
      delta(items[i][2])
      tex.sprint([[&]])
      tex.sprint(items[i][3][2])
      tex.sprint([[&]])
      delta(items[i][4])
      tex.sprint([[&\texttt{]])
      tex.sprint(items[i][5])
      tex.sprint([[}]])
    end
    if i ~= start+57 then
      tex.sprint([[\\ \hline]])
    end
  end
end

function ereignisse.render()
  local num = 1
  repeat
    tex.print(string.format([[\Ereignisliste{%d}]], (num-1)/58 + 1))
    tex.print("")
    num = num + 58
  until num > #data.Ereignisse
end

return ereignisse