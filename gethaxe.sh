#!/bin/bash

sudo rm -rf /usr/lib/haxe
sudo rm -f /usr/bin/haxe*

source $TRAVIS_HX/defaults.sh

get_haxe_build()
{
    echo "getting already built haxe: "$1
    DIR=$OS$ARCH_BITS
    if [ $OS = "mac" ]; then
            DIR=mac
    fi
    cd $HOME
    rm -rf haxe*
    retry wget -O $HOME/haxe.tgz "http://hxbuilds.s3-website-us-east-1.amazonaws.com/builds/haxe/$DIR/$1"
    tar -zxf haxe.tgz
    cd haxe*
    sudo mkdir -p /usr/lib/haxe
    sudo cp -Rf * /usr/lib/haxe
    sudo ln -s /usr/lib/haxe/haxe* /usr/bin
}

get_haxe_git()
{
    echo "building haxe from git: "$1
    sudo apt-get install ocaml zlib1g-dev libgc-dev -qq
    cd $HOME
    rm -rf haxe
    git clone --recursive git://github.com/HaxeFoundation/haxe.git haxe
    cd haxe
    git checkout $1
    echo `git log -1 --oneline --abbrev-commit`
    make libs haxe tools
    sudo make install
}

case $HAXE_VAR in
"" | "latest" )
    get_haxe_build "haxe_latest.tar.gz"
    ;;
"3.1.3")
    get_haxe_build "haxe_2014-04-13_master_7be3067.tar.gz"
    ;;
"3.1.2")
    get_haxe_build "haxe_2014-03-29_master_a04aec3.tar.gz"
    ;;
"3.1.1")
    get_haxe_git "v3.1.1"
    ;;
"3.1.0")
    get_haxe_git "v3.1.0"
    ;;
*)
    get_haxe_git $HAXE_VAR
    ;;
esac

haxe 2>&1 | head -n 1 || exit 1

