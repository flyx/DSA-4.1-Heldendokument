local data = require("values")
local common = require("common")

local kampfbogen = {}

local nahkampf_render = {
  [2]= {false, nil},
  [3]= {true, function(v)
    -- TODO
    tex.sprint(-2, 3)
  end}
}

function kampfbogen.nahkampf()
  for i,v in ipairs(data.nahkampf) do
    if i ~= 1 then
      tex.sprint([[\\\hline]])
    end
    local input_index = 1
    for j = 1,15 do
      if j ~= 1 then
        tex.sprint([[&]])
      end
      local spec = nahkampf_render[j]
      local advance, render = true, nil
      if spec ~= nil then
        advance, render = unpack(spec)
      end
      local val = v[input_index]
      if val ~= nil then
        if render == nil then
          tex.sprint(-2, val)
        else
          render(val)
        end
      end
      if advance then
        input_index = input_index + 1
      end
    end
  end
end

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