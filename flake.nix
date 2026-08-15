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
    # noctalia は意図的に nixpkgs を follows させていない。独自 pin の
    # quickshell しか上流キャッシュにバイナリが無く、follows させると
    # Qt と quickshell をローカルでビルドすることになる。
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

        # home.nix から flake input（noctalia）を直接参照できるようにする。
        extraSpecialArgs = { inherit inputs; };

        modules = [
          nvf.homeManagerModules.default
          ./home.nix
          ./nvf.nix
        ];
      };
    };
}
