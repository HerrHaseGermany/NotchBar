-- Run from the NotchBar root: lua tests/offhand-compatibility.lua
-- Model native anchor dependencies: either addon creating a cycle is a failure.
local function scenario(offhandAtLogin, loadOffhandLater, preference)
  local timers, eventFrame = {}, nil
  local function frame(name)
    local f = {name = name, points = {}}
    function f:GetNumPoints() return #self.points end
    function f:GetPoint(i) return table.unpack(self.points[i]) end
    function f:ClearAllPoints() self.points = {} end
    function f:SetPoint(point, relative, relativePoint, x, y)
      local function reaches(node, target, seen)
        if node == target then return true end
        if type(node) ~= "table" or seen[node] then return false end
        seen[node] = true
        for _, anchor in ipairs(node.points or {}) do
          if reaches(anchor[2], target, seen) then return true end
        end
        return false
      end
      assert(not reaches(relative, self, {}), "native anchor cycle: " .. self.name)
      self.points[#self.points + 1] = {point, relative, relativePoint, x, y}
    end
    function f:SetAllPoints(relative)
      self:ClearAllPoints()
      self:SetPoint("TOPLEFT", relative, "TOPLEFT", 0, 0)
      self:SetPoint("BOTTOMRIGHT", relative, "BOTTOMRIGHT", 0, 0)
    end
    function f:GetHeight() return 1000 end
    function f:SetHeight(value) self.height = value end
    function f:Show() self.shown = true end
    function f:Hide() self.shown = false end
    function f:SetFrameStrata() end
    function f:SetFrameLevel() end
    function f:SetColorTexture() end
    function f:CreateTexture() return frame("texture") end
    function f:RegisterEvent() end
    function f:SetScript(_, callback) self.callback = callback; eventFrame = self end
    return f
  end
  local screen = frame("screen")
  UIParent, WorldFrame = frame("UIParent"), frame("WorldFrame")
  UIParent:SetAllPoints(screen)
  WorldFrame:SetAllPoints(screen)
  NotchBarDB = {fixUIParent = preference}
  Offhand = offhandAtLogin and {} or nil
  UIWidgetTopCenterContainerFrame = nil
  local bar
  CreateFrame = function(_, name)
    local f = frame(name or "event")
    if name == "NotchBarFrame" then bar = f end
    return f
  end
  InCombatLockdown = function() return false end
  C_Timer = {NewTicker = function(_, callback)
    timers[#timers + 1] = callback
    return {}
  end}
  assert(loadfile("NotchBar.lua"))("NotchBar")
  eventFrame.callback(eventFrame, "PLAYER_LOGIN")
  if loadOffhandLater then
    Offhand = {}
    eventFrame.callback(eventFrame, "ADDON_LOADED", "Offhand")
  end
  if Offhand then
    WorldFrame:SetAllPoints(UIParent) -- Offhand's real disabled/reset relationship
  else
    local _, relative = UIParent:GetPoint(1)
    assert(relative == (preference == false and screen or WorldFrame))
  end
  for _, callback in ipairs(timers) do callback() end
  eventFrame.callback(eventFrame, "DISPLAY_SIZE_CHANGED")
  eventFrame.callback(eventFrame, "PLAYER_REGEN_ENABLED")
  assert(bar.shown, "notch bar must remain visible")
  assert(NotchBarDB.fixUIParent == (preference ~= false), "preference changed")
  if Offhand then
    local _, relative = UIParent:GetPoint(1)
    assert(relative == screen, "UIParent must retain its original screen anchors")
  end
end

scenario(true, false, true)
scenario(false, true, true)
scenario(false, false, true)
scenario(false, false, false)
print("PASS: Offhand at login/later load, ticker, display changes, standalone, preference, bar visibility")
