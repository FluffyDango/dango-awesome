local awful = require('awful')
require('awful.autofocus')
local beautiful = require('beautiful')
local hotkeys_popup = require('awful.hotkeys_popup').widget
local taskPopup = require('widget.taskWidget')
local switcher = require('widget.window-switcher')
    switcher.settings.preview_box_title_font = { beautiful.font, 'italic', 'normal' }

local modkey = require('configuration.keys.mod').modKey
local altkey = require('configuration.keys.mod').altKey
local apps = require('configuration.apps')
local languages = require('configuration.languages')

local Xscreen1 = 'off'
local Xscreen2 = 'auto'

-- Key bindings
local globalKeys =
  awful.util.table.join(
  -------------------------------  AWESOME  ---------------------------------------------------
  awful.key({modkey}, 'F1', hotkeys_popup.show_help, {description = 'Show help', group = 'awesome'}),
  
  awful.key({modkey, 'Control'}, 'r', _G.awesome.restart, {description = 'reload awesome', group = 'awesome'}),
  awful.key({modkey, 'Control'}, 'q', _G.awesome.quit, {description = 'quit awesome', group = 'awesome'}),
  
  awful.key(
    {modkey, 'Shift'},
    'r',
    function()
      awful.spawn('reboot')
    end,
    {description = 'Reboot Computer', group = 'awesome'}
  ),
  
  awful.key(
    {modkey, 'Shift'},
    'e',
    function()
      awful.spawn('shutdown now')
    end,
    {description = 'Shutdown Computer', group = 'awesome'}
  ),
  
  awful.key(
    {modkey, 'Shift'},
    'l',
    function()
      _G.exit_screen_show()
    end,
    {description = 'Log Out Screen', group = 'awesome'}
  ),
  
  
  -------------------------------  CLIENT  ---------------------------------------------------
  awful.key(
    {modkey},
    'u', 
    awful.client.urgent.jumpto,
    {description = 'jump to urgent client', group = 'client'}
  ),

  awful.key(
    {altkey},
    'Tab',
    function()
        switcher.switch(1, "Mod1", "Alt_L", "Shift", "Tab")
    end,
    {description = 'Switch to next window', group = 'client'}
  ),

  awful.key(
    {altkey, 'Shift'},
    'Tab',
    function()
        switcher.switch(-1, "Mod1", "Alt_L", "Shift", "Tab")
    end,
    {description = 'Switch to previous window', group = 'client'}
  ),
  
  awful.key(
    {modkey, 'Control'},
    'n',
    function()
      local c = awful.client.restore()
      -- Focus restored client
      if c then
        _G.client.focus = c
        c:raise()
      end
    end,
    {description = 'restore minimized', group = 'client'}
  ),
  
  
  -------------------------------  HOTKEYS  ---------------------------------------------------
  -- Speakers
  awful.key(
    {'Control', 'Shift'},
    'F1',
    function()
       awful.spawn.with_shell("pactl set-default-sink alsa_output.usb-C-Media_Electronics_Inc._USB_PnP_Sound_Device-00.analog-stereo; " .. "pactl set-default-source alsa_input.usb-C-Media_Electronics_Inc._USB_PnP_Sound_Device-00.mono-fallback")
    end,
    {description = 'switch to speakers', group = 'hotkeys'}
  ),
  
  -- Headphones
  awful.key(
    {'Control', 'Shift'},
    'F2',
    function()
       awful.spawn.with_shell("pactl set-default-sink alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink; " .. "pactl set-default-source alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__source")
    end,
    {description = 'switch to headphones', group = 'hotkeys'}
  ),

  awful.key(
    {modkey},
    'a',
    function()
      awful.util.spawn_with_shell('ibus emoji')
    end,
    {description = 'Open the ibus emoji picker to copy an emoji to your clipboard', group = 'hotkeys'}
  ),
  
  awful.key(
    {modkey, 'Shift'},
    'F1',
    function()
      if Xscreen1 == 'auto' then 
          Xscreen1 = 'off'
      else
          Xscreen1 = 'auto'
      end
      awful.spawn('xrandr --output eDP-1 --' .. Xscreen1)
    end,
    {description = 'Switch off or on screen 1', group = 'hotkeys'}
  ),
  awful.key(
    {modkey, 'Shift'},
    'F2',
    function()
      if Xscreen2 == 'auto' then 
          Xscreen2 = 'off'
      else
          Xscreen2 = 'auto'
      end
      awful.spawn('xrandr --output HDMI-0 --' .. Xscreen2)
    end,
    {description = 'Switch off or on screen 2', group = 'hotkeys'}
  ),
  
  -- Lock screen
  awful.key(
    {modkey},
    'l',
    function()
      awful.spawn(apps.default.lock)
    end,
    {description = 'Lock the screen', group = 'hotkeys'}
  ),
  
  -- Screenshot
  awful.key(
    {},
    'Print',
    function()
      awful.util.spawn_with_shell(apps.default.region_screenshot)
    end,
    {description = 'Screenshot an area', group = 'hotkeys'}
  ),

  awful.key(
    {altkey},
    'Shift_L',
    function()
      languages:inc(1)
    end,
    {description = 'Change language', group = 'hotkeys'}
  ),

  awful.key(
    {modkey},
    'Home',
    function()
        awful.spawn.with_shell('feh --randomize --bg-fill ~/Pictures/wallpapers/Anime/*')
    end,
    {description = 'Change background', group = 'hotkeys'}
  ),

  awful.key(
    {},
    'Home',
    function()
        awful.spawn.with_shell('feh --randomize --bg-fill ~/Pictures/wallpapers/.pictures/*')
    end
  ),


 -- awful.key(
 --   {},
 --   'XF86MonBrightnessUp',
 --   function()
 --     awful.spawn('xbacklight -inc 10')
 --   end,
 --   {description = '+10%', group = 'hotkeys'}
 -- ),

 -- awful.key(
 --   {},
 --   'XF86MonBrightnessDown',
 --   function()
 --     awful.spawn('xbacklight -dec 10')
 --   end,
 --   {description = '-10%', group = 'hotkeys'}
 -- ),

  awful.key(
    {modkey},
    'p',
    function()
        awful.spawn("passmenu -fn 'Roboto-14'")
    end,
    {description = 'dmenu for pass', group = 'hotkeys'}
  ),
  
  
  -------------------------------  LAUNCHER  ---------------------------------------------------
  -- Editor
  awful.key(
    {modkey},
    'c',
    function()
      awful.util.spawn(apps.default.editor)
    end,
    {description = 'Open text/code editor', group = 'launcher'}
  ),
  
  -- Browser
  awful.key(
    {modkey},
    'b',
    function()
      awful.util.spawn(apps.default.browser)
    end,
    {description = 'Open browser', group = 'launcher'}
  ),

  -- Terminal
  awful.key(
    {modkey},
    'x',
    function()
      awful.spawn(apps.default.terminal)
    end,
    {description = 'Open terminal', group = 'launcher'}
  ),
  
  -- File Manager
  awful.key(
    {modkey},
    'e',
    function()
      awful.util.spawn(apps.default.files)
    end,
    {description = 'Open file browser', group = 'launcher'}
  ),
  
  -- Menu
  awful.key(
    {modkey},
    'r',
    function()
      awful.spawn(apps.default.rofi)
    end,
    {description = 'Open Rofi menu', group = 'launcher'}
  ),
  
  
  -------------------------------  LAYOUT  ---------------------------------------------------
  awful.key(
    {modkey},
    'Up',
    function()
        local c = client.focus
        local s = c.screen.workarea
        c.x = s.x
        c.y = s.y
        c.width = s.width
        c.height = s.height
    end,
    {description = 'Resize window to use all of the workarea', group = 'layout'}
  ),

  awful.key(
    {altkey, 'Shift'},
    'Right',
    function()
      awful.tag.incmwfact(0.05)
    end,
    {description = 'Increase master width factor', group = 'layout'}
  ),
  
  awful.key(
    {altkey, 'Shift'},
    'Left',
    function()
      awful.tag.incmwfact(-0.05)
    end,
    {description = 'Decrease master width factor', group = 'layout'}
  ),
  
  awful.key(
    {altkey, 'Shift'},
    'Down',
    function()
      awful.client.incwfact(0.05)
    end,
    {description = 'Decrease master height factor', group = 'layout'}
  ),
  
  awful.key(
    {altkey, 'Shift'},
    'Up',
    function()
      awful.client.incwfact(-0.05)
    end,
    {description = 'Increase master height factor', group = 'layout'}
  ),
  
  awful.key(
    {modkey, 'Shift'},
    'Left',
    function()
      awful.tag.incnmaster(1, nil, true)
    end,
    {description = 'Increase the number of master clients', group = 'layout'}
  ),
  
  awful.key(
    {modkey, 'Shift'},
    'Right',
    function()
      awful.tag.incnmaster(-1, nil, true)
    end,
    {description = 'Decrease the number of master clients', group = 'layout'}
  ),
  
  awful.key(
    {modkey, 'Control'},
    'Left',
    function()
      awful.tag.incncol(1, nil, true)
    end,
    {description = 'Increase the number of columns', group = 'layout'}
  ),
  
  awful.key(
    {modkey, 'Control'},
    'Right',
    function()
      awful.tag.incncol(-1, nil, true)
    end,
    {description = 'Decrease the number of columns', group = 'layout'}
  ),
  
  awful.key(
    {modkey},
    'space',
    function()
      awful.layout.inc(1)
    end,
    {description = 'Select next', group = 'layout'}
  ),
  
  awful.key(
    {modkey, 'Shift'},
    'space',
    function()
      awful.layout.inc(-1)
    end,
    {description = 'Select previous', group = 'layout'}
  ),
  
  
  -------------------------------  TAG  ---------------------------------------------------
  -- Open default program for tag
  awful.key(
    {modkey},
    't',
    function()
      awful.spawn(
          awful.screen.focused().selected_tag.defaultApp,
          {
            tag = _G.mouse.screen.selected_tag,
            placement = awful.placement.bottom_right
          }
        )
    end,
    {description = 'Open default program for tag/workspace', group = 'tag'}
  ),
  
    -- Tag browsing
  awful.key({modkey}, 'w', awful.tag.viewprev, {description = 'view previous', group = 'tag'}),
  awful.key({modkey}, 's', awful.tag.viewnext, {description = 'view next', group = 'tag'})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  -- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
  local descr_view, descr_toggle, descr_move, descr_toggle_focus
  if i == 1 or i == 9 then
    descr_view = {description = 'view tag #', group = 'tag'}
    descr_toggle = {description = 'toggle tag #', group = 'tag'}
    descr_move = {description = 'move focused client to tag #', group = 'tag'}
    descr_toggle_focus = {description = 'toggle focused client on tag #', group = 'tag'}
  end
  globalKeys =
    awful.util.table.join(
    globalKeys,
    -- View tag only.
    awful.key(
      {'Control', 'Shift'},
      '#' .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          tag:view_only()
        end
      end,
      descr_view
    ),
    -- Toggle tag display.
    awful.key(
      {modkey, 'Control'},
      '#' .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end,
      descr_toggle
    ),
    -- Move client to tag.
    awful.key(
      {modkey, 'Shift'},
      '#' .. i + 9,
      function()
        if _G.client.focus then
          local tag = _G.client.focus.screen.tags[i]
          if tag then
            _G.client.focus:move_to_tag(tag)
          end
        end
      end,
      descr_move
    ),
    -- Toggle tag on focused client.
    awful.key(
      {modkey, 'Control', 'Shift'},
      '#' .. i + 9,
      function()
        if _G.client.focus then
          local tag = _G.client.focus.screen.tags[i]
          if tag then
            _G.client.focus:toggle_tag(tag)
          end
        end
      end,
      descr_toggle_focus
    )
  )
end

return globalKeys
