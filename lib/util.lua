local http = require("http")
local json = require("json")
local util = {}


util.windowsInstall = function(ctx)
  print(ctx.rootPath)
  error("Not implemented yet")-- FIXME: if its like linux we have to fix filename
end

util.linuxInstall = function(ctx)
  --- SDK installation root path, e.g. /Users/../.version-fox/cache/terragrunt/v-0.45.14
  local pwd = ctx.rootPath .. "/" .. io.popen("ls " .. ctx.rootPath):read("*l")
  local downloadedFile = pwd .. "/" .. io.popen("ls " .. pwd):read("*l")
  local targetFile = pwd .. "/terragrunt"
  
  local cmd = "mv " .. downloadedFile .. " " .. targetFile
  local exitCode = os.execute(cmd)
  if exitCode ~= 0 then error("'" .. cmd .. "' failed. exit " .. exitCode) end

  cmd = "chmod +x " .. targetFile
  exitCode = os.execute(cmd)
  if exitCode ~= 0 then error("'" .. cmd .. "' failed. exit " .. exitCode) end
end

-- curl -s https://api.github.com/repos/gruntwork-io/terragrunt/releases | jq -r '.[].tag_name'
util.getInfo = function()
  local req = { url = "https://api.github.com/repos/gruntwork-io/terragrunt/releases?per_page=100&page=1" }
  local output = {}

  repeat
    local resp, err = http.get(req)

    if err ~= nil then error("Failed to get information: " .. err) end
    if resp.status_code ~= 200 then error("Failed to get information: status_code =>" .. resp.status_code) end

    local jsonBody = json.decode(resp.body)

    for i = 1, #jsonBody do
      table.insert(output, {
        version = string.gsub(jsonBody[i].tag_name, "^v", "") -- "v0.72.6" to "0.72.6", vfox will prefix 'v'
      })
    end

    -- search for: .., <https://api.github.com/repositories/59522149/releases?per_page=100&page=2>; rel="next", ..
    local _, _, nextPage = string.find(resp.headers['Link'], "<([^>]+)>; rel=\"next\"")

    req.url = nextPage
  until nextPage == nil

  table.sort(output, util.compare_versions)

  return output
end

util.compare_versions = function(v1o, v2o)
  local v1 = v1o.version
  local v2 = v2o.version
  local v1_parts = {}
  for part in string.gmatch(v1, "%d+") do
    table.insert(v1_parts, tonumber(part))
  end

  local v2_parts = {}
  for part in string.gmatch(v2, "%d+") do
    table.insert(v2_parts, tonumber(part))
  end

  for i = 1, math.max(#v1_parts, #v2_parts) do
    local v1_part = v1_parts[i] or 0
    local v2_part = v2_parts[i] or 0
    if v1_part > v2_part then return true
    elseif v1_part < v2_part then return false end
  end
  return v1 > v2
end

return util
