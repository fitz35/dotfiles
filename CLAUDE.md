# Dotfiles : notes for Claude Code

Read [README.md](README.md) for the layout (one row per folder) and [PLAN.md](PLAN.md) for the work in progress.

## How it works
- `nixos/` is a NixOS flake built from the repo (stable release only, never nixos-unstable). Apply a change : `sh nixos/update_config.sh` (needs sudo : tell me to run it, don't run it yourself).
- The home configuration is plain files linked into `~` by `install.sh` (no home-manager : `/home` is shared with Fedora). A new config file = a new `link` line in `install.sh`.
- Sway is the default session, i3 the fallback : `i3/common.conf` is shared by both, the Wayland-only parts are in `sway/`. Reload : `swaymsg reload` (waybar restarts with it).
- `my_script/` : the commands of the bars and shortcuts, one file per command in `my_script/commands/`, packaged by `my_script/default.nix`. Try a command without rebuilding : `bash my_script/my_script.sh <command>`. The build checks the syntax (`bash -n`, python `ast`).
- `zed/` : Zed settings, keymap and tasks (Zed writes into `settings.json` itself, its changes land here).

## Rules
- The repository is public : never commit the wifi certificates, the NAS address / Tailscale name / shares, the `nas` ssh hosts, or touch the hashed password. Check the diff before each commit.
- Nerd Font icons : write them as `\u` escapes (raw private-use characters get dropped when a file is written).
- On NixOS the process names are often `.<name>-wrapped` : use `pgrep -f`.
- Comments explain the why, in English, with a space before `:` like the existing ones.
- Commit messages : `<area> : <what changed>` (e.g. `waybar : ...`, `zed : ...`), one commit per topic.

## Monitoring
- Disk alert at 80 % : `my_script clean`. Claude usage : `my_script claude_usage report` (real % : `/usage`).
- Context hook thresholds : top of `claude/hooks/context_reminder.py`. `claude/settings.json` is also written by Claude Code : check its diff before each commit.
- The waybar Claude module shows the real % (as `/usage`) read from `https://api.anthropic.com/api/oauth/usage` (header `anthropic-beta: oauth-2025-04-20`, token from `~/.claude/.credentials.json`, read only, never copied). This endpoint is undocumented : if the bar falls back to the log-based estimate (tooltip says "estimate"), test it by hand, then fix `real_usage()` in `my_script/commands/claude_usage.py` (expected keys : `five_hour` / `seven_day` with `utilization` and `resets_at`). The bar runs the Nix-packaged copy : rebuild (`sh nixos/update_config.sh`) after an edit.
