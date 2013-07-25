ifndef NAVISERVER
    NAVISERVER  = /opt/naviserver
endif

#
# Module name
#
MOD      =  nssmtpd.so

#
# Objects to build.
#
OBJS     = nssmtpd.o

# Use DSPAM
#CFLAGS   += -I/usr/local/include -DUSE_DSPAM -DSIGNATURE_LIFE=14 -DDSPAM_HOME=/usr/local/aolserver/modules/dspam
#MODLIBS  += -ldspam

# Use SpamAssassin
#CFLAGS   += -DUSE_SPAMASSASSIN

# SAVI interface
#CFLAGS   += -DUSE_SAVI -I/usr/local/include/sav_if
#MODLIBS  += -L/usr/local/lib -lsavi

# ClamAv interface
#CFLAGS   += -DUSE_CLAMAV
#MODLIBS  += -lclamav

include  $(NAVISERVER)/include/Makefile.module
