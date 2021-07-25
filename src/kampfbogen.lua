local data = require("values")
local common = require("common")
local schemadef = require("schemadef")
local schema = require("schema")

local kampfbogen = {}

local function calc_be(input)
  local be = data:cur("BE")
  if be == "" then
    be = 0
  end
  if string.find(input, "^BEx") then
    return be * input:sub(4)
  elseif string.find(input, "^BE%-") then
    return common.round(math.max(0, be - tonumber(input:sub(4))))
  elseif string.find(input, "^BE") then
    return be
  else
    return 0
  end
end

local function parse_tp(input)
  local orig = input
  local n_start, n_end = string.find(input, "^[0-9]+")
  local num = n_start == nil and nil or string.sub(input, n_start, n_end)
  if n_start ~= nil then
    input = string.sub(input, n_end + 1)
  end
  if string.len(input) == 0 then
    return {num = num}
  end
  local ret = {dice = num}
  local first = string.sub(input, 1, 1)
  if first == "W" or first == "w" then
    input = string.sub(input, 2)
    n_start, n_end = string.find(input, "^[0-9]+")
    if n_start == nil then
      ret.die = 6
    else
      ret.die = tonumber(string.sub(input, n_start, n_end))
      input = string.sub(input, n_end + 1)
    end
  else
    tex.error("ungültige TP: '" .. orig .. "' (W/w erwartet bei '" .. first .. "')")
  end
  if #input == 0 then
    ret.num = 0
    return ret
  end
  first = string.sub(input, 1, 1)
  if first ~= "+" and first ~= "-" then
    tex.error("ungültige TP: '" .. orig .. "' (+/- erwartet bei '" .. first .. "')")
  end
  ret.num = tonumber(input)
  if ret.num == nil then
    tex.error("ungültige TP: '" .. orig .. "' (ungültiger Summand: '" .. input .. "')")
  end
  return ret
end

local function render_tp(tp)
  if tp.dice ~= nil then
    tex.sprint(-2, tp.dice)
  end
  if tp.die ~= nil then
    if tp.die == 6 then
      tex.sprint([[\hspace{1pt}\faDiceD6\hspace{1pt}]])
    elseif tp.die == 20 then
      tex.sprint([[\hspace{1pt}\faDiceD20\hspace{1pt}]])
    else
      tex.sprint(-2, "W" .. tp.die)
    end
  end
  if tp.num ~= 0 then
    if tp.num < 0 then
      tex.sprint(-2, "−")
    elseif tp.die ~= nil then
      tex.sprint(-2, "+")
    end
    tex.sprint(-2, common.round(math.abs(tp.num)))
  end
end

local function mod_tp(tp, schwelle, schritt)
  local cur_kk = data:cur("KK")
  if cur_kk == "" then
    return nil
  end
  while cur_kk < schwelle do
    tp.num = tp.num - 1
    cur_kk = cur_kk + schritt
  end
  while cur_kk > schwelle + schritt do
    tp.num = tp.num + 1
    cur_kk = cur_kk - schritt
  end
  return tp
end

local function art(zeile)
  if zeile.Art ~= "" then
    return zeile.Art
  else
    return zeile.Name
  end
end

local function atpa_mod(basis, talent, schwelle, schritt, wm, art, spez)
  local val = basis
  local cur_kk = data:cur("KK")
  if cur_kk ~= "" and type(schwelle) == "number" and type(schritt) == "number" then
    while cur_kk < schwelle do
      val = val - 1
      cur_kk = cur_kk + schritt
    end
  end
  if art ~= nil and spez ~= nil then
    for _, s in ipairs(spez) do
      if s == art then
        val = val + 1
        break
      end
    end
  end
  if type(talent) == "number" then
    val = val + talent
  end
  return type(wm) == "number" and val + wm or val
end

local function render_num(input)
  if type(input) == "number" then
    if input < 0 then
      tex.sprint("−")
    end
    tex.sprint(math.abs(input))
  else
    tex.sprint(-2, input)
  end
end

--  render => table: index => {bool, function}
--      false => function aufgerufen mit Talentzeile, Waffenzeile und eBE,
--      true  => function aufgerufen mit iteriertem Wert aus der Waffenzeile
local function kampfwerte(items, render, typ_index, num_values, num_rows)
  typ_index = typ_index or 1
  for i,v in ipairs(items) do
    if i ~= 1 then
      tex.sprint([[\\\hline]])
    end
    local input_index = 1
    local talent = nil
    local ebe = 0
    if typ_index > 0 then
      local pattern = "^" .. v[typ_index]
      for i,t in ipairs(data.Talente.Kampf) do
        if #t >= 1 then
          found, _ = string.find(t.Name, pattern)
          if found ~= nil then
            talent = t
            if #talent >= 3 then
              ebe = calc_be(talent.BE)
            end
            break
          end
        end
      end
    else
      talent = false
    end

    for j = 1,num_values do
      if j ~= 1 then
        tex.sprint([[&]])
      end
      local spec = render[j]
      local single_value, render = true, nil
      if spec ~= nil then
        single_value, render = unpack(spec)
      end
      if single_value then
        local val = v[input_index]
        if render == nil then
          tex.sprint(-2, val)
        else
          render(val)
        end
        input_index = input_index + 1
      elseif talent ~= false or typ_index <= 0 then
        render(v, talent, ebe)
      end
    end
  end
  for i=#items+1,num_rows do
    if i ~= 1 then
      tex.sprint([[\\\hline]])
    end
    for j=2,num_values do
      tex.sprint("&")
    end
  end
end

local nahkampf_render = {
  short = {
    ["Anderthalbhänder"] = "Anderthalb",
    ["Fechtwaffen"] = "Fecht",
    ["Hiebwaffen"] = "Hieb",
    ["Infanteriewaffen"] = "Infanterie",
    ["Zweihandflegel"] = "ZH-Flegel",
    ["Zweihandhiebwaffen"] = "ZH-Hieb",
    ["Zweihandschwerter/-säbel"] = "ZH-Schw/Säb",
  },
}

nahkampf_render[2]= {true, function(v)
  local s = nahkampf_render.short[v]
  if s ~= nil then
    tex.sprint(-2, s)
  else
    tex.sprint(-2, v)
  end
end}
nahkampf_render[3]= {false, function(v, talent, ebe)
  if talent ~= nil then
    tex.sprint(-2, ebe)
  end
end}
nahkampf_render[5]= {true, function(v)
  local tp = parse_tp(v)
  render_tp(tp)
end}
for i=8,10 do
  nahkampf_render[i] = {true, common.render_delta}
end
nahkampf_render[11]= {false, function(v, talent, ebe)
  local atb = data:cur("AT")
  if talent == nil or #talent < 4 or atb == "" or #v < 8 then
    return
  end
  tex.sprint(-2, atpa_mod(atb - common.round(ebe/2, true), talent.AT, v["TP/KK Schwelle"], v["TP/KK Schritt"], v["WM AT"], art(v), talent.Spezialisierungen))
end}
nahkampf_render[12]= {false, function(v, talent, ebe)
  local pab = data:cur("PA")
  if talent == nil or #talent < 5 or pab == "" or #v < 9 then
    return
  end
  tex.sprint(-2, atpa_mod(pab - common.round(ebe/2), talent.PA, v["TP/KK Schwelle"], v["TP/KK Schritt"], v["WM PA"], art(v), talent.Spezialisierungen))
end}
nahkampf_render[13]= {false, function(v, talent, ebe)
  if #v < 6 then
    return
  end
  local tp = parse_tp(v.TP)
  tp = mod_tp(tp, v["TP/KK Schwelle"], v["TP/KK Schritt"])
  if tp ~= nil then
    render_tp(tp)
  end
end}
for i=14,15 do
  nahkampf_render[i] = {true, render_num}
end

function kampfbogen.nahkampf()
  kampfwerte(data.Waffen.Nahkampf, nahkampf_render, 2, 15, common.current_page.Nahkampf.Waffen)
end

local fernkampf_render = {
  [3]= {false, function(v, talent, ebe)
    if talent ~= nil and #talent >= 3 then
      tex.sprint(-2, ebe)
    end
  end},
  [4]= {true, function(v)
    local tp = parse_tp(v)
    render_tp(tp)
  end},
  [15]= {false, function(v, talent, ebe)
    local fk_basis = data:cur("FK")
    if talent == nil or fk_basis == "" then
      return
    end
    local fk = talent.TaW - ebe
    local a = art(v)
    for _, s in ipairs(talent.Spezialisierungen) do
      if s == a then
        fk = fk + 2
        break
      end
    end
    tex.sprint(-2, fk_basis + fk)
  end}
}

for i=10,14 do
  fernkampf_render[i] = {true, common.render_delta}
end

function kampfbogen.fernkampf()
  kampfwerte(data.Waffen.Fernkampf, fernkampf_render, 2, 18, common.current_page.Fernkampf.Waffen)
end

