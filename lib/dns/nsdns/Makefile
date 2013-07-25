ifndef NAVISERVER
    NAVISERVER  = /usr/local/ns
endif

#
# Module name
#
MOD      =  nsdns.so

#
# Objects to build.
#
OBJS     = nsdns.o dns.o

#
# Modules to install
#
PROCS   = dns_procs.tcl

INSTALL += install-procs

include  $(NAVISERVER)/include/Makefile.module

install-procs: $(PROCS)
	for f in $(PROCS); do $(INSTALL_SH) $$f $(INSTTCL)/; done


