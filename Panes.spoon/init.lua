print("IN INIT")

Panes = {}

-- Internal function used to find our location, so we know where to load files from
local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
Panes.spoonPath = script_path()

local WindowSet = dofile(Panes.spoonPath.."/window_set.lua")

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

  OneWindowSet:showIndicators()

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
  OneWindowSet:showIndicators()
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


--------

return Panes
