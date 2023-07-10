{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      forEachSystem = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      packages = forEachSystem(system: 
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
      {
        default = pkgs.stdenv.mkDerivation {
          name = "perplex-systems-website";
          src = ./.;

          buildInputs=  [ pkgs.hugo ];

          buildPhase = ''
            hugo
          '';

          installPhase = ''
            mkdir -p $out
            cp -r public/* $out
          '';
        };
      });

      devShells = forEachSystem
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            default = pkgs.mkShell {
              buildInputs = [ pkgs.hugo pkgs.hut ];
            };
          });
    };
}
