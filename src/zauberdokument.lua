local data = require("values")
local common = require("common")

local zauberdokument = {}

function zauberdokument.asp_regeneration()
  tex.sprint([[\rule{0pt}{1em}]])
  if data:cur("KL") ~= "" and data:cur("IN") ~= "" then
    local val = common.schaden.parse("1W6")
    local ar = data.Vorteile.Magisch.AstraleRegeneration
    if ar ~= nil then
      val.num = val.num + ar
    end
    if data.Nachteile.Magisch.AstralerBlock then
      val.num = val.num - 1
    end
    local mr = data.SF.Magisch.MeisterlicheRegeneration
    if mr ~= nil then
      val.num = val.num + 3 + math.floor((data:cur(mr) + 1)/3)
      tex.sprint(-2, val.num)
    else
      local reg = data.SF.Magisch:getlist("Regeneration")
      for i=1,2 do
        if reg[i] then
          val.num = val.num + 1
        end
      end
      common.schaden.render(val)
    end
    tex.sprint(" AsP")
  end
end

return zauberdokument