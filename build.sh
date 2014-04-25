#!/bin/bash
source $(dirname $0)/defaults.sh

HXFLAGS=$HXFLAGS $HXFLAGS_EXTRA

for i in "${!TARGET[@]}"; do
	CURTARGET=${TARGET[i]}
	for j in "${!TOOLCHAIN[@]}"; do
		CURTOOL=${TOOLCHAIN[j]}
		case ${TARGET[i]} in
			js )
				haxe $HXFLAGS -js "$TARGET_DIR/js.js" || exit 1
				;;
			swf | flash | swf9 )
				haxe $HXFLAGS -swf "$TARGET_DIR/swf.swf" || exit 1
			swf8 )
				haxe $HXFLAGS -swf -swf-version 8 "$TARGET_DIR/swf-8.swf" || exit 1
				;;
			as3 )
				haxe $HXFLAGS -as3 "$TARGET_DIR/as3" || exit 1
				;;
			neko )
				haxe $HXFLAGS -neko "$TARGET_DIR/neko.n" || exit 1
				;;
			php )
				haxe $HXFLAGS -php "$TARGET_DIR/php" || exit 1
				;;
			cpp )
				haxe $HXFLAGS -cpp "$TARGET_DIR/cpp" || exit 1
				;;
			cs )
				haxe $HXFLAGS -cs "$TARGET_DIR/cs" || exit 1
				;;
			java )
				haxe $HXFLAGS -java "$TARGET_DIR/java" || exit 1
				;;
			interp )
				haxe $HXFLAGS --interp || exit 1
				;;
			macro )
				haxe $HXFLAGS $MACROFLAGS || exit 1
				;;
			* )
				echo "unrecognized target ${TARGET[i]}"
				;;
		esac
done
