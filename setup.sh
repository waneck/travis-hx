#!/bin/bash
source $(dirname $0)/defaults.sh

# compile neko
if [ ! -f /usr/bin/neko ]; then
	sudo rm -f /usr/bin/neko*
	sudo rm -f /usr/lib/libneko*
	sudo rm -rf /usr/lib/neko
	install libgc1c2 bdw-gc # boehm gc
	install libpcre3 pcre # pcre
	install zlib1g libzip # zlib
	if [ $OS = "mac" ]; then
		# echo "no prebuilt binary available; building neko"
		# retry git clone https://github.com/HaxeFoundation/neko.git $HOME/neko
		# cd $HOME/neko && make clean && make LIB_PREFIX=/usr/local os=osx INSTALL_FLAGS= && sudo make install os=osx
		# sudo cp -Rf $HOME/neko/bin /usr/lib/neko
		retry wget -O $HOME/neko.tgz "http://waneck-pub.s3-website-us-east-1.amazonaws.com/unitdeps/neko-mac.tar.gz"
	else
		# retry wget -O $HOME/neko.tgz "http://nekovm.org/_media/neko-2.0.0-$OS$NEKO_ARCH.tar.gz"
		retry wget -O $HOME/neko.tar.xz "http://waneck-pub.s3-website-us-east-1.amazonaws.com/unitdeps/neko-linux$ARCH_BITS.tar.xz"
	fi
	tar -xf $HOME/neko.* -C ~/
	rm $HOME/neko.*
	cd $HOME/neko*
	sudo mkdir -p /usr/lib/neko
	sudo cp -Rf * /usr/lib/neko
	sudo chmod +x /usr/lib/neko/neko*
	sudo ln -s /usr/lib/neko/neko* /usr/bin
	sudo ln -s /usr/lib/neko/lib* /usr/lib
fi

neko -version || exit 1
echo "neko v$(neko -version)"

# get haxe
echo "getting haxe"
sudo rm -rf /usr/lib/haxe
sudo rm -f /usr/bin/haxe*
DIR=$OS$ARCH_BITS
if [ $OS = "mac" ]; then
	DIR=mac
fi
retry wget -O $HOME/haxe.tgz "http://hxbuilds.s3-website-us-east-1.amazonaws.com/builds/haxe/$DIR/haxe_latest.tar.gz"
cd $HOME
tar -zxf haxe.tgz
cd haxe*
sudo mkdir -p /usr/lib/haxe
sudo cp -Rf * /usr/lib/haxe
sudo ln -s /usr/lib/haxe/haxe* /usr/bin
haxe 2>&1 | head -n 1 || exit 1

# setup haxelib
echo "setup haxelib"
mkdir -p $HOME/haxelib && haxelib setup ~/haxelib || exit 1

