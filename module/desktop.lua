local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')

local cairo = require("lgi").cairo
local surface = cairo.ImageSurface(cairo.Format.ARGB32,10,10)
local cr = cairo.Context(surface)


local mousegrabber = mousegrabber
local client = client
local mouse = mouse
local root = root

desktop = {}

-- Type desktop because it makes picom ignore it
desktop_wbox = wibox({ type="desktop" })
desktop_wbox.bg = "#4287f580"
desktop_wbox.border_color = "#0565ff"
desktop_wbox.border_width = 1

local function getClients()
	local clients = {}
	local s = mouse.screen;

	-- Minimized clients will not appear in the focus history
	-- Find them by cycling through all clients, and adding them to the list
	local t = s.selected_tags
	local all = client.get(s)

	for i in pairs(all) do
		local c = all[i]
		local ctags = c:tags();

		-- check if the client is on the current tag
		local isCurrentTag = false
		for j in pairs(ctags) do
            for z in pairs(t) do 
		    	if t[z] == ctags[j] then
		    		isCurrentTag = true
		    		break
		    	end
            end
            if isCurrentTag then break end
		end

		if isCurrentTag then
            table.insert(clients, c)
		end
	end

	return clients
end


root.buttons(awful.util.table.join(
    awful.button({}, 1, function() desktop:mouse_click() end)
))

function desktop:mouse_click() 
    local starting_coords = mouse.coords()
    desktop_wbox.visible = true
    desktop_wbox.screen = mouse.screen

    local X, Y, w, h

    mousegrabber.run(function(fmouse)
        --log_this('x=' .. fmouse.x .. ' y=' .. fmouse.y)
        -- added + 2 at the end, because width and height has to be > 1
        w = fmouse.x - starting_coords.x + 2
        h = fmouse.y - starting_coords.y + 2
        X = starting_coords.x
        Y = starting_coords.y

        if w <= 1 then
            X = fmouse.x + 2
            w = starting_coords.x - fmouse.x
        end
        if h <= 1 then
            Y = fmouse.y + 2
            h = starting_coords.y - fmouse.y
        end

        desktop_wbox:geometry({x=X, y=Y, width=w, height=h})

        -- fmouse.buttons[1] is left click button (bool)
        if not fmouse.buttons[1] then
            desktop_wbox.visible = false

            desktop_wbox:geometry({x=0, y=0, width=1, height=1})
            mousegrabber.stop()
        end
        -- return true to keep running
        return true
    end, "arrow")
end
