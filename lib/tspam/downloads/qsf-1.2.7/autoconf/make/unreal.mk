#
# Rules for all phony targets.
#

.PHONY: all help dep depend depclean make \
  check test memtest benchmark bigbenchmark \
  clean distclean cvsclean \
  index manhtml indent indentclean \
  changelog doc dist release \
  install uninstall \
  rpmbuild srpm rpm deb

all: $(alltarg)

help:
	@echo 'This Makefile has the following utility targets:'
	@echo
	@echo '  all             build all binary targets'
	@echo '  doc             regenerate text version of man page'
	@echo '  install         install compiled package and manual'
	@echo '  uninstall       uninstall the package'
	@echo '  check / test    run standardised tests on the compiled binary'
	@echo
	@echo 'Developer targets:'
	@echo
	@echo '  make            rebuild the Makefile (after adding new files)'
	@echo '  dep / depend    rebuild .d (dependency) files'
	@echo '  clean           remove .o (object) and .c~ (backup) files'
	@echo '  depclean        remove .d (dependency) files'
	@echo '  indentclean     remove files left over from "make indent"'
	@echo '  distclean       remove everything not distributed'
	@echo '  cvsclean        remove everything not in CVS'
	@echo
	@echo '  index           generate an HTML index of source code'
	@echo '  manhtml         output HTML man page to stdout'
	@echo '  indent          reformat all source files with "indent"'
	@echo '  changelog       generate doc/changelog from CVS log info'
	@echo
	@echo '  memtest         run "make test" using valgrind to find faults'
	@echo '  benchmark       run benchmarking tests'
	@echo '  bigbenchmark    run many benchmarking tests to make a graph'
	@echo
	@echo '  dist            create a source tarball for distribution'
	@echo '  rpm             build a binary RPM (passes $$RPMFLAGS to RPM)'
	@echo '  srpm            build a source RPM (passes $$RPMFLAGS to RPM)'
	@echo '  deb             build a binary Debian package'
	@echo '  release         dist+rpm+srpm'
	@echo
	@echo 'Note that "test", "memtest", and "{,big}benchmark" can be passed'
	@echo 'additional environment variables: BACKENDS is a space separated'
	@echo 'list of backends to test (default is to test all) and MYSQLDB'
	@echo 'is a database spec for testing the MySQL backend, in the same'
	@echo 'format as for @PACKAGE@ -d, eg MYSQLDB=database=foo;host=...'
	@echo

make:
	echo > $(srcdir)/autoconf/make/filelist.mk
	echo > $(srcdir)/autoconf/make/modules.mk
	cd $(srcdir); \
	bash autoconf/scripts/makemake.sh \
	     autoconf/make/filelist.mk \
	     autoconf/make/modules.mk
	sh ./config.status
	
dep depend: $(alldep)
	echo '#' > $(srcdir)/autoconf/make/depend.mk
	echo '# Dependencies.' >> $(srcdir)/autoconf/make/depend.mk
	echo '#' >> $(srcdir)/autoconf/make/depend.mk
	echo >> $(srcdir)/autoconf/make/depend.mk
	cat $(alldep) >> $(srcdir)/autoconf/make/depend.mk
	sh ./config.status

clean:
	rm -f $(allobj)
	find . -type f -name "*.c~" -exec rm -f '{}' ';'
	rm -f memtest-out-*
	rm -f benchmark-report benchmark-data-* benchmark-graph-*

depclean:
	rm -f $(alldep)

indentclean:
	cd $(srcdir) && for FILE in $(allsrc); do rm -fv ./$${FILE}~; done

distclean: clean depclean
	rm -f $(alltarg) src/include/config.h
	rm -rf $(package)-$(version).tar* $(package)-$(version) BUILD-DEB
	rm -f *.rpm *.deb
	rm -f *.html config.*
	rm -f test.db trace
	rm -f .test-spam .test-non-spam
	rm -f .test-benchmark-spam .test-benchmark-non-spam
	rm -f .testdump-a .testdump-b .testdump-c
	rm -f fakemail mboxsplit gmon.out
	rm Makefile

cvsclean: distclean
	rm -f doc/lsm
	rm -f doc/$(package).spec
	rm -f doc/quickref.1
	rm -f doc/quickref.txt
	rm -f configure
	rm -f doc/changelog ChangeLog
	cat /dev/null > $(srcdir)/autoconf/make/depend.mk
	cat /dev/null > $(srcdir)/autoconf/make/filelist.mk
	cat /dev/null > $(srcdir)/autoconf/make/modules.mk

