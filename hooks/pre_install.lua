local http = require("http")

--- Returns some pre-installed information, such as version number, download address, local files, etc.
--- If checksum is provided, vfox will automatically check it for you.
--- @param ctx table
--- @field ctx.version string User-input version
--- @return table Version information
function PLUGIN:PreInstall(ctx)
  local version = ctx.version

  local archType = RUNTIME.archType
  local osType = RUNTIME.osType

  -- https://github.com/gruntwork-io/terragrunt/releases/download/v0.73.11/SHA256SUMS
  -- https://github.com/gruntwork-io/terragrunt/releases/download/v0.73.11/terragrunt_darwin_arm64
  local baseURL = "https://github.com/gruntwork-io/terragrunt/releases/download/v" .. version .. "/"

  local filename = "terragrunt_" .. osType .. "_" .. archType
  local url = baseURL .. filename
  if osType == "windows" then url = url .. ".exe" end

  local resp, err = http.get({ url = baseURL .. "SHA256SUMS" })

  if err ~= nil or resp.status_code ~= 200 then error("get checksum failed") end

  print("filename", filename)

  local lines = {}
  for word in string.gmatch(resp.body, "%S+") do
    table.insert(lines, word)
  end

  local sha256
  for i = 1, #lines, 2 do
    local hash = lines[i]
    local name = lines[i + 1]
    if name == filename then
      sha256 = hash
      break
    end
  end

  return {
    --- Version number
    version = version,
    --- remote URL or local file path [optional]
    url = url,
    --- SHA256 checksum [optional]
    sha256 = sha256,
  }
end
