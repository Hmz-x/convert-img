#!/bin/bash

# insall convert-img and convert-vid to PATH

err(){
	printf "%s. Exitting.\n" "$1" >&2
	exit 1
}

[ $UID -ne 0 ] && "Run as root to install to PATH"

cp -v "$(dirname "$0")/convert-img.sh" /usr/local/bin
cp -v "$(dirname "$0")/convert-vid.sh" /usr/local/bin
