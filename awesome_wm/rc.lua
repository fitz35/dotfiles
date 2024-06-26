-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

local sharedtags = require("shared_tags")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local home = os.getenv("HOME")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(home .. "/.config/awesome/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
my_script = "my_script"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.max,
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end


-- define shared tags
local tags = sharedtags({
    { name = "1", layout = awful.layout.layouts[1] },
    { name = "2", layout = awful.layout.layouts[1] },
    { name = "3", layout = awful.layout.layouts[1] },
    { name = "4", layout = awful.layout.layouts[1] },
    { name = "5", layout = awful.layout.layouts[1] },
    { name = "6", layout = awful.layout.layouts[1] },
    { name = "7", layout = awful.layout.layouts[1] },
    { name = "8", layout = awful.layout.layouts[1] },
    { name = "9", layout = awful.layout.layouts[1] },
    { name = "10", layout = awful.layout.layouts[1] },
    { name = "11", layout = awful.layout.layouts[1] },
    { name = "12", layout = awful.layout.layouts[1] },
    { name = "13", layout = awful.layout.layouts[1] },
    { name = "14", layout = awful.layout.layouts[1] },
    { name = "15", layout = awful.layout.layouts[1] },
    { name = "16", layout = awful.layout.layouts[1] },
    { name = "17", layout = awful.layout.layouts[1] },
    { name = "18", layout = awful.layout.layouts[1] },
    { name = "19", layout = awful.layout.layouts[1] },
    { name = "20", layout = awful.layout.layouts[1] }
})
-- set the favourite screen for the tags
tags[1].favourite_screen = "SCREEN_2" 
tags[2].favourite_screen = "SCREEN_2"
tags[3].favourite_screen = "SCREEN_1"
tags[4].favourite_screen = "SCREEN_1"
tags[5].favourite_screen = "SCREEN_2"
tags[6].favourite_screen = "SCREEN_1"
tags[7].favourite_screen = "SCREEN_1"
tags[8].favourite_screen = "SCREEN_1"
tags[9].favourite_screen = "SCREEN_1"
tags[10].favourite_screen = "SCREEN_2"
for i = 11, 20 do
    tags[i].favourite_screen = "SCREEN_3"
end


-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- function to handle screen change
local my_screen = {
    SCREEN_1 = screen[1],
    SCREEN_2 = screen[1],
    SCREEN_3 = screen[1],
}
local screen_command = "python "..home.."/.config/i3/screen_management.py"
local function parse_screen_command_output(str)
    local result = {}
    for line in str:gmatch("[^\n]+") do
        local screen_name, port = line:match("(%w+)%s*=%s*(.+)")
        if port and screen_name then
            result[port] = screen_name
        end
    end
    -- store the number of the screen on the screen and in the my_screen
    for i = 1, #screen do 
        for key, value in pairs(screen[i].outputs) do
            if result[key] then 
                screen[i].my_screen_tag = result[key]
                my_screen[result[key]] = screen[i]

            end
        end
    end
end



awful.screen.connect_for_each_screen(function(s)
    -- redefine the screen layout
    awful.spawn.easy_async_with_shell(screen_command, function (output) 
        parse_screen_command_output(output)
          -- Wallpaper
        set_wallpaper(s)

        -- moove the tags
        -- set the tag to the screens
        for i = 1, #tags do
            sharedtags.movetag(tags[i], my_screen[tags[i].favourite_screen])
        end

        -- Create a promptbox for each screen
        s.mypromptbox = awful.widget.prompt()
        -- Create an imagebox widget which will contain an icon indicating which layout we're using.
        -- We need one layoutbox per screen.
        s.mylayoutbox = awful.widget.layoutbox(s)
        s.mylayoutbox:buttons(gears.table.join(
                            awful.button({ }, 1, function () awful.layout.inc( 1) end),
                            awful.button({ }, 3, function () awful.layout.inc(-1) end),
                            awful.button({ }, 4, function () awful.layout.inc( 1) end),
                            awful.button({ }, 5, function () awful.layout.inc(-1) end)))
        -- Create a taglist widget
        s.mytaglist = awful.widget.taglist {
            screen  = s,
            filter  = awful.widget.taglist.filter.all,
            buttons = taglist_buttons
        }

        -- Create a tasklist widget
        s.mytasklist = awful.widget.tasklist {
            screen  = s,
            filter  = awful.widget.tasklist.filter.currenttags,
            buttons = tasklist_buttons
        }

        -- Create the wibox
        s.mywibox = awful.wibar({ position = "top", screen = s })

        -- Add widgets to the wibox
        s.mywibox:setup {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                mylauncher,
                s.mytaglist,
                s.mypromptbox,
            },
            s.mytasklist, -- Middle widget
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                mykeyboardlayout,
                wibox.widget.systray(),
                mytextclock,
                s.mylayoutbox,
            },
        }
    
    end)
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    --awful.key({ modkey,           }, "", awful.tag.history.restore,
    --          {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),

    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),

    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),

    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),

    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),

    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
        {description = "increase master width factor", group = "layout"}),

    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
            {description = "decrease master width factor", group = "layout"}),

    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
            {description = "increase the number of master clients", group = "layout"}),

    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
            {description = "decrease the number of master clients", group = "layout"}),

    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
            {description = "increase the number of columns", group = "layout"}),

    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
            {description = "decrease the number of columns", group = "layout"}),

    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
            {description = "select next", group = "layout"}),

    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
            {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
            function ()
                local c = awful.client.restore()
                -- Focus restored client
                if c then
                c:emit_signal(
                    "request::activate", "key.unminimize", {raise = true}
                )
                end
            end,
            {description = "restore minimized", group = "client"}),

    -- Standard program
    awful.key({ "Shift", "Control"  }, "t", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "Escape", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "w", function () awful.spawn("nm-connection-editor") end,
                {description = "open network manager", group = "launcher"}),

    -- my_script program
    awful.key({ modkey,      }, "t", function () awful.spawn(my_script.." github_menu code") end,
              {description = "run my_script github menu code", group = "my_script"}),
    awful.key({ modkey,      }, "v", function () awful.spawn(my_script.." greenclip") end,
              {description = "run my_script greenclip", group = "my_script"}),
    awful.key({ modkey, "Shift"}, "t", function () awful.spawn(my_script.." github_menu terminal") end,
              {description = "run my_script github menu terminal", group = "my_script"}),
    awful.key({ modkey,      }, "Escape", function () awful.spawn(my_script.." logout_menu") end,
              {description = "run my_script logout_menu", group = "my_script"}),
    awful.key({ modkey, "Alt"}, "w", function () awful.spawn(my_script.." vpn_menu") end,
              {description = "run my_script vpn_menu", group = "my_script"}),
    awful.key({ modkey, "Alt"}, "u", function () awful.spawn(my_script.." manage_disk") end,
              {description = "run my_script manage_disk", group = "my_script"}),
    awful.key({ modkey, }, "d", function () awful.spawn(my_script.." rofi -show drun") end,
              {description = "run rofi (my_script) d menu", group = "my_script"}),
    

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "a",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    --awful.key({ modkey,           },  ,      function (c) c.ontop = not c.ontop            end,
    --          {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
local function bind_tag(tag_name, key)
    globalkeys = gears.table.join(globalkeys, 
        awful.key({ modkey }, key,
                  function ()
                        local tag = tags[tag_name]
                        if tag then
                           sharedtags.jumpto(tag)
                        end
                  end,
                  {description = "view tag #"..tag_name, group = "tag"}),
    awful.key({ modkey, "Control" }, key,
                  function ()
                    local screen = awful.screen.focused()
                    local tag = tags[tag_name]
                    if tag then
                       sharedtags.viewtoggle(tag, screen)
                    end
                  end,
                  {description = "toggle tag #" .. tag_name, group = "tag"}),
    awful.key({ modkey, "Shift" }, key,
                  function ()
                    if client.focus then
                        local tag = tags[tag_name]
                        if tag then
                            client.focus:move_to_tag(tag)
                        end
                   end
                  end,
                  {description = "move focused client to tag #"..tag_name, group = "tag"}),
    awful.key({ modkey, "Control", "Shift" }, key,
                  function ()
                    if client.focus then
                        local tag = tags[tag_name]
                        if tag then
                            client.focus:toggle_tag(tag)
                        end
                    end
                  end,
                  {description = "toggle focused client on tag #" .. tag_name, group = "tag"})
    )
end


for i = 1, 9 do
    -- use xev to have keycodes
    bind_tag(i, "#" .. i + 9)
    bind_tag(i + 10, "F" .. i)
end
bind_tag(10, "#19")
globalkeys = gears.table.join(globalkeys,
    awful.key({ modkey, "Alt" }, "#12",      
            function () 
                if client.focus then
                    local tag = client.focus.first_tag
                    local screen = client.focus.screen:get_next_in_direction("right")
                    if tag then
                        sharedtags.movetag(tag, screen)
                        sharedtags.jumpto(tag)
                    end
                end
            end,
            {description = "move the focus tag to next screen", group = "tag"}),
    awful.key({ modkey, "Alt" }, "#10",
            function () 
                if client.focus then
                    local tag = client.focus.first_tag
                    local screen = client.focus.screen:get_next_in_direction("left")
                    if tag then
                        sharedtags.movetag(tag, screen)
                        sharedtags.jumpto(tag)
                    end
                end
            end,
            {description = "move the focus tag to prec screen", group = "tag"})
)
clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- set program to tag 
    { rule = { class = "Thunderbird" },
        properties = { tag = tags[1] } },
    -- Set Firefox to always map on the tag named "2" on screen 1.
    { rule = { class = "Firefox" },
        properties = { tag = tags[2] } },
    { rule = { class = "obsidian" },
        properties = { tag = tags[4] } },
    { rule = { class = "Discord" },
        properties = { tag = tags[5] } },
    { rule = { class = "stacer" },
        properties = { tag = tags[10] } },
    { rule = { class = "Spotify" },
        properties = { tag = tags[11] } },
    
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- startup daemon
awful.spawn("greenclip daemon")
awful.spawn("flameshot")



-- startup program
awful.spawn("discord", {
    tag       = "5",
    --screen = awful.screen.focused(),
})

awful.spawn("obsidian " .. home .. "/Documents/github/perso-divers/notes", {
    tag       = "4",
    --screen = awful.screen.focused(),
})

awful.spawn("code " .. home .. "/Documents/github/dotfiles/", {
    tag       = "9",
    --screen = awful.screen.focused(),
})


awful.spawn("stacer", {
    tag       = "10",
    --screen = awful.screen.focused(),
})

awful.spawn("spotify", {
    tag       = "11",
    screen = awful.screen.focused(),
})

awful.spawn("firefox", {
    tag       = "2",
    --screen = awful.screen.focused(),
})

awful.spawn("thunderbird", {
    tag       = "1",
    --screen = awful.screen.focused(),
})