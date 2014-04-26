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
							echo '<!DOCTYPE html>\n<html><head><meta charset="utf-8"><title>Tests (JS)</title></head><body id="haxe:trace">' > unit-js.html
							echo "<script src=\"$BUILTFILE\"></script>" >> unit-js.html
							echo "</body></html>" >> unit-js.html
						fi
						nekotools server &
						if [ ! -z "$SAUCE_USERNAME" ]; then
							CURDIR=$PWD
							cd $(dirname $0)/extra/saucelabs
							npm install wd || exit 1
							cd "$CURDIR"
							retry curl https://gist.github.com/santiycr/5139565/raw/sauce_connect_setup.sh -L | bash
							node $(dirname $0)/extra/saucelabs/RunSauceLabs.js || exit 1
						fi
						echo "phantomjs test"
						phantomjs $(dirname $0)/extra/testphantom.js || exit 1
						;;
					* )
						;;
				esac
				;;
			swf | flash | swf9 | swf8 | flash8 | flash9 )
				;;
			as3 )
				;;
			neko )
				[ ! -z $BUILTFILE ] || BUILTFILE="$TARGET_DIR/neko.n"
				neko "$BUILTFILE" || exit 1
				;;
			php )
				[ ! -z $BUILTFILE ] || BUILTFILE="$TARGET_DIR/php/index.php"
				php "$BUILTFILE" || exit 1
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
						mono --debug $file || exit 1
						HASRUN=1
					done
					[ $HASRUN -eq 1 ] || exit 1
				else
					echo "mono --debug $BUILTFILE"
					mono --debug $BUILTFILE || exit 1
				fi
				;;
			java )
				if [ -z $BUILTFILE ]; then
					HASRUN=0
					for file in "$TARGET_DIR/java/"*.jar; do
						echo "java -jar $file"
						java -jar $file || exit 1
						HASRUN=1
					done
					[ $HASRUN -eq 1 ] || exit 1
				else
					java -jar "$BUILTFILE" || exit 1
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
