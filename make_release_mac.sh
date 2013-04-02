#!/bin/bash
cd
cd Desktop

#create dirs
mkdir Scope2DMac
mkdir Scope2DMac/source
mkdir Scope2DMac/source/ressource

#copy stuff (change )
DEV_DIR="/Users/markus/Developer/Projects/Scope2D"
cp -r $DEV_DIR/main.app/ Scope2DMac/Scope2D.app
cp -r $DEV_DIR/source/ressource/ Scope2DMac/source/ressource/
cp -r $DEV_DIR/data Scope2DMac/data
cp $DEV_DIR/versions.txt Scope2DMac/versions.txt
cp $DEV_DIR/README.md Scope2DMac/README.md

#delete developer stuff
rm Scope2DMac/source/ressource/toolbar.pxm

#set icon
mv -f Scope2DMac/source/ressource/main.icns Scope2DMac/Scope2D.app/Contents/Resources/main.icns

#set plist
mv -f Scope2DMac/source/ressource/Info.plist Scope2DMac/Scope2D.app/Contents/Info.plist
