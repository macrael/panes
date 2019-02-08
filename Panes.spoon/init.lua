print("IN INIT")

Panes = {}

local OneWindowSet = nil

function Panes:init()
	OneWindowSet = WindowSet:new()
end

Panes.name = "Panes"
Panes.version = "0.0.0"
Panes.author = "MacRae Linton macrae.linton@gmail.com"
Panes.license = "MIT"


function Panes:hello()
	print("HELLO THERE, YOU Lkk NICE TODAY")
end


function Panes:addTopWindowToSet()
	print("HI", OneWindowSet)

  local win = hs.window.focusedWindow()

	OneWindowSet:add(win)

	print("ADDED")
end


function Panes:focusSet()
	print("LO")

	OneWindowSet:focus()
end


function Panes:showSet()

	print("SHOWING")

	OneWindowSet:showIndicators()

end

function Panes:removeTopWindowFromSet()
	print("REMOVING")
  local win = hs.window.focusedWindow()
	OneWindowSet:remove(win)
end


function Panes:bindHotkeys(mapping)
   if mapping["hello"] then
      if (self.key_show_grid) then
         self.key_show_grid:delete()
      end
      self.key_show_grid = hs.hotkey.bindSpec(mapping["hello"], Panes.hello)
   end

   if mapping["addTopWindowToSet"] then
      if (self.key_addTopWindowToSet) then
         self.key_addTopWindowToSet:delete()
      end
      self.key_addTopWindowToSet = hs.hotkey.bindSpec(mapping["addTopWindowToSet"], Panes.addTopWindowToSet)
   end

   if mapping["focusSet"] then
      if (self.key_focusSet) then
         self.key_focusSet:delete()
      end
      self.key_focusSet = hs.hotkey.bindSpec(mapping["focusSet"], Panes.focusSet)
   end

   if mapping["showSet"] then
      if (self.key_showSet) then
         self.key_showSet:delete()
      end
      self.key_showSet = hs.hotkey.bindSpec(mapping["showSet"], Panes.showSet)
   end

   if mapping["removeTopWindowFromSet"] then
      if (self.key_removeTopWindowFromSet) then
         self.key_removeTopWindowFromSet:delete()
      end
      self.key_removeTopWindowFromSet = hs.hotkey.bindSpec(mapping["removeTopWindowFromSet"], Panes.removeTopWindowFromSet)
   end

end

-----------

-- Window Set Stuff.
WindowSet = {}

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
	for i, win in ipairs(self._windows) do
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

--------

return Panes
