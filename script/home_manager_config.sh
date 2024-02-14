

home_manager_folder="$1.config/home-manager"


mkdir -p "$home_manager_folder"

rm -f -- "$home_manager_folder/home.nix"
ln "../home_manager/home.nix" "$home_manager_folder/home.nix"

rm -f -- "$home_manager_folder/flake.nix"
ln "../home_manager/flake.nix" "$home_manager_folder/flake.nix"

rm -f -- "$home_manager_folder/config_nix.nix"
ln "../nixos/config_nix.nix" "$home_manager_folder/config_nix.nix"
