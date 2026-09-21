local M = {enabled = true}

local function modems()
  local result = {}
  for _, side in ipairs(peripheral.getNames()) do
    if peripheral.getType(side) == "modem" then
      result[#result + 1] = side
    end
  end
  table.sort(result)
  return result
end

function M.list()
  return modems()
end

function M.open()
  if not M.enabled then
    return false, "network disabled"
  end

  local found = modems()
  if #found == 0 then
    return false, "no modem"
  end

  local opened = 0
  local errors = {}
  for _, side in ipairs(found) do
    local ok, err = pcall(rednet.open, side)
    if ok then
      opened = opened + 1
    else
      errors[#errors + 1] = side .. ": " .. tostring(err)
    end
  end

  if opened > 0 then return true, opened end
  return false, table.concat(errors, " | ")
end

function M.close()
  for _, side in ipairs(modems()) do
    pcall(rednet.close, side)
  end
end

function M.status()
  local opened = 0
  local found = modems()
  for _, side in ipairs(found) do
    local ok, value = pcall(rednet.isOpen, side)
    if ok and value then opened = opened + 1 end
  end

  return {
    enabled = M.enabled,
    modems = found,
    opened = opened
  }
end

function M.setEnabled(value)
  M.enabled = value and true or false
  if M.enabled then
    return M.open()
  end
  M.close()
  return true
end

function M.send(id, message, protocol)
  if not M.enabled then return false, "disabled" end
  local ok, err = pcall(rednet.send, id, message, protocol)
  return ok, ok and nil or err
end

function M.broadcast(message, protocol)
  if not M.enabled then return false, "disabled" end
  local status = M.status()
  if status.opened == 0 then
    local ok, err = M.open()
    if not ok then return false, err end
  end
  local sent, err = pcall(rednet.broadcast, message, protocol)
  return sent, sent and nil or err
end

function M.receive(timeout, protocol)
  if not M.enabled then return nil end
  if M.status().opened == 0 then
    M.open()
  end
  return rednet.receive(protocol, timeout)
end

return M
