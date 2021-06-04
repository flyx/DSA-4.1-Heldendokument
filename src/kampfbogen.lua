local data = require("values")
local common = require("common")

local kampfbogen = {}

function kampfbogen.waffenlos(v)
  common.inner_rows({
    {"Raufen", "10", "3", "+0", unpack(v.raufen)},
    {"Ringen", "10", "3", "+0", unpack(v.ringen)}
  }, 7)
end

function kampfbogen.energieleiste(label, val)
  tex.sprint(-2, label)
  num = tonumber(val)
  if num == nil then
    tex.sprint("&&&&")
  else
    for i=1,4 do
      tex.sprint("&")
      tex.sprint(-2, common.round(num/i))
    end
  end
  tex.sprint("&")
end

function kampfbogen.optionalleiste(label, val)
  if val ~= "" and val ~= 0 then
    tex.sprint([[\\ \hline ]])
    tex.sprint(-2, label)
    tex.sprint("&")
    tex.sprint(-2, val)
    tex.sprint([[& \multicolumn{4}{l}{}]])
  end
end

return kampfbogen