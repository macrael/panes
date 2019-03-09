
local WindowSet = {}

function WindowSet:new()
  -- _windows is an ordered list of window objects.
  -- in order of raising, so the one to be focused is last.
	local ws = { _windows = {} }

  setmetatable(ws, self)
  self.__index = self
  return ws
end

function WindowSet:add(window)
	print('add', window)

  local extantIndex = nil
  for i, win in ipairs(self._windows) do
    if win:id() == window:id() then
      extantIndex = i
      break
    end
  end

  if extantIndex then
    table.remove(self._windows, extantIndex)
  end

  table.insert(self._windows, window)

end

function WindowSet:remove(window)
	print('remove', window)

  local extantIndex = nil
  for i, win in ipairs(self._windows) do
    if win:id() == window:id() then
      extantIndex = i
      break
    end
  end

  if extantIndex then
    table.remove(self._windows, extantIndex)
  else
    print("TRIED TO REMOVE WINDOW NOT IN LIST")
  end

end

function WindowSet:focus()
  local focusedID = hs.window.focusedWindow():id()
  local focusWindow = nil
  local raiseWindows = {}

  if #self._windows == 0 then
    print("Nothing to return")
    return
  end

  -- raise all windows but the last in the current order
  -- focus the last
  -- if one of the windows is currently focused, focus it instead
  -- if all the windows are already on top (already focused) then cycle, sending front to back
	for i, win in ipairs(self._windows) do
    print(win)
    print(win:role())
    print(win:subrole())
    if win:id() == focusedID then
      focusWindow = win
    elseif i == #self._windows and focusWindow == nil then
      focusWindow = win
    else
      table.insert(raiseWindows, win)
    end
	end

  focusWindow:focus()

  for i, win in ipairs(raiseWindows) do
    win:raise()
  end

end

function WindowSet:sendToBack()

end

function WindowSet:showIndicators()
  local HACKPrimaryScreen = hs.screen.primaryScreen()
  local f = HACKPrimaryScreen:fullFrame()

  local c = hs.canvas.new{x=f.x, y=f.y, w=f.w, h=f.h}
  print(c)
  for id, win in pairs(self._windows) do
    local border = win:borderElement()
    c:appendElements(border)
  end
  c:show()
  c:delete(2.0)
end

--

function hs.window:borderElement()

  local f = self:frame()
  local fx = f.x - 2
  local fy = f.y - 2
  local fw = f.w + 4
  local fh = f.h + 4

  local elem = {
    type = "rectangle",
    frame = { x = fx, y = fy, w = fw, h = fh },
    action = "stroke",
    strokeWidth = 4,
    strokeColor = {["red"]=0.75,["blue"]=0.14,["green"]=0.83,["alpha"]=0.80},
    roundedRectRadii = { xRadius = 5.0, yRadius = 5.0},
  }

  return elem

end

return WindowSet
