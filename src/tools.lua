
local standalone = false
local gendoc = false
local validate = false
local list = false
local curarg = 1
while string.sub(arg[curarg], 1, 1) == "-" do
  if arg[curarg] == "--standalone" then
    standalone = true
  else
    io.stderr:write("unknown option: " .. arg[curarg] .. "\n")
    os.exit(1)
  end
  curarg = curarg + 1
end
if arg[curarg] == "gendoc" then
  gendoc = true
elseif arg[curarg] == "validate" then
  validate = true
  if #arg == curarg then
    io.stderr:write("validate requires at least one path to a file that should be validated\n")
    os.exit(1)
  end
elseif arg[curarg] == "list" then
  list = true
  if #arg == curarg then
    io.stderr:write("list requires at least one path to a file that should be listed\n")
    os.exit(1)
  end
elseif arg[curarg] ~= nil then
  io.stderr:write("unknown command: " .. arg[curarg] .. "\n")
  os.exit(1)
end

local d = require("schemadef")
local schema = loadfile("schema.lua", "t")(true)

if gendoc then
  if standalone then
    io.write([[
<!doctype html>
<html lang="de" style="background-color: darkslategray;">
  <head>
    <title>DSA 4.1 Heldendokument: Formatspezifikation</title>
    <link rel="stylesheet" href="style.css"/>
  </head>
  <body>
    <nav>
      <ul>
        <li><a href="index.html">Home</a></li>
        <li><a href="manual.html">Installation &amp; Bedienung</a></li>
        <li><a href="format.html">Formatspezifikation</a></li>
        <li><a href="imprint.html">Impressum</a></li>
        <li><a href="https://github.com/flyx/DSA-4.1-Heldendokument"><img src="GitHub-Mark-Light-32px.png" srcset="GitHub-Mark-Light-64px.png 2x" style="height: .8em;"/> Github</a></li>
      </ul>
    </nav>
    <article class="doc">
      <section>
        <h1>DSA 4.1 Heldendokument: Formatspezikifation</h1>
        <p>Dieses Dokument spezifiziert die Struktur der Eingabedatei für die Generierung des Heldendokuments.
        Es dient der Referenz; generell ist es nicht nötig, das komplette Dokument zu lesen, um eine Eingabedatei schreiben zu können.
        Zum Einstieg wird empfohlen, beim Abschnitt <a href="#Struktur">Struktur des Eingabedokuments</a> zu beginnen und bei den dort verlinkten Strukturen auf der obersten Ebene die Beispiele anzuschauen.
        Sind dann Einzelheiten unklar, kann die Referenz zu Rate gezogen werden.</p>
      </section>
]])
  end
  d:typeclass_docs()
  d:gendocs()
  if standalone then
    io.write([[
    </article>
  </body>
</html>]])
  end
end

local pages_source = {
  Front             = "frontseite.tex",
  Talentliste       = "talentbogen.tex",
  Kampfbogen        = "kampfbogen.tex",
  Ausruestungsbogen = "ausruestung.tex",
  Liturgiebogen     = "liturgien.tex",
  Zauberdokument    = "zauberdokument.tex",
  Zauberliste       = "zauberliste.tex",
  Ereignisliste     = "ereignisse.tex",
}

if validate then
  local res = 0
  local prev_pcount = 0
  for i = curarg + 1,#arg do
    local f = function() error(arg[i] .. " did load too long!") end
    debug.sethook(f, "", 1e6)
    local f, errmsg = loadfile(arg[i], "t", schema)
    if f == nil then
      debug.sethook()
      io.stderr:write(errmsg)
      res = 1
    else
      local ret = f()
      debug.sethook()
      if d.Poison.count ~= prev_pcount then
        res = 1
        prev_pcount = d.Poison.count
      end
      if ret ~= nil then
        io.stderr:write(arg[i] .. ": unexpected return value: " .. type(ret) .. "\n")
        res = 1
      end
    end
  end
  if res == 0 then
    io.stdout:write("all files validated successfully! This input will process the following files:\n---\n")
    local l = schema.Layout:instance()
    for i,p in ipairs(l.value) do
      local pKind = getmetatable(p).name
      io.stdout:write(pages_source[pKind])
      io.stdout:write("\n")
    end
    io.stdout:write("---\n")
  end
  os.exit(res)
end

function format_len(input, len, right)
  while #input > len do len = len + 10 end
  if right then
    for i=1,len-#input do io.stdout:write(" ") end
  end
  io.stdout:write(input)
  if not right then
    for i=1,len-#input do io.stdout:write(" ") end
  end
end

if list then
  for i = curarg + 1,#arg do
    local f = loadfile("values.lua")
    local data = f(arg[i])
    io.stdout:write(arg[i] .. "\n--------------------------------------------------------------------------------")
    for _, e in ipairs(data.Ereignisse) do
      io.stdout:write("\n")
      format_len(e[1], 66)
      if e[4] < 0 then
        io.stdout:write("| -")
        format_len(tostring(e[4] * -1), 4, true)
      else
        io.stdout:write("| ")
        format_len(tostring(e[4]), 5, true)
      end
      io.stdout:write("| ")
      format_len(tostring(e[5]), 5, true)
    end
    io.stdout:write("\n================================================================================\n")
  end
end