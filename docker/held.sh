#!/bin/sh

cp /dev/stdin held.lua
cd src
latexmk -c
latexmk -lualatex='lualatex %O %S ../held.lua' heldendokument.tex
if [ $? -eq 0 ]; then
  if [ "$1" -eq "-" ]; then
    cat heldendokument.pdf
  fi
else
  if [ "$1" -eq "-" ]; then
    cat heldendokument.log >&2
  fi
  exit 1
fi