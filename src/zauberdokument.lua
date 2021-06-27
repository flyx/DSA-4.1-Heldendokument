local data = require("values")

local zauberdokument = {}

function zauberdokument.asp_regeneration()
  tex.sprint([[\rule{0pt}{1em}]])
  if string.len(data.Magie.Regeneration()) > 0 then
    tex.sprint(-2, data.Magie.Regeneration() .. " AsP")
  end
end

return zauberdokument