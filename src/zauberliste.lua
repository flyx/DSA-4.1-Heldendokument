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

local zauberliste = {
  repraesentationen = repraesentationen
}

function zauberliste.seite(start)
  local zauber = data.Magie.Zauber
  for i=start,start+48 do
    local z = zauber[i]
    if z == nil then
      for j=1,9 do
        tex.sprint("&")
      end
    else
      tex.sprint(-2, z.Seite)
      tex.sprint("&")
      tex.sprint(-2, z.Name)
      if #z.Spezialisierungen > 0 then
        tex.sprint(-2, " (")
        for j, s in ipairs(z.Spezialisierungen) do
          if j > 1 then
            tex.sprint(-2, ", ")
          end
          tex.sprint(-2, s)
        end
        tex.sprint(-2, ")")
      end
      tex.sprint("&")
      for j=3,7 do
        tex.sprint(-2, z[j])
        tex.sprint("&")
      end
      local first = true
      for j, m in ipairs(z.Merkmale) do
        if first then
          first = false
        else
          tex.sprint(-2, ", ")
        end
        tex.sprint(-2, merkmale.kurz(m))
      end
      for k, label in pairs({Daemonisch="Dämon", Elementar="Element"}) do
        local sub = z.Merkmale[k]
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
      tex.sprint(-2, z.Repraesentation)
      tex.sprint("&")
      tex.sprint(-2, data:lernschwierigkeit(z))
      if z.Hauszauber then
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
  repeat
    tex.print(string.format([[\Zauberliste{%d}]], (num-1)/49 + 1))
    tex.print("")
    num = num + 49
  until num > #data.Magie.Zauber
end

return zauberliste