#!/bin/bash
cd
cd Desktop

#create dirs
mkdir Scope2DMac
mkdir Scope2DMac/source
mkdir Scope2DMac/source/ressource
mkdir Scope2DMac/data
mkdir Scope2DMac/data/scenes
mkdir Scope2DMac/data/graphics

#copy stuff
cp -r ~/Developer/Projects/Scope\ 2D/main.app/ Scope2DMac/Scope2D.app
cp ~/Developer/Projects/Scope\ 2D/versions.txt Scope2DMac/versions.txt
cp ~/Developer/Projects/Scope\ 2D/README.txt Scope2DMac/README.txt
cp -r ~/Developer/Projects/Scope\ 2D/source/ressource/ Scope2DMac/source/ressource/
cp -r ~/Developer/Projects/Scope\ 2D/source/ressource/PlanetCute/ Scope2DMac/data/graphics/
mv -f Scope2DMac/data/graphics/example.css Scope2DMac/data/scenes/

#delete developer stuff
rm Scope2DMac/source/ressource/toolbar.pxm
rm -r Scope2DMac/source/ressource/PlanetCute/

#set icon
mv -f Scope2DMac/source/ressource/main.icns Scope2DMac/Scope2D.app/Contents/Resources/main.icns

#set plist
mv -f Scope2DMac/source/ressource/Info.plist Scope2DMac/Scope2D.app/Contents/Info.plist
