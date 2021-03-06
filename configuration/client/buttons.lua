local awful = require('awful')
local gears = require('gears')

local modkey = require('configuration.keys.mod').modKey

return gears.table.join(
  awful.button(
    {},
    1,
    function(c)
      _G.client.focus = c
      c:raise()
    end
  ),
  awful.button({modkey}, 1, awful.mouse.client.move),
  awful.button({modkey}, 3, awful.mouse.client.resize)
  )
