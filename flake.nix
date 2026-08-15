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
    # noctalia は意図的に nixpkgs を follows させていない。noctalia.cachix.org
    # にあるバイナリは上流が pin した nixpkgs でビルドされたもので、follows
    # させると入力が変わってキャッシュに当たらなくなる。
    noctalia.url = "github:noctalia-dev/noctalia-shell";
    # mango は /etc/nixos 側でコンポジタ本体を有効にしているが、設定を書く
    # home-manager モジュールはこちらの input から取る。
    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, home-manager, nvf, noctalia, mangowm, ... }:
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
          noctalia.homeModules.default
          mangowm.hmModules.mango
          ./home.nix
          ./nvf.nix
          ./desktop.nix
        ];
      };
    };
}
