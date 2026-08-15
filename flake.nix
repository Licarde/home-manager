{
  description = "Home Manager configuration of riorio";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Deliberately does NOT follow nixpkgs: noctalia pins its own quickshell and
    # only that pin has binaries in the upstream cache. Following would rebuild
    # Qt/quickshell locally.
    noctalia.url = "github:noctalia-dev/noctalia-shell";
  };

  outputs =
    inputs@{ nixpkgs, home-manager, nvf, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."riorio" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Lets home.nix reach flake inputs (noctalia) directly.
        extraSpecialArgs = { inherit inputs; };

        modules = [
          nvf.homeManagerModules.default
          ./home.nix
          ./nvf.nix
        ];
      };
    };
}
