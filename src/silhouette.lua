local index = 1

local function trefferzone(namen, schilde, wunden)
  for i, schild in ipairs(schilde) do
    local node_name = "tz" .. index
    local short_name = string.sub(namen[i], 1, 2)
    if short_name == "Ru" then short_name = "Rü" end
    index = index + 1
    tex.sprint([[\node(]] .. node_name .. ") at (" .. schild[1] .. ", " .. schild[2] .. [[) {\RS{]] .. namen[i] .. [[}};
    \shield{]] .. node_name .. [[}
    \node[below=2pt of ]] .. node_name .. [[] {]] .. short_name .. [[};
    ]])
  end
  local start
  if wunden.Mitte then
    start = {wunden.Mitte[1] - wunden.Schritt[1], wunden.Mitte[2] - wunden.Schritt[2]}
  else
    start = {wunden.Start[1], wunden.Start[2]}
  end
  tex.sprint([[\filldraw[fill=white, draw=black] (]] .. start[1] .. "cm, " .. start[2] .. "cm) circle (0.2cm);")
  for i=1,2 do
    local x = start[1] + (wunden.Schritt[1] * i)
    local y = start[2] + (wunden.Schritt[2] * i)
    tex.sprint([[\filldraw[fill=white, draw=black] (]] .. x .. "cm, " .. y .. "cm) circle (0.2cm);")
  end
end

return function(kind, variant)
  local meta = require("img/" .. kind .. "/data")
  local var_data = meta.Varianten[variant]
  local img_path = "img/" .. kind .. "/" .. var_data[1]

  tex.sprint([[
  \newcommand{\shield}[1]{
    \begin{scope}[on background layer]
      \path[fill=white, draw=black] ([xshift=0.2cm, yshift=0.1cm]#1.north west) -- ([xshift=0.2cm]#1.west) to[out=270, in=155] ([yshift=-0.1cm]#1.south) to[out=25, in=270] ([xshift=-0.2cm]#1.east) -- ([xshift=-0.2cm, yshift=0.1cm]#1.north east) -- cycle;
    \end{scope}
  }
    
  \begin{tikzpicture}
    \begin{scope}[on background layer]
      \node[anchor=south west, inner sep=0, opacity=]] .. var_data[2] .. [[] at (0, 0) {
        \includegraphics[width=6cm]{]] .. img_path .. [[}
      };
    \end{scope}
  ]])

  trefferzone({"Kopf"}, {meta.Kopf.Schild}, meta.Kopf.Wunden)
  trefferzone({"Brust", "Ruecken"}, {meta.BrustRuecken.SchildBr, meta.BrustRuecken.SchildRu}, meta.BrustRuecken.Wunden)
  trefferzone({"LArm"}, {meta.LArm.Schild}, meta.LArm.Wunden)
  trefferzone({"RArm"}, {meta.RArm.Schild}, meta.RArm.Wunden)
  trefferzone({"Bauch"}, {meta.Bauch.Schild}, meta.Bauch.Wunden)
  trefferzone({"RBein"}, {meta.RBein.Schild}, meta.RBein.Wunden)
  trefferzone({"LBein"}, {meta.LBein.Schild}, meta.LBein.Wunden)
  
  tex.sprint([[\end{tikzpicture}]])
end