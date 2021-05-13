local i = 1
while i <= #arg do
  local name = arg[i]
  i = i + 1

  if name == "heldendokument.tex" then
    break
  end
end

if i > #arg then
  tex.error("missing argument for hero data!")
end

local function sum_and_round(items, pos)
  local cur = nil
  for i,v in ipairs(items) do
    if #v >= pos then
      local num = tonumber(v[pos])
      if num == nil then
        return ""
      elseif cur == nil then
        cur = num
      else
        cur = cur + num
      end
    end
  end
  return cur == nil and "" or string.format("%.0f", cur + 0.0001) -- round up at 0.5
end

local values = require(arg[i])

function values:grs()
  return sum_and_round(self.ruestung, 2)
end

function values:gbe()
  return sum_and_round(self.ruestung, 3)
end

return values