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
  fixUIParent = true, -- match UIParent to WorldFrame (notch safe-area fix)
  widgetTopOffset = -30, -- y-offset for UIWidgetTopCenterContainerFrame
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
bar:SetPoint("BOTTOMLEFT", UIParent, "TOPLEFT", 0, 0)
bar:SetPoint("BOTTOMRIGHT", UIParent, "TOPRIGHT", 0, 0)

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

-- Optional: match UIParent to WorldFrame to avoid notch safe-area offsets
local uiParentDefaults = { captured = false, points = {} }
local fixApplied = false
local fixPending = nil
local fixTicker = nil
local widgetPending = false

local function CaptureUIParentDefaults()
  if uiParentDefaults.captured then return end
  local n = UIParent:GetNumPoints()
  uiParentDefaults.num = n
  for i = 1, n do
    local point, rel, relPoint, x, y = UIParent:GetPoint(i)
    uiParentDefaults.points[i] = { point, rel, relPoint, x, y }
  end
  uiParentDefaults.captured = true
end

local function TryApplyUIParentFix()
  if InCombatLockdown and InCombatLockdown() then
    fixPending = "apply"
    return
  end
  fixPending = nil
  if UIParent:GetNumPoints() == 1 then
    local p, rel, relPoint, x, y = UIParent:GetPoint(1)
    if p == "CENTER" and rel == WorldFrame and relPoint == "CENTER" and x == 0 and y == 0 then
      fixApplied = true
      return
    end
  end
  UIParent:ClearAllPoints()
  UIParent:SetAllPoints(WorldFrame)
  fixApplied = true
end

local function TryRestoreUIParentFix()
  if not fixApplied or not uiParentDefaults.captured then return end
  if InCombatLockdown and InCombatLockdown() then
    fixPending = "restore"
    return
  end
  fixPending = nil
  UIParent:ClearAllPoints()
  for i = 1, uiParentDefaults.num do
    local p = uiParentDefaults.points[i]
    UIParent:SetPoint(p[1], p[2], p[3], p[4], p[5])
  end
  fixApplied = false
end

local function UpdateUIParentFix()
  CaptureUIParentDefaults()
  TryApplyUIParentFix()
end

local function StartUIParentFixTicker()
  if fixTicker or not C_Timer or not C_Timer.NewTicker then return end
  fixTicker = C_Timer.NewTicker(2, function()
    TryApplyUIParentFix()
  end)
end

local function TryUpdateWidgetTopCenter()
  if not UIWidgetTopCenterContainerFrame then return end
  if InCombatLockdown and InCombatLockdown() then
    widgetPending = true
    return
  end
  widgetPending = false
  UIWidgetTopCenterContainerFrame:ClearAllPoints()
  UIWidgetTopCenterContainerFrame:SetPoint("TOP", UIParent, "TOP", 0, tonumber(NotchBarDB.widgetTopOffset) or 0)
end

local function UpdateWidgetTopCenter()
  TryUpdateWidgetTopCenter()
end

-- Events
local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("UI_SCALE_CHANGED")
ev:RegisterEvent("DISPLAY_SIZE_CHANGED")
ev:RegisterEvent("PLAYER_REGEN_ENABLED")
ev:RegisterEvent("PLAYER_ENTERING_WORLD")
ev:RegisterEvent("ZONE_CHANGED")
ev:RegisterEvent("ZONE_CHANGED_NEW_AREA")
ev:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_REGEN_ENABLED" and fixPending then
    if fixPending == "apply" then
      TryApplyUIParentFix()
    elseif fixPending == "restore" then
      TryRestoreUIParentFix()
    end
  end
  if event == "PLAYER_REGEN_ENABLED" and widgetPending then
    TryUpdateWidgetTopCenter()
  end
  ApplyDefaults()
  UpdateUIParentFix()
  StartUIParentFixTicker()
  UpdateWidgetTopCenter()
  UpdateBar()
end)
