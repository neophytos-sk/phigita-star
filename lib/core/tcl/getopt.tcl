# Copyright (c) 2008, Federico Ferri
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of Federico Ferri nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL FEDERICO FERRI BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# getopt::init {
#   {verbose  v  {verbose}}
#   {input    i  {input input_file}}
#   {output   o  {output output_file}}
#   {range    r  {range range_min range_max}}
#   row
#   col
# }
#
# getopt::init accepts a list of items of the following form:
#   {longName shortName varList}
#   posArg
#
# longName is the long option name (without the initial '--')
# shortName is the short (one character) option name (without the initial '-')
# varList is a list of variable names which will hold the value of the
# corresponding arguments. The first will be set to 1 (one) whenever the switch
# appears on the command line, the second variable name will hold the first switch
# argument, and so forth. It is possible to have switches taking multiple arguments.
# In the above example, range takes two arguments in the form: --range <min> <max>


namespace eval getopt {
        # list of option vars (keys are long option names)
        variable optargs

        # positional arguments
        variable posArgs

        # map option names to long option names
        variable map
}

proc getopt::init {optdata} {
    variable optargs
    variable map
    variable posArgs

    set posArgs {}
    array set optargs {}
    array set map {}

    foreach item $optdata {
        set len [llength $item]
        if { $len == 3 } {
            lassign $item longname shortname varlist
            set stl_map($shortname) $longname

            set argname [lindex $varlist 0]
            set map(-$shortname) $argname
            set map(--$longname) $argname
            set optargs($argname) $varlist


        } else {
            lappend posArgs $item
        }
    }
}

proc getopt::getopt {argVar argv} {

    upvar $argVar arg

    variable map
    variable posArgs

    if { [array size map] } {

        set argc [llength $argv]
        for {set i 0} {$i < $argc} {} {
            set argv_i [lindex $argv $i]

            if { [string index $argv_i 0] ne {-} } {

                # nonPosArgs shall precede posArgs
                # first occurrence of an argument
                # that does not start with a dash
                # terminates nonPosArgs processing

                set argv [lrange $argv $i end]
                break

            } else {

                incr i

                if { $argv_i eq {--} && ${posArgs} ne {} } {

                    # separator (--) terminates nonPosArgs processing
                    # in cases that we also have posArgs

                    set argv [lrange $argv $i end]
                    break

                } elseif { [string range $argv_i 0 1] eq {--} } {

                    if { ![info exists map($argv_i)] } {

                        # nonPosArgs must have an entry
                        # in the array that maps options
                        # to variable names

                        error "no such option: $argv_i"

                    }

                    # isLongOpt - starts with two dashes
                    # and entry exists in map array

                    set argname $map($argv_i)
                    set arg($argname) ""
                    set i [getoptargs arg $argname $argc $argv $i]

                } elseif { [string index $argv_i 0] eq {-} } {

                    set argv_i_opts [split [regsub {^-} $argv_i {}] {}]
                    foreach shortOpt $argv_i_opts {

                        if { [info exists map(-$shortOpt)] } {

                            # isShortOpt - starts with two dashes
                            # and entry exists in map array

                            set argname $map(-$shortOpt)
                            set arg($argname) ""
                            set i [getoptargs arg $argname $argc $argv $i]

                        } else {

                            # nonPosArgs must have an entry
                            # in the array that maps options
                            # to variable name

                            puts "error: unknown option: -$shortOpt"
                            exit 2
                        }
                    }
                    #continue
                }
            }
        }
    }

    while { $argv ne {} && $posArgs ne {} } {
        set posArgs [lassign $posArgs argv_i]
        upvar $argv_i _
        set argv [lassign $argv {_}]
    }

    if { $posArgs ne {} } {
        error "not enough arguments for posArgs: $posArgs"
    }

    return $argv

}

proc getopt::getoptargs {argVar argname argc argv i} {
    upvar $argVar arg
    variable optargs

    set varlist $optargs($argname)
    set n_required_opt_args [expr {-1+[llength $varlist]}]
    set j 1
    while {$n_required_opt_args > 0} {
        incr n_required_opt_args -1
        if {$i >= $argc} {
            puts "not enough arguments for option: $argname"
            exit 3
        }

        # Note: if it's a multiple, we need to use lappend or some
        # other form of setter that preserves mutliple values

        set varname [lindex $varlist $j]
        set arg($varname) [lindex $argv $i]

        incr j
        incr i
    }
    return $i
}
