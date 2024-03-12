local data = require("data")
local common = require("common")
local schema = require("schema")
require("stdext")

local frontseite = {}

local function local_heading(label)
  tex.sprint([[\textmansontt{\textbf{]])
  tex.sprint(-2, label)
  tex.sprint([[}}]])
end

local held_basis = {
  labels = {
    Name="Name", GP="GP-Basis", Rasse="Rasse", Kultur="Kultur", Profession="Profession",
    Geschlecht="Geschlecht", Tsatag="Tsatag", Groesse="Größe",
    Gewicht="Gewicht", Haarfarbe="Haarfarbe", Augenfarbe="Augenfarbe",
    Stand="Stand", Sozialstatus="Sozialstatus", Titel="Titel"
  }
}

function held_basis.top(self)
  for i,n in ipairs({"Name", "GP", "Rasse", "Kultur", "Profession"}) do
    local_heading(self.labels[n])
    tex.sprint("&")
    if i == 5 then
      tex.sprint([[\multicolumn{3}{l}{]])
      tex.sprint(-2, data.Held[n])
      tex.sprint("}")
    else
      tex.sprint(-2, data.Held[n])
    end
    if i % 2 == 0 then
      tex.sprint([[\\ \hline]])
    elseif i < 5 then
      tex.sprint("&")
    end
  end
end

function held_basis.links(self)
  for i,n in ipairs({"Geschlecht", "Tsatag", "Groesse", "Gewicht",
                     "Haarfarbe", "Augenfarbe"}) do
    if i ~= 1 then
      tex.sprint([[\\ \hline]])
    end
    local_heading(self.labels[n])
    tex.sprint("&")
    tex.sprint(-2, data.Held[n])
  end
end

function held_basis.rechts(self)
  for i,n in ipairs({"Stand", "Sozialstatus"}) do
    if i ~= 1 then
      tex.sprint([[\\ \hline]])
    end
    local_heading(self.labels[n])
    tex.sprint("&")
    tex.sprint(-2, data.Held[n])
  end
  tex.sprint([[\\ \hline]])
  common.multiline_content({
    name="Titel", rows=4, cols=2, col=[[p{.9\textwidth}]], baselinestretch=1.35,
    preamble=self.labels["Titel"], hspace="54.92pt"}, data.Held.Titel)
end

frontseite.held = held_basis

frontseite.schEig = function()
  local ret = {}
  for _, e in ipairs(data.Nachteile.Eigenschaften.value) do
    table.insert(ret, schema.String(e.Name .. " " .. e.Wert))
  end
  return {value = ret, inner = schema.String}
end

local eigenschaften = {
  label = {
    MU = "Mut", KL = "Klugheit", IN = "Intuition", CH = "Charisma",
    FF = "Fingerfertigkeit", GE = "Gewandtheit", KO = "Konstitution", KK = "Körperkraft",
    GS = "Geschwindigkeit",
    LE = {"Lebensenergie", "(KO+KO+KK)/2"}, AU = {"Ausdauer", "(MU+KO+GE)/2"},
    AE = {"Astralenergie", "(MU+IN+CH)/2"}, KE = {"Karmaenergie", ""},
    MR = {"Magieresistenz", "(MU+KL+KO)/5"}, INI = {"Ini-Basiswert", "(MU+MU+IN+GE)/5"},
    AT = {"AT-Basiswert", "(MU+GE+KK)/5"}, PA = {"PA-Basiswert", "(IN+GE+KK)/5"},
    FK = {"FK-Basiswert", "(IN+FF+KK)/5"}
  },
  max = {
    LE = function() return data:cur("KO", 2), "KO/2" end,
    AU = function() return data:cur("KO"), "KO" end,
    AE = function() return data:cur("CH"), "CH" end,
    MR = function() return data:cur("MU", 2), "MU/2" end,
  },

  render_mod = function(val)
    if val == 0 then
      return ""
    elseif val < 0 then
      return "−" .. math.abs(val)
    else
      return "+" .. val
    end
  end,
}

function eigenschaften.links(self)
  for i, e in ipairs({"MU", "KL", "IN", "CH", "FF", "GE", "KO", "KK"}) do
    if i ~= 1 then
      tex.sprint([[\\]])
    end
    tex.sprint(i == 1 and [[\Xhline{2\arrayrulewidth}]] or [[\hline]])
    tex.sprint([[\small\mansontt\bfseries]])
    tex.sprint(-2, self.label[e])
    for j=1,3 do
      tex.sprint("&")
      if j == 3 then
        tex.sprint([[\cellcolor{white}]])
      end
      local val = data.eig[e][j]
      if j == 1 then
        tex.sprint(-2, eigenschaften.render_mod(val))
      elseif j == 2 and i ~= 9 then
        if val ~= 0 then
          tex.sprint([[\begin{minipage}[t][0.49em][b]{0.8cm}\centering\small]])
          tex.sprint(-2, val)
          tex.sprint([[\\\tiny\textbf{Max: }]])
          tex.sprint(data.sparse(val, 2/3))
          tex.sprint([[\\]])
          tex.print()
          tex.print([[\vspace{0.9pt}\end{minipage}]])
        end
      elseif val ~= 0 then
        tex.sprint(-2, val)
      end
    end
  end
  tex.sprint([[\\\Xhline{2\arrayrulewidth}\small\mansontt\bfseries]])
  tex.sprint(-2, self.label["GS"])
  tex.sprint("&")
  local gsmod = data:cur("GS_mod")
  if gsmod ~= "" then
    tex.sprint(-2, eigenschaften.render_mod(gsmod))
  end
  tex.sprint([[&&\cellcolor{white}]])
  if gsmod ~= "" then
    tex.sprint(-2, 8 + gsmod)
  end
end

function eigenschaften.rechts(self)
  for i,e in ipairs({"LE", "AU", "AE", "MR", "KE", "INI", "AT", "PA", "FK"}) do
    if i == 1 then
      tex.sprint([[\Xhline{2\arrayrulewidth}]])
    elseif i <= 5 or i == 7 then
      tex.sprint([[\\\hline]])
    elseif i == 6 then
      tex.sprint([[\\\cline{1-3}]])
    else
      tex.sprint([[\\\cline{1-2}]])
    end
    tex.sprint([[\small\bfseries\textmansontt{]])
    local info = self.label[e]
    tex.sprint(-2, info[1])
    tex.sprint([[} \hspace*{\fill} \tiny ]])
    tex.sprint(-2, data:formula(e))
    tex.sprint([[ \hspace{3pt} & \cellcolor{white}]])
    tex.sprint(-2, data:cur(e))

    for j=1,4 do
      if i < 5 or j == 1 or (i <= 6 and j == 2) then
        tex.sprint("&")
      end
      if (i == 5 or i == 6) and j > 1 then
        if j == 2 then
          if i == 5 then
            common.p([[\multicolumn{3}{l}{
              \hspace{0.1cm}\tiny\normalfont\raisebox{2pt}{
              \begin{minipage}{3cm}
                \directlua{common.checkbox(data.SF.Magisch.GefaessDerSterne)} Gefäß der Sterne (AE: CH×2) \\[1.5pt]
              \end{minipage}
            }}]])
          else
            common.p([[\multicolumn{3}{l}{
              \hspace{0.1cm}\tiny\normalfont\raisebox{2pt}{
              \begin{minipage}{2.5cm}
                  \directlua{common.checkbox(data.SF.Nahkampf.Kampfreflexe)} Kampfreflexe (INI+4) \\[1.5pt]
                  \directlua{common.checkbox(data.SF.Nahkampf.Kampfgespuer)} Kampfgespür (INI+2)
              \end{minipage}
            }}]])
          end
        end
      elseif i > 6 then
        if j == 1 then
          if i == 7 then
            common.p([[
              \multicolumn{4}{c}{\multirow{3}{*}{
                \begin{minipage}{4.4cm}
                  \centering
                  {\textmansontt{\textbf{Wundschwellen}}}\smallbreak\vspace{-6pt}
                  {\tiny\normalfont (KO/2 • KO • KO×3/2)+Modifikator}\smallbreak
                  \bgroup\fboxsep=0pt\colorbox{white}{\begin{tabular}{|x{1.2cm}|x{1.2cm}|x{1.2cm}|}\hline
            ]])
            for k=1,3 do
              if k ~= 1 then
                tex.sprint("&")
              end
              local base = data:cur("KO", 2/k)
              if base ~= "" then
                if data.Vorteile.Eisern then
                  base = base + 2
                end
                if data.Nachteile.Glasknochen then
                  base = base - 2
                end
                tex.sprint(-2, math.round(base))
              end
            end
            tex.sprint([[\\\hline\end{tabular}}\egroup\par]])
            common.p([[
              {\tiny\hspace{2pt}\directlua{common.checkbox(data.Vorteile.Eisern)} Eisern (WS+2)
              \hfill
              \directlua{common.checkbox(data.Nachteile.Glasknochen)} Glasknochen (WS−2)\hspace{2pt}}\\
            ]])

            common.p([[
                \end{minipage}
              }}
            ]])
          else
            tex.sprint([[\multicolumn{4}{c}{}]])
          end
        end
      else
        if j == 1 then
          if i == 6 then
            tex.sprint(-2, eigenschaften.render_mod(data.eig[e]))
          else
            tex.sprint(-2, eigenschaften.render_mod(data.eig[e][1]))
          end
        elseif j == 3 then
          tex.sprint([[\begin{minipage}[t][0.49em][b]{0.8cm}\centering\small]])
          local val, label = self.max[e]()
          if val == "" then
            tex.sprint([[\ ]])
          else
            tex.sprint(-2, val)
          end
          tex.sprint([[\\\tiny]])
          tex.sprint(label)
          tex.sprint([[\\]])
          tex.print()
          tex.print([[\vspace{1pt}\end{minipage}]])
        else
          tex.sprint(-2, data.sparse(data.eig[e][j < 3 and j or j - 1]))
        end
      end
    end
  end
end

frontseite.eigenschaften = eigenschaften

return frontseite
