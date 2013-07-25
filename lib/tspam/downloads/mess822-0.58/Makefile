# Don't edit Makefile! Use conf-* for configuration.

SHELL=/bin/sh

default: it

822date: \
load 822date.o libtai.a mess822.a getln.a strerr.a substdio.a \
stralloc.a alloc.a error.a str.a case.a fs.a
	./load 822date libtai.a mess822.a getln.a strerr.a \
	substdio.a stralloc.a alloc.a error.a str.a case.a fs.a 

822date.0: \
822date.1
	nroff -man 822date.1 > 822date.0

822date.o: \
compile 822date.c substdio.h strerr.h subfd.h substdio.h getln.h \
mess822.h stralloc.h gen_alloc.h caltime.h caldate.h exit.h \
leapsecs.h caltime.h tai.h uint64.h
	./compile 822date.c

822field: \
load 822field.o mess822.a getln.a strerr.a substdio.a stralloc.a \
alloc.a error.a str.a case.a fs.a
	./load 822field mess822.a getln.a strerr.a substdio.a \
	stralloc.a alloc.a error.a str.a case.a fs.a 

822field.0: \
822field.1
	nroff -man 822field.1 > 822field.0

822field.o: \
compile 822field.c substdio.h strerr.h subfd.h substdio.h getln.h \
mess822.h stralloc.h gen_alloc.h caltime.h caldate.h exit.h
	./compile 822field.c

822header: \
load 822header.o mess822.a getln.a strerr.a substdio.a stralloc.a \
alloc.a error.a str.a
	./load 822header mess822.a getln.a strerr.a substdio.a \
	stralloc.a alloc.a error.a str.a 

822header.0: \
822header.1
	nroff -man 822header.1 > 822header.0

822header.o: \
compile 822header.c substdio.h strerr.h subfd.h substdio.h getln.h \
mess822.h stralloc.h gen_alloc.h caltime.h caldate.h exit.h
	./compile 822header.c

822print: \
load 822print.o libtai.a mess822.a getln.a strerr.a substdio.a \
stralloc.a alloc.a error.a str.a case.a fs.a
	./load 822print libtai.a mess822.a getln.a strerr.a \
	substdio.a stralloc.a alloc.a error.a str.a case.a fs.a 

822print.0: \
822print.1
	nroff -man 822print.1 > 822print.0

822print.o: \
compile 822print.c substdio.h subfd.h substdio.h getln.h mess822.h \
stralloc.h gen_alloc.h caltime.h caldate.h strerr.h exit.h leapsecs.h \
caltime.h tai.h uint64.h
	./compile 822print.c

822received: \
load 822received.o libtai.a mess822.a getln.a strerr.a substdio.a \
stralloc.a alloc.a error.a str.a case.a fs.a
	./load 822received libtai.a mess822.a getln.a strerr.a \
	substdio.a stralloc.a alloc.a error.a str.a case.a fs.a 

822received.0: \
822received.1
	nroff -man 822received.1 > 822received.0

822received.o: \
compile 822received.c substdio.h strerr.h subfd.h substdio.h getln.h \
mess822.h stralloc.h gen_alloc.h caltime.h caldate.h exit.h \
leapsecs.h caltime.h tai.h uint64.h
	./compile 822received.c

addrlist: \
load addrlist.o mess822.a getln.a strerr.a substdio.a stralloc.a \
alloc.a error.a str.a
	./load addrlist mess822.a getln.a strerr.a substdio.a \
	stralloc.a alloc.a error.a str.a 

addrlist.o: \
compile addrlist.c substdio.h strerr.h subfd.h substdio.h getln.h \
mess822.h stralloc.h gen_alloc.h caltime.h caldate.h
	./compile addrlist.c

alloc.a: \
makelib alloc.o alloc_re.o
	./makelib alloc.a alloc.o alloc_re.o

alloc.o: \
compile alloc.c alloc.h error.h
	./compile alloc.c

alloc_re.o: \
compile alloc_re.c alloc.h byte.h
	./compile alloc_re.c

