local data = require("values")

local zauberdokument = {}

function zauberdokument.asp_regeneration()
  tex.sprint([[\rule{0pt}{1em}]])
  local val = data.Magie.Regeneration:get()
  if val ~= nil then
    tex.sprint(-2, val .. " AsP")
  end
end

return zauberdokument