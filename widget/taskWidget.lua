local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local beautiful = require('beautiful')
local gears = require('gears')

local wait = false
local released = false

local taskPopup = awful.popup {
    widget = awful.widget.tasklist {
        screen   = awful.screen.focused(),
        filter   = awful.widget.tasklist.filter.allscreen,
        buttons  = tasklist_buttons,
        style    = {
            bg_focus = "#fcba03",
            bg_normal = "0",
        },
        layout   = {
            spacing = 5,
            forced_num_rows = 2,
            layout = wibox.layout.grid.horizontal
        },
        widget_template = {
            {
                {    
                   {
                      id     = "clienticon",
                      widget = awful.widget.clienticon,
                      forced_height = 80,
                   },
                widget = wibox.container.place,
                },
                {
                   {
                      id     = "clienttext",
                      widget = wibox.widget.textbox,
                      text   = '...',
                      align = 'center',
                   },
                widget = wibox.container.background,
                bg = "#615532",
                },
                widget  = wibox.layout.fixed.vertical,
                fill_space = true
            },
            id              = "background_role",
            forced_width    = 120,
            forced_height   = 120,
            widget          = wibox.container.background,
            create_callback = function(self, c, index, objects) --luacheck: no unused
                self:get_children_by_id("clienticon")[1].client = c
                self:get_children_by_id("clienttext")[1].text = c.class
            end,
        },
    },
    border_width = 0,
    bg = "0",
    ontop        = true,
    placement    = awful.placement.centered,
    opacity      = 0.8,
    visible      = false,
    type = "desktop"  -- setting the type to desktop makes picom ignore it
}

function taskPopup:show(bool)
    if bool then
        wait = true
        released = false
        gears.timer.start_new(0.2, 
        function()
            if not released then
                self.visible = not self.visible
                wait = false
            end
        end)
    else
        released = true
        if not wait then
            self.visible = not self.visible
        end
    end
end

function taskPopup:select_next()
    for client in awful.screen.focused().selected_tags.clients() do
        log_this("title", c)
    end
end

return taskPopup