auto-ccld.sh: \
conf-cc conf-ld warn-auto.sh
	( cat warn-auto.sh; \
	echo CC=\'`head -1 conf-cc`\'; \
	echo LD=\'`head -1 conf-ld`\' \
	) > auto-ccld.sh

auto-str: \
load auto-str.o substdio.a error.a str.a
	./load auto-str substdio.a error.a str.a 

auto-str.o: \
compile auto-str.c substdio.h readwrite.h exit.h
	./compile auto-str.c

auto_home.c: \
auto-str conf-home
	./auto-str auto_home `head -1 conf-home` > auto_home.c

auto_home.o: \
compile auto_home.c
	./compile auto_home.c

auto_qmail.c: \
auto-str conf-qmail
	./auto-str auto_qmail `head -1 conf-qmail` > auto_qmail.c

auto_qmail.o: \
compile auto_qmail.c
	./compile auto_qmail.c

byte_chr.o: \
compile byte_chr.c byte.h
	./compile byte_chr.c

byte_copy.o: \
compile byte_copy.c byte.h
	./compile byte_copy.c

byte_cr.o: \
compile byte_cr.c byte.h
	./compile byte_cr.c

byte_rchr.o: \
compile byte_rchr.c byte.h
	./compile byte_rchr.c

caldate_fmjd.o: \
compile caldate_fmjd.c caldate.h
	./compile caldate_fmjd.c

caldate_fmt.o: \
compile caldate_fmt.c caldate.h
	./compile caldate_fmt.c

caldate_mjd.o: \
compile caldate_mjd.c caldate.h
	./compile caldate_mjd.c

caldate_scan.o: \
compile caldate_scan.c caldate.h
	./compile caldate_scan.c

caltime_fmt.o: \
compile caltime_fmt.c caldate.h caltime.h caldate.h
	./compile caltime_fmt.c

caltime_scan.o: \
compile caltime_scan.c caltime.h caldate.h
	./compile caltime_scan.c

caltime_tai.o: \
compile caltime_tai.c tai.h uint64.h leapsecs.h caldate.h caltime.h \
caldate.h
	./compile caltime_tai.c

caltime_utc.o: \
compile caltime_utc.c tai.h uint64.h leapsecs.h caldate.h caltime.h \
caldate.h
	./compile caltime_utc.c

case.a: \
makelib case_diffb.o case_diffs.o
	./makelib case.a case_diffb.o case_diffs.o

case_diffb.o: \
compile case_diffb.c case.h
	./compile case_diffb.c

case_diffs.o: \
compile case_diffs.c case.h
	./compile case_diffs.c

cdb.a: \
makelib cdb_hash.o cdb_unpack.o cdb_seek.o
	./makelib cdb.a cdb_hash.o cdb_unpack.o cdb_seek.o

cdb_hash.o: \
compile cdb_hash.c cdb.h uint32.h
	./compile cdb_hash.c

cdb_seek.o: \
compile cdb_seek.c cdb.h uint32.h
	./compile cdb_seek.c

cdb_unpack.o: \
compile cdb_unpack.c cdb.h uint32.h
	./compile cdb_unpack.c

cdbmake.a: \
makelib cdbmake_pack.o cdbmake_hash.o cdbmake_add.o
	./makelib cdbmake.a cdbmake_pack.o cdbmake_hash.o \
	cdbmake_add.o

cdbmake_add.o: \
compile cdbmake_add.c cdbmake.h uint32.h
	./compile cdbmake_add.c

cdbmake_hash.o: \
compile cdbmake_hash.c cdbmake.h uint32.h
	./compile cdbmake_hash.c

cdbmake_pack.o: \
compile cdbmake_pack.c cdbmake.h uint32.h
	./compile cdbmake_pack.c

cdbmss.o: \
compile cdbmss.c readwrite.h seek.h alloc.h cdbmss.h cdbmake.h \
uint32.h substdio.h
	./compile cdbmss.c

check: \
it instcheck
	./instcheck

commands.o: \
compile commands.c commands.h substdio.h stralloc.h gen_alloc.h str.h \
case.h
	./compile commands.c

compile: \
make-compile warn-auto.sh systype
	( cat warn-auto.sh; ./make-compile "`cat systype`" ) > \
	compile
	chmod 755 compile

config.o: \
compile config.c open.h readwrite.h substdio.h error.h getln.h \
stralloc.h gen_alloc.h config.h stralloc.h env.h
	./compile config.c

constmap.o: \
compile constmap.c constmap.h alloc.h case.h
	./compile constmap.c

env.a: \
makelib env.o
	./makelib env.a env.o

env.o: \
compile env.c str.h env.h
	./compile env.c

error.a: \
makelib error.o error_str.o
	./makelib error.a error.o error_str.o

error.o: \
compile error.c error.h
	./compile error.c

error_str.o: \
compile error_str.c error.h
	./compile error_str.c

fd.a: \
makelib fd_copy.o fd_move.o
	./makelib fd.a fd_copy.o fd_move.o

fd_copy.o: \
compile fd_copy.c fd.h
	./compile fd_copy.c

fd_move.o: \
compile fd_move.c fd.h
	./compile fd_move.c

find-systype: \
find-systype.sh auto-ccld.sh
	cat auto-ccld.sh find-systype.sh > find-systype
	chmod 755 find-systype

fork.h: \
compile load tryvfork.c fork.h1 fork.h2
	( ( ./compile tryvfork.c && ./load tryvfork ) >/dev/null \
	2>&1 \
	&& cat fork.h2 || cat fork.h1 ) > fork.h
	rm -f tryvfork.o tryvfork

fs.a: \
makelib scan_ulong.o scan_long.o scan_sign.o
	./makelib fs.a scan_ulong.o scan_long.o scan_sign.o

getln.a: \
makelib getln.o getln2.o
	./makelib getln.a getln.o getln2.o

getln.o: \
compile getln.c substdio.h byte.h stralloc.h gen_alloc.h getln.h
	./compile getln.c

getln2.o: \
compile getln2.c substdio.h stralloc.h gen_alloc.h byte.h getln.h
	./compile getln2.c

getopt.a: \
makelib subgetopt.o sgetopt.o
	./makelib getopt.a subgetopt.o sgetopt.o

hassgact.h: \
trysgact.c compile load
	( ( ./compile trysgact.c && ./load trysgact ) >/dev/null \
	2>&1 \
	&& echo \#define HASSIGACTION 1 || exit 0 ) > hassgact.h
	rm -f trysgact.o trysgact

haswaitp.h: \
trywaitp.c compile load
	( ( ./compile trywaitp.c && ./load trywaitp ) >/dev/null \
	2>&1 \
	&& echo \#define HASWAITPID 1 || exit 0 ) > haswaitp.h
	rm -f trywaitp.o trywaitp

hier.o: \
compile hier.c auto_home.h
	./compile hier.c

iftocc: \
load iftocc.o mess822.a getln.a strerr.a substdio.a stralloc.a \
alloc.a error.a env.a str.a case.a fs.a open.a
	./load iftocc mess822.a getln.a strerr.a substdio.a \
	stralloc.a alloc.a error.a env.a str.a case.a fs.a open.a 

iftocc.0: \
iftocc.1
	nroff -man iftocc.1 > iftocc.0

iftocc.o: \
compile iftocc.c substdio.h strerr.h subfd.h substdio.h getln.h \
mess822.h stralloc.h gen_alloc.h caltime.h caldate.h case.h env.h \
exit.h
	./compile iftocc.c

install: \
load install.o hier.o auto_home.o strerr.a substdio.a stralloc.a \
alloc.a open.a error.a str.a
	./load install hier.o auto_home.o strerr.a substdio.a \
	stralloc.a alloc.a open.a error.a str.a 

install.o: \
compile install.c substdio.h strerr.h error.h open.h readwrite.h \
exit.h
	./compile install.c

instcheck: \
load instcheck.o hier.o auto_home.o strerr.a substdio.a stralloc.a \
alloc.a error.a str.a
	./load instcheck hier.o auto_home.o strerr.a substdio.a \
	stralloc.a alloc.a error.a str.a 

instcheck.o: \
compile instcheck.c strerr.h error.h readwrite.h exit.h
	./compile instcheck.c

it: \
prog man

leapsecs_add.o: \
compile leapsecs_add.c leapsecs.h tai.h uint64.h
	./compile leapsecs_add.c

leapsecs_init.o: \
compile leapsecs_init.c leapsecs.h
	./compile leapsecs_init.c

leapsecs_read.o: \
compile leapsecs_read.c tai.h uint64.h leapsecs.h
	./compile leapsecs_read.c

leapsecs_sub.o: \
compile leapsecs_sub.c leapsecs.h tai.h uint64.h
	./compile leapsecs_sub.c

libtai.a: \
makelib tai_now.o tai_pack.o tai_unpack.o caldate_fmjd.o \
caldate_mjd.o caldate_fmt.o caldate_scan.o leapsecs_read.o \
leapsecs_init.o leapsecs_add.o leapsecs_sub.o caltime_tai.o \
caltime_utc.o caltime_fmt.o caltime_scan.o
	./makelib libtai.a tai_now.o tai_pack.o tai_unpack.o \
	caldate_fmjd.o caldate_mjd.o caldate_fmt.o caldate_scan.o \
	leapsecs_read.o leapsecs_init.o leapsecs_add.o \
	leapsecs_sub.o caltime_tai.o caltime_utc.o caltime_fmt.o \
	caltime_scan.o

load: \
make-load warn-auto.sh systype
	( cat warn-auto.sh; ./make-load "`cat systype`" ) > load
	chmod 755 load

make-compile: \
make-compile.sh auto-ccld.sh
	cat auto-ccld.sh make-compile.sh > make-compile
	chmod 755 make-compile

make-load: \
make-load.sh auto-ccld.sh
	cat auto-ccld.sh make-load.sh > make-load
	chmod 755 make-load

make-makelib: \
make-makelib.sh auto-ccld.sh
	cat auto-ccld.sh make-makelib.sh > make-makelib
	chmod 755 make-makelib

makelib: \
make-makelib warn-auto.sh systype
	( cat warn-auto.sh; ./make-makelib "`cat systype`" ) > \
	makelib
	chmod 755 makelib

man: \
iftocc.0 ofmipd.0 ofmipname.0 new-inject.0 rewriting.0 rewritehost.0 \
822header.0 822field.0 822date.0 822received.0 822print.0 mess822.0 \
mess822_addr.0 mess822_date.0 mess822_fold.0 mess822_quote.0 \
mess822_token.0 mess822_when.0

mess822.0: \
mess822.3
	nroff -man mess822.3 > mess822.0

mess822.a: \
makelib mess822_date.o mess822_quote.o mess822_fold.o mess822_token.o \
mess822_addr.o mess822_when.o mess822_line.o mess822_ok.o
	./makelib mess822.a mess822_date.o mess822_quote.o \
	mess822_fold.o mess822_token.o mess822_addr.o \
	mess822_when.o mess822_line.o mess822_ok.o

mess822_addr.0: \
mess822_addr.3
	nroff -man mess822_addr.3 > mess822_addr.0

mess822_addr.o: \
compile mess822_addr.c mess822.h stralloc.h gen_alloc.h caltime.h \
caldate.h str.h
	./compile mess822_addr.c

mess822_date.0: \
mess822_date.3
	nroff -man mess822_date.3 > mess822_date.0

mess822_date.o: \
compile mess822_date.c mess822.h stralloc.h gen_alloc.h caltime.h \
caldate.h stralloc.h
	./compile mess822_date.c

mess822_fold.0: \
mess822_fold.3
	nroff -man mess822_fold.3 > mess822_fold.0

mess822_fold.o: \
compile mess822_fold.c mess822.h stralloc.h gen_alloc.h caltime.h \
caldate.h
	./compile mess822_fold.c

mess822_line.o: \
compile mess822_line.c mess822.h stralloc.h gen_alloc.h caltime.h \
caldate.h
	./compile mess822_line.c

mess822_ok.o: \
compile mess822_ok.c mess822.h stralloc.h gen_alloc.h caltime.h \
caldate.h byte.h
	./compile mess822_ok.c

mess822_quote.0: \
mess822_quote.3
	nroff -man mess822_quote.3 > mess822_quote.0

mess822_quote.o: \
compile mess822_quote.c mess822.h stralloc.h gen_alloc.h caltime.h \
caldate.h str.h
	./compile mess822_quote.c

mess822_token.0: \
mess822_token.3
	nroff -man mess822_token.3 > mess822_token.0

mess822_token.o: \
compile mess822_token.c mess822.h stralloc.h gen_alloc.h caltime.h \
caldate.h
	./compile mess822_token.c

mess822_when.0: \
mess822_when.3
	nroff -man mess822_when.3 > mess822_when.0

mess822_when.o: \
compile mess822_when.c mess822.h stralloc.h gen_alloc.h caltime.h \
caldate.h scan.h
	./compile mess822_when.c

new-inject: \
load new-inject.o qmail.o auto_qmail.o rewritehost.o rwhconfig.o \
constmap.o config.o env.a getopt.a mess822.a getln.a strerr.a \
substdio.a stralloc.a alloc.a error.a sig.a fd.a wait.a open.a case.a \
str.a fs.a libtai.a
	./load new-inject qmail.o auto_qmail.o rewritehost.o \
	rwhconfig.o constmap.o config.o env.a getopt.a mess822.a \
	getln.a strerr.a substdio.a stralloc.a alloc.a error.a \
	sig.a fd.a wait.a open.a case.a str.a fs.a libtai.a 

new-inject.0: \
new-inject.1
	nroff -man new-inject.1 > new-inject.0

new-inject.o: \
compile new-inject.c substdio.h subfd.h substdio.h getln.h mess822.h \
stralloc.h gen_alloc.h caltime.h caldate.h strerr.h exit.h caltime.h \
leapsecs.h tai.h uint64.h sgetopt.h subgetopt.h stralloc.h config.h \
stralloc.h auto_qmail.h case.h constmap.h qmail.h substdio.h sig.h \
rewritehost.h rwhconfig.h strerr.h
	./compile new-inject.c

ofmipd: \
load ofmipd.o rewritehost.o rwhconfig.o config.o qmail.o auto_qmail.o \
timeoutread.o timeoutwrite.o commands.o env.a cdb.a mess822.a \
libtai.a getln.a strerr.a substdio.a stralloc.a alloc.a error.a \
case.a str.a fs.a open.a wait.a sig.a fd.a
	./load ofmipd rewritehost.o rwhconfig.o config.o qmail.o \
	auto_qmail.o timeoutread.o timeoutwrite.o commands.o env.a \
	cdb.a mess822.a libtai.a getln.a strerr.a substdio.a \
	stralloc.a alloc.a error.a case.a str.a fs.a open.a wait.a \
	sig.a fd.a 

ofmipd.0: \
ofmipd.8
	nroff -man ofmipd.8 > ofmipd.0

ofmipd.o: \
compile ofmipd.c commands.h sig.h auto_qmail.h qmail.h substdio.h \
readwrite.h timeoutread.h timeoutwrite.h stralloc.h gen_alloc.h \
substdio.h config.h stralloc.h env.h exit.h error.h str.h mess822.h \
stralloc.h caltime.h caldate.h tai.h uint64.h caltime.h cdb.h \
uint32.h
	./compile ofmipd.c

ofmipname: \
load ofmipname.o cdbmss.o cdbmake.a strerr.a getln.a substdio.a \
stralloc.a alloc.a error.a seek.a open.a str.a
	./load ofmipname cdbmss.o cdbmake.a strerr.a getln.a \
	substdio.a stralloc.a alloc.a error.a seek.a open.a str.a 

ofmipname.0: \
ofmipname.8
	nroff -man ofmipname.8 > ofmipname.0

ofmipname.o: \
compile ofmipname.c cdbmss.h cdbmake.h uint32.h substdio.h strerr.h \
open.h substdio.h subfd.h substdio.h stralloc.h gen_alloc.h getln.h \
exit.h
	./compile ofmipname.c

open.a: \
makelib open_read.o open_trunc.o
	./makelib open.a open_read.o open_trunc.o

open_read.o: \
compile open_read.c open.h
	./compile open_read.c

open_trunc.o: \
compile open_trunc.c open.h
	./compile open_trunc.c

parsedate: \
load parsedate.o libtai.a mess822.a getln.a strerr.a substdio.a \
stralloc.a alloc.a error.a str.a case.a fs.a
	./load parsedate libtai.a mess822.a getln.a strerr.a \
	substdio.a stralloc.a alloc.a error.a str.a case.a fs.a 

parsedate.o: \
compile parsedate.c substdio.h strerr.h subfd.h substdio.h getln.h \
mess822.h stralloc.h gen_alloc.h caltime.h caldate.h leapsecs.h \
caltime.h tai.h uint64.h
	./compile parsedate.c

prog: \
iftocc ofmipd ofmipname new-inject rts 822header 822field 822date \
822received 822print tokenize addrlist quote parsedate

qmail.o: \
compile qmail.c substdio.h readwrite.h wait.h exit.h fork.h fd.h \
qmail.h substdio.h auto_qmail.h
	./compile qmail.c

quote: \
load quote.o mess822.a strerr.a substdio.a stralloc.a alloc.a error.a \
str.a
	./load quote mess822.a strerr.a substdio.a stralloc.a \
	alloc.a error.a str.a 

quote.o: \
compile quote.c mess822.h stralloc.h gen_alloc.h caltime.h caldate.h \
subfd.h substdio.h substdio.h strerr.h
	./compile quote.c

rewritehost.0: \
rewritehost.3
	nroff -man rewritehost.3 > rewritehost.0

rewritehost.o: \
compile rewritehost.c stralloc.h gen_alloc.h str.h case.h \
rewritehost.h
	./compile rewritehost.c

rewriting.0: \
rewriting.5
	nroff -man rewriting.5 > rewriting.0

rts: \
warn-auto.sh rts.sh conf-home
	cat warn-auto.sh rts.sh \
	| sed s}HOME}"`head -1 conf-home`"}g \
	> rts
	chmod 755 rts

