#!/bin/bash
source $(dirname $0)/defaults.sh

for i in "${!TARGET[@]}"; do
	CURTARGET=${TARGET[i]}
	for j in "${!TOOLCHAIN[@]}"; do
		CURTOOL=${TOOLCHAIN[j]}
		case ${TARGET[i]} in
			js )
				if [ $CURTOOL = "browser" ]; then
					[[ $HXFLAGS_EXTRA && ${HXFLAGS_EXTRA-x} ]] || HXFLAGS_EXTRA="-js \"$TARGET_DIR/js.js\""
				else
					[[ $HXFLAGS_EXTRA && ${HXFLAGS_EXTRA-x} ]] || HXFLAGS_EXTRA="-js \"$TARGET_DIR/js.js\" -D nodejs"
				fi

				HX="$HXFLAGS $HXFLAGS_EXTRA"
				eval "haxe $HX" || exit 1
				;;
			swf | flash | swf9 | flash9 )
				[[ $HXFLAGS_EXTRA && ${HXFLAGS_EXTRA-x} ]] || HXFLAGS_EXTRA="-swf \"$TARGET_DIR/$CURTARGET.swf\" -D fdb"
				HX="$HXFLAGS $HXFLAGS_EXTRA"
				eval "haxe $HX" || exit 1
				;;
			swf8 | flash8 )
				[[ $HXFLAGS_EXTRA && ${HXFLAGS_EXTRA-x} ]] || HXFLAGS_EXTRA="-swf-version 8 -swf \"$TARGET_DIR/$CURTARGET.swf\" -D fdb"
				HX="$HXFLAGS $HXFLAGS_EXTRA"
				eval "haxe $HX" || exit 1
				;;
			as3 )
				[[ $HXFLAGS_EXTRA && ${HXFLAGS_EXTRA-x} ]] || HXFLAGS_EXTRA="-as3 \"$TARGET_DIR/as3\" -D fdb"
				HX="$HXFLAGS $HXFLAGS_EXTRA"
				eval "haxe $HX" || exit 1
				;;
			neko )
				[[ $HXFLAGS_EXTRA && ${HXFLAGS_EXTRA-x} ]] || HXFLAGS_EXTRA="-neko \"$TARGET_DIR/neko.n\""
				HX="$HXFLAGS $HXFLAGS_EXTRA"
				eval "haxe $HX" || exit 1
				;;
			php )
				[[ $HXFLAGS_EXTRA && ${HXFLAGS_EXTRA-x} ]] || HXFLAGS_EXTRA="-php \"$TARGET_DIR/php\""
				HX="$HXFLAGS $HXFLAGS_EXTRA"
				eval "haxe $HX" || exit 1
				;;
			cpp )
				rm -rf "$TARGET_DIR/cpp"
				[[ $HXFLAGS_EXTRA && ${HXFLAGS_EXTRA-x} ]] || HXFLAGS_EXTRA="-cpp \"$TARGET_DIR/cpp\""
				if [ ! $ARCH = "i686" ]; then
					HXFLAGS_EXTRA="-D HXCPP_M64 $HXFLAGS_EXTRA"
				fi
				HX="$HXFLAGS $HXFLAGS_EXTRA"
				eval "haxe $HX" || exit 1
				;;
			cs )
				rm -rf "$TARGET_DIR/cs"
				[[ $HXFLAGS_EXTRA && ${HXFLAGS_EXTRA-x} ]] || HXFLAGS_EXTRA="-cs \"$TARGET_DIR/cs\""
				HX="$HXFLAGS $HXFLAGS_EXTRA"
				eval "haxe $HX" || exit 1
				;;
			java )
				rm -rf "$TARGET_DIR/java"
				[[ $HXFLAGS_EXTRA && ${HXFLAGS_EXTRA-x} ]] || HXFLAGS_EXTRA="-java \"$TARGET_DIR/java\""
				HX="$HXFLAGS $HXFLAGS_EXTRA"
				eval "haxe $HX" || exit 1
				;;
			python )
				[[ $HXFLAGS_EXTRA && ${HXFLAGS_EXTRA-x} ]] || HXFLAGS_EXTRA="-python \"$TARGET_DIR/python.py\""
				HX="$HXFLAGS $HXFLAGS_EXTRA"
				eval "haxe $HX" || exit 1
				;;
			interp )
				[[ $HXFLAGS_EXTRA && ${HXFLAGS_EXTRA-x} ]] || HXFLAGS_EXTRA="--interp"
				HX="$HXFLAGS $HXFLAGS_EXTRA"
				eval "haxe $HX" || exit 1
				;;
			macro )
				[[ $HXFLAGS_EXTRA && ${HXFLAGS_EXTRA-x} ]] || HXFLAGS_EXTRA="$MACROFLAGS"
				HX="$HXFLAGS $HXFLAGS_EXTRA"
				eval "haxe $HX" || exit 1
				;;
			* )
				echo "unrecognized target ${TARGET[i]}"
				;;
		esac
	done
done
