# my_script : the commands called by i3 and polybar (see README.md), built by nixos/configuration.nix.
# Only bin/my_script is on the PATH, the commands are in libexec/my_script/.
{ lib, stdenvNoCC, makeWrapper, rofi, python3, kitty, libnotify
, feh, i3lock-color, xdotool, xclip # X (i3)
, swaylock-effects, wl-clipboard, cliphist, wtype # Wayland (sway)
}:

let
  # the tools used by the commands (the others, like i3-msg or code, come from the system)
  # (nmcli of vpn_menu comes from networking.networkmanager)
  runtimeDeps = [ rofi python3 kitty libnotify feh i3lock-color xdotool xclip swaylock-effects wl-clipboard cliphist wtype ];
in
stdenvNoCC.mkDerivation {
  pname = "my_script";
  version = "2.0";
  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  # a syntax error in a command fails the build (update_config.sh) instead of a shortcut silently
  doCheck = true;
  nativeCheckInputs = [ python3 ];
  checkPhase = ''
    for script in my_script.sh lib.sh commands/*.sh; do bash -n "$script"; done
    python3 -c 'import ast, sys; [ast.parse(open(f).read(), f) for f in sys.argv[1:]]' commands/*.py
  '';

  installPhase = ''
    mkdir -p $out/libexec/my_script $out/bin
    cp -r my_script.sh lib.sh commands rofi $out/libexec/my_script/
    makeWrapper $out/libexec/my_script/my_script.sh $out/bin/my_script \
      --prefix PATH : ${lib.makeBinPath runtimeDeps}
  '';
}
