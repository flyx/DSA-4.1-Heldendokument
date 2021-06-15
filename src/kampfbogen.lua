local data = require("values")
local common = require("common")

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
      tex.sprint([[\faDiceD6]])
    elseif tp.die == 20 then
      tex.sprint([[\faDiceD20]])
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

local function atpa_mod(basis, talent, schwelle, schritt, wm, spez)
  local val = basis
  local cur_kk = data:cur("KK")
  if cur_kk ~= "" then
    while cur_kk < schwelle do
      val = val - 1
      cur_kk = cur_kk + schritt
    end
  end
  if spez then
    val = val + 1
  end
  return val + talent + wm
end

local function kampfwerte(rows, render, typ_index, num_values)
  typ_index = typ_index or 1
  for i,v in ipairs(rows) do
    if i ~= 1 then
      tex.sprint([[\\\hline]])
    end
    local input_index = 1
    local talent = nil
    local ebe = 0
    if #v >= 1 and typ_index > 0 then
      local pattern = "^" .. v[typ_index]
      for i,t in ipairs(data.talente.kampf) do
        found, _ = string.find(t[1], pattern)
        if found ~= nil then
          talent = t
          if #talent >= 3 then
            ebe = calc_be(talent[3])
          end
          break
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
        if val ~= nil then
          if render == nil then
            tex.sprint(-2, val)
          else
            render(val)
          end
        end
        input_index = input_index + 1
      elseif talent ~= false or typ_index <= 0 then
        render(v, talent, ebe)
      end
    end
  end
end

local nahkampf_render = {
  --  false => aufgerufen mit Talentzeile, Waffenzeile und eBE,
  --  true  => aufgerufen mit iteriertem Wert aus der Waffenzeile
  [3]= {false, function(v, talent, ebe)
    if talent ~= nil and #talent >= 3 then
      tex.sprint(-2, ebe)
    end
  end},
  [5]= {true, function(v)
    local tp = parse_tp(v)
    render_tp(tp)
  end},
  [8]= {true, common.render_delta},
  [9]= {true, common.render_delta},
  [10]= {true, common.render_delta},
  [11]= {false, function(v, talent, ebe)
    local atb = data:cur("AT")
    if talent == nil or #talent < 4 or atb == "" or #v < 8 then
      return
    end
    tex.sprint(-2, atpa_mod(atb - common.round(ebe/2, true), talent[4], v[5], v[6], v[8], v.spez))
  end},
  [12]= {false, function(v, talent, ebe)
    local pab = data:cur("PA")
    if talent == nil or #talent < 5 or pab == "" or #v < 9 then
      return
    end
    tex.sprint(-2, atpa_mod(pab - common.round(ebe/2), talent[5], v[5], v[6], v[9], v.spez))
  end},
  [13]= {false, function(v, talent, ebe)
    if #v < 6 then
      return
    end
    local tp = parse_tp(v[4])
    tp = mod_tp(tp, v[5], v[6])
    if tp ~= nil then
      render_tp(tp)
    end
  end}
}

function kampfbogen.nahkampf()
  kampfwerte(data.nahkampf, nahkampf_render, 2, 15)
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
    local fk = data:cur("FK")
    if talent == nil or #talent < 6 or fk == "" then
      return
    end
    tex.sprint(-2, fk + talent[6] - ebe)
  end}
}

for i=5,9 do
  fernkampf_render[i] = {true, common.render_delta}
end

function kampfbogen.fernkampf()
  kampfwerte(data.fernkampf, fernkampf_render, 2, 19)
end

local waffenlos_render = {
  [5]= {false, function(v, talent, ebe)
    local atb = data:cur("AT")
    if talent == nil or #talent < 4 or atb == "" or #v < 3 then
      return
    end
    for _, t in pairs(data.sf.kampfstil) do
      if v[1] == t then
        atb = atb + 1
      end
    end
    tex.sprint(-2, atpa_mod(atb - common.round(ebe/2, true), talent[4], v[2], v[3], 0, false))
  end},
  [6]= {false, function(v, talent, ebe)
    local pab = data:cur("PA")
    if talent == nil or #talent < 4 or pab == "" or #v < 3 then
      return
    end
    for _, t in pairs(data.sf.kampfstil) do
      if v[1] == t then
        pab = pab + 1
      end
    end
    tex.sprint(-2, atpa_mod(pab - common.round(ebe/2), talent[4], v[2], v[3], 0, false))
  end},
  [7]= {false, function(v, talent, ebe)
    tp = mod_tp({dice=1, die=6, num=0}, v[2], v[3])
    if tp ~= nil then
      render_tp(tp)
    end
  end}
}

function kampfbogen.waffenlos()
  kampfwerte({
    {"Raufen", 10, 3, 0},
    {"Ringen", 10, 3, 0}
  }, waffenlos_render, 1, 7)
end

local schilde_render = {
  [3]= {true, common.render_delta},
  [4]= {true, common.render_delta},
  [5]= {true, common.render_delta},
  [6]= {false, function(v, talent, ebe)
    if #v < 5 then
      return
    end
    if v[2] == "Schild" then
      local val = data:cur("PA")
      if val == "" then
        return
      end
      if data.sf.linkhand then
        val = val + 1
      end
      for i=1,2 do
        if data.sf.schildkampf[i] then
          val = val + 2
        end
      end
      tex.sprint(-2, val + v[5])
    elseif v[2] == "Parierwaffe" then
      local val = v[5]
      if data.sf.parierwaffen[2] then
        val = val + 2
      elseif data.sf.parierwaffen[1] then
        val = val - 1
      else
        val = val - 4
      end
      common.render_delta(val)
    else
      tex.error("Typ muss 'Schild' oder 'Parierwaffe' sein: " .. v[2])
    end
  end}
}

function kampfbogen.schilde()
  kampfwerte(data.schilde, schilde_render, 0, 8)
end

function kampfbogen.ruestung(name)
  local value = nil
  for i,v in ipairs(data.ruestung) do
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
    if data.sf.ausweichen[i] then
      val = val + 3
    end
  end
  if data.vorteile.flink then
    val = val + 1
  end
  if data.nachteile.behaebig then
    val = val - 1
  end
  for i,v in ipairs(data.talente.koerper) do
    if #v >= 6 then
      found, _ = string.find(v[1], "^Akrobatik")
      if found ~= nil then
        local x = v[6] - 11
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