doc: doc/quickref.txt

index:
	(cd $(srcdir); sh autoconf/scripts/index.sh $(srcdir)) > index.html

manhtml:
	@man2html ./doc/quickref.1 \
	| sed -e '1,/<BODY/d' -e '/<\/BODY/,$$d' \
	      -e 's|<A [^>]*>&nbsp;</A>||ig' \
	      -e 's|<A [^>]*>\([^<]*\)</A>|\1|ig' \
	      -e '/<H1/d' -e 's|\(</H[0-9]>\)|\1<P>|ig' \
	      -e 's/<DL COMPACT>/<DL>/ig' \
	      -e 's/&lt;[0-9A-Za-z_.-]\+@[0-9A-Za-z_.-]\+&gt;//g' \
	      -e 's|<I>\(http://.*\)</I>|<A HREF="\1">\1</A>|ig' \
	| sed -e '1,/<HR/d' -e '/<H2>Index/,/<HR/d' \

indent:
	cd $(srcdir) && indent -npro -kr -i8 -cd42 -c45 $(allsrc)

changelog:
	@which cvs2cl >/dev/null 2>&1 || ( \
	  echo '*** Please put cvs2cl in your PATH'; \
	  echo '*** Get it from http://www.red-bean.com/cvs2cl/'; \
	  exit 1; \
	)
	rm -f $(srcdir)/ChangeLog
	cd $(srcdir) && cvs2cl -S -P
	mv -f $(srcdir)/ChangeLog doc/changelog

dist: doc
	test -d $(srcdir)/CVS && $(MAKE) changelog || :
	rm -rf $(package)-$(version)
	mkdir $(package)-$(version)
	cp -dprf Makefile $(distfiles) $(package)-$(version)
	cd $(package)-$(version); $(MAKE) distclean
	-cp -dpf doc/changelog      $(package)-$(version)/doc/
	cp -dpf doc/lsm             $(package)-$(version)/doc/
	cp -dpf doc/$(package).spec $(package)-$(version)/doc/
	cp -dpf doc/quickref.txt    $(package)-$(version)/doc/
	chmod 644 `find $(package)-$(version) -type f -print`
	chmod 755 `find $(package)-$(version) -type d -print`
	chmod 755 `find $(package)-$(version)/autoconf/scripts`
	chmod 755 $(package)-$(version)/configure
	chmod 755 $(package)-$(version)/debian/rules
	rm -rf DUMMY `find $(package)-$(version) -type d -name CVS` \
	 `find $(package)-$(version) -type f -name .cvsignore`
	tar cf $(package)-$(version).tar $(package)-$(version)
	rm -rf $(package)-$(version)
	-cat $(package)-$(version).tar \
	 | bzip2 > $(package)-$(version).tar.bz2 \
	 || rm -f $(package)-$(version).tar.bz2
	$(DO_GZIP) $(package)-$(version).tar

.test-spam:
	$(CC) $(CFLAGS) $(CPPFLAGS) -o fakemail $(srcdir)/autoconf/scripts/fakemail.c
	./fakemail \
	  $(srcdir)/test/tokenlist-non-spam 15 > .test-non-spam
	./fakemail \
	  $(srcdir)/test/tokenlist-spam 15 > .test-spam

check test: $(package) .test-spam
	@$(CC) -o mboxsplit $(srcdir)/autoconf/scripts/mboxsplit.c
	@FAIL=0; PROG=./$(package); TESTDB=$(testdb); TESTFILE=$(testfile); \
	export PROG TESTDB TESTFILE; \
	test "x$$BACKENDS" = x && BACKENDS="$(testbackends)"; \
	CREATEDTABLE=""; \
	if test x$$MYSQLDB = x; then \
	  CREATEDTABLE=@PACKAGE@test$$RANDOM; \
	  if mysql test -Be "CREATE TABLE $$CREATEDTABLE ( key1 BIGINT UNSIGNED NOT NULL, key2 BIGINT UNSIGNED NOT NULL, token VARCHAR(64) DEFAULT '' NOT NULL, value1 INT UNSIGNED NOT NULL, value2 INT UNSIGNED NOT NULL, value3 INT UNSIGNED NOT NULL, PRIMARY KEY (key1,key2,token), KEY (key1), KEY (key2), KEY (token) );" >/dev/null 2>&1; then \
		MYSQLDB="database=test;host=localhost;port=3306;user=$$USER;pass=;table=$$CREATEDTABLE;key1=0;key2=0"; \
	  else \
	  	CREATEDTABLE=""; \
	  fi; \
	fi; \
	for BACKEND in $$BACKENDS; do \
	  SKIPMYSQL=0; \
	  test $$BACKEND = MySQL && test x$$MYSQLDB = x && SKIPMYSQL=1; \
	  test $$BACKEND = mysql && test x$$MYSQLDB = x && SKIPMYSQL=1; \
	  test $$SKIPMYSQL = 1 && echo \*\*\* MySQL tests disabled - define \$$MYSQLDB; \
	  test $$SKIPMYSQL = 1 && echo \*\*\* to enable \(see man page for spec format\); \
	  test $$SKIPMYSQL = 1 && continue; \
	  TESTDB=$(testdb); \
	  rm -f $$TESTDB; \
	  export BACKEND; \
	  test $$BACKEND = MySQL && TESTDB=$$MYSQLDB; \
	  test $$BACKEND = mysql && TESTDB=$$MYSQLDB; \
	  for SCRIPT in $(srcdir)/test/t[0-9]*; do \
	    test -f $$SCRIPT || continue; \
	    sed -n 's/^# *TEST: */'"$$BACKEND"': /p' < $$SCRIPT | tr "\n" ' '; \
	    STATUS=0; \
	    sh -e $$SCRIPT || STATUS=1; \
	    test $$STATUS -eq 1 && FAIL=1; \
	    test $$STATUS -eq 1 && echo FAILED || echo OK; \
	  done; rm -f $$TESTDB $$TESTFILE; \
	done; \
	test x$$CREATEDTABLE = x || mysql test -Be "DROP TABLE $$CREATEDTABLE;" >/dev/null 2>&1; \
	exit $$FAIL

memtest: $(package) .test-spam
	@which valgrind >/dev/null 2>/dev/null || (\
	 echo These tests require valgrind to be installed.; \
	 echo See http://valgrind.kde.org/ for details.; \
	 exit 1; \
	)
	@$(CC) -o mboxsplit $(srcdir)/autoconf/scripts/mboxsplit.c
	@FAIL=0; \
	PROG="valgrind --tool=memcheck --leak-check=yes --db-attach=no ./$(package)"; \
	TESTDB=$(testdb); TESTFILE=$(testfile); \
	export PROG TESTDB TESTFILE; \
	test "x$$BACKENDS" = x && BACKENDS="$(testbackends)"; \
	CREATEDTABLE=""; \
	if test x$$MYSQLDB = x; then \
	  CREATEDTABLE=@PACKAGE@test$$RANDOM; \
	  if mysql test -Be "CREATE TABLE $$CREATEDTABLE ( key1 BIGINT UNSIGNED NOT NULL, key2 BIGINT UNSIGNED NOT NULL, token VARCHAR(64) DEFAULT '' NOT NULL, value1 INT UNSIGNED NOT NULL, value2 INT UNSIGNED NOT NULL, value3 INT UNSIGNED NOT NULL, PRIMARY KEY (key1,key2,token), KEY (key1), KEY (key2), KEY (token) );" >/dev/null 2>&1; then \
		MYSQLDB="database=test;host=localhost;port=3306;user=$$USER;pass=;table=$$CREATEDTABLE;key1=0;key2=0"; \
	  else \
	  	CREATEDTABLE=""; \
	  fi; \
	fi; \
	for BACKEND in $$BACKENDS; do \
	  SKIPMYSQL=0; \
	  test $$BACKEND = MySQL && test x$$MYSQLDB = x && SKIPMYSQL=1; \
	  test $$BACKEND = mysql && test x$$MYSQLDB = x && SKIPMYSQL=1; \
	  test $$SKIPMYSQL = 1 && echo \*\*\* MySQL tests disabled - define \$$MYSQLDB; \
	  test $$SKIPMYSQL = 1 && echo \*\*\* to enable \(see man page for spec format\); \
	  test $$SKIPMYSQL = 1 && continue; \
	  TESTDB=$(testdb); \
	  rm -f $$TESTDB; \
	  export BACKEND; \
	  test $$BACKEND = MySQL && TESTDB=$$MYSQLDB; \
	  test $$BACKEND = mysql && TESTDB=$$MYSQLDB; \
	  for SCRIPT in $(srcdir)/test/t[0-9]*; do \
	    test -f $$SCRIPT || continue; \
	    TESTOUT=memtest-out-$$BACKEND-`basename $$SCRIPT`; \
	    sed -n 's/^# *TEST: */'"$$BACKEND"': /p' < $$SCRIPT | tr "\n" ' '; \
	    STATUS=0; \
	    sh -e $$SCRIPT >$$TESTOUT 2>&1 || STATUS=1; \
	    grep '^==[0-9]\+== ERROR SUMMARY: ' $$TESTOUT \
	    | grep -q -v '^==[0-9]\+== ERROR SUMMARY: 0 ' && STATUS=2; \
	    test $$STATUS -eq 1 && FAIL=1; \
	    test $$STATUS -eq 2 && FAIL=1; \
	    test $$STATUS -eq 1 && echo FAILED, MEMTEST OK; \
	    test $$STATUS -eq 2 && echo FAILED MEMTEST; \
	    test $$STATUS -eq 0 && echo OK; \
	  done; rm -f $$TESTDB $$TESTFILE; \
	done; \
	test x$$CREATEDTABLE = x || mysql test -Be "DROP TABLE $$CREATEDTABLE;" >/dev/null 2>&1; \
	exit $$FAIL

