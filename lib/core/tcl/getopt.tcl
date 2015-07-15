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
        variable optlist

        # residual arguments
        variable posArgs

        # map short option names to long option names
        variable stl_map
}

proc getopt::init {optdata} {
    variable optlist
    variable posArgs
    variable stl_map
    array set optlist {}
    array set stl_map {}
    foreach item $optdata {
        set len [llength $item]
        if { $len == 3 } {
            lassign $item longname shortname varlist
            set optlist($longname) $varlist
            set stl_map($shortname) $longname
        } else {
            lappend posArgs $item
        }
    }
}

proc getopt::expandOptNames {argv} {
        variable optlist
        variable stl_map
        set argv2 {}
        set argc [llength $argv]
        for {set i 0} {$i < $argc} {} {
                set argv_i [lindex $argv $i]
                incr i

                if [isShortOpt $argv_i] {
                        set argv_i_opts [split [regsub {^-} $argv_i {}] {}]
                        foreach shortOpt $argv_i_opts {
                                if [info exists stl_map($shortOpt)] {
                                        set longOpt $stl_map($shortOpt)
                                        lappend argv2 --$longOpt
                                        set n_required_opt_args [expr {-1+[llength $optlist($longOpt)]}]
                                        while {$n_required_opt_args > 0} {
                                                incr n_required_opt_args -1
                                                if {$i >= $argc} {
                                                        puts "error: not enough arguments for option -$shortOpt"
                                                        exit 3
                                                }
                                                lappend argv2 [lindex $argv $i]
                                                incr i
                                        }
                                } else {
                                        puts "error: unknown option: -$shortOpt"
                                        exit 2
                                }
                        }
                        continue
                }

                lappend argv2 $argv_i
        }
        return $argv2
}

proc getopt::isShortOpt {o} {
        return [regexp {^-[a-zA-Z0-9]+} $o]
}

proc getopt::isLongOpt {o} {
        return [regexp {^--[a-zA-Z0-9][a-zA-Z0-9]*} $o]
}

proc getopt::getopt {argv} {
        variable optlist
        variable posArgs

        set argv [expandOptNames $argv]
        set argc [llength $argv]

        set residualArgs {}

        for {set i 0} {$i < $argc} {} {
            set argv_i [lindex $argv $i]
            incr i

            if [isLongOpt $argv_i] {
                set optName [regsub {^--} $argv_i {}]
                if [info exists optlist($optName)] {
                    set varlist $optlist($optName)
                    upvar [lindex $optlist($optName) 0] _
                    set _ ""
                    set n_required_opt_args [expr {-1+[llength $varlist]}]
                    set j 1
                    while {$n_required_opt_args > 0} {
                        incr n_required_opt_args -1
                        if {$i >= $argc} {
                            puts "error: not enough arguments for option --$optName"
                            exit 5
                        }
                        uplevel [list set [lindex $varlist $j] [lindex $argv $i]]
                        incr j
                        incr i
                    }
                } else {
                    puts "error: unknown option: --$optName"
                    exit 4
                }
                continue
            }

            lappend residualArgs $argv_i
        }

        while { $residualArgs ne {} && $posArgs ne {} } {
            set posArgs [lassign $posArgs argv_i]
            upvar $argv_i _
            set residualArgs [lassign $residualArgs {_}]
        }

        if { $posArgs ne {} } {
            error "not enough arguments for posArgs: $posArgs"
        }

        return $residualArgs
}
