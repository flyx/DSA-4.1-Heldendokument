#!/bin/sh

cd src
cp /dev/stdin held.lua

texlua tools.lua validate held.lua >heldendokument.log 2>&1
if [ $? -eq 1 ]; then
  if [ "$1" = "-" ]; then
    cp heldendokument.log /dev/stderr
  fi
  exit 1
fi

latexmk -c
latexmk -lualatex='lualatex %O %S held.lua' heldendokument.tex
if [ $? -eq 0 ]; then
  if [ "$1" = "-" ]; then
    cp heldendokument.pdf /dev/stdout
  fi
else
  if [ "$1" = "-" ]; then
    cp heldendokument.log /dev/stderr
  fi
  exit 1
fi