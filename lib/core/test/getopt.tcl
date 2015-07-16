package require core

set args { -vio infile outfile --range {2 7} 3 4 }

getopt::init {
  {verbose  v  {verbose}}
  {input    i  {__arg_input input_file}}
  {output   o  {__arg_output output_file}}
  {range    r  {__arg_range range}}
  row
  col
}

set args [getopt::getopt arg $args]

puts [array get arg]
