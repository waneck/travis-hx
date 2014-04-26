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
						[ ! -z $NODECMD ] && node -e $NODECMD || node $BUILTFILE || exit 1
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
