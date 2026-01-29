-- NotchBar: black top bar for macOS notch masking
-- SavedVariables: NotchBarDB

local ADDON = ...
NotchBarDB = NotchBarDB or {}

local defaults = {
  enabled = true,
  mode = "auto",     -- "auto" or "manual"
  manualHeight = 74, -- UI units (not pixels)
  ratio = 0.038,     -- ~3.8% of UIParent height
  clampMin = 50,
  clampMax = 110,
}

local function ApplyDefaults()
  for k, v in pairs(defaults) do
    if NotchBarDB[k] == nil then
      NotchBarDB[k] = v
    end
  end
end

local bar = CreateFrame("Frame", "NotchBarFrame", UIParent)
bar:SetFrameStrata("FULLSCREEN_DIALOG")
bar:SetFrameLevel(9999)
bar:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
bar:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)

local tex = bar:CreateTexture(nil, "BACKGROUND")
tex:SetAllPoints(true)
tex:SetColorTexture(0, 0, 0, 1)

local function Clamp(x, mn, mx)
  if x < mn then return mn end
  if x > mx then return mx end
  return x
end

local function ComputeAutoHeight()
  local h = UIParent:GetHeight() * (NotchBarDB.ratio or defaults.ratio)
  return Clamp(h, NotchBarDB.clampMin or defaults.clampMin, NotchBarDB.clampMax or defaults.clampMax)
end

local function UpdateBar()
  if not NotchBarDB.enabled then
    bar:Hide()
    return
  end

  local height
  if NotchBarDB.mode == "manual" then
    height = tonumber(NotchBarDB.manualHeight) or defaults.manualHeight
  else
    height = ComputeAutoHeight()
  end

  bar:SetHeight(height)
  bar:Show()
end

-- Events
local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("UI_SCALE_CHANGED")
ev:RegisterEvent("DISPLAY_SIZE_CHANGED")
ev:SetScript("OnEvent", function()
  ApplyDefaults()
  UpdateBar()
end)

-- Slash commands
SLASH_NOTCHBAR1 = "/notchbar"
SLASH_NOTCHBAR2 = "/notch"

local function Print(msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cff00ffccNotchBar:|r " .. msg)
end

SlashCmdList.NOTCHBAR = function(input)
  input = (input or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")

  if input == "" or input == "help" then
    Print("Commands:")
    Print("/notchbar auto            - auto height (recommended)")
    Print("/notchbar <number>        - manual height (e.g. /notchbar 74)")
    Print("/notchbar on | off        - enable/disable")
    Print("/notchbar status          - show current settings")
    Print("/notchbar ratio <number>  - set auto ratio (default 0.038)")
    Print("/notchbar clamp <min> <max> - clamp auto height (default 50 110)")
    return
  end

  if input == "on" then
    NotchBarDB.enabled = true
    UpdateBar()
    Print("Enabled.")
    return
  end

  if input == "off" then
    NotchBarDB.enabled = false
    UpdateBar()
    Print("Disabled.")
    return
  end

  if input == "auto" then
    NotchBarDB.mode = "auto"
    UpdateBar()
    Print(string.format("Mode: auto (ratio %.3f, clamp %d..%d).",
      NotchBarDB.ratio, NotchBarDB.clampMin, NotchBarDB.clampMax))
    return
  end

  if input == "status" then
    Print(string.format("enabled=%s, mode=%s, manualHeight=%s, ratio=%.3f, clamp=%d..%d",
      tostring(NotchBarDB.enabled),
      tostring(NotchBarDB.mode),
      tostring(NotchBarDB.manualHeight),
      tonumber(NotchBarDB.ratio) or defaults.ratio,
      tonumber(NotchBarDB.clampMin) or defaults.clampMin,
      tonumber(NotchBarDB.clampMax) or defaults.clampMax
    ))
    return
  end

  do
    local r = input:match("^ratio%s+([%d%.]+)$")
    if r then
      NotchBarDB.ratio = tonumber(r) or defaults.ratio
      NotchBarDB.mode = "auto"
      UpdateBar()
      Print("Auto ratio set to " .. tostring(NotchBarDB.ratio) .. " (mode auto).")
      return
    end
  end

  do
    local mn, mx = input:match("^clamp%s+(%d+)%s+(%d+)$")
    if mn and mx then
      NotchBarDB.clampMin = tonumber(mn)
      NotchBarDB.clampMax = tonumber(mx)
      NotchBarDB.mode = "auto"
      UpdateBar()
      Print(string.format("Clamp set to %d..%d (mode auto).", NotchBarDB.clampMin, NotchBarDB.clampMax))
      return
    end
  end

  local n = tonumber(input)
  if n then
    NotchBarDB.mode = "manual"
    NotchBarDB.manualHeight = n
    NotchBarDB.enabled = true
    UpdateBar()
    Print("Mode: manual, height set to " .. n .. ".")
    return
  end

  Print("Unknown command. Use /notchbar help")
end