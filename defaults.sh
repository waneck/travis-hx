
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
			retry sudo apt-get install -qq -y $1:i386 2> /dev/null
		else
			retry sudo apt-get install -qq -y $1 2> /dev/null
		fi
	else
		if [ $FIRST -eq 0 ]; then
			sudo brew update 2> /dev/null
			FIRST=1
		fi
		retry sudo brew install $1 2> /dev/null
	fi
}

function testprog {
	"$@" 2> /dev/null
}

echo "$(basename $0) - $ARCH-$OS-$TARGET-$TOOLCHAIN"

git --version || sudo apt-get install -y git || install git
