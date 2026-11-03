# my_script

The commands of my i3 / polybar setup (rofi menus, lock, wallpaper, polybar modules), packaged by `default.nix` and installed by `nixos/configuration.nix` : edit a command, then `sh nixos/update_config.sh`. To try a change without rebuilding : `bash my_script/my_script.sh <command>` (needs the runtime tools of `default.nix` on the PATH).

```shell
my_script <command> [arguments]
```

| Command | Called by | Description |
|---|---|---|
| `chronometer <toggle\|reset\|display>` | polybar | stopwatch |
| `timer <add [s]\|toggle\|reset\|display>` | polybar | countdown (60s by default, scroll ±5s) |
| `uptime [-display_entry]` | polybar | daily time spent on the computer, saved in `~/daily_uptime.txt` (analysed in [my_personnal_script](https://github.com/fitz35/my_personnal_script)) |
| `github_menu <code\|terminal>` | i3 `$mod+t` / `$mod+Alt+t` | open a project folder (`PARENT_FOLDERS` / `HAND_PICKED_FOLDERS`) in vscode (inside `nix develop` if it has a flake) or kitty |
| `vpn_menu` | i3 `$mod+w` | start a vpn / ssh connection in kitty |
| `greenclip` | i3 `$mod+v` | clipboard history, paste the chosen entry |
| `logout_menu` | i3 `$mod+Escape`, power button, polybar | lock / logout / reboot / shutdown |
| `lock` | xss-lock, `logout_menu` | i3lock-color lock screen |
| `wallpaper` | i3 at login | random wallpaper of the dotfiles assets, every `INTERVAL` seconds |
| `rofi <arguments>` | i3 `$mod+d`, the menus | rofi with a random theme of `rofi/themes/` ([themes](https://github.com/newmanls/rofi-themes-collection)) |

A command is a file of `commands/` (`.sh` or `.py`), it calls the others through `$MY_SCRIPT` (e.g. `"$MY_SCRIPT" rofi -dmenu`) and the shared helpers are in `lib.sh`.
