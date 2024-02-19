awesome_folder="$1.config/awesome"


mkdir -p "$awesome_folder"
rm -f -- "$awesome_folder/rc.lua"
ln "../awesome_wm/rc.lua" "$awesome_folder/rc.lua"
rm -f -- "$awesome_folder/theme.lua"
ln "../awesome_wm/theme.lua" "$awesome_folder/theme.lua"