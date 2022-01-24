{
  description = "Heldendokument-Generator und Webinterface dazu";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
    flake-utils.url = github:numtide/flake-utils;
  };
  
  outputs = { self, nixpkgs, flake-utils }: let
    inherit (nixpkgs.lib) genAttrs substring;
    version = "${substring 0 8 self.lastModifiedDate}-${self.shortRev or "dirty"}";
    systemDependents = flake-utils.lib.eachSystem flake-utils.lib.allSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      newg8 = pkgs.fetchzip {
        url = https://github.com/probonopd/font-newg8/releases/download/continuous/newg8-otf.zip;
        sha256 = "4c7f39a116de61c6806e28681cb6f2adda43226f7ad7e9b6b8d8f77b81c7cb60";
        stripRoot = false;
      };
      copse = pkgs.fetchurl {
        url = https://github.com/google/fonts/raw/main/ofl/copse/Copse-Regular.ttf;
        sha256 = "b852e682f0c66de4db1835f8545ff2e94761549987a4607447b069e973f50b1d";
      };
      mason = pkgs.fetchurl {
        url = http://d.xiazaiziti.com/en_fonts/fonts/m/Mason-Bold.ttf;
        sha256 = "f1e9d84cfba5477a4a08fdb4ea1c39143bdb25e3e915adbce45bd9447d641794";
      };
      fanpaket = pkgs.fetchurl {
        url = http://www.ulisses-spiele.de/download/889/;
        sha256 = "7dad01f12a526bca74ed4235a307f5bfe7939f5bc66b738cd6709f5aa5e3c7bd";
      };
      wds = pkgs.fetchurl {
        url = http://www.ulisses-spiele.de/download/468/;
        sha256 = "273dc1e19b5dc95c2454c7f2cfd8b49688f11312e6b82cd8f3bc63ee13b371a4";
      };
      tex = pkgs.texlive.combine {
        inherit (pkgs.texlive) scheme-minimal latex-bin tools collection-luatex koma-script geometry
        polyglossia hyphen-german environ makecell multirow amsmath epstopdf-pkg
        fontawesome5 nicematrix xcolor pgf colortbl wallpaper eso-pic shadowtext 
        latexmk;
      };
      binSh = pkgs.runCommand "bin-sh" { } ''
        mkdir -p $out/bin $out/tmp
        ln -s ${pkgs.bash}/bin/bash $out/bin/sh
      '';
    in {
      packages = with pkgs; rec {
        dsa41held = stdenvNoCC.mkDerivation rec {
          name ="DSA-4.1-Heldendokument";
          src = self;
          buildInputs = [ ];
          propagatedBuildInputs = [
            coreutils tex coreutils bash
          ];
          phases = ["unpackPhase" "installPhase"];
          GENERATOR = ''
            #!${bash}/bin/bash
            set -e
            BASE_NAME="heldendokument"
            while :; do
              case $1 in
                -w|--white) BASE_NAME="heldendokument-weiss"
                ;;
                *) break
              esac
              shift
            done
            
            if [ -z "$1" ]; then
              echo "Pfad zur Heldendatei muss als Eingabe angegeben werden!"
              exit 1
            fi
            
            export PATH="${lib.makeBinPath propagatedBuildInputs}"
            ABS_INPUT="$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
            DIR=$(mktemp -d)
            RES=$(pwd)/${"$" + "{1%.lua}"}.pdf
            SOURCES="${builtins.placeholder "out"}"
            mkdir -p "$DIR/.texcache/texmf-var"
            env TEXHOME="$DIR/.cache" \
                TEXMFVAR="$DIR/.cache/texmf-var" \
                latexmk -interaction=nonstopmode -output-directory="$DIR" \
                -pretex="\pdfvariable suppressoptionalinfo 512\relax"\
                -usepretex -cd -file-line-error -halt-on-error \
                -r "$SOURCES/share/.latexmkrc" \
                -lualatex="${tex}/bin/lualatex %O %S \"$ABS_INPUT\"" \
                "$SOURCES/share/$BASE_NAME.tex"
            mv -- "$DIR/$BASE_NAME.pdf" "$RES"
            rm -rf "$DIR"
          '';
          EREIGNISSE = ''
            #!/bin/sh
            set -e
            ABS_INPUT="$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
            (cd "${builtins.placeholder "out"}/share" && ${tex}/bin/texlua tools.lua list "$ABS_INPUT")
          '';
          installPhase = ''
            mkdir -p "$out"/{bin,share/fonts}
            cp src/*.{lua,tex,cls} "$out/share"
            cp -r src/.latexmkrc img "$out/share"
            cp ${newg8}/NewG8-{Reg,Bol,BolIta,Ita}.otf "$out/share/fonts"
            cp ${copse} "$out/share/fonts/Copse-Regular.ttf"
            cp ${mason} "$out/share/fonts/Mason-Bold.ttf"
            ${pkgs.unzip}/bin/unzip -p "${fanpaket}" "Das Schwarze Auge - Fanpaket - 2013.07.29/Logo - Fanprodukt.png" >"$out/share/img/logo-fanprodukt.png"
            ${pkgs.poppler_utils}/bin/pdfimages -f 2 -l 2 "${wds}" wds
            ${pkgs.imagemagick}/bin/convert wds-000.ppm "$out/share/img/wallpaper.jpg"
            
            printenv GENERATOR >$out/bin/dsa41held
            printenv EREIGNISSE >$out/bin/ereignisse
            chmod u+x "$out/bin/dsa41held" "$out/bin/ereignisse"
          '';
        };
        dsa41held-webui = pkgs.buildGoModule {
          name = "DSA-4.1-Heldendokument-WebUI";
          src = self;
          vendorSha256 = "e8fc083fda5696e2d251e447cf1a7bce9582c8e1b638a03b4aeea4c16f2ee6d6";
          modRoot = "webui";
          nativeBuildInputs = [ makeWrapper ];
          propagatedBuildInputs = [ bash libxslt dsa41held ];
          postInstall = ''
            mkdir "$out/share"
            cp -r index.html ../templates ../import.xsl ../heldensoftware-meta.xml "$out/share"
            wrapProgram "$out/bin/webui" --prefix PATH : "${lib.makeBinPath [ bash libxslt dsa41held ]}"
          '';
        };
        dsa41held-webui-docker = pkgs.dockerTools.buildLayeredImage {
          name = "dsa41held-webui";
          tag = "latest";
          contents = [ coreutils binSh dsa41held-webui ];
          config = {
            Cmd = "/bin/webui";
            ExposedPorts = {
              "80" = {};
            };
          };
        };
        dsa41held-doc = stdenvNoCC.mkDerivation {
          name = "DSA-4.1-Heldendokument-Dokumentation";
          src = self;
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
      devShell = pkgs.mkShell {
        buildInputs = [ tex pkgs.go ];
      };
    });
  in systemDependents // {
    nixosModules.webui = {lib, pkgs, config, ...}:
    with lib;
    let
      cfg = config.services.dsa41generator;
      webui = systemDependents.packages.${config.nixpkgs.system}.dsa41held-webui;
    in {
      options.services.dsa41generator = {
        enable = mkEnableOption "DSA 4.1 Heldendokument-Generator Webinterface";
        address = mkOption {
          type = types.str;
          default = ":8080";
          description = "Listen address, conforming to Go's http module";
        };
      };
      config = mkIf cfg.enable {
        systemd.services.dsa41generator = {
          wantedBy = ["multi-user.target"];
          after = ["network.target"];
          serviceConfig.ExecStart = ''${webui}/bin/webui -addr "${cfg.address}"'';
        };
      };
    };
  };
}