# Boot : GRUB with the minegrub theme (a random Minecraft background at each boot), the boot console, the shutdown.
{ config, lib, pkgs, inputs, myConf, ... }:

let
  # script to pick a grub background at each boot (randomly choose a minegrub background, shown at the next boot)
  # nixos-rebuild copies the theme in /boot/theme, with the background chosen in the minegrub-theme options
  myGrubBackgroundScript = pkgs.writeShellScript "my-grub-background.sh" ''
    MINEGRUB="${inputs.minegrub-theme}"
    THEME_DIR="/boot/theme"
    [ -d "$THEME_DIR" ] || exit 0

    IMG=$(ls "$MINEGRUB/background_options/" | shuf -n 1)
    cp "$MINEGRUB/background_options/$IMG" "$THEME_DIR/background.png"
    cp "$MINEGRUB/background_options/$IMG" "/boot/background.png"

    # the backgrounds from 1.15 use the modern buttons (same rule as the minegrub update_theme.py)
    STYLE="classic"
    COLORS="#ffffa0 #3f3f28"
    if [[ "$IMG" =~ ^([0-9]+)\.([0-9]+) ]] && (( BASH_REMATCH[1] > 1 || (BASH_REMATCH[1] == 1 && BASH_REMATCH[2] >= 15) )); then
      STYLE="modern"
      COLORS="#ffffff #383838"
    fi
    cp "$MINEGRUB/button_options/$STYLE/"selected_item_*.png "$THEME_DIR/"
    # the first selected_item_color is the text, the second the shadow
    ${pkgs.gawk}/bin/awk -v colors="$COLORS" '
      BEGIN { split(colors, c, " ") }
      /selected_item_color = "/ { n++; sub(/selected_item_color = "[^"]+"/, "selected_item_color = \"" c[n] "\"") }
      { print }
    ' "$THEME_DIR/theme.txt" > "$THEME_DIR/theme.txt.new"
    mv "$THEME_DIR/theme.txt.new" "$THEME_DIR/theme.txt"
    echo "grub background for the next boot : $IMG ($STYLE buttons)"
  '';
in
{
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = false;
      device = "nodev";
      useOSProber = true; # the boot menu also starts Windows and Fedora
      enableCryptodisk = myConf.DISK_ENCRYPTION; # LUKS encryption
      minegrub-theme = {
        enable = true;
        splash = "Lise is watching you !";
        # one of the files in https://github.com/Lxtharia/minegrub-theme/tree/main/background_options
        # only used until the next boot, then my-grub-background picks a random one at each boot
        background = "background_options/1.8  - [Classic Minecraft].png";
        boot-options-count = 7; # place the bottom bar under the 7th entry (same as the 0nyr fork)
      };
      extraEntries = ''
        menuentry "Reboot" {
          reboot
        }
        menuentry "Poweroff" {
          halt
        }
      '';
    };
    efi = {
      efiSysMountPoint = "/boot/efi"; # the EFI partition shared by the 3 OS
      canTouchEfiVariables = true;
    };
  };

  # Change the grub background at each boot (grub is already displayed, so it is used at the next boot)
  systemd.services.my-grub-background = {
    description = "Change the grub background randomly for the next boot";
    wantedBy = [ "multi-user.target" ];
    unitConfig.RequiresMountsFor = "/boot";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${myGrubBackgroundScript}";
      User = "root";
    };
  };

  # don't print the kernel errors on screen at boot (harmless "ACPI BIOS Error (bug)" from the laptop firmware)
  # they are still available with `journalctl -b -p err`
  boot.consoleLogLevel = 3;

  # remove the leftovers (nix-shell.* folders...) of /tmp at each boot
  boot.tmp.cleanOnBoot = true;

  # don't arm the hardware watchdog (iTCO_wdt) at reboot / power off : it only resets a hung reboot after 10min,
  # and prints "watchdog: watchdog0: watchdog did not stop!" at each shutdown
  systemd.settings.Manager.RebootWatchdogSec = "0";
}
