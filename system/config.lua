local ROOT = "/pacificos"
local PATH = ROOT .. "/config.cfg"

local function defaults()
  return {
    version = "1.9.0",
    theme = "pacific-blue",
    hostname = "pacificos",
    autostart = true,
    network = true,
    animations = true,
    sounds = true,
    notifications = true,
    show_seconds = false,
    boot_delay = 0.2,
    default_app = "Files"
  }
end

local data = defaults()
local M = {}

local function ensureRoot()
  if not fs.exists(ROOT) then fs.makeDir(ROOT) end
end

local function load()
  ensureRoot()
  if not fs.exists(PATH) then return end
  local handle = fs.open(PATH, "r")
  if not handle then return end

  local raw = handle.readAll() or ""
  handle.close()

  local ok, loaded = pcall(textutils.unserialize, raw)
  if ok and type(loaded) == "table" then
    for key, value in pairs(loaded) do data[key] = value end
  end

  data.version = "1.9.0"
  if type(data.hostname) ~= "string" or data.hostname == "" then data.hostname = "pacificos" end
  if type(data.boot_delay) ~= "number" then data.boot_delay = 0.2 end
end

local function save()
  ensureRoot()
  local handle = fs.open(PATH, "w")
  if not handle then return false end
  handle.write(textutils.serialize(data))
  handle.close()
  return true
end

load()

function M.get(key) return data[key] end

function M.set(key, value)
  data[key] = value
  return save()
end

function M.all()
  local result = {}
  for key, value in pairs(data) do result[key] = value end
  return result
end

function M.reset()
  data = defaults()
  return save()
end

return M
