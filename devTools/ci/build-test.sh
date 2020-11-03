#!/bin/sh

SRC_DIR='coc'

sudo apt-get update
# install VNC and xfce4 so we have a desktop, as the flash player requires one
sudo apt-get install git ant vnc4server xfce4 openjdk-11-jre -y

# start a VNC session, this will be the desktop for tests
Xvnc :1 &

# this is to trick the flash player into thinking it is running on a desktop
export DISPLAY=":1"

if [ ! -d "$SRC_DIR" ] ; then
    git clone --depth=50 --recursive --branch=master https://github.com/Kitteh6660/Corruption-of-Champions-Mod.git "$SRC_DIR"
fi

cd $SRC_DIR

# checkout the master branch
git checkout origin/master

# So flexunit can find the player and the ant build file does not have to be modified  
sudo cp -v build-dep/bin/flashplayer /usr/local/bin/gflashplayer

# build and run the tests
ant test -DFLEX_HOME="build-dep/bin/flex/"