for i in "${!SETUP[@]}"; do
	echo "setup for ${SETUP[i]}"
	case ${SETUP[i]} in
		php )
			testprog php -v || install php5-cli || install php5
			;;
		cpp )
			retry haxelib git hxcpp https://github.com/HaxeFoundation/hxcpp
			cd $HOME/haxelib/hxcpp/git/project
			if [ $OS = "mac" ]; then
				neko build.n -DHXCPP_GCC || exit 1
			elif [ $ARCH = "i686" ]; then
				sudo apt-get install -y gcc-multilib g++-multilib
				neko build.n clean ndll-linux-m32 || exit 1
			else
				install gcc-multilib
				install g++-multilib
				neko build.n || exit 1
			fi
			;;
		java )
			testprog javac -version || install openjdk || install openjdk-7-jdk || exit 1
			retry haxelib git hxjava https://github.com/HaxeFoundation/hxjava
			javac -version || exit 1
			;;
		python )
			testprog python3 --version || install python3 || exit 1
			python3 --version || exit 1
			;;
		cs )
			testprog mcs --version || install mono-mcs mono || sudo apt-get install -y mono-mcs || exit 1
			if [ $ARCH = "i686" ] || [ $ARCH = "x86" ]; then
				if [ $OS = "mac" ]; then
					echo "Mac i686 C# tests is not available!"
					exit 1
				fi
				retry wget -O $HOME/mono32.tar.xz http://waneck-pub.s3-website-us-east-1.amazonaws.com/unitdeps/mono32.tar.xz || exit 1
				sudo tar -xvf $HOME/mono32.tar.xz -C /tmp || exit 1
				sudo cp /tmp/mono/bin/mono32 /usr/bin || exit 1
			fi
			retry haxelib git hxcs https://github.com/HaxeFoundation/hxcs
			mcs --version || exit 1
			;;
		flash | as3 | swf | swf9 | swf8 | flash8 | flash9 )
			if [ $OS = "mac" ]; then
				retry wget http://waneck-pub.s3-website-us-east-1.amazonaws.com/unitdeps/flashplayer-dbg-osx.tar.gz -O $HOME/flash.tar.gz
				tar -xf $HOME/flash.tar.gz -C $HOME/
				# ln -s "$HOME/flashplayer.app/Contents/MacOS/Flash Player Debugger" ~/flashplayerdebugger
				if [ ${SETUP[i]} = "as3" ] && [ ! -f $HOME/flex_sdk_4/bin/mxmlc ]; then
					retry wget -O $HOME/flex.tar.gz http://waneck-pub.s3-website-us-east-1.amazonaws.com/unitdeps/flex_sdk_4.mac.tar.gz
					tar -xf $HOME/flex.tar.gz -C ~
					mxmlc --version || exit 1
				fi
				sudo mkdir -p "/Library/Application Support/Macromedia"
				echo "ErrorReportingEnable=1\nTraceOutputFileEnable=1" | sudo tee -a "/Library/Application Support/Macromedia/mm.cfg"
			else
				# TODO if the following doesn't work, uncomment either the next lines
				retry wget http://waneck-pub.s3-website-us-east-1.amazonaws.com/unitdeps/flashplayer_11_sa_debug.i386.min.tar.xz
				# retry wget http://waneck-pub.s3-website-us-east-1.amazonaws.com/unitdeps/flashplayer_11_sa_debug.i386.tar.gz
				# retry wget http://fpdownload.macromedia.com/pub/flashplayer/updaters/11/flashplayer_11_sa_debug.i386.tar.gz
				# install libgd2-xpm ; install ia32-libs ; install ia32-libs-multiarch ; 
				install libgtk2.0-0:i386 ; install libxt6:i386 ; install libnss3:i386 ; install libcurl3:i386
				[ -f /etc/init.d/xvfb ] || install xvfb
				# retry sudo apt-get install -qq -y libgd2-xpm ia32-libs ia32-libs-multiarch
				tar -xf flashplayer* -C $HOME/
				echo "ErrorReportingEnable=1\nTraceOutputFileEnable=1" > $HOME/mm.cfg
				mxmlc --version
				if [ $? -ne 0 ] && [ ${SETUP[i]} = "as3" ]; then
					#TODO if the following doesn't work, uncomment either the next lines
					retry wget -O $HOME/flex.tar.xz http://waneck-pub.s3-website-us-east-1.amazonaws.com/unitdeps/apache-flex-sdk-4.12.0-bin-min.tar.xz
					#retry wget -O $HOME/flex.tar.gz http://waneck-pub.s3-website-us-east-1.amazonaws.com/unitdeps/apache-flex-sdk-4.12.0-bin.tar.gz
					#retry wget -O $HOME/flex.tar.gz http://mirror.cc.columbia.edu/pub/software/apache/flex/4.12.0/binaries/apache-flex-sdk-4.12.0-bin.tar.gz
					tar -xf $HOME/flex.tar.* -C ~
					FLEXPATH=$HOME/flex_sdk_4
					mkdir -p $FLEXPATH/player/11.1
					retry wget -nv http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_1.swc -O "$FLEXPATH/player/11.1/playerglobal.swc"
					echo "env.PLAYERGLOBAL_HOME=$FLEXPATH/player" > $FLEXPATH/env.properties
					testprog java -version || install openjdk-7-jdk || exit 1
					mxmlc --version || exit 1
				fi
				# $HOME/runflash || exit 1
			fi
			;;
		js )
			for j in "${!TOOLCHAIN[@]}"; do
				if [ ${TOOLCHAIN[j]} = "default" ] || [ ${TOOLCHAIN[j]} = "nodejs" ]; then
					testprog nodejs -v || testprog node -v || install nodejs node
					testprog nodejs -v || testprog node -v || exit 1
				elif [ ${TOOLCHAIN[j]} = "browser" ]; then
					testprog phantomjs -v || install phantomjs
					phantomjs -v || exit 1
				fi
			done
			;;
		* )
			;;
	esac
done
