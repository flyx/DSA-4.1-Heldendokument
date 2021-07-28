
local standalone = false
local gendoc = false
local validate = false
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
    <title>DSA 4.1 Heldendokument: Dokumentation Eingabedaten</title>
    <link rel="stylesheet" href="style.css"/>
  </head>
  <body>
    <article class="doc">
      <h1>DSA 4.1 Heldendokument: Dokumentation Eingabedaten</h1>
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

if validate then
  local res = 0
  local prev_pcount = 0
  for i = curarg + 1,#arg do
    local f, errmsg = loadfile(arg[i], "t", schema)
    if f == nil then
      io.stderr:write(errmsg)
      res = 1
    else
      local ret = f()
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
    io.stdout:write("all files validated successfully!\n")
  end
  os.exit(res)
end