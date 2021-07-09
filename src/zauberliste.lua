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

function zauberliste.merkmalliste(input, zauber)
  local first = true
  if zauber ~= nil then
    for _, v in ipairs(zauber) do
      if first then
        first = false
      else
        tex.sprint(-2, ", ")
      end
      tex.sprint(-2, v)
    end
  end
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
      for j =1,10 do
        local v = zauber[i][j]
        if j == 8 then
          z[8] = v
        else
          z[j] = v()
          local spez = zauber[i].Spezialisierung
          if j == 2 and #spez > 0 then
            z[2] = z[2] .. " ("
            for k, s in ipairs(spez) do
              if k > 1 then
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
      tex.sprint(-2, data:lernschwierigkeit(z[2], z[7], z[8], z[9], z[10]))
      if z[10] then
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