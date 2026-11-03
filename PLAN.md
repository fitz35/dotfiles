# my_script : diagnostic and plan (merge into dotfiles, VPN, Sway next to i3)

## Status
- [x] Phase 0 : plan saved in the repo
- [x] Phase 1 : my_script inside dotfiles, same behaviour
- [x] Phase 2 : polybar timers without polling
- [ ] Phase 3 : Inria VPN through NetworkManager
- [ ] Phase 4 : my_script works on X and Wayland
- [ ] Phase 5 : Sway session next to i3
- [ ] Phase 6 : remove the X-only parts (later, my decision)

## Context
`my_personnal_script` exists to make frequent actions one keystroke away (rofi menus, polybar modules, lock, wallpaper), and to plug easily into NixOS. Today it does the job, but it costs more than it should:

| Area | Finding |
|---|---|
| Edit loop | It's a separate repo pulled as a GitHub flake input, so a 1-line script change = push → `flake_update.sh` → rebuild. It's only used by the dotfiles (its config lives there too). |
| Packaging | `cp -r src/* $out/bin` puts `common.sh`, `__init__.py`, `default_config.json`, `my_script.py`, `my_script.sh`, `my_script.pth` on the system PATH. `src = self` includes the uptime data and the 1 MB notebook, so every data commit makes a new package. The version string is hard-coded. |
| Dispatcher | Each call goes bash → python (load JSON config, merge, convert to env vars) → bash. ~40 ms per call; polybar runs 2 calls/s (chronometer + timer, even when hidden). |
| Config system | `default_config.json` + `~/.config/my_script/config.json` merge, passed as env vars: 3 values in total (github folders, wallpaper interval, mount dir). |
| vpn_menu | Shows nothing: no real `.env` exists, only `.bk` templates. Plain-text passwords by design, `sudo openvpn/openconnect`, `sshpass`. The Inria VPN is actually used through `~/Documents/certificat/inria-intern/connect_to_vpn.sh` (`sudo openconnect --script ./vpnc_script --cafile ./Chain-TCS-4-OV.pem vpn.inria.fr`, password typed in the terminal). A NetworkManager connection `vpn inria` also exists, but **no NM VPN plugin is installed** (26.05 no longer adds them by default), so it can't connect. |
| X-only parts | lock (i3lock-color), greenclip (+ xdotool / xclip), wallpaper (feh), logout (`i3-msg exit`). These are what a Sway move touches. |
| Unused | manage_disk (your answer). |

Goal (your answers): **merge my_script into dotfiles**, the **Inria VPN through NetworkManager** (INSA / Passau dropped), delete **manage_disk**, then make everything work on **Sway too, with i3 kept** until Sway is fine for daily use. `my_personnal_script` becomes the uptime-analysis repo only.

## Phase 0 : keep this plan in the repo
- Copy this plan as `dotfiles/PLAN.md` (linked from the README), commit and push, so it isn't lost. Each later phase ticks its line there.

## Phase 1 : my_script inside dotfiles, same behaviour (1 commit per repo)
- New `dotfiles/my_script/` (replaces the current `my_script/config.json` folder):
  - `default.nix` : `stdenvNoCC.mkDerivation`, `src = ./.`, installs `commands/`, `lib.sh`, `rofi/` into `$out/libexec/my_script/`, and only `bin/my_script` (makeWrapper, `--prefix PATH` with the runtime deps : rofi python3 kitty feh i3lock-color xdotool xclip libnotify). No glibcLocales (NixOS already sets LOCALE_ARCHIVE).
  - `my_script.sh` : dispatcher `my_script <command> [args]` → runs `commands/<command>.sh` or `commands/<command>.py` (python3), lists the commands when unknown. `my_script rofi …` = `commands/rofi.sh` (random theme, same as today).
  - `commands/` : chronometer, timer, uptime.py, github_menu.py, vpn_menu, logout_menu, lock, greenclip, wallpaper, rofi. `lib.sh` = today's `common.sh` (`format_time`).
  - The 3 config values become constants at the top of their script (github folders, wallpaper interval) : `default_config.json`, `common.py`'s merge, the env-var passing and the `install.sh` link go away.
- Delete manage_disk : script, i3 `$mod+u` binding, its README line, and the `disk` group of the user (its only purpose; the polkit prompt now handles GUI mounts).
- NixOS : `my_script = pkgs.callPackage ../my_script { };` in `configuration.nix`; remove the `my_personnal_script` flake input (`nix flake lock` only drops it, other versions unchanged).
- `my_personnal_script` repo : keep `src/analyze/`, `daily_uptime_save/`, `JUPYTER.md`, the flake `devShell`; delete the package output, `src/script`, `src/python`, `src/rofi`, `run_without_nixos.sh`; README = "uptime analysis of `~/daily_uptime.txt` (recorded by the dotfiles `my_script uptime`)".

## Phase 2 : polybar timers without polling (1 commit)
- chronometer / timer get a `watch` subcommand (loop : display, sleep 1). Polybar modules : `exec = my_script timer watch`, `tail = true`, no `interval`. One long-running process instead of 2 spawns per second; clicks still call toggle / reset / add. Same design works for waybar later.

