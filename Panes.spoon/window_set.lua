
local WindowSet = {}

function WindowSet:new()
	local ws = { _windows = {},  -- the list of windows in the set in order
                    _realOrder = {},
                    _upTop = false,  -- the current mode, are we cycling or not
                    _watcherfn = nil,  -- the function doing the watching
                    _currentRaise = nil } -- the current window being raised so the watcher can ignore it

  setmetatable(ws, self)
  self.__index = self
  ws:_startWatcher()

  return ws
end

function WindowSet:add(window)
	print('add', window)

  if self:_contains(window) then
    -- we should already have it at the right place.
    return
  end

  table.insert(self._windows, window, 1)
  table.insert(self._realOrder, window, 1)

  -- should probably reset order here?

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

  extantIndex = nil
  for i, win in ipairs(self._realOrder) do
    if win:id() == window:id() then
      extantIndex = i
      break
    end
  end

  if extantIndex then
    table.remove(self._realOrder, extantIndex)
  else
    print("TRIED TO REMOVE WINDOW NOT IN LIST")
  end

end

function WindowSet:removeAll()

  self._windows = {}
  self._realOrder = {}
  self._upTop = false
  self._currentRaise = nil

  print("Zeroed out")

end


  -- windows are in order, top most at the end of the list.


-------- OPTION 1

  -- Above: take all the windows, pick out the ones in the set and put them in order
  -- shouldCycle means that all windows are on the top already.

  -- next, raise them all up.
  -- save their current order


  -- if they are already on top:
  -- bring the next on in order to the top

  -- IF you click on one??? how do you reset the order?
  -- have an expected order thing?
  -- use the events?

  -- we have the current order
  -- if they are on top and in the current order, we cycle
  -- we don't know how to cycle them based on only the current order (that's the problem)
  -- fucking horrible.

  -- every time you hit it, we get the current order
  -- cycle order plus expectd current order. if expected current order is wrong, then we consider that a reset.
  -- can start cycling based on that.
  -- every time we cycle, we move the ring one, and we shift the "expected order" thing. and we raise one.
  -- if we are at the top and the order doesn't match the expected order, we reset the order
  -- this seems right

-- + no modes
-- - have to check the whole orderedWindows every time

  -- ALTERNATIVELY

-- + fast
-- + maintains the origional saved order? (-)? -- can mitigate with checking the order on RAISE
-- modes, suck.

  -- MODE: LOW
  -- click button, bring things up
    -- do we have to check the current order for this?
    -- what if one of the cycle is currently selected?
  -- set MODE: HIGH, start listening (make sure that the fn hasn't been set?,nah)

  -- MODE: HIGH
  -- click button, cycle through things
  -- change the order, raise the one

  -- LISTEN
  -- one of the windows in the set is focused:
    -- reset the order, still HIGH
    -- any way to do this without doing the orderedWindowsDance?
  -- one of the windows not in the set is focused:
   -- set mode: LOW, stop listening


------- AVOID THE WINDOW CHECK

-- set the "made frontmost" tap on creation
-- every time we add a window, we put it on the top of our list of windows
-- we maintain actual order and cycle order.
-- any time a window that isn't ours is put frontmost, we save the actual order.



--------

function WindowSet:focus()

  if #self._windows == 0 then
    print("Nothing to return")
    return
  end

  if not self._upTop then

    -- raise all windows but the last in the current order
    -- focus the last
    self._windows[1]:focus()

    -- then raise the rest of them.
    for i = #self._windows, 2, -1 do
      local win = self._windows[i]
      print(win)
      win:raise()
    end

    -- then, focus the front most
    self._windows[1]:focus()

    -- set up watchers, state management
    self._upTop = true

  else
    print("CYCLING")
    local frontMost = table.remove(self._windows, 1)
    table.insert(self._windows, frontMost)

    self._currentRaise = self._windows[1]
    self._windows[1]:focus()

    -- update Real order.

    self:_bringRealToTop(self._currentRaise)

  end

end

function WindowSet:_startWatcher()

  if self._watcherfn ~= nil then
    print("ERROR, should have cleared the watcher!")
  end

  self._watcherfn = function(window, appName)
      print("HELLO,")
      print(self)
      print("Focused: " .. window:title())

      if self:_contains(window) then
        -- if we click on a window that's in the set...
        -- Update our orderings. -- we can always update real ordering...
        -- can we update cycle order as well?

        -- cycle order is updated when cycling, I think.
        -- if you click on a window though, we should probably reset the whole order?
        -- other option?
        -- just put that one on the end of the cycle order?
        -- nah, we should reset.
        -- we have to check that it's not being focused by a button switch
        self:_bringRealToTop(window)

        if self._currentRaise ~= nil and window:id() == self._currentRaise:id() then
          print("No need to do anything here.")
          self._currentRaise = nil
        else
          -- reset the current order

          self._windows = {}
          for i, win in ipairs(self._realOrder) do
            table.insert(self._windows, win)
          end
        end
      else
        print("Clearing the watchers.")
        self._upTop = false
      end

  end

  print("WELL")
  hs.window.filter.default:subscribe(hs.window.filter.windowFocused, self._watcherfn)
  print("SUBSCRIBED")
  print("Does this do new windows?")

end

function WindowSet:_stopWatcher()

  hs.window.filter.default:unsubscribe(self._watcherfn)
  self._watcherfn = nil

end


function WindowSet:showIndicators()
  local HACKPrimaryScreen = hs.screen.primaryScreen()
  local f = HACKPrimaryScreen:fullFrame()

  local c = hs.canvas.new{x=f.x, y=f.y, w=f.w, h=f.h}
  print(c)
  for id, win in pairs(self._windows) do
    local border = win:_borderElement()
    c:appendElements(border)
  end
  c:show()
  c:delete(2.0)
end

--

-- Look at the current order of things, put _windows in that order
function WindowSet:_resetOrder()

  -- can benchmark this against the default windowset ordered by last focused
  -- but i bet it's the same.
  local allOrderedWindows = hs.window.orderedWindows()
  print(allOrderedWindows)

  local orderedWindowSet = {}

  local foundCount = 0
  local shouldCycle = false
  for i, oWin in ipairs(allOrderedWindows) do
    print(oWin)
    print(oWin:id())

    if self:_contains(oWin) then
      table.insert(orderedWindowSet, oWin)
    end

    print(i)
    print(foundCount)

    if #orderedWindowSet == #self._windows then
      if #orderedWindowSet == i then
        -- All of them are on top
        shouldCycle = true
      end
      break
    end
  end

  self._windows = orderedWindowSet

  return shouldCycle

end


function WindowSet:_contains(win)

  print(self)

  for i, setWin in ipairs(self._windows) do
    if setWin:id() == win:id() then
      return true
    end
  end
  return false
end

function WindowSet:_bringRealToTop(window)

  local extantIndex = nil
  for i, win in ipairs(self._realOrder) do
    if win:id() == window:id() then
      extantIndex = i
      break
    end
  end

  if extantIndex == nil then
    print("WOAH THERE Gotta be in both all the time!")
  else
    table.remove(self._realOrder, extantIndex)
    table.insert(self._realOrder, self._currentRaise, 1)
  end

end


function hs.window:_borderElement()

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
