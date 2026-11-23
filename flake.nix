{
  description = "inferzero -- C++ AI engine for intel based machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    inferzero = {
      url = "github:rizagp/inferzero";
      flake = false;
    };
  };

  outputs = { nixpkgs, inferzero, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.callPackage ./package.nix {
        source = inferzero;
      };
    };
}
