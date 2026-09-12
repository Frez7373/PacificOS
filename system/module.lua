local M = {cache={}}
function M.load(path)
  if M.cache[path] ~= nil then return M.cache[path] end
  local fn, err = loadfile("/pacificos/" .. path)
  if not fn then error("Module load failed: " .. path .. ": " .. tostring(err), 0) end
  local ok, result = pcall(fn)
  if not ok then error("Module crashed: " .. path .. ": " .. tostring(result), 0) end
  if result == nil then result = true end
  M.cache[path] = result
  return result
end
function M.clear() M.cache={} end
return M
