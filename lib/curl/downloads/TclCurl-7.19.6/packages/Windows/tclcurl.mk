TCL_VERSION     = 8.5.7
TCLCURL_VERSION = 7.19.6
TclCurl_nodot   = 7.196
CURL_VERSION    = 7.19.6
ZLIB_VERSION    = 1.2.3

installFiles = ChangeLog.txt changes.txt license.terms ReadMe.txt ReadMeW32.txt ToDo.txt packages/Windows/SetUp.tcl
installDirs  = tests
certFiles    = curl-${CURL_VERSION}/lib/cacert.pem
sslFiles     = libeay32.dll libssl32.dll
docFiles     = aolserver.txt OpenSSL-LICENSE.txt tclcurl.html tclcurl_multi.html tclcurl_share.html

tclcurl-plain:        DESTDIR = TclCurl-${TCLCURL_VERSION}
tclcurl-plain:        TclCurlFlags= --disable-threads

tclcurl-ssl:          DESTDIR = TclCurl-SSL-${TCLCURL_VERSION}
tclcurl-ssl:          TclCurlFlags = --enable-ssl --disable-threads
tclcurl-ssl:          curlFlags = --with-ssl=/usr/local/

tclcurl-threaded:     DESTDIR = TclCurl-THREADED-${TCLCURL_VERSION}
tclcurl-threaded:     TclFlags = --enable-threads

tclcurl-threaded-ssl: DESTDIR = TclCurl-THREADED-SSL-${TCLCURL_VERSION}
tclcurl-threaded-ssl: TclFlags = --enable-threads
tclcurl-threaded-ssl: TclCurlFlags = --enable-ssl
tclcurl-threaded-ssl: curlFlags = --with-ssl=/usr/local/

tclcurl-plain:        tcl zlib curl tclcurlComp createDir extraFiles extraDirs docs     rar

tclcurl-ssl:          tcl zlib curl tclcurlComp createDir extraFiles extraDirs docs ssl rar

tclcurl-threaded:     tcl zlib curl tclcurlComp createDir extraFiles extraDirs docs     rar

tclcurl-threaded-ssl: tcl zlib curl tclcurlComp createDir extraFiles extraDirs docs ssl rar

clean:
	rm TclCurl-${TCLCURL_VERSION}.exe TclCurl-SSL-${TCLCURL_VERSION}.exe TclCurl-THREADED-${TCLCURL_VERSION}.exe TclCurl-THREADED-SSL-${TCLCURL_VERSION}.exe

tcl:
	cd tcl${TCL_VERSION}/win                     ;\
	make distclean                               ;\
	./configure ${TclFlags}                      ;\
	make                                         ;\
	make install

curl:
	cd curl-${CURL_VERSION}                      ;\
	./configure ${curlFlags}  --enable-shared=no ;\
	make                                         ;\
	make install-strip

zlib:
	cd zlib-${ZLIB_VERSION}                      ;\
	make distclean                               ;\
	./configure                                  ;\
	make                                         ;\
	make install                                 ;\

tclcurlComp:
	cd TclCurl                                                    ;\
	make distclean                                                ;\
	CC=gcc ./configure ${TclFlags} ${TclCurlFlags} -enable-zlib   ;\
	make                                                          ;\
	make install

createDir:
	mkdir ${DESTDIR}                                              ;\
	cp -r /usr/local/lib/TclCurl${TCLCURL_VERSION} ${DESTDIR}     ;\

extraFiles:
	for f in $(installFiles) ; do                                  \
	cp  TclCurl/$$f ${DESTDIR}                                    ;\
	done

extraDirs:
	for f in $(installDirs) ; do                                   \
	cp -r TclCurl/$$f ${DESTDIR}/TclCurl${TCLCURL_VERSION}        ;\
	done

ssl:
	mkdir ${DESTDIR}/certs                                        ;\
	cp ${certFiles} ${DESTDIR}/certs                              ;\
	mkdir ${DESTDIR}/ssl                                          ;\
	for f in $(sslFiles) ; do                                      \
	cp -r /usr/local/bin/$$f ${DESTDIR}/ssl                       ;\
	done

docs:
	mkdir ${DESTDIR}/tclcurl${TCLCURL_VERSION}/doc                ;\
	for f in $(docFiles) ; do                                      \
	cp -r TclCurl/doc/$$f ${DESTDIR}/tclcurl${TCLCURL_VERSION}/doc;\
	done

rar:
	c:/Archiv~1/WinRAR/rar a -r -s -sfx  ${DESTDIR}.exe ${DESTDIR};\
	rm -r ${DESTDIR}

