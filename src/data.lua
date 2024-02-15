local i = 1
while i <= #arg do
  local name = arg[i]
  i = i + 1

  if name == "heldendokument.tex" or name == "heldendokument-weiss.tex" then
	break
  end
end

if i < #arg then
  tex.error("zu viele Argumente. Erstes überflüssiges Argument: '" .. tostring(arg[i+1]) .. "'")
end

return assert(loadfile("values.lua", "t"))(arg[i])