local waffenlos_render = {
  [5]= {false, function(v, talent, ebe)
    local atb = data:cur("AT")
    if talent == nil or #talent < 4 or atb == "" or #v < 3 then
      return
    end
    for _, t in pairs(data.SF.Waffenlos:getlist("Kampfstile")) do
      if v.Name == t then
        atb = atb + 1
      end
    end
    tex.sprint(-2, atpa_mod(atb - common.round(ebe/2, true), talent.AT, v["TP/KK Schwelle"], v["TP/KK Schritt"], 0))
  end},
  [6]= {false, function(v, talent, ebe)
    local pab = data:cur("PA")
    if talent == nil or #talent < 4 or pab == "" or #v < 3 then
      return
    end
    for _, t in pairs(data.SF.Waffenlos:getlist("Kampfstile")) do
      if v.Name == t then
        pab = pab + 1
      end
    end
    tex.sprint(-2, atpa_mod(pab - common.round(ebe/2), talent.PA, v["TP/KK Schwelle"], v["TP/KK Schritt"], 0))
  end},
  [7]= {false, function(v, talent, ebe)
    tp = mod_tp({dice=1, die=6, num=0}, v["TP/KK Schwelle"], v["TP/KK Schritt"])
    if tp ~= nil then
      render_tp(tp)
    end
  end}
}

function kampfbogen.waffenlos()
  local Ganzzahl = schema.Ganzzahl
  kampfwerte(schemadef.List:def({name = "Waffenlos", documentation = ""}, {
    schemadef.Row:def({name = "Kampftalent", documentation = ""},
      {"Name", schema.String}, {"TP/KK Schwelle", schema.Ganzzahl}, {"TP/KK Schritt", schema.Ganzzahl}, {"INI", schema.Ganzzahl}
    )
  }) {
    {"Raufen", 10, 3, 0},
    {"Ringen", 10, 3, 0}
  }, waffenlos_render, 1, 7, 2)
end

local schilde_render = {
  [2]= {false, function(v, talent, ebe)
    tex.sprint(-2, getmetatable(v).name)
  end},
  [3]= {true, common.render_delta},
  [4]= {true, common.render_delta},
  [5]= {true, common.render_delta},
  [6]= {false, function(v, talent, ebe)
    if #v < 5 then
      return
    end
    if getmetatable(v).name == "Schild" then
      local val = data:cur("PA")
      if val == "" then
        return
      end
      if data.SF.Nahkampf.Linkhand then
        val = val + 1
      end
      for i=1,2 do
        if data.SF.Nahkampf:getlist("Schildkampf")[i] then
          val = val + 2
        end
      end
      tex.sprint(-2, val + v["WM PA"])
    else
      local val = v["WM PA"]
      if data.SF.Nahkampf:getlist("Parierwaffen")[2] then
        val = val + 2
      elseif data.SF.Nahkampf:getlist("Parierwaffen")[1] then
        val = val - 1
      else
        val = val - 4
      end
      common.render_delta(val)
    end
  end},
  [7] = {true, render_num},
  [8] = {true, render_num}
}

function kampfbogen.schilde()
  kampfwerte(data.Waffen.SchildeUndParierwaffen, schilde_render, 0, 8, common.current_page.Schilde)
end

function kampfbogen.ruestungsteile()
  common.inner_rows(data.Waffen.Ruestung, 3, common.current_page.Ruestung)
end

function kampfbogen.ruestung(name)
  local value = nil

  for i,v in ipairs(data.Waffen.Ruestung) do
    local item = v[name]
    if item ~= nil then
      if value == nil then
        value = item
      else
        value = value + item
      end
    end
  end
  if value ~= nil then
    tex.sprint(-2, value)
  end
end

function kampfbogen.ausweichen()
  local val = data:cur("PA")
  if val == "" then
    return
  end
  local be = data:cur("BE")
  if be ~= "" then
    val = val - be
  end
  for i=1,3 do
    if data.SF.Nahkampf:getlist("Ausweichen")[i] then
      val = val + 3
    end
  end
  local flink = data.Vorteile.Flink or 0
  val = val + flink
  if data.Nachteile.Behaebig then
    val = val - 1
  end
  for i,v in ipairs(data.Talente.Koerper) do
    if #v >= 6 then
      found, _ = string.find(v.Name, "^Akrobatik")
      if found ~= nil and type(v.TaW) == "number" then
        local x = v.TaW - 11
        while x > 0 do
          val = val + 1
          x = x - 3
        end
        break
      end
    end
  end
  tex.sprint(-2, val)
end

function kampfbogen.energieleiste(label, val)
  tex.sprint(-2, label)
  num = tonumber(val)
  if num == nil then
    tex.sprint("&&&&")
  else
    for i=1,4 do
      tex.sprint("&")
      tex.sprint(-2, common.round(num/i))
    end
  end
  tex.sprint("&")
end

function kampfbogen.optionalleiste(label, val)
  if val ~= "" and val ~= 0 then
    tex.sprint([[\\ \hline ]])
    tex.sprint(-2, label)
    tex.sprint("&")
    tex.sprint(-2, val)
    tex.sprint([[& \multicolumn{4}{l}{}]])
  end
end

return kampfbogen