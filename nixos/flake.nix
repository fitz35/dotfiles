# NixOS configuration, built from this repository : sudo nixos-rebuild switch --flake .#<hostname>
{
  description = "Custom Clement's NixOS configuration";

  inputs = {
       # WARNING : CAN'T DECLARE REUSABLE VARIABLES HERE

      # Official NixOS package source
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

      # Minecraft grub2 theme
      # official repo (the splash customization was fixed in https://github.com/Lxtharia/minegrub-theme/pull/35, no need of the 0nyr fork anymore)
      minegrub-theme.url = "github:Lxtharia/minegrub-theme";
      minegrub-theme.inputs.nixpkgs.follows = "nixpkgs"; # use our stable nixpkgs instead of its pinned unstable one
    };

  outputs = {nixpkgs, ...} @ inputs: {
    # one entry per machine, named after its hostname (nixos-rebuild picks it automatically)
    # the machine specific part (hardware, user name...) is in hosts/<hostname>/
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        { _module.args.inputs = inputs; } # pass "inputs" to configuration.nix (minegrub)
        ./configuration.nix
        ./hosts/nixos # the standard work station
        inputs.minegrub-theme.nixosModules.default
      ];
    };
  };
}