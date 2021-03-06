#!/bin/bash
source $(dirname $0)/defaults.sh

for i in "${!TARGET[@]}"; do
	CURTARGET=${TARGET[i]}
	for j in "${!TOOLCHAIN[@]}"; do
		CURTOOL=${TOOLCHAIN[j]}
		export CURTARGET=$CURTARGET
		export CURTOOL=$CURTOOL
		BUILTFILE=$1
		case ${TARGET[i]} in
			js )
				[ ! -z $BUILTFILE ] || BUILTFILE="$TARGET_DIR/js.js"
				case $CURTOOL in
					default | nodejs )
						if [ ! -z "$NODECMD" ]; then
							node -e "$NODECMD" || exit 1
						else
							node $BUILTFILE || exit 1
						fi
						;;
					browser )
						if [ ! -f "unit-js.html" ]; then
							echo '<!DOCTYPE html>\n<html><head><meta charset="utf-8"><title>Tests (JS)</title></head><body><div id="haxe:trace"></div>' > unit-js.html
							echo "<script src=\"$BUILTFILE\"></script>" >> unit-js.html
							echo "</body></html>" >> unit-js.html
						fi
						killall nekotools
						nekotools server &
						# wait a while for the nekotools server to initialize
						sleep .5
						echo "phantomjs test"
						evaltest phantomjs $(dirname $0)/extra/phantom/testphantom.js || exit 1

						if [ ! -z "$SAUCE_USERNAME" ]; then
							echo "saucelabs tests"
							CURDIR=$PWD
							cd $(dirname $0)/extra/saucelabs
							npm install wd || exit 1
							cd "$CURDIR"
							retry curl https://gist.github.com/santiycr/5139565/raw/sauce_connect_setup.sh -L | bash
							node $(dirname $0)/extra/saucelabs/RunSauceLabs.js || exit 1
						fi
						;;
					* )
						echo "Unknown toolchain $CURTOOL"
						exit 1
						;;
				esac
				;;
			swf | flash | swf9 | swf8 | flash8 | flash9 | as3 )
				if [ $CURTARGET = "as3" ]; then
					# compile as3
					[ ! -z $BUILTFILE ] || BUILTFILE="$TARGET_DIR/as3"
					PATH=$PATH:$HOME/flex_sdk_4
					mxmlc -static-link-runtime-shared-libraries=true -debug $BUILTFILE/__main__.as --output "$TARGET_DIR/as3.swf"
					BUILTFILE="$TARGET_DIR/as3.swf"
				fi
				[ ! -z $BUILTFILE ] || BUILTFILE="$TARGET_DIR/$CURTARGET.swf"
				echo "ErrorReportingEnable=1\nTraceOutputFileEnable=1" > $HOME/mm.cfg
				if [ $OS = "linux" ]; then
					export DISPLAY=:99.0
					export AUDIODEV=null
					# sh -e /etc/init.d/xvfb start
					FLASHLOGPATH=$HOME/.macromedia/Flash_Player/Logs/flashlog.txt
				else
					sudo mkdir -p "/Library/Application Support/Macromedia"
					echo "ErrorReportingEnable=1\nTraceOutputFileEnable=1" | sudo tee -a "/Library/Application Support/Macromedia/mm.cfg"
					FLASHLOGPATH="$HOME/Library/Preferences/Macromedia/Flash Player/Logs/flashlog.txt"
				fi
				ls

				sudo killall "Flash Player Debugger"
				killall tail
				rm -f /tmp/flash-fifo
				rm -f "$FLASHLOGPATH"

				echo "runflash $BUILTFILE"
				runflash "$BUILTFILE" &
				for i in 0 1 2 3 4 5; do
					sudo chmod 777 "$FLASHLOGPATH"
					if [ -f "$FLASHLOGPATH" ]; then
						break
					fi
					sleep 2
					echo "waiting for $FLASHLOGPATH"
				done
				if [ ! -f "$FLASHLOGPATH" ]; then
					echo "$FLASHLOGPATH not found"
					exit 1
				fi
				echo "checking contents"

				mkfifo /tmp/flash-fifo
				tail -f "$FLASHLOGPATH" > /tmp/flash-fifo &
				$EVAL_TEST_CMD < /tmp/flash-fifo || exit 1
				# evaltest tail -f "$FLASHLOGPATH" || exit 1
				;;
			neko )
				[ ! -z $BUILTFILE ] || BUILTFILE="$TARGET_DIR/neko.n"
				neko "$BUILTFILE" || exit 1
				;;
			php )
				[ ! -z $BUILTFILE ] || BUILTFILE="$TARGET_DIR/php/index.php"
				php "$BUILTFILE" || exit 1
				;;
			python )
				[ ! -z $BUILTFILE ] || BUILTFILE="$TARGET_DIR/python.py"
				[ ! -z $PYTHONCMD ] || PYTHONCMD=python3
				$PYTHONCMD "$BUILTFILE" || exit 1
				;;
			cpp )
				if [ -z $BUILTFILE ]; then
					# get first executable at directory
					HASRUN=0
					for file in "$TARGET_DIR/cpp/"*; do
						if [ -x $file ] && [ -f $file ]; then
							$file || exit 1
							HASRUN=1
						fi
					done
					[ $HASRUN -eq 1 ] || exit 1
				else
					$BUILTFILE || exit 1
				fi
				;;
			cs )
				if [ -z $BUILTFILE ]; then
					HASRUN=0
					for file in "$TARGET_DIR/cs/bin/"*.exe; do
						echo "mono --debug $file"
						if [ $ARCH = "i686" ]; then
							mono32 --debug $file || exit 1
						else
							mono --debug $file || exit 1
						fi
						HASRUN=1
					done
					[ $HASRUN -eq 1 ] || exit 1
				else
					echo "mono --debug $BUILTFILE"
					if [ $ARCH = "i686" ]; then
						mono32 --debug $BUILTFILE || exit 1
					else
						mono --debug $BUILTFILE || exit 1
					fi
				fi
				;;
			java )
				if [ $ARCH = "i686" ]; then
					# max priority
					export PATH=/usr/lib/jvm/java-7-openjdk-i386/bin:$PATH
				fi
				if [ -z $BUILTFILE ]; then
					HASRUN=0
					for file in "$TARGET_DIR/java/"*.jar; do
						echo "java -jar $file"
						if [ $ARCH = "i686" ]; then
							/usr/lib/jvm/java-7-openjdk-i386/bin/java -d32 -jar "$file" || exit 1
						else
							java -jar "$file" || exit 1
						fi
						HASRUN=1
					done
					[ $HASRUN -eq 1 ] || exit 1
				else
					if [ $ARCH = "i686" ]; then
						/usr/lib/jvm/java-7-openjdk-i386/bin/java -d32 -jar "$BUILTFILE" || exit 1
					else
						java -jar "$BUILTFILE" || exit 1
					fi
				fi
				;;
			interp | macro )
				# nothing to do, they were already run by the build
				;;
			* )
				echo "unrecognized setup ${TARGET[i]}"
				;;
		esac
	done
done
