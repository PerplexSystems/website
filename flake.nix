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
            ls -al
            hugo
          '';

          installPhase = ''
            mkdir -p $out
            tar -C public -cvz . > site.tar.gz
            cp -r site.tar.gz $out
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
