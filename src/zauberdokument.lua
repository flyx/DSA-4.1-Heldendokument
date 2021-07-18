local data = require("values")

local zauberdokument = {}

function zauberdokument.asp_regeneration()
  tex.sprint([[\rule{0pt}{1em}]])
  if string.len(data.Magie.Regeneration:get()) > 0 then
    tex.sprint(-2, data.Magie.Regeneration:get() .. " AsP")
  end
end

return zauberdokument