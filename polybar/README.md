# Installation

## Fedora

```shell
sudo dnf install polybar
sudo dnf install rofi
```

## ubuntu
```shell
sudo apt install polybar rofi

```

## Configuration

To config :

```shell
mkdir ~/.config/polybar/
ln ./config_placeholder.ini ~/.config/polybar/config_placeholder.ini
ln ./launch.sh ~/.config/polybar/launch.sh
ln ./logout_menu.sh ~/.config/polybar/logout_menu.sh
chmod +x ~/.config/polybar/logout_menu.sh
```

The script launch regenerate the config.ini replacing the placeholder.

## Bluetooth

In order to add the bluetooth module, `blueberry` must be installed. Crédit [here](https://github.com/msaitz/polybar-bluetooth).

## spotify

Repo [here](https://github.com/PrayagS/polybar-spotify/tree/master). Dependencies :

```shell
zscroll playerctl 
```

# My_script

[here](https://github.com/fitz35/my_personnal_script) are my personnal script. PAckage with nixos.

# Fonts

## Install fonts from [Nerd Fonts](https://www.nerdfonts.com/#home)

Download the fonts you want, for instance **JetBrainsMono**, `unzip JetBrainsMono.zip`, then `cp *.ttf ~/.fonts/`. Now, update the font cache with `fc-cache -fv`. You can check for installed fonts with `fc-list | grep "SomeFontName"`.

> Remember to use a terminal application that support well Nerd Fonts like [Kitty](https://github.com/kovidgoyal/kitty).

`$ fc-list | grep -i "JetBrains"`: list installed JetBrains fonts
