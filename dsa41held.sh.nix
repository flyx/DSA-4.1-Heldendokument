{pkgs, lib, propagatedBuildInputs, tex}: ''
#!${pkgs.bash}/bin/bash
set -e

export PATH="${lib.makeBinPath propagatedBuildInputs}"

sub_help(){
  echo "Benutzung: dsa41held <unterkommando> [options] <datei>\n"
  echo "Unterkommandos:\n"
  echo "    pdf            baue ein PDF mit Namen <datei ohne .lua>.pdf"
  echo "        -w         weißer Hintergrund statt der Karte"
  echo "        <datei>    Lua-Datei, die die Heldendaten enthält\n"
  echo "    ereignisse     zeige Tabelle aller Steigerungsereignisse"
  echo "        <datei>    Lua-Datei, die die Heldendaten enthält\n"
  echo "    import         importiere einen Held aus der Heldensoftware."
  echo "                   gibt Lua-Daten auf der Standardausgabe aus."
  echo "        <datei>    XML-Datei, die einen aus der Heldensoftware exportierten"
  echo "                   Helden enthält.\n"
  echo "    validate       Validiere eine gegebene Lua-Datei gegen das Schema."
  echo "        <datei>    Lua-Datei, die die Heldendaten enthält.\n"
}

sub_pdf(){
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
  ABS_INPUT="$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
  DIR=$(mktemp -d)
  RES=$(pwd)/${"$" + "{1%.lua}"}.pdf
  SOURCES="${builtins.placeholder "out"}"
  mkdir -p "$DIR/.texcache/texmf-var"
  env TEXHOME="$DIR/.cache" \
      TEXMFVAR="$DIR/.cache/texmf-var" \
      SOURCE_DATE_EPOCH=$(date -r "$ABS_INPUT" +%s) \
      latexmk -interaction=nonstopmode -output-directory="$DIR" \
      -pretex="\pdfvariable suppressoptionalinfo 512\relax"\
      -usepretex -cd -file-line-error -halt-on-error -shell-escape \
      -r "$SOURCES/share/.latexmkrc" \
      -lualatex="${tex}/bin/lualatex %O %S \"$ABS_INPUT\"" \
      "$SOURCES/share/$BASE_NAME.tex"
  mv -- "$DIR/$BASE_NAME.pdf" "$RES"
  rm -rf "$DIR"
}

sub_ereignisse(){
  ABS_INPUT="$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
  (cd "${builtins.placeholder "out"}/share" && ${tex}/bin/texlua tools.lua list "$ABS_INPUT")
}

sub_import(){
  ${pkgs.libxslt}/bin/xsltproc ${builtins.placeholder "out"}/share/import.xsl "$1"
}

sub_validate(){
  ABS_INPUT="$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
  (cd "${builtins.placeholder "out"}/share" && ${tex}/bin/texlua tools.lua validate "$ABS_INPUT")
}

subcommand=$1
case $subcommand in
  "" | "-h" | "--help" | "help")
    sub_help
    ;;
  *)
    shift
    sub_${"$"}{subcommand} $@
    if [ $? = 127 ]; then
      echo "Fehler: Unbekanntes Unterkommando '$subcommand'." >&2
      echo "        Liste von Unterkommandos verfügbar unter 'dsa41held -h" >&2
      exit 1
    fi
    ;;
esac
''
