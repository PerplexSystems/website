{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    railroad.url = "github:PerplexSystems/Railroad";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      packages = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          railroad = inputs.railroad.outputs.packages."${system}";
        in
        {
          default = pkgs.stdenv.mkDerivation {
            name = "perplex-systems-website";
            src = ./.;

            buildInputs = [ pkgs.hugo ];

            configurePhase = ''
              mkdir -p content/projects
              cp -r ${railroad.docs}/* content/projects
            '';

            buildPhase = ''
              hugo
            '';

            installPhase = ''
              mkdir -p $out
              cp -r public/* $out
            '';
          };
        }
      );

      devShells = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = [ pkgs.zola ];
          };
        }
      );
    };
}
