{
  description = "Root flake for NixOS and Home Manager configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
#    hardware.url = "github:nixos/nixos-hardware"; #should I keep this? is it the unstable channel?

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs: 
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;

      overlays = [
        (final: _prev: { # allow the usage of pkgs.unstable.packagename, see https://www.reddit.com/r/NixOS/comments/1c6m5j4/how_to_use_both_stable_and_unstable_nixpkgs_in_a/l058ik3/
          unstable = import nixpkgs-unstable { inherit (final) system config; };
        })
      ];
    };

  in {
    
    # MACHINES
    nixosConfigurations = {

      figaro = nixpkgs.lib.nixosSystem {
        inherit system;
        
        modules = [
          {nixpkgs.hostPlatform = system;}
          ./machines/common.nix
          ./machines/figaro.nix
        ];
      };
    };
   
    # USERS
    homeConfigurations = {
    
      davide = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./users/common.nix
          ./users/davide.nix
        ];
      };
    };
  };
}
