local awful = require('awful')

local client_list = {}
local check = true

-- initialization
awful.spawn.with_shell("mkdir -p /tmp/client-screenshots")
awful.spawn.easy_async("ls /tmp/client-screenshots", function (stdout, stderr, reason, exit_code)
    for match in string.gmatch(stdout, "%a+") do
        client_list[match] = true
    end
end)

local function screenshot_client(client)
    local command = "import -window " .. 
                    client.window .. " /tmp/client-screenshots/" .. client.window .. ".jpg"

    if (client_list[client.window] == true and check) then
        awful.spawn(command);
       -- awful.spawn.easy_async(command,
       -- function (stdout, stderr, reason, exit_code)
       --      log_this("title", stderr)
       -- end)
    else 
        client_list[client.window] = true
    end
end

local function remove_screenshot_client(client)
    client_list[client.window] = nil
    check = false
    local command = "rm /tmp/client-screenshots/" .. client.window
    awful.spawn.easy_async_with_shell(command,
    function(stdout, stderr, reason, exit_code)
    end)
end

_G.client.connect_signal('unfocus', screenshot_client)
--_G.client.connect_signal('unmanage', remove_screenshot_client)
