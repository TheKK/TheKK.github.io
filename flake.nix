{
  description = "Simple flake with flake-utils";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    neuron = {
      url = "github:srid/neuron";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, neuron }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        neuron' = import neuron { inherit system; };

        neuronGen = pkgs.runCommand "gen-blog" {} ''
          mkdir $out

          cp -r ${self}/* .
          ${neuron'}/bin/neuron gen
          mv .neuron/output/* $out
        '';

      in {
        packages = { inherit neuronGen; };
        defaultPackage = neuronGen;

        devShell = pkgs.mkShell {
          # inputs = [ neuronGen ];
          nativeBuildInputs = [ neuron' ];
        };
      });
}
