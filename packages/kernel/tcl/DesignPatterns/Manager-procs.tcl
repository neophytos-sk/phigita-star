# $Id: s.manager.xotcl 1.7 01/03/23 21:55:33+01:00 neumann@somewhere.wu-wien.ac.at $

# a simle manager pattern following buschmann (164) 
# based on dynamic object aggregation and using dynamic code
# for supplier creation (instead of loading)
#
# it shares the suppliers !
#

#
# abstract supplier, init starts dynamic code creation
#
Class Supplier
Supplier abstract instproc init args
Supplier abstract instproc m args


Class Manager -parameter {
  {supplierClass Supplier}
} 

Manager instproc getSupplier {name} {
  if {[[self] info children [namespace tail $name]] != ""} {
    return [self]::[namespace tail $name]
  } else {
    return [[self] [[self] supplierClass] [namespace tail $name]]
  }
}