rwhconfig.o: \
compile rwhconfig.c rewritehost.h stralloc.h gen_alloc.h config.h \
stralloc.h strerr.h rwhconfig.h strerr.h auto_qmail.h
	./compile rwhconfig.c

scan_long.o: \
compile scan_long.c scan.h
	./compile scan_long.c

scan_sign.o: \
compile scan_sign.c scan.h
	./compile scan_sign.c

scan_ulong.o: \
compile scan_ulong.c scan.h
	./compile scan_ulong.c

seek.a: \
makelib seek_set.o
	./makelib seek.a seek_set.o

seek_set.o: \
compile seek_set.c seek.h
	./compile seek_set.c

select.h: \
compile trysysel.c select.h1 select.h2
	( ./compile trysysel.c >/dev/null 2>&1 \
	&& cat select.h2 || cat select.h1 ) > select.h
	rm -f trysysel.o trysysel

setup: \
it install
	./install

sgetopt.o: \
compile sgetopt.c substdio.h subfd.h substdio.h sgetopt.h subgetopt.h \
subgetopt.h
	./compile sgetopt.c

shar: \
FILES BLURB README TODO THANKS CHANGES FILES VERSION SYSDEPS INSTALL \
TARGETS Makefile hier.c 822header.1 822header.c 822field.1 822field.c \
822date.1 822date.c 822received.1 822received.c 822print.1 822print.c \
rewriting.5 new-inject.1 new-inject.c rts.sh rts.tests rts.rw rts.mft \
rts.exp ofmipd.8 ofmipd.c ofmipname.8 ofmipname.c iftocc.1 iftocc.c \
tokenize.c addrlist.c parsedate.c quote.c mess822.3 mess822.h \
mess822_date.3 mess822_date.c mess822_fold.3 mess822_fold.c \
mess822_quote.3 mess822_quote.c mess822_token.3 mess822_token.c \
mess822_addr.3 mess822_addr.c mess822_when.3 mess822_when.c \
mess822_line.c mess822_ok.c config.3 config.h config.c rewritehost.3 \
rewritehost.h rewritehost.c rwhconfig.h rwhconfig.c conf-cc conf-ld \
find-systype.sh make-compile.sh make-load.sh make-makelib.sh trycpp.c \
warn-auto.sh conf-home auto-str.c auto_home.h install.c instcheck.c \
gen_alloc.h gen_allocdefs.h stralloc.h stralloc_num.c stralloc_eady.c \
stralloc_pend.c stralloc_copy.c stralloc_opyb.c stralloc_opys.c \
stralloc_cat.c stralloc_catb.c stralloc_cats.c alloc.h alloc.c \
alloc_re.c error.h error.c error_str.c strerr.h strerr_sys.c \
strerr_die.c getln.h getln.c getln2.c substdio.h substdio.c substdi.c \
substdo.c substdio_copy.c subfd.h subfderr.c subfdouts.c subfdout.c \
subfdins.c subfdin.c readwrite.h exit.h open.h open_read.c \
open_trunc.c byte.h byte_chr.c byte_copy.c byte_cr.c byte_rchr.c \
str.h str_chr.c str_diff.c str_diffn.c str_len.c str_rchr.c \
str_start.c case.h case_diffb.c case_diffs.c tai.h tai_now.c \
tai_pack.c tai_unpack.c caldate.h caldate_fmjd.c caldate_fmt.c \
caldate_mjd.c caldate_scan.c leapsecs.h leapsecs.dat leapsecs_add.c \
leapsecs_init.c leapsecs_read.c leapsecs_sub.c caltime.h \
caltime_fmt.c caltime_scan.c caltime_tai.c caltime_utc.c scan.h \
scan_ulong.c scan_long.c scan_sign.c uint64.h1 uint64.h2 tryulong64.c \
sgetopt.h sgetopt.c subgetopt.h subgetopt.c conf-qmail auto_qmail.h \
qmail.h qmail.c constmap.h constmap.c wait.h wait_pid.c trywaitp.c \
fork.h1 fork.h2 tryvfork.c fd.h fd_copy.c fd_move.c sig.h sig_catch.c \
sig_pipe.c trysgact.c commands.3 commands.h commands.c timeoutread.h \
timeoutread.c timeoutwrite.h timeoutwrite.c select.h1 select.h2 \
trysysel.c cdb.3 cdb.h cdb_hash.c cdb_seek.c cdb_unpack.c cdbmake.h \
cdbmake_add.c cdbmake_hash.c cdbmake_pack.c cdbmss.h cdbmss.c \
uint32.h1 uint32.h2 tryulong32.c seek.h seek_set.c env.h env.c
	shar -m `cat FILES` > shar
	chmod 400 shar

sig.a: \
makelib sig_catch.o sig_pipe.o
	./makelib sig.a sig_catch.o sig_pipe.o

sig_catch.o: \
compile sig_catch.c sig.h hassgact.h
	./compile sig_catch.c

sig_pipe.o: \
compile sig_pipe.c sig.h
	./compile sig_pipe.c

str.a: \
makelib str_len.o str_diff.o str_diffn.o str_chr.o str_rchr.o \
str_start.o byte_chr.o byte_rchr.o byte_copy.o byte_cr.o
	./makelib str.a str_len.o str_diff.o str_diffn.o str_chr.o \
	str_rchr.o str_start.o byte_chr.o byte_rchr.o byte_copy.o \
	byte_cr.o

str_chr.o: \
compile str_chr.c str.h
	./compile str_chr.c

str_diff.o: \
compile str_diff.c str.h
	./compile str_diff.c

str_diffn.o: \
compile str_diffn.c str.h
	./compile str_diffn.c

str_len.o: \
compile str_len.c str.h
	./compile str_len.c

str_rchr.o: \
compile str_rchr.c str.h
	./compile str_rchr.c

str_start.o: \
compile str_start.c str.h
	./compile str_start.c

stralloc.a: \
makelib stralloc_num.o stralloc_eady.o stralloc_pend.o \
stralloc_copy.o stralloc_opys.o stralloc_opyb.o stralloc_cat.o \
stralloc_cats.o stralloc_catb.o
	./makelib stralloc.a stralloc_num.o stralloc_eady.o \
	stralloc_pend.o stralloc_copy.o stralloc_opys.o \
	stralloc_opyb.o stralloc_cat.o stralloc_cats.o \
	stralloc_catb.o

stralloc_cat.o: \
compile stralloc_cat.c byte.h stralloc.h gen_alloc.h
	./compile stralloc_cat.c

stralloc_catb.o: \
compile stralloc_catb.c stralloc.h gen_alloc.h byte.h
	./compile stralloc_catb.c

stralloc_cats.o: \
compile stralloc_cats.c byte.h str.h stralloc.h gen_alloc.h
	./compile stralloc_cats.c

stralloc_copy.o: \
compile stralloc_copy.c byte.h stralloc.h gen_alloc.h
	./compile stralloc_copy.c

stralloc_eady.o: \
compile stralloc_eady.c alloc.h stralloc.h gen_alloc.h \
gen_allocdefs.h
	./compile stralloc_eady.c

stralloc_num.o: \
compile stralloc_num.c stralloc.h gen_alloc.h
	./compile stralloc_num.c

stralloc_opyb.o: \
compile stralloc_opyb.c stralloc.h gen_alloc.h byte.h
	./compile stralloc_opyb.c

stralloc_opys.o: \
compile stralloc_opys.c byte.h str.h stralloc.h gen_alloc.h
	./compile stralloc_opys.c

stralloc_pend.o: \
compile stralloc_pend.c alloc.h stralloc.h gen_alloc.h \
gen_allocdefs.h
	./compile stralloc_pend.c

strerr.a: \
makelib strerr_sys.o strerr_die.o
	./makelib strerr.a strerr_sys.o strerr_die.o

strerr_die.o: \
compile strerr_die.c substdio.h subfd.h substdio.h exit.h strerr.h
	./compile strerr_die.c

strerr_sys.o: \
compile strerr_sys.c error.h strerr.h
	./compile strerr_sys.c

subfderr.o: \
compile subfderr.c readwrite.h substdio.h subfd.h substdio.h
	./compile subfderr.c

subfdin.o: \
compile subfdin.c readwrite.h substdio.h subfd.h substdio.h
	./compile subfdin.c

subfdins.o: \
compile subfdins.c readwrite.h substdio.h subfd.h substdio.h
	./compile subfdins.c

subfdout.o: \
compile subfdout.c readwrite.h substdio.h subfd.h substdio.h
	./compile subfdout.c

subfdouts.o: \
compile subfdouts.c readwrite.h substdio.h subfd.h substdio.h
	./compile subfdouts.c

subgetopt.o: \
compile subgetopt.c subgetopt.h
	./compile subgetopt.c

substdi.o: \
compile substdi.c substdio.h byte.h error.h
	./compile substdi.c

substdio.a: \
makelib substdio.o substdi.o substdo.o subfderr.o subfdout.o \
subfdouts.o subfdin.o subfdins.o substdio_copy.o
	./makelib substdio.a substdio.o substdi.o substdo.o \
	subfderr.o subfdout.o subfdouts.o subfdin.o subfdins.o \
	substdio_copy.o

substdio.o: \
compile substdio.c substdio.h
	./compile substdio.c

substdio_copy.o: \
compile substdio_copy.c substdio.h
	./compile substdio_copy.c

substdo.o: \
compile substdo.c substdio.h str.h byte.h error.h
	./compile substdo.c

systype: \
find-systype trycpp.c
	./find-systype > systype

tai_now.o: \
compile tai_now.c tai.h uint64.h
	./compile tai_now.c

tai_pack.o: \
compile tai_pack.c tai.h uint64.h
	./compile tai_pack.c

tai_unpack.o: \
compile tai_unpack.c tai.h uint64.h
	./compile tai_unpack.c

timeoutread.o: \
compile timeoutread.c timeoutread.h select.h error.h readwrite.h
	./compile timeoutread.c

timeoutwrite.o: \
compile timeoutwrite.c timeoutwrite.h select.h error.h readwrite.h
	./compile timeoutwrite.c

tokenize: \
load tokenize.o mess822.a getln.a strerr.a substdio.a stralloc.a \
alloc.a error.a str.a
	./load tokenize mess822.a getln.a strerr.a substdio.a \
	stralloc.a alloc.a error.a str.a 

tokenize.o: \
compile tokenize.c substdio.h strerr.h subfd.h substdio.h getln.h \
mess822.h stralloc.h gen_alloc.h caltime.h caldate.h
	./compile tokenize.c

uint32.h: \
tryulong32.c compile load uint32.h1 uint32.h2
	( ( ./compile tryulong32.c && ./load tryulong32 && \
	./tryulong32 ) >/dev/null 2>&1 \
	&& cat uint32.h2 || cat uint32.h1 ) > uint32.h
	rm -f tryulong32.o tryulong32

uint64.h: \
tryulong64.c compile load uint64.h1 uint64.h2
	( ( ./compile tryulong64.c && ./load tryulong64 && \
	./tryulong64 ) >/dev/null 2>&1 \
	&& cat uint64.h1 || cat uint64.h2 ) > uint64.h
	rm -f tryulong64.o tryulong64

wait.a: \
makelib wait_pid.o
	./makelib wait.a wait_pid.o

wait_pid.o: \
compile wait_pid.c error.h haswaitp.h
	./compile wait_pid.c
