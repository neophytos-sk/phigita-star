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
            if { $shortname ne {} } {
                set map(-$shortname) $argname
            }
            set map(--$longname) $argname
            set optargs($argname) $varlist
        } else {
            lappend posArgs $item
        }
    }
}

proc getopt::getopt {argv {argVar ""} } {

    if { $argVar ne {} } {
        upvar $argVar arg
    }

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

    # TODO: deal with args argument

    while { $argv ne {} && $posArgs ne {} } {
        set posArgs [lassign $posArgs argv_i]
        set argv [lassign $argv arg($argv_i)]
    }

    if { $posArgs ne {} } {
        error "not enough arguments for posArgs: $posArgs"
    }

    if { $argVar eq {} } {
        # instantiate variables from array
        foreach {varname value} [array get arg] {
            upvar ${varname} _
            set _ ${value}
        }
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
