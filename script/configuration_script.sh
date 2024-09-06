#!/bin/sh
# This script will configure i3, polybar, and other visuel elements of the system.

# Check if exactly one argument is provided (wich is the home directory ->  can run this script from anywhere)
if [ $# -ne 1 ]; then
    echo "Usage: $0 home_directory"
    exit 1
fi

home_directory="$1"

# Check if the home directory exists
if [ ! -d $home_directory ]; then
    echo "Error: $home_directory is not a directory"
    exit 1
fi

# Check the presence of the .config folder
if [ ! -d "$home_directory/.config" ]; then
    echo "Error: $home_directory/.config does not exist"
    exit 1
fi

if [[ $home_directory != */ ]]; then
    home_directory="$home_directory/"
fi

# ------------------ fonts ------------------
echo "Installing fonts..."
# Check if the fonts folder exists
if [ ! -d "$home_directory/.fonts" ]; then
    echo "Creating $home_directory/.fonts"
    mkdir "$home_directory/.fonts"
fi

# Copy the fonts if they are not already present
fonts_name=("CustomJetBrainsMonoNFFantasqueSansMNF-Italic.ttf" "CustomJetBrainsMonoNFFantasqueSansMNF-Regular.ttf")

for font in "${fonts_name[@]}"; do
    if [ ! -f "$home_directory/.fonts/$font" ]; then
        echo "Copying $font to $home_directory/.fonts"
        cp ../fonts/$font "$home_directory/.fonts/$font"
    fi
done

# on nixos, are loaded automatically
#fc-cache -fv

# ------------------ prepare the file system ------------------
cleaning_and_create_folder() {
    folder="$1"
    echo "Creating and cleaning $folder"
    if test -d "$folder"; then
        rm -rf $folder
    fi
    mkdir -p $folder
}
echo "Preparing the file system..."
# assets
assets_folder="$home_directory.config/assets"
cleaning_and_create_folder $assets_folder

# greenclip
greenclip_config_file="$home_directory.config/greenclip.toml"
xinitrc_file="$home_directory/.xinitrc"
if test -e "$greenclip_config_file"; then
    rm $greenclip_config_file
fi
if test -e "$xinitrc_file"; then
    rm $xinitrc_file
fi


# my_script
my_script_folder="$home_directory.config/my_script"
cleaning_and_create_folder $my_script_folder

# ------------------ copy the configuration files ------------------
echo "Copying the configuration files..."
# assets
echo "cp assets..."
cp -r ../assets/* $assets_folder

# greenclip
echo "ln greenclip configuration files..."
ln ../greenclip/greenclip.toml $greenclip_config_file
ln ../greenclip/.xinitrc $xinitrc_file


# my_script
echo "ln my_script configuration files..."
ln ../my_script/config.json $my_script_folder/config.json

# i3
echo "cp i3 configuration files..."
sh ./i3_config.sh $home_directory

# polybar
echo "cp polybar configuration files..."
sh ./polybar_config.sh $home_directory

# openvpn
echo "cp openvpn configuration files..."
sh ./openvpn_config.sh $home_directory

# home manager
#echo "cp home manager configuration files..."
#sh ./home_manager_config.sh $home_directory

# awesome
echo "cp awesome configuration files..."
sh ./awesome_config.sh $home_directory