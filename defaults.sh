
# setting up defaults 
[[ $OS && ${OS-x} ]] || OS=linux
OS=$(echo $OS | tr '[:upper:]' '[:lower:]')

[[ $SETUP && ${SETUP-x} ]] || SETUP=$TARGET
[[ $TARGET_DIR && ${TARGET_DIR-x} ]] || TARGET_DIR=.
mkdir -p $TARGET_DIR

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
		for i in 0 1 2 3; do
			$@ && return 0
		done
		return 1
	else
		$@
	fi
}

FIRST=0

function install {
	echo "installing $1"
	if [ $OS = "linux" ]; then
		if [ $FIRST -eq 0 ]; then
			retry sudo apt-get update -qq
			FIRST=1
		fi
		if [ $ARCH = "i686" ] && [[ ! $1 == *:i386 ]]; then
			retry sudo apt-get install -y $1:i386 2> /dev/null
		else
			retry sudo apt-get install -y $1 2> /dev/null
		fi
	else
		if [ $FIRST -eq 0 ]; then
			brew update 2> /dev/null
			FIRST=1
		fi
		[[ $2 && ${2-x} ]] && retry brew install $2 2> /dev/null || retry brew install $1 2> /dev/null
	fi
}

function testprog {
	"$@" 2> /dev/null
}

function runflash {
	if [ $OS = "mac" ]; then
		"~/flashplayer.app/Contents/MacOS/Flash Player Debugger" "$@"
	else
		xvfb-run ~/flashplayerdebugger "$@"
	fi
}

function evaltest {
	if [[ $EVAL_TEST_CMD && ${EVAL_TEST_CMD-x} ]]; then
		"$@" | $EVAL_TEST_CMD
	else
		"$@" | neko $(dirname $0)/extra/evaluate-test/evaluate-test.n
	fi
}

PATH=$PATH:$HOME/flex_sdk_4/bin

echo "$(basename $0) - $ARCH-$OS-$TARGET-$TOOLCHAIN"
IFS=' ' read -a SETUP <<< "$SETUP"
IFS=' ' read -a TARGET <<< "$TARGET"
IFS=' ' read -a TOOLCHAIN <<< "$TOOLCHAIN"

git --version || sudo apt-get install -y git || install git

wget --version 2>&1 > /dev/null || install wget
