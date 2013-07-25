# libdkim makefile for UNIX
#

#ifdef LINUX
CFLAGS  = -c
LFLAGS  = 
LIBS    = -lcrypto -lresolv
#else
CFLAGS  = -c
LFLAGS  = 
LIBS    = -lcrypto 
#endif

INCL	=  -I /usr/include/openssl/

SRCS = dkim.cpp dns.cpp dkimbase.cpp dkimsign.cpp dkimverify.cpp

OBJS = $(SRCS:.cpp=.o)

HDRS = dkim.h dns.h dkimbase.h dkimsign.h dkimverify.h

all: libdkim.a libdkimtest

libdkim.a: $(OBJS)
	rm -f libdkim.a
	ar cr libdkim.a $(OBJS)
	ranlib libdkim.a

libdkimtest : libdkim.a libdkimtest.o
	g++ -olibdkimtest $(LFLAGS) \
	       -L . libdkimtest.o $(LIBS) -ldkim
	
libdkimtest.o: libdkimtest.cpp $(HDRS)

.cpp.o:
	g++ $(CFLAGS) -c $<

clean:
	rm  *.o libdkim.lib libdkimtest