## Phase 3 : Inria VPN through NetworkManager (1 commit + one manual step)
The INSA and Passau VPNs and the Passau ssh servers are no longer needed : only the Inria VPN stays.
- NixOS : `networking.networkmanager.plugins = [ pkgs.networkmanager-openconnect ];` (makes `vpn inria` usable). Drop the `openvpn` user package (only used for Passau).
- `vpn inria` set like `connect_to_vpn.sh` (I check its settings with `nmcli`, you fix what differs in `nm-connection-editor`) : AnyConnect, gateway `vpn.inria.fr`, CA certificate = the chain file of `~/Documents/certificat/inria-intern/` (kept out of the repos, like the wifi certificates), password saved in the keyring. NetworkManager sets the routes and DNS itself, so the `vpnc_script` copy isn't needed. Once `vpn inria` connects, `connect_to_vpn.sh` can be retired (your call, the certificates folder stays).
- `vpn_menu` rewritten (bash, a few lines) : rofi list of the NM VPN connections (● active / ○ inactive), selecting one toggles `nmcli connection up/down`, result in a dunst notification. No sudo, no plaintext, no terminal.
- Delete `openvpn/` from dotfiles (INSA / Passau templates, `client.ovpn`), its `install.sh` copy and README lines, then your local `~/.config/openvpn/` (confirmed first).

## Phase 4 : my_script works on X and Wayland (1 commit)
- `lib.sh` : `is_wayland` (`$WAYLAND_DISPLAY`) and `wm_msg` (`swaymsg` / `i3-msg`).
- lock : i3lock-color on X, swaylock-effects on Wayland (same colors, clock, indicator). greenclip : greenclip + xdotool on X, cliphist + wl-copy + wtype on Wayland. logout : `wm_msg exit`. wallpaper : feh on X, `swaymsg output '*' bg <file> fill` on Wayland. rofi 2.0, kitty, github_menu, vpn_menu, uptime : already both.
- Runtime deps add swaylock-effects, wl-clipboard, cliphist, wtype.

## Phase 5 : Sway session next to i3 (several commits, tested day to day)
- NixOS : `programs.sway.enable` (+ `wrapperFeatures.gtk`, extraPackages waybar kanshi swayidle grim slurp), `xdg.portal.wlr.enable` (screen sharing : Zoom, Discord, Firefox). GDM then offers "Sway" and "i3".
- Config sharing : `i3/config` split into `common.conf` (bindings, workspace names, assigns, rules, both syntaxes are the same) included by `i3/config` (X-only : polybar, xss-lock, greenclip daemon, flameshot) and a new `sway/config` (input : fr layout, numlock, touchpad ; `bar { swaybar_command waybar }` ; swayidle 2 min → `my_script lock` ; cliphist store ; polkit, nm-applet `--indicator`, dunst as today). `install.sh` links `sway/`, `waybar/`, `kanshi/`.
- Screens : 9 kanshi profiles converted from the autorandr ones (positions, rotation of DP-1-2, modes), outputs identified by make/model/serial (sway names MST outputs differently, e.g. DP-5). Each profile's `exec` runs `screen_management.py` (Wayland path : `swaymsg -t get_outputs`, `screen.json` matched by output description instead of EDID) then `rearrange_workspaces.py` (works with `swaymsg`, same IPC). workspaces.conf / screens.conf unchanged.
- waybar (`waybar/config.jsonc` + `style.css`, polybar colors) : sway/workspaces, sway/window, battery, mpris (spotify), pulseaudio, backlight, memory, cpu, temperature, network, bluetooth, `my_script` timer / chronometer / uptime (custom, `watch`), clock, power → `my_script logout_menu`, tray.
- Wayland-specific fixes : Thunderbird reminder rule by `app_id` + title (no window_role on Wayland), screenshots `$mod+Print` → grim + slurp (flameshot is unreliable on Sway).
- Risks to check during daily use : Zoom / Discord screen sharing, XWayland apps (Spotify, Zoom, xmind), dock hotplug with kanshi, Thunderbird popups (the rotated-screen issue should disappear).

## Phase 6 (later, your decision) : remove the X-only parts
Once Sway is your daily session : polybar, autorandr + xrandr path of screen_management.py, xss-lock, greenclip, feh, numlockx, i3lock-color, the i3 session.

## Verification
- Phase 1 : `nixos-rebuild build` from the scratchpad (no `result` in the repo); every command run once : `my_script chronometer display`, `timer display`, `uptime`, `rofi -show drun`, `github_menu code`, `logout_menu` (Return), `lock` (you, unlock), `greenclip`, `wallpaper` restart; `ls /run/current-system/sw/bin | grep -E 'common|__init__|default_config|my_script'` → only `my_script`; `git grep` for `my_personnal_script`, `manage_disk`, `config.json` → none left.
- Phase 2 : polybar shows both timers, clicks work, `pgrep -c -f 'my_script timer'` stays at 1, no process spawned every second.
- Phase 3 : `nmcli connection up "vpn inria"` (you), same access as with `connect_to_vpn.sh` (an internal Inria site / gitlab.inria.fr), the menu toggles it with a connect / disconnect notification; `git grep -i -E 'openvpn|passau|insa'` → nothing left.
- Phase 4 : X behaviour unchanged (same checks); Wayland paths tested in Phase 5.
- Phase 5 : log into Sway from GDM; dock unplug / replug (kanshi + rearrange), lock after 2 min, notifications, clipboard menu, waybar modules, a Zoom screen share; i3 session still works.
- Each phase committed; pushes only when you ask. Privacy rules checked before each push (no certs, no NAS hosts, password hash untouched; the VPN CA files stay in `~/Documents/certificat/`).

Out of scope : changing what the commands do (except vpn_menu), the uptime analysis itself.
