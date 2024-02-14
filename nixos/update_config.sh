# update the configuration file and generte a new generation

# assets and patch
BACKGROUND_PATH="../assets/login_images" # without trailing slash, to be copied in /etc/nixos
sudo cp -r $BACKGROUND_PATH /etc/nixos/
IMG=$(ls /etc/nixos/login_images/ | shuf -n 1)
sudo cp "/etc/nixos/login_images/$IMG" "/etc/nixos/"

# home manager
sudo rm /etc/nixos/home.nix
sudo cp ./home.nix /etc/nixos/home.nix

# flake
sudo rm /etc/nixos/flake.nix
sudo cp ./flake.nix /etc/nixos/flake.nix

# configuration
sudo rm /etc/nixos/configuration.nix
sudo cp ./configuration.nix /etc/nixos/configuration.nix

#rebuild
sudo nixos-rebuild switch --show-trace
