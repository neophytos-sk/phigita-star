#!/bin/sh
# Fri Jan  5 14:57:59 EST 2001
# FILE: /usr/local/bin/unpack
# Copyright 2001, 2002, 2003, Chris F.A. Johnson
# Released under the terms of the GNU General Public License

die() {
    printf "%b\n" "$*"
    exit 5
}

for file in "$@"
do
    case $file in

	*.zip|*.ZIP)
	    unzip "$file"
	    ;;

	*.tar)
	    tar xvpf "$file"
	    ;;

	*.tgz|*tar.gz|*.tar.Z)
	    gunzip -c  "$file" | tar xvpf -
	    ;;

	*tar.bz2|*.tbz2)
	    bunzip2 -c "$file" | tar xvpf -
	    ;;

	## gzipped and bzip2ed files are uncompressed to the current
	## directory, leaving the original files in place
	*.gz)
	    gunzip -c "$file" > "`basename "$file" .gz`"
	    ;;

	*.Z)
	    gunzip -c "$file" > "`basename "$file" .Z`"
	    ;;

	*.bz2)
	    bunzip2  -c "$file" > "`basename "$file" .bz2`"
	    ;;

        *.rpm)
            dir="`basename "$file" .rpm`"
	    mkdir -p "$dir" || die "Could not create $dir"
	    (
		cd "$dir" || die "Could not cd to $dir"
		rpm2cpio "$file" | cpio -dim
	    )
	    ;;

        *.deb)
            dir="`basename "$file" .deb`"
	    mkdir -p "$dir" || die "Could not create $dir"
	    (
		cd "$dir" || die "Could not cd to $dir"
		ar -x "$file"
		[ -f control.tar.gz ] && gunzip -c  control.tar.gz | tar xvp
		[ -f data.tar.gz ] && gunzip -c  data.tar.gz | tar xvp
	    )
	    ;;
    esac
done