.test-benchmark-spam:
	$(CC) $(CFLAGS) $(CPPFLAGS) -o fakemail $(srcdir)/autoconf/scripts/fakemail.c
	./fakemail \
	  $(srcdir)/test/tokenlist-non-spam 1500 > .test-benchmark-non-spam
	./fakemail \
	  $(srcdir)/test/tokenlist-spam 1500 > .test-benchmark-spam

benchmark: $(package) .test-benchmark-spam
	@test "x$$BACKENDS" = x && BACKENDS="$(testbackends)"; \
	CREATEDTABLE=""; \
	if test x$$MYSQLDB = x; then \
	  CREATEDTABLE=@PACKAGE@test$$RANDOM; \
	  if mysql test -Be "CREATE TABLE $$CREATEDTABLE ( key1 BIGINT UNSIGNED NOT NULL, key2 BIGINT UNSIGNED NOT NULL, token VARCHAR(64) DEFAULT '' NOT NULL, value1 INT UNSIGNED NOT NULL, value2 INT UNSIGNED NOT NULL, value3 INT UNSIGNED NOT NULL, PRIMARY KEY (key1,key2,token), KEY (key1), KEY (key2), KEY (token) );" >/dev/null 2>&1; then \
		MYSQLDB="database=test;host=localhost;port=3306;user=$$USER;pass=;table=$$CREATEDTABLE;key1=0;key2=0"; \
	  else \
	  	CREATEDTABLE=""; \
	  fi; \
	fi; \
	for BACKEND in $$BACKENDS; do \
	  SKIPMYSQL=0; \
	  test $$BACKEND = MySQL && test x$$MYSQLDB = x && SKIPMYSQL=1; \
	  test $$BACKEND = mysql && test x$$MYSQLDB = x && SKIPMYSQL=1; \
	  test $$SKIPMYSQL = 1 && echo \*\*\* MySQL tests disabled - define \$$MYSQLDB; \
	  test $$SKIPMYSQL = 1 && echo \*\*\* to enable \(see man page for spec format\); \
	  test $$SKIPMYSQL = 1 && continue; \
	  TESTDB=$$BACKEND; \
	  test $$BACKEND = MySQL && TESTDB=mysql:$$MYSQLDB; \
	  test $$BACKEND = mysql && TESTDB=mysql:$$MYSQLDB; \
	  ./$(package) -d $$TESTDB -B .test-benchmark-spam .test-benchmark-non-spam; \
	done; \
	test x$$CREATEDTABLE = x || mysql test -Be "DROP TABLE $$CREATEDTABLE;" >/dev/null 2>&1

bigbenchmark: $(package) .test-benchmark-spam
	rm -f benchmark-report benchmark-data-* benchmark-graph-*
	test "x$$BACKENDS" = x && BACKENDS="$(testbackends)"; \
	echo "set title 'Training times'" > benchmark-graph-train; \
	echo "set title 'Classification times'" > benchmark-graph-class; \
	echo "set title 'Accuracy of trained database'" > benchmark-graph-accuracy; \
	for GRAPH in train class accuracy; do \
	  CMD=""; \
	  for BACKEND in $$BACKENDS; do \
	    CMD="$$CMD, 'benchmark-data-$$GRAPH-$$BACKEND' title '$$BACKEND' with linespoints"; \
	  done; \
	  echo "$$CMD" | sed -e 's/^,/plot/' -e 's/SQLite2/sqlite/g' >> benchmark-graph-$$GRAPH; \
	done
	for NUM in 5 6 7 8 9 10 11 12 14 16 18 20 22 24 26 28 30 35 40 45 50 55 60 65 70 80 90 100 120 140 160 180 200 250 300 350 400 450 500 600 700 800 900 1000 1100 1200 1300 1400 1500; do \
	  ./fakemail $(srcdir)/test/tokenlist-non-spam $$NUM > .test-benchmark-non-spam; \
	  ./fakemail $(srcdir)/test/tokenlist-spam $$NUM > .test-benchmark-spam; \
	  $(MAKE) benchmark | tee benchmark-report; \
	  awk -f $(srcdir)/autoconf/scripts/benchmark.awk < benchmark-report; \
	  $(MAKE) benchmark | tee benchmark-report; \
	  awk -f $(srcdir)/autoconf/scripts/benchmark.awk < benchmark-report; \
	  $(MAKE) benchmark | tee benchmark-report; \
	  awk -f $(srcdir)/autoconf/scripts/benchmark.awk < benchmark-report; \
	done
	@echo
	@echo 'You can now load the files "benchmark-graph-*" into "gnuplot".'
	@echo

install: all doc
	$(srcdir)/autoconf/scripts/mkinstalldirs \
	  "$(DESTDIR)/$(bindir)"
	$(srcdir)/autoconf/scripts/mkinstalldirs \
	  "$(DESTDIR)/$(mandir)/man1"
	$(INSTALL) -m 755 $(package) \
	  "$(DESTDIR)/$(bindir)/$(package)"
	$(INSTALL) -m 644 doc/quickref.1 \
	  "$(DESTDIR)/$(mandir)/man1/$(package).1"
	$(DO_GZIP) "$(DESTDIR)/$(mandir)/man1/$(package).1"      || :

uninstall:
	$(UNINSTALL) "$(DESTDIR)/$(bindir)/$(package)"
	$(UNINSTALL) "$(DESTDIR)/$(mandir)/man1/$(package).1"
	$(UNINSTALL) "$(DESTDIR)/$(mandir)/man1/$(package).1.gz"

rpmbuild:
	echo macrofiles: `rpm --showrc \
	  | grep ^macrofiles \
	  | cut -d : -f 2- \
	  | sed 's,^[^/]*/,/,'`:`pwd`/rpmmacros > rpmrc
	echo %_topdir `pwd`/rpm > rpmmacros
	rm -rf rpm
	mkdir rpm
	mkdir rpm/SPECS rpm/BUILD rpm/SOURCES rpm/RPMS rpm/SRPMS
	-cat /usr/lib/rpm/rpmrc /etc/rpmrc $$HOME/.rpmrc \
	 | grep -hsv ^macrofiles \
	 >> rpmrc

srpm:
	-test -e $(package)-$(version).tar.gz || $(MAKE) dist
	-test -e rpmrc || $(MAKE) rpmbuild
	rpmbuild $(RPMFLAGS) --rcfile=rpmrc -ts $(package)-$(version).tar.bz2
	mv rpm/SRPMS/*$(package)-*.rpm .
	rm -rf rpm rpmmacros rpmrc

rpm:
	-test -e $(package)-$(version).tar.gz || $(MAKE) dist
	-test -e rpmrc || $(MAKE) rpmbuild
	rpmbuild $(RPMFLAGS) --rcfile=rpmrc -tb $(package)-$(version).tar.bz2
	rpmbuild $(RPMFLAGS) --rcfile=rpmrc -tb --with static $(package)-$(version).tar.bz2
	mv rpm/RPMS/*/$(package)-*.rpm .
	rm -rf rpm rpmmacros rpmrc

deb: dist
	rm -rf BUILD-DEB
	mkdir BUILD-DEB
	cd BUILD-DEB && tar xzf ../$(package)-$(version).tar.gz
	cd BUILD-DEB && cd $(package)-$(version) && dpkg-buildpackage -rfakeroot
	mv BUILD-DEB/*.deb .
	rm -rf BUILD-DEB

release: dist rpm srpm

