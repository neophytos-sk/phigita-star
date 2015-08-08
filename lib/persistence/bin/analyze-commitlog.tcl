#!/bin/sh
#\
 exec tclsh "$0" "$@"

package require persistence

::persistence::commitlog::analyze
