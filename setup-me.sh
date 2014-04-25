#!/bin/bash

# setting up defaults 
[[ $OS && ${OS-x} ]] || OS=linux
OS=$(echo $OS | tr '[:upper:]' '[:lower:]')

[[ $SETUP && ${SETUP-x} ]] || SETUP=$TARGET

[[ $ARCH && ${ARCH-x} ]] || ARCH=x86_64
case $ARCH in
	x86_64 )
		ARCH_BITS=64
		NEKO_ARCH=64
		;;
	i686 )
		if [ $OS = mac ]; then
			echo "Only x86_64 architecture is support for mac"
			exit 1
		fi
		ARCH_BITS=32
		NEKO_ARCH=
		;;
	* )
		echo "Unknown architecture $ARCH"
		exit 1
		;;
esac

[[ $TOOLCHAIN && ${TOOLCHAIN-x} ]] || TOOLCHAIN=default

function retry {
	if [[ $TRAVIS && ${TRAVIS-x} ]]; then
		travis_retry "$@"
	else
		$@
	fi
}

FIRST=0

function install {
	if [ $OS = "linux" ]; then
		if [ $FIRST -eq 0 ]; then
			retry sudo apt-get update -qq
			FIRST=1
		fi
		if [ $ARCH = "i686" ] && [[ ! $1 == *:i386 ]]; then
			retry sudo apt-get install -qq -y $1:i386
		else
			retry sudo apt-get install -qq -y $1
		fi
	else
		if [ $FIRST -eq 0 ]; then
			sudo brew update
			FIRST=1
		fi
		retry sudo brew install $1
	fi
}

function testprog {
	"$@" 2> /dev/null
}

echo "$ARCH-$OS-$TARGET-$TOOLCHAIN-$SETUP"

git --version || sudo apt-get install -y git || install git

# compile neko
sudo rm -f /usr/bin/neko*
sudo rm -f /usr/lib/libneko*
sudo rm -rf /usr/lib/neko
install libgc || install libgc1c2 || install libgc-dev
install libpcre || install libpcre3
install zlib1g
if [ $OS = "mac" ]; then
	echo "no prebuilt binary available; building neko"
	retry git clone https://github.com/HaxeFoundation/neko.git ~/neko
	cd ~neko && make && sudo make install
else
	retry wget -O ~/neko.tgz "http://nekovm.org/_media/neko-2.0.0-$OS$NEKO_ARCH.tar.gz"
	tar -zxf ~/neko.tgz -C ~/
	rm ~/neko.tgz
	cd ~/neko*
	sudo mkdir -p /usr/lib/neko
	sudo cp -Rf * /usr/lib/neko
	sudo ln -s /usr/lib/neko/neko* /usr/bin
	sudo ln -s /usr/lib/neko/lib* /usr/lib
fi

neko -version || exit 1
echo "neko v$(neko -version)"

# get haxe
echo "getting haxe"
sudo rm -rf /usr/lib/haxe
sudo rm -f /usr/bin/haxe*
retry wget -O ~/haxe.tgz "http://hxbuilds.s3-website-us-east-1.amazonaws.com/builds/haxe/$OS$ARCH_BITS/haxe_latest.tar.gz"
cd ~
tar -zxf haxe.tgz
cd haxe*
sudo mkdir -p /usr/lib/haxe
sudo cp -Rf * /usr/lib/haxe
sudo ln -s /usr/lib/haxe/haxe* /usr/bin
haxe 2>&1 | head -n 1 || exit 1

# setup haxelib
echo "setup haxelib"
mkdir -p ~/haxelib && haxelib setup ~/haxelib || exit 1

case $SETUP in
	php )
		testprog php -v || sudo apt-get install -y php5 || install php5
		;;
	cpp )
		install gcc-multilib
		install g++-multilib
		retry haxelib git hxcpp https://github.com/HaxeFoundation/hxcpp
		cd ~/haxelib/hxcpp/git/project
		neko build.n || exit 1
		;;
	java )
		testprog javac -version || install openjdk || sudo apt-get install -y openjdk-7-jdk || install openjdk-7-jdk || exit 1
		retry haxelib git hxjava https://github.com/HaxeFoundation/hxjava
		javac -version || exit 1
		;;
	cs )
		testprog mcs --version || sudo apt-get install -y mono-mcs || install mono-mcs || exit 1
		retry haxelib git hxcs https://github.com/HaxeFoundation/hxcs
		mcs --version || exit 1
		;;
	flash | as3 | swf | swf9 | swf8 )
		# TODO if the following doesn't work, uncomment either the next lines
		retry wget http://hxbuilds.s3-website-us-east-1.amazonaws.com/unitdeps/flashplayer_11_sa_debug.i386.min.tar.xz
		# retry wget http://hxbuilds.s3-website-us-east-1.amazonaws.com/unitdeps/flashplayer_11_sa_debug.i386.tar.gz
		# retry wget http://fpdownload.macromedia.com/pub/flashplayer/updaters/11/flashplayer_11_sa_debug.i386.tar.gz
		install libgd2-xpm ; install ia32-libs ; install ia32-libs-multiarch ; install libgtk2.0-0:i386 ; install libxt6:i386 ; install libnss3:i386
		[ -f /etc/init.d/xvfb ] || install xvfb
		# retry sudo apt-get install -qq -y libgd2-xpm ia32-libs ia32-libs-multiarch
		tar -xvf flashplayer* -C ~/
		echo "ErrorReportingEnable=1\nTraceOutputFileEnable=1" > ~/mm.cfg
		if [ $SETUP = "as3" ] && [ ! mxmlc --version ]; then
			#TODO if the following doesn't work, uncomment either the next lines
			retry wget -O ~/flex.tar.xz http://hxbuilds.s3-website-us-east-1.amazonaws.com/unitdeps/apache-flex-sdk-4.12.0-bin-min.tar.xz
			#retry wget -O ~/flex.tar.gz http://hxbuilds.s3-website-us-east-1.amazonaws.com/unitdeps/apache-flex-sdk-4.12.0-bin.tar.gz
			#retry wget -O ~/flex.tar.gz http://mirror.cc.columbia.edu/pub/software/apache/flex/4.12.0/binaries/apache-flex-sdk-4.12.0-bin.tar.gz
			tar -xvf ~/flex.tar.* -C ~
			FLEXPATH=$HOME/apache-flex-sdk-4.12.0-bin/
			export PATH=$PATH:$FLEXPATH/bin
			mkdir -p $FLEXPATH/player/11.1
			retry wget -nv http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_1.swc -O "$FLEXPATH/player/11.1/playerglobal.swc"
			echo "env.PLAYERGLOBAL_HOME=$FLEXPATH/player" > $FLEXPATH/env.properties
			testprog java -version || install openjdk || install openjdk-7-jdk || exit 1
			mxmlc --version || exit 1
		fi
		~/flashplayerdebugger
		;;
	js )
		if [ $TOOLCHAIN = "default" ] || [ $TOOLCHAIN = "nodejs" ]; then
			testprog nodejs -v || node -v || install nodejs
			nodejs -v || exit 1
		elif [ $TOOLCHAIN = "browser" ]; then
			testprog phantomjs -v || install phantomjs
			phantomjs -v || exit 1
		fi
		;;
	* )
		;;
esac

cd $TRAVIS_BUILD_DIR
