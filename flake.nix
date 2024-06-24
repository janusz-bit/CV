{
  description = "CV — Quarto website";

  inputs = {
    # Pinned: quarto 1.8.26 (1.9.x ma bug pandoc mismatch — nixpkgs#519484)
    nixpkgs.url = "github:NixOS/nixpkgs/b3da656039dc7a6240f27b2ef8cc6a3ef3bccae7";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { pkgs, ... }: {
        # nix develop — środowisko z quarto
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ quarto ];
        };

        # nix build — renderuje CV do ./result
        packages = rec {
          default = cv;

          cv = pkgs.stdenv.mkDerivation {
            name = "cv-website";
            src = ./.;

            nativeBuildInputs = [ pkgs.quarto ];

            # Quarto (Deno) potrzebuje zapisywalnego HOME dla cache
            HOME = "$TMPDIR";

            buildPhase = ''
              runHook preBuild
              quarto render --output-dir _site
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out
              cp -r _site/* $out/
              runHook postInstall
            '';
          };
        };
      };
    };
}