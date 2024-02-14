{
  description = "Home Manager configuration of clahoche";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    my_personnal_script.url = "github:fitz35/my_personnal_script";
  };

  outputs = { nixpkgs, home-manager, ... }@ inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      perso_config = import ./config.nix;
    in {
      homeConfigurations."clahoche" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        extraSpecialArgs = { inherit pkgs perso_config; };
        modules = [
          { _module.args.inputs = inputs; }
          ./home.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}