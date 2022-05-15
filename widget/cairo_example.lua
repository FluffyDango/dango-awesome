-- This is for anyone lost in how to use cairo in awesomeWM
-- add this to rc.lua
-- require('widget.cairo_example')


local wibox = require('wibox')
local cairo = require("lgi").cairo

local surface = cairo.ImageSurface(cairo.Format.RGB24,20,20)
local cr = cairo.Context(surface)

my_wbox = wibox()
my_wbox.visible = true
my_wbox:set_bg("#ff0000")

cairo_widget = wibox.widget.base.make_widget()

cairo_widget.fit = function(context, width, height) 
    return 100, 100
end
cairo_widget.draw = function(self, my_wbox, cr, width, height)
    cr:translate(100, 100)
    cr:set_source_rgb(0,0,0)
    cr:rectangle(0, 0, 100, 100)
    cr:fill()
end

my_wbox:set_widget(cairo_widget)
my_wbox:geometry({x=50, y=50, width=500, height=500})
