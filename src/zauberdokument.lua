local data = require("values")

local zauberdokument = {}

function zauberdokument.asp_regeneration()
  tex.sprint([[\rule{0pt}{1em}]])
  if string.len(data.magie.asp_regeneration) > 0 then
    tex.sprint(-2, data.magie.asp_regeneration .. " AsP")
  end
end

return zauberdokument