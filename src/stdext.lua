-- Rounds to the nearest integer. Halfway cases are arounded _away_ from zero.
function math.round(x)
  local integral, fractional = math.modf(x)
  if fractional >= 0.5 then
    return integral + 1
  elseif fractional <= -0.5 then
    return integral - 1
  end
  return integral
end
