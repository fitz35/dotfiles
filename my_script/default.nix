# my_script : the commands called by i3 and polybar (see README.md), built by nixos/configuration.nix.
# Only bin/my_script is on the PATH, the commands are in libexec/my_script/.
{ lib, stdenvNoCC, makeWrapper, rofi, python3, kitty, feh, i3lock-color, xdotool, xclip, libnotify, sshpass }:

let
  # the tools used by the commands (the others, like i3-msg or code, come from the system)
  runtimeDeps = [ rofi python3 kitty feh i3lock-color xdotool xclip libnotify sshpass ];
in
stdenvNoCC.mkDerivation {
  pname = "my_script";
  version = "2.0";
  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/libexec/my_script $out/bin
    cp -r my_script.sh lib.sh commands rofi $out/libexec/my_script/
    makeWrapper $out/libexec/my_script/my_script.sh $out/bin/my_script \
      --prefix PATH : ${lib.makeBinPath runtimeDeps}
  '';
}
