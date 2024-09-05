# flake.nix for /etc/nixos/
{
  description = "Custom Clement's NixOS configuration";

  inputs = {
       # WARNING : CAN'T DECLARE REUSABLE VARIABLES HERE

      # Official NixOS package source
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
      
      # Minecraft grub2 theme
      minegrub-theme.url = "github:0nyr/minegrub-theme"; 
      #minegrub-theme.url = "github:Lxtharia/minegrub-theme"; # -> this the official repo, but the customization of the splashs doesnt work https://github.com/Lxtharia/minegrub-theme/pull/35 
    
      my_personnal_script.url = "github:fitz35/my_personnal_script";
    };

  outputs = {nixpkgs, ...} @ inputs: {
    # replace whatever comes after nixosConfigurations with your hostname.
    # My laptop configuration
    nixosConfigurations.nixos = let 
      config = import ./config_nix.nix;
    in nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        { _module.args.inputs = inputs; } # pass "inputs" to configurtion.nix, making available myscript into the configuration
        ./configuration.nix
        inputs.minegrub-theme.nixosModules.default
      ];
    };
  };
}