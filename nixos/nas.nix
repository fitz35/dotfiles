# The NAS's shares (Samba, guest), through Tailscale : at home the connection goes direct over the home network,
# away it goes through Tailscale. Mounted when first opened, unmounted after 10 idle minutes ; NAS off or unreachable
# → the folder answers an error after ~10 s instead of freezing. Turning tailscale off unmounts them at once.
#
# The private values (address, shares) are in nas.privateFile, outside this public repository (like the wifi
# certificates), so the rebuild is --impure (update_config.sh). Without this file, nothing is configured. Content :
#   { address = "<tailscale address of the NAS>"; mountPoint = "/mnt/nas"; shares = [ "Documents" ... ]; }
{ config, lib, pkgs, myConf, ... }:

let
  cfg = config.nas;
  nas = if builtins.pathExists cfg.privateFile then import (/. + cfg.privateFile) else null;
  user = config.users.users.${myConf.USER_NAME};

  mountPath = share: "${nas.mountPoint}/${share}";
  # systemd name of the mount unit (/mnt/nas/Documents → mnt-nas-Documents.mount)
  mountUnit = share: "${lib.replaceStrings [ "/" ] [ "-" ] (lib.removePrefix "/" (mountPath share))}.mount";
in
{
  options.nas.privateFile = lib.mkOption {
    type = lib.types.str;
    default = "/etc/nixos/nas-private.nix";
    description = "File with the private values of the NAS (address, mountPoint, shares).";
  };

  config = lib.mkIf (nas != null) {
    fileSystems = lib.listToAttrs (map (share: lib.nameValuePair (mountPath share) {
      device = "//${nas.address}/${share}";
      fsType = "cifs";
      options = [
        "guest" "vers=3.0" "uid=${toString (if user.uid != null then user.uid else 1000)}" "gid=100"
        "noauto" "nofail" "_netdev"
        "x-systemd.automount" "x-systemd.idle-timeout=600"
        "x-systemd.mount-timeout=10s"
        "x-systemd.after=tailscaled.service"
      ];
    }) nas.shares);

    # tailscale off (vpn menu, tailscale down) : unmount the shares at once, else they freeze on the dead connection ;
    # the automount stays armed, so they come back when opened with tailscale on
    systemd.services.nas-follow-tailscale = {
      description = "Unmount the NAS shares when tailscale is off";
      after = [ "tailscaled.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ config.services.tailscale.package pkgs.jq pkgs.util-linux ];
      script = ''
        while sleep 5; do
          if [ "$(tailscale status --json 2>/dev/null | jq -r .BackendState)" != "Running" ]; then
            ${lib.concatMapStringsSep "\n" (share: ''
              if systemctl -q is-active ${mountUnit share}; then
                echo "tailscale is off : unmounting ${mountPath share}"
                # a file still open makes it busy : then detach it anyway (the automount below stays armed)
                systemctl stop ${mountUnit share} || umount --lazy --force ${mountPath share}
              fi'') nas.shares}
          fi
        done
      '';
    };
  };
}
