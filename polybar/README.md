# Polybar

Installed by `nixos/configuration.nix`, this folder is linked as `~/.config/polybar` by `install.sh`. `launch.sh` (run by i3 and after each screen switch) starts a bar per screen, with the battery and adapter of the machine (`POLYBAR_BATTERY` / `POLYBAR_ADAPTER`, used by `config.ini`).

## Bluetooth

In order to add the bluetooth module, `blueman` must be installed (`services.blueman.enable` on nixos). Crédit [here](https://github.com/msaitz/polybar-bluetooth).

## spotify

Repo [here](https://github.com/PrayagS/polybar-spotify/tree/master). Dependencies : `zscroll playerctl` (installed by nixos).

# My_script

[here](https://github.com/fitz35/my_personnal_script) are my personnal script. Packaged with nixos.

# Fonts

The bar uses the JetBrainsMono Nerd Font, installed by nixos (`fonts.packages`). You can check for installed fonts with `fc-list | grep -i "JetBrains"`.

> Remember to use a terminal application that support well Nerd Fonts like [Kitty](https://github.com/kovidgoyal/kitty).
