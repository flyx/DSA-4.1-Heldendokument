require("stdext")

local skt = {
  spalte = {
    {n="A*", f=1}, {n="A", f=1, [31] = 50}, {n="B", f=2}, {n="C", f=3}, {n="D", f=4, [28] = 170, [31] = 200}, {n="E", f=5, [8] = 48}, {n="F", f=7.5, [30] = 350, [31] = 375}, {n="G", f=10, [30] = 480, [31] = 500}, {n="H", f=20, [2] = 35, [6] = 140, [24] = 720, [27] = 830, [31] = 1000}
  },
  faktor = {
    {1/2, "1/2"},
    {9/16, "9/16"},
    {3/4, "3/4"},
    {1, "1"},
    {3/2, "3/2"},
  },
}

setmetatable(skt.faktor, {
  __index = function(self, key)
    if type(key) == "string" then
      for _, v in ipairs(self) do
        if key == v[2] then
          return v
        end
      end
    end
    return rawget(self, key)
  end
})

function skt.spalte:num(name)
  for i=1,#self do
    if self[i].n == name then
      return i
    end
  end
end

function skt.spalte:name(index)
  if index <= 0 then
    index = 1
  elseif index > #self then
    index = #self
  end
  return self[index].n
end

function skt.spalte:effektiv(basis, zielwert, methode)
  local index = self:num(basis)
  if methode == "SE" or methode == "Lehrmeister" then
    index = index - 1
  elseif methode == "Selbststudium" then
    index = index + (zielwert > 10 and 2 or 1)
  end
  return self:name(index)
end

function skt.faktor:apply(value)
  return math.round(value * self[1])
end

for _, f in ipairs(skt.faktor) do
  f.apply = skt.faktor.apply
end

function skt:kosten(spalte, zielwert)
  local index = self.spalte:num(spalte)
  zielwert = math.min(zielwert, 31)
  if zielwert <= 0 then
    return 5 * math.round(self.spalte[index].f)
  end
  if index == 1 then
    return math.max(self:kosten("A", zielwert) - 2, 1)
  end
  local explicit = self.spalte[index][zielwert]
  if explicit ~= nil then
    return explicit
  end
  local val = math.round(0.8 * self.spalte[index].f * zielwert^1.2)

  if val > 200 then
    val = math.round(val / 10) * 10
  elseif val > 50 then
    val = math.round(val / 5) * 5
  end
  return val
end

return skt
