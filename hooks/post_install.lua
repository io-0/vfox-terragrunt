local util = require("util")

--- Extension point, called after PreInstall, can perform additional operations,
--- such as file operations for the SDK installation directory or compile source code
--- Currently can be left unimplemented!
function PLUGIN:PostInstall(ctx)
  local osType = RUNTIME.osType

  if osType == "windows" then return util.windowsInstall(ctx)
  else return util.linuxInstall(ctx) end
end
