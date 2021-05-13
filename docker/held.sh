#!/bin/sh

cp /dev/stdin held.lua
cd src
latexmk -lualatex='lualatex %O %S ../held.lua' heldendokument.tex
if [ $? -eq 0 ]; then
  cat heldendokument.pdf
else
  cat heldendokument.log >&2
  exit 1
fi