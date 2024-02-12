{
  description = "Heldendokument-Generator und Webinterface dazu";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
    wds-handouts = {
      url =
        "https://dsa-satinavsketten.de/fileadmin/downloads/offiziell/Regelmaterial&Errata/WdS-Handouts.pdf";
      flake = false;
    };
    fanpaket = {
      url =
        "https://dsa-satinavsketten.de/fileadmin/downloads/offiziell/Das_Schwarze_Auge_Fanpaket_2011_08_19.zip";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, nix-filter, wds-handouts, fanpaket }:
    let
      inherit (nixpkgs.lib) genAttrs substring;
      version =
        "${substring 0 8 self.lastModifiedDate}-${self.shortRev or "dirty"}";
      systemDependents = utils.lib.eachSystem utils.lib.allSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          newg8 = pkgs.fetchzip {
            url =
              "https://github.com/probonopd/font-newg8/releases/download/continuous/newg8-otf.zip";
            sha256 =
              "4c7f39a116de61c6806e28681cb6f2adda43226f7ad7e9b6b8d8f77b81c7cb60";
            stripRoot = false;
          };
          copse = pkgs.fetchurl {
            url =
              "https://github.com/google/fonts/raw/main/ofl/copse/Copse-Regular.ttf";
            sha256 =
              "b852e682f0c66de4db1835f8545ff2e94761549987a4607447b069e973f50b1d";
          };
          mason = pkgs.fetchurl {
            url = "http://d.xiazaiziti.com/en_fonts/fonts/m/Mason-Bold.ttf";
            sha256 =
              "f1e9d84cfba5477a4a08fdb4ea1c39143bdb25e3e915adbce45bd9447d641794";
          };
          tex = pkgs.texlive.combine {
            inherit (pkgs.texlive)
              scheme-minimal latex-bin tools collection-luatex koma-script
              geometry polyglossia hyphen-german environ makecell multirow
              amsmath epstopdf-pkg fontawesome5 nicematrix xcolor pgf colortbl
              wallpaper eso-pic shadowtext latexmk;
          };
          binSh = pkgs.runCommand "bin-sh" { } ''
            mkdir -p $out/bin $out/tmp
            ln -s ${pkgs.bash}/bin/bash $out/bin/sh
          '';
          filtered-src = nix-filter.lib.filter {
            root = ./.;
            exclude = [
              ./flake.nix
              ./flake.lock
              ./Readme.md
              ./Makefile
              ./dsa41held.sh.nix
              ./build.dockerfile
            ];
          };
        in {
          packages = with pkgs; rec {
            silhouette = stdenvNoCC.mkDerivation rec {
              name = "silhouette";
              src = filtered-src;
              propagatedBuildInputs = [
                coreutils
                bash
                (texlive.combine {
                  inherit (pkgs.texlive)
                    scheme-minimal latex-bin collection-luatex latexmk
                    standalone infwarerr ltxcmds grfext kvdefinekeys kvoptions
                    kvsetkeys xkeyval tools fontspec epstopdf-pkg pgf;
                })
              ];
              phases = [ "unpackPhase" "installPhase" ];
              GENERATOR = ''
                #!${pkgs.bash}/bin/bash
                set -e

                export PATH=${lib.makeBinPath propagatedBuildInputs}

                DIR=$(mktemp -d)
                INPUT="${builtins.placeholder "out"}"
                mkdir -p "$DIR/.texcache/texmf-var"
                env TEXHOME="$DIR/.cache" \
                    TEXMFVAR="$DIR/.cache/texmf-var" \
                    SOURCE_DATE_EPOCH=$(date -r "$INPUT/share/silhouette.tex" +%s) \
                    latexmk -interaction=nonstopmode -output-directory="$DIR" \
                    -pretex="\pdfvariable suppressoptionalinfo 512\relax\def\SilKind{$1}\def\SilVariant{$2}" \
                    -usepretex -cd -file-line-error -halt-on-error \
                    -r "$INPUT/share/.latexmkrc" \
                    "$INPUT/share/silhouette.tex"
                mv -- "$DIR/silhouette.pdf" silhouette.pdf
              '';
              installPhase = ''
                mkdir -p $out/{bin,share/fonts}
                cp src/silhouette.{tex,lua} $out/share
                cp -r src/.latexmkrc img $out/share
                cp ${newg8}/NewG8-{Reg,Bol,BolIta,Ita}.otf "$out/share/fonts"
                printenv GENERATOR >$out/bin/silhouette
                chmod u+x $out/bin/silhouette
              '';
            };
            dsa41held = stdenvNoCC.mkDerivation rec {
              name = "dsa41held";
              src = filtered-src;
              nativeBuildInputs = [ poppler_utils imagemagick unzip ];
              propagatedBuildInputs = [ coreutils tex coreutils bash libxslt ];
              phases = [ "unpackPhase" "installPhase" ];
              GENERATOR = (import ./dsa41held.sh.nix) {
                inherit pkgs propagatedBuildInputs tex;
                inherit (nixpkgs) lib;
              };
              installPhase = ''
                mkdir -p "$out"/{bin,share/fonts}
                cp src/*.{lua,tex,cls} "$out/share"
                cp -r src/.latexmkrc img "$out/share"
                cp ${newg8}/NewG8-{Reg,Bol,BolIta,Ita}.otf "$out/share/fonts"
                cp ${copse} "$out/share/fonts/Copse-Regular.ttf"
                cp ${mason} "$out/share/fonts/Mason-Bold.ttf"
                cp "${fanpaket}/DSA_Fanpaket_PNG/Fan-Produkt-Logo.png" "$out/share/img/logo-fanprodukt.png"
                ${poppler_utils}/bin/pdfimages -f 2 -l 2 "${wds-handouts}" wds
                ${imagemagick}/bin/convert wds-000.ppm "$out/share/img/wallpaper.jpg"
                cp import.xsl heldensoftware-meta.xml "$out/share"

                printenv GENERATOR >$out/bin/dsa41held
                chmod u+x "$out/bin/dsa41held"
              '';
            };
            dsa41held_webui = pkgs.buildGoModule {
              name = "dsa41held_webui";
              src = filtered-src;
              vendorHash =
                "sha256-SnM7NYq8kquzzDyOmafMu7rR6QrjDToqx7kNVO/GC5Y=";
              modRoot = "dsa41held_webui";
              nativeBuildInputs = [ makeWrapper ];
              propagatedBuildInputs = [ bash libxslt dsa41held ];
              postInstall = ''
                mkdir "$out/share"
                cp -r index.html ../templates ../import.xsl ../heldensoftware-meta.xml "$out/share"
                wrapProgram "$out/bin/dsa41held_webui" --prefix PATH : "${
                  lib.makeBinPath [ bash libxslt dsa41held ]
                }"
              '';
            };
            dsa41held_webui-docker = pkgs.dockerTools.buildLayeredImage {
              name = "dsa41held_webui-docker";
              tag = "latest";
              contents = [ coreutils binSh dsa41held_webui ];
              config = {
                Cmd = "/bin/dsa41held_webui";
                ExposedPorts = { "80" = { }; };
              };
            };
            dsa41held-doc = stdenvNoCC.mkDerivation {
              name = "dsa41held-doc";
              src = filtered-src;
              buildInputs = [ tex ];
              phases = [ "unpackPhase" "buildPhase" "installPhase" ];
              buildPhase = ''
                (cd src && texlua tools.lua --standalone gendoc > ../format.html)
              '';
              installPhase = ''
                mkdir -p "$out"
                mv format.html "$out/format.html"
              '';
            };
          };
          devShell = pkgs.mkShell { buildInputs = [ tex pkgs.go ]; };
        });
    in systemDependents // {
      nixosModules.webui = { lib, pkgs, config, ... }:
        with lib;
        let
          cfg = config.services.dsa41generator;
          webui =
            systemDependents.packages.${config.nixpkgs.system}.dsa41held_webui;
        in {
          options.services.dsa41generator = {
            enable =
              mkEnableOption "DSA 4.1 Heldendokument-Generator Webinterface";
            address = mkOption {
              type = types.str;
              default = ":8080";
              description = "Listen address, conforming to Go's http module";
            };
          };
          config = mkIf cfg.enable {
            systemd.services.dsa41generator = {
              wantedBy = [ "multi-user.target" ];
              after = [ "network.target" ];
              serviceConfig.ExecStart =
                ''${webui}/bin/dsa41held_webui -addr "${cfg.address}"'';
            };
          };
        };
    };
}
