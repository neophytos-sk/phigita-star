# mkIndex.tcl --
#
#	This script generates a pkgIndex.tcl file for an installed extension.
#
# Copyright (c) 1999 Scriptics Corporation.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
#
# Notes:
#
# If you redefine $(libdir) using the configure switch --libdir=, then
# this script will probably fail for you.
#
# UNIX:
#      exec_prefix
#           |
#           |
#           |
#          lib
#          / \
#         /   \
#        /     \
#   PACKAGE   (.so files)
#       |
#       |
#       |
#  pkgIndex.tcl
#
# WIN:
#      exec_prefix
#          / \
#         /   \
#        /     \
#      bin     lib
#       |        \
#       |         \
#       |          \
# (.dll files)   PACKAGE
#                    |
#                    |
#                    |
#                pkgIndex.tcl
       
# The pkg_mkIndex routines from Tcl 8.2 and later support stub-enabled
# extensions.  Notify the user if this is not a valid tcl shell.
# Exit with a status of 0 so that the make-install process does not stop.

if {[catch {package require Tcl 8.2} msg]} {
    puts stderr "**WARNING**"
    puts stderr $msg
    puts stderr "Could not build pkgIndex.tcl file.  You must create one by hand"
    exit 0
}

# Nativepath --
#
#	Convert a Cygnus style path to a native path
#
# Arguments:
#	pathName	Path to convert
#
# Results:
#	The result is the native name of the input pathName.
#	On Windows, this is z:/foo/bar, on Unix the input pathName is
#	returned.

proc Nativepath {pathName} {
    global tcl_platform

    if {![string match $tcl_platform(platform) unix]} {
	if {[regexp {//(.)/(.*)} $pathName null driveLetter pathRemains]} {
	    set pathName $driveLetter:/$pathRemains
	}
    }
    return $pathName
}

set prefix "/opt/aolserver-4.5.0/"
set exec_prefix "/opt/aolserver-4.5.0/"

set exec_prefix [Nativepath $exec_prefix] 

set libdir ${exec_prefix}/lib
set package ttext

cd $libdir
puts "Making pkgIndex.tcl in [file join [pwd] $package]"

if {$tcl_platform(platform) == "unix"} {
    pkg_mkIndex $package ../*[info sharedlibextension] *.tcl
} else {
    pkg_mkIndex $package [file join .. .. bin *[info sharedlibextension]]
}
