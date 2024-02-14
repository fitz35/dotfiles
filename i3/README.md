# Installation

## Fedora

Install the i3 desktop : `sudo dnf group install "i3 Desktop"`

Install the lightDm manager : `sudo dnf install lightdm lightdm-gtk`

After the installation, add a link from `~/.config/i3/config` : `ln ./config ~/.config/i3/config`

## Ubuntu

Install i3 : `sudo apt install i3`

## Rofi

Rofi must be installed

## Kitty

kitty too

> Warn : to use kitty with ssh, type `kitten` before. Like : `kitten ssh truc@truc.fr`

## xss-lock

xss-lock too

## Multiscreen

[here](https://fedoramagazine.org/using-i3-with-multiple-monitors/) to read. Use [autorandr](https://github.com/phillipberndt/autorandr) to handle multiple screen configuration.

# Power button

To capture the power buton, check `/etc/systemd/logind.conf`. For nixos [here](https://nixos.wiki/wiki/Logind). (that disable the default behavior, then use i3 to capture it)
