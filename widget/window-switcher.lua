-------------------------------------------------
-- Window switcher for Awesome Window Manager
-- Modified version from troglobit:
-- https://github.com/troglobit/awesome-switcher
-------------------------------------------------

local cairo = require("lgi").cairo
local wibox = require('wibox')
local math = require('math')
local awful = require('awful')
local gears = require("gears")
local naughty = require("naughty")

local surface = cairo.ImageSurface(cairo.Format.RGB24,20,20)
local cr = cairo.Context(surface)

-- Global awesome classes
local keygrabber = keygrabber
local mouse = mouse
local screen = screen
local client = client

-- Lua specific functions
local table = table
local string = string
local unpack = unpack or table.unpack

local _M = {}

--	preview_box_bg = "#333333CC",
--	preview_box_title_color = {150, 150, 150, 0.8},
-- default settings

local settings = {
	preview_box = true,
	preview_box_bg = "#ddddddCC",
	preview_box_border = "#22222200",
	preview_box_delay = 100,
	preview_box_title_font = {"sans","italic","normal"},
	preview_box_title_font_size_factor = 0.8,
	preview_box_title_color = {0, 0, 0, 0.8},

	client_opacity = false,
	client_opacity_value_selected = 1,
    client_opacity_value_in_focus = 0.5,
	client_opacity_value = 0.5,

	cycle_raise_client = true,
}

-- Create a wibox to contain all the client-widgets
-- We set the type to desktop to make picom ignore it and not create shadows
_M.preview_wbox = wibox( { type = "desktop" })
_M.preview_wbox.ontop = true
_M.preview_wbox.visible = false

-- Apply settings
_M.preview_wbox:set_bg(settings.preview_box_bg)
_M.preview_wbox.border_color = settings.preview_box_border

_M.preview_widgets = {}

_M.altTabTable = {}
--_M.altTabIndex = 1
local idx = 1
_M.historyTable = {}

_M.source = string.sub(debug.getinfo(1,'S').source, 2)
_M.path = string.sub(_M.source, 1, string.find(_M.source, "/[^/]*$"))
_M.noicon = _M.path .. "noicon.png"

--local taskPopup = awful.popup {
--    widget = awful.widget.tasklist {
--        screen   = awful.screen.focused(),
--        filter   = awful.widget.tasklist.filter.currenttags,
--        buttons  = tasklist_buttons,
--        style    = {
--            bg_focus = "#fcba03",
--            bg_normal = "0",
--        },
--        layout   = {
--            spacing = 5,
--            forced_num_rows = 1,
--            layout = wibox.layout.grid.horizontal
--        },
--        widget_template = {
--            {
--                {    
--                   {
--                      id     = "clienticon",
--                      widget = awful.widget.clienticon,
--                      forced_height = 80,
--                   },
--                widget = wibox.container.place,
--                },
--                {
--                   {
--                      id     = "clienttext",
--                      widget = wibox.widget.textbox,
--                      text   = '...',
--                      align = 'center',
--                   },
--                widget = wibox.container.background,
--                bg = "#615532",
--                },
--                widget  = wibox.layout.fixed.vertical,
--                fill_space = true
--            },
--            id              = "background_role",
--            forced_width    = 120,
--            forced_height   = 120,
--            widget          = wibox.container.background,
--            create_callback = function(self, c, index, objects) --luacheck: no unused
--                self:get_children_by_id("clienticon")[1].client = c
--                self:get_children_by_id("clienttext")[1].text = c.class
--            end,
--        },
--    },
--    border_width = 0,
--    bg = "0",
--    ontop        = true,
--    placement    = awful.placement.centered,
--    opacity      = 0.8,
--    visible      = false,
--    type = "desktop"  -- setting the type to desktop makes picom ignore it
--}

-- this function returns the list of clients to be shown.
local function getClients()
	local clients = {}
	local s = mouse.screen;

	-- Minimized clients will not appear in the focus history
	-- Find them by cycling through all clients, and adding them to the list
	-- if not already there.
	-- This will preserve the history AND enable you to focus on minimized clients
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
		end

		if isCurrentTag then
            table.insert(clients, c)
		end
	end

	return clients
end

local function createPreviewText(client)
    local text 
	if client.class then
		text =  "  " .. client.class
	else
		text =  "  " .. client.name
	end
    
    if string.len(text) > 17 then
        text = string.sub(text, 1, 14)
        text = text .. "..."
    end

    return text
end

-- Preview is created here.
local function clientOpacity()
	if not settings.client_opacity then return end

	local opacity = settings.client_opacity_value
	for i,data in pairs(_M.altTabTable) do
		data.client.opacity = opacity
	end

	if client.focus == _M.altTabTable[_M.altTabIndex].client then
		-- Let's normalize the value up to 1.
	--	local opacityFocusSelected = settings.client_opacity_value_selected + settings.client_opacity_value_in_focus
	--	if opacityFocusSelected > 1 then opacityFocusSelected = 1 end
		client.focus.opacity = settings.client_opacity_value_selected
	else
		-- Let's normalize the value up to 1.
		local opacityFocus = settings.client_opacity_value_in_focus
	--	if opacityFocus > 1 then opacityFocus = 1 end
		local opacitySelected = settings.client_opacity_value_selected
	--	if opacitySelected > 1 then opacitySelected = 1 end

		client.focus.opacity = opacityFocus
		_M.altTabTable[_M.altTabIndex].client.opacity = opacitySelected
	end
end

local function newAltTabTable()
	local clients = getClients()

	_M.altTabTable = {}

    -- reset selected index of altTabTable
    idx = 1

    for i = 1, #clients do
    	table.insert(_M.altTabTable, {
    	client = clients[i],
    	minimized = clients[i].minimized,
    	opacity = clients[i].opacity
       })
       _M.historyTable[i] = i
    end 
end

local function updateAltTabTable(client)
    -- If it has the same window id then it's probably called by signal 'unmanage'
    for i = 1, #_M.altTabTable do
        if client.window == _M.altTabTable[i].client.window then
            table.remove(_M.altTabTable, i)
            return
        end
    end
    -- If it's a new client we add it to the table
    table.insert(_M.altTabTable, {
        client = client,
        minimized = client.minimized,
        opacity = client.opacity
    })
end

local function cyclePreview(dir)
	-- Switch to next client
    for i = 1, #_M.altTabTable do
        local c = awful.client.focus.history.get(screen[1], i-1)
        if c then
            for j = 1, #_M.altTabTable do
                if c == _M.altTabTable[j].client then
                    _M.historyTable[i] = j
                    break
                end
            end
        else
            _M.historyTable[i] = i
        end
    end

   -- for i=1, #awful.client.focus.history.list do
   --     log_this(tostring(i))
   -- end
	idx = idx + dir
	if idx > #_M.altTabTable then
		idx = 1 -- wrap around
	elseif idx < 1 then
		idx = #_M.altTabTable -- wrap around
	end

    --log_this(tostring(idx))
    -- Update selected client
    _M.preview()

    -- Unminimize
	_M.altTabTable[_M.historyTable[idx]].client.minimized = false

    -- Settings
	if not settings.preview_box and not settings.client_opacity then
		client.focus = _M.altTabTable[_M.historyTable[idx]].client
	end
	if settings.client_opacity and _M.preview_wbox.visible then
		clientOpacity()
	end
	if settings.cycle_raise_client then
		_M.altTabTable[_M.historyTable[idx]].client:raise()
	end
end

function _M.preview()
	if not settings.preview_box then return end


	-- Make the wibox the right size, based on the number of clients
	local n = math.max(7, #_M.altTabTable)
	local W = screen[mouse.screen].geometry.width -- + 2 * _M.preview_wbox.border_width
	local w = W / n -- widget width
	local h = w * 0.75  -- widget height
	local textboxHeight = w * 0.125

	local x = screen[mouse.screen].geometry.x + (W - w*#_M.altTabTable) / 2
	local y = screen[mouse.screen].geometry.y + (screen[mouse.screen].geometry.height - h - textboxHeight) / 2
	_M.preview_wbox:geometry({x = x, y = y, width = w*#_M.altTabTable, height = h + textboxHeight})

	local text, textWidth, textHeight
	local bigFont = textboxHeight / 2

	local smallFont = bigFont * settings.preview_box_title_font_size_factor

	_M.preview_widgets = {}

	-- create all the widgets
	for i = 1, #_M.altTabTable do
		local c = _M.altTabTable[_M.historyTable[i]].client

		_M.preview_widgets[i] = wibox.widget.base.make_widget()
		_M.preview_widgets[i].fit = function(preview_widget, width, height)
			return w, h
		end
		_M.preview_widgets[i].draw = function(preview_widget, preview_wbox, cr, width, height)
            -- a is the scale of client image
			local a = 0.8
            -- overlay is the opacity of blackness on client images
		--	local overlay = 0.6
			local fontSize = smallFont
			if c == _M.altTabTable[_M.historyTable[idx]].client then
				a = 0.9
			--	overlay = 0
				fontSize = bigFont
			end

            -- sx and sy means to scale and tx and ty means to move
			local sx, sy, tx, ty

			-- Icons
			local icon
			if c.icon == nil then
				icon = gears.surface(gears.surface.load(_M.noicon))
			else
				icon = gears.surface(c.icon)
			end

			local iconboxWidth = 1 * textboxHeight
			local iconboxHeight = iconboxWidth

			-- Titles
            -- select_font_face: family, slant, weight
            -- unpack is a lua keyword
        	cr:select_font_face(unpack(settings.preview_box_title_font))
        	cr:set_font_face(cr:get_font_face())
			cr:set_font_size(fontSize)

			text = createPreviewText(c)
			textWidth = cr:text_extents(text).width
			textHeight = cr:text_extents(text).height

			local titleboxWidth = textWidth + iconboxWidth
			local titleboxHeight = textboxHeight

			-- Draw icons
			tx = (w - titleboxWidth) / 2
            ty = 20
			sx = iconboxWidth / icon.width
			sy = iconboxHeight  / icon.height

            -- translate means to move the context (x + tx, y + ty)
			cr:translate(tx, ty)
            -- scale so the icon is not too small or too large
			cr:scale(sx, sy)
            -- 0 and 0 is the coordinates x and y
			cr:set_source_surface(icon, 0, 0)
			cr:paint()

            -- Restore scaling (scaling is additive)
            -- cr:scale(sx, sy) -> cr:scale(sx*1/sx, sy*1/sy)
			cr:scale(1/sx, 1/sy)
            -- Go back to where we started
			cr:translate(-tx, -ty)

			-- Draw titles
			tx = tx + iconboxWidth
			ty = textboxHeight + iconboxHeight / 4
			cr:set_source_rgba(unpack(settings.preview_box_title_color))
            -- Moves cairo path
			cr:move_to(tx, ty)
            -- Draws the text
			cr:show_text(text)
            -- A drawing operator that strokes the current path according to the current
            -- line width, line join, line cap, and dash settings.
            -- After cairo_stroke(), the current path will be cleared from the cairo context.
			cr:stroke()

			-- Draw previews content (images)
			local cg = c:geometry()
			if cg.width > cg.height then
				sx = a * w / cg.width
				sy = math.min(sx, a * h / cg.height)
			else
				sy = a * h / cg.height
				sx = math.min(sy, a * h / cg.width)
			end

			tx = (w - sx * cg.width) / 2
			ty = (h - sy * cg.height) / 2 + textboxHeight

            -- Client image
			local content = gears.surface(c.content)
			cr:translate(tx, ty)
			cr:scale(sx, sy)
			cr:set_source_surface(content, 0, 0)
			cr:paint()
            -- This function finishes the surface and drops all references to external resources.
            -- For example, for the Xlib backend it means that cairo will no longer access the drawable, which can be freed. 
			content:finish()

			-- Overlays
		--	cr:scale(1/sx, 1/sy)
		--	cr:translate(-tx, -ty)
            -- Set a black background with opacity(overlay)
		--	cr:set_source_rgba(0,0,0,overlay)
		--	cr:rectangle(tx, ty, sx * cg.width, sy * cg.height)
		--	cr:fill()
		end
	end

	--layout
	local preview_layout = wibox.layout.fixed.horizontal()

    -- Add everything together
	for i = 1, #_M.altTabTable do
		preview_layout:add(_M.preview_widgets[i])
	end

	_M.preview_wbox:set_widget(preview_layout)
end


-- This starts the timer for updating and it shows the preview UI.
local function showPreview()
	_M.preview()
	_M.preview_wbox.visible = true

	--clientOpacity()
end

function switch(dir, mod_key1, release_key, mod_key2, key_switch)
	if #_M.altTabTable == 0 then
		return
	elseif #_M.altTabTable == 1 then
		_M.altTabTable[1].client.minimized = false
		_M.altTabTable[1].client:raise()
		return
	end

	-- preview delay timer
	local previewDelayTimer = gears.timer({timeout = (settings.preview_box_delay / 1000)})
	previewDelayTimer:connect_signal("timeout", function()
		previewDelayTimer:stop()
		showPreview()
	end)
	previewDelayTimer:start()

	-- Now that we have collected all windows, we should run a keygrabber
	-- as long as the user is alt-tabbing:
	keygrabber.run(
		function (mod, key, event)
			-- Stop alt-tabbing when the alt-key is released
			if gears.table.hasitem(mod, mod_key1) then
				if (key == release_key) and event == "release" then
					if _M.preview_wbox.visible then
						_M.preview_wbox.visible = false
					else
						previewDelayTimer:stop()
					end

					-- Raise clients in order to restore history
					local c
					for i = 1, idx - 1 do
						c = _M.altTabTable[_M.historyTable[idx - i]].client
						if not _M.altTabTable[i].minimized then
							c:raise()
							client.focus = c
						end
					end

					-- raise chosen client on top of all
					c = _M.altTabTable[_M.historyTable[idx]].client
					c:raise()
					client.focus = c

                    idx = 1
					-- restore minimized clients
					for i = 1, #_M.altTabTable do
						if i ~= _M.historyTable[idx] and _M.altTabTable[i].minimized then
							_M.altTabTable[i].client.minimized = true
						end
						_M.altTabTable[i].client.opacity = _M.altTabTable[i].opacity
					end
					

					keygrabber.stop()
				
                -- Pressed tab
				elseif key == key_switch and event == "press" then
					if gears.table.hasitem(mod, mod_key2) then
						-- Move to previous client on Shift-Tab
						cyclePreview(-1)
					else
						-- Move to next client on each Tab-press
						cyclePreview(1)
					end
                end
			end
		end
	)

	-- switch to next client
	cyclePreview(dir)

end 

_G.client.connect_signal('manage', updateAltTabTable) -- opened a new client
_G.client.connect_signal('unmanage', updateAltTabTable) -- closed a client
_G.tag.connect_signal('property::selected', newAltTabTable) -- tag changed

return {switch = switch, settings = settings}
