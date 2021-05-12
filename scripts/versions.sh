#!/bin/bash

# script file that will save a "daily" build
# tagged with the commit number so we can run
# older versions of the game.

rootfolder=rel.archive/dailies

mkdir -p $rootfolder

gitcommit=$(git rev-parse --short HEAD)
date=$(date '+%y%m%d-%H%M%S')

echo "Building Hashlink (SDL)"
haxe hxml/hl.sdl.hxml
mv bin/game.hl $rootfolder/game-$date-$gitcommit-sdl.hl

echo "Building Hashlink (DX)"
haxe hxml/hl.dx.hxml
mv bin/game.hl $rootfolder/game-$date-$gitcommit-dx.hl