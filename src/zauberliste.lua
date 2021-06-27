local schema = require("schema")
local data = require("values")

local repraesentationen = {
  label = {
    Ach      = "Kristallomantisch",
    Alh      = "Alhanisch",
    Bor      = "Borbaradianisch",
    Dru      = "Druidisch",
    Dra      = "Drachisch",
    Elf      = "Elfisch",
    Fee      = "Feen",
    Geo      = "Geodisch",
    Gro      = "Grolmisch",
    ["Gül"]  = "Güldenländisch",
    Kob      = "Koboldisch",
    Kop      = "Kophtanisch",
    Hex      = "Hexisch",
    Mag      = "Gildenmagisch",
    Mud      = "Mudramulisch",
    Nac      = "Nachtalbisch",
    Srl      = "Scharlatanisch",
    Sch      = "Schelmisch"
  }
}
setmetatable(repraesentationen.label, {
  __call = function(self, name)
    res = self[name]
    return res ~= nil and res or name
  end
})

function repraesentationen.render(self, list)
  for i, item in ipairs(list) do
    if i ~= 1 then
      tex.sprint(-2, ", ")
    end
    tex.sprint(-2, self.label(item()))
  end
end

local merkmale = {
  kurz = {
    Antimagie         = "Anti",
    Geisterwesen      = "Geist",
    Metamagie         = "Meta",
    Blakharaz         = "BLK",
    Belhalhar         = "BLH",
    Charyptoroth      = "CPT",
    Lolgramoth        = "LGM",
    Thargunitoth      = "TGT",
    Amazeroth         = "AMZ",
    Belshirash        = "BLS",
    Asfaloth          = "ASF",
    Tasfarelel        = "TSF",
    Belzhorash        = "BLZ",
    Agrimoth          = "AGM",
    Belkelel          = "BLL",
  }
}

setmetatable(merkmale.kurz, {
  __call = function(self, name)
    res = self[name]
    return res ~= nil and res or name
  end
})

local schwierigkeit = {"A*", "A", "B", "C", "D", "E", "F", "G", "H"}

function schwierigkeit:num(input)
  for i=1,#self do
    if self[i] == input then
      return i
    end
  end
  tex.error("Unbekannte Komplexität: '" .. input .. "'")
end

function schwierigkeit:name(index)
  if index <= 0 then
    index = 1
  elseif index > #self then
    index = #self
  end
  return self[index]
end

function schwierigkeit:mod_from(merkmal, merkmale, delta)
  if type(merkmale) ~= "table" then
    tex.error("Folgender Wert muss eine Liste sein, ist aber keine: '" .. merkmale .. "'")
    return 0
  end
  for i, n in ipairs(merkmale) do
    if merkmal == n then
      return delta
    end
  end
  return 0
end

function schwierigkeit:submod_from(name, sub, merkmale, delta)
  local ret = 0
  if sub ~= nil and merkmale ~= nil then
    if merkmale.gesamt ~= nil then
      ret = ret + delta
    end
    if type(sub) == "table" then
      for _,v in ipairs(sub) do
        if merkmale[v] ~= nil then
          ret = ret + delta
        end
      end
    elseif type(sub) == "string" and merkmale[sub] ~= nil then
      ret = ret + delta
    end
  end
  return ret
end

function schwierigkeit:malus_from(repr1, repr2)
  if repr2 == "Srl" or repr2 == "Sch" then
    return self:malus_from(repr2, repr1)
  end
  if repr1 == repr2 then
    return 0
  elseif repr1 == "Srl" then
    return repr2 == "Mag" and 1 or 2
  elseif repr1 == "Sch" then
    return repr2 == "Srl" and 2 or 3
  else
    return 2
  end
end

function schwierigkeit:malus_repr(repr, known)
  local min = 3
  for i,v in ipairs(known) do
    min = math.min(min, self:malus_from(repr, v()))
  end
  return min
end

function schwierigkeit:mod(input, merkmale, repr, lernmod, haus)
  if math.min(string.len(input), string.len(repr)) == 0 then
    return ""
  end
  index = self:num(input)
  for i, merkmal in ipairs(merkmale) do
    index = index + self:mod_from(merkmal, data.Magie.Merkmalskenntnis, -1)
    index = index + self:mod_from(merkmal, data.Magie.Begabungen, -1)
    index = index + self:mod_from(merkmal, data.Magie.Unfaehigkeiten, 1)
  end
  for _, name in ipairs({"Elementar", "Daemonisch"}) do
    index = index + self:submod_from(name, merkmale[name], data.Magie.Merkmalskenntnis[name], -1)
    index = index + self:submod_from(name, merkmale[name], data.Magie.Begabungen[name], -1)
    index = index + self:submod_from(name, merkmale[name], data.Magie.Unfaehigkeiten[name], 1)
  end
  index = index + (haus and -1 or 0)
  index = index + (lernmod == nil and 0 or lernmod)
  index = index + self:malus_repr(repr, data.Magie.Repraesentationen)
  return self:name(index)
end

local zauberliste = {
  repraesentationen = repraesentationen
}

function zauberliste.merkmalliste(input)
  local first = true
  for _, v in ipairs(input) do
    if first then
      first = false
    else
      tex.sprint(-2, ", ")
    end
    tex.sprint(-2, v)
  end
  for k, label in pairs({Daemonisch="Dämonisch", Elementar="Elementar"}) do
    local vals = input[k]
    if vals ~= nil then
      for _, item in ipairs(vals) do
        if first then
          first = false
        else
          tex.sprint(-2, ", ")
        end
        tex.sprint(-2, label .. " (")
        tex.sprint(-2, item)
        tex.sprint(-2, ")")
      end
    end
  end
end

function zauberliste.seite(start)
  local zauber = data.Magie.Zauber
  for i=start,start+48 do
    if zauber[i] == nil then
      for j=1,9 do
        tex.sprint("&")
      end
    else
      local z = {}
      for j,v in ipairs(zauber[i]) do
        if j == 8 then
          z[8] = v
        else
          z[j] = v()
          if j == 2 and zauber[i].spez ~= nil then
            z[2] = z[2] .. " ("
            for i, s in ipairs(zauber[i].spez) do
              if i > 1 then
                z[2] = z[2] .. ", "
              end
              z[2] = z[2] .. s
            end
            z[2] = z[2] .. ")"
          end
        end
      end
      for j=1,7 do
        tex.sprint(-2, z[j])
        tex.sprint("&")
      end
      for j, m in ipairs(z[8]) do
        if j ~= 1 then
          tex.sprint(-2, ", ")
        end
        tex.sprint(-2, merkmale.kurz(m))
      end
      local first = #z[8] == 0
      for k, label in pairs({Daemonisch="Dämon", Elementar="Element"}) do
        local sub = z[8][k]
        if sub ~= nil then
          if first then
            first = false
          else
            tex.sprint(-2, ", ")
          end
          if type(sub) == "string" then
            tex.sprint(-2, label .. " (")
            tex.sprint(-2, merkmale.kurz(sub))
            tex.sprint(-2, ")")
          else
            tex.sprint(-2, label)
          end
        end
      end
      tex.sprint("&")
      tex.sprint(-2, z[9])
      tex.sprint("&")
      tex.sprint(-2, schwierigkeit:mod(z[7], z[8], z[9], z.lernmod, z.haus))
      if z.haus then
        tex.sprint([[\hfill\faHome]])
      end
    end
    if i ~= start+48 then
      tex.sprint([[\\ \hline]])
    end
  end
end

function zauberliste.render()
  local num = 1
  while num <= #data.Magie.Zauber do
    tex.print(string.format([[\Zauberliste{%d}]], (num-1)/49 + 1))
    tex.print("")
    num = num + 49
  end
end

return zauberliste