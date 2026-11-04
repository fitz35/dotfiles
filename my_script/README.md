# my_script

The commands of my i3 / sway setup (rofi menus, lock, wallpaper, polybar modules), packaged by `default.nix` and installed by `nixos/configuration.nix` : edit a command, then `sh nixos/update_config.sh`. To try a change without rebuilding : `bash my_script/my_script.sh <command>` (needs the runtime tools of `default.nix` on the PATH).

```shell
my_script <command> [arguments]
```

| Command | Called by | Description |
|---|---|---|
| `chronometer <toggle\|reset\|display\|watch>` | polybar (`watch`) | stopwatch |
| `timer <add [s]\|toggle\|reset\|display\|watch>` | polybar (`watch`) | countdown (60s by default, scroll ±5s) |
| `uptime [-display_entry]` | polybar | daily time spent on the computer, saved in `~/daily_uptime.txt` (analysed in [my_personnal_script](https://github.com/fitz35/my_personnal_script)) |
| `github_menu <zed\|code\|terminal>` | `$mod+t` / `$mod+Shift+t` / `$mod+Alt+t` | open a project folder (`PARENT_FOLDERS` / `HAND_PICKED_FOLDERS`) in a new zed window (even if already open), vscode (both inside `nix develop` if it has a flake) or kitty |
| `vpn_menu` | i3 / sway `$mod+w` | connect / disconnect a NetworkManager VPN (e.g. `vpn inria`) or tailscale, with a notification |
| `clipboard` | i3 / sway `$mod+v` | clipboard history (greenclip in i3, cliphist in sway), paste the chosen entry |
| `logout_menu` | i3 `$mod+Escape`, power button, polybar | lock / logout / reboot / shutdown |
| `lock` | xss-lock / swayidle, `logout_menu` | lock screen (i3lock-color in i3, swaylock-effects in sway) |
| `wallpaper` | i3 / sway at login | random wallpaper of the dotfiles assets, every `INTERVAL` seconds (feh in i3, the sway background in sway) |
| `rofi <arguments>` | i3 `$mod+d`, the menus | rofi with a random theme of `rofi/themes/` ([themes](https://github.com/newmanls/rofi-themes-collection)) |

A command is a file of `commands/` (`.sh` or `.py`), it calls the others through `$MY_SCRIPT` (e.g. `"$MY_SCRIPT" rofi -dmenu`) and the shared helpers are in `lib.sh` (`format_time`, `is_wayland`, `wm_msg` = `i3-msg` or `swaymsg`).
