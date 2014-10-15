#!/bin/bash


#mkdir /web
#groupadd web
#useradd nsadmin
#usermod -g web -d /web nsadmin
#chown -R nsadmin:web /web
#chmod -R 755 /web

###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh



###################################################################




mkdir -p ${WORKDIR}


### TCL
. ${WEBHOME}/bin/install-tcl.sh

### AOLSERVER
cd ${WORKDIR}
tar -xjvf ${FILEDIR}/aolserver/${AOLSERVER}.tar.bz2
mv aolserver ${AOLSERVER}
mv aolserver-modules modules-${AOLSERVER}
cp ${FILEDIR}/aolserver-util/ns*.tcl ${AOLSERVER}/util/
chmod +x ${AOLSERVER}/util/*
cd ${AOLSERVER}
#patch -p0 < ${FILEDIR}/aolserver45-configure.patch
./configure --prefix=${NSHOME} --enable-threads
make
make install
cp ${FILEDIR}/aolserver-util/ns*.tcl ${NSHOME}/bin/
chmod +x ${NSHOME}/bin/ns*.tcl


### AOLSERVER MODULES

cd ${WORKDIR}/modules-${AOLSERVER}
cd nscache
make install NSHOME=${NSHOME}

cd ${WORKDIR}/modules-${AOLSERVER}
cd nssha1
make install NSHOME=${NSHOME}


cd ${WORKDIR}/modules-${AOLSERVER}
cd nspostgres
make install ACS=1 POSTGRES=${PGHOME} AOLSERVER=${NSHOME}


. ${WEBHOME}/bin/install-tcllib.sh


. ${WEBHOME}/bin/install-libthread.sh
. ${WEBHOME}/bin/install-tdom.sh
. ${WEBHOME}/bin/install-xotcl.sh




### Neophytos Utils
#cd ${WORKDIR}
#tar -xjvf ${FILEDIR}/neo-utils-1.4.tar.bz2
#cd neo-utils-1.4
#make INST=${NSHOME} NSHOME=${NSHOME} NAVISERVER=${NSHOME} install


### tcl_xcmds
#cd ${WORKDIR}
#tar -xjvf ${FILEDIR}/tcl_xcmds-0.2.tar.bz2
#cd tcl_xcmds-0.2/unix
#make clean
#make distclean
#autoconf
#./configure --enable-threads --prefix=${NSHOME} --exec-prefix=${NSHOME} --with-tcl=${NSHOME}/lib --with-aolserver=${NSHOME}
#make install





# Make sure to call nsd-postgres instead of nsd if you use postgresql

echo "export PATH=\$PATH:${PGHOME}/bin" >${NSHOME}/bin/nsd-postgres
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${PGHOME}/lib:${NSHOME}/lib" >>${NSHOME}/bin/nsd-postgres
echo "exec ${NSHOME}/bin/nsd \$*" >>${NSHOME}/bin/nsd-postgres
chmod +x ${NSHOME}/bin/nsd-postgres


exit


### smsc-20070819
# qcluster
# smsq
# generic-gsm
cd ${WORKDIR}
tar -xjvf ${FILEDIR}/smsc-20070819.tar.bz2 
cd smsc-20070819
cd qcluster
make clean NSHOME=${NSHOME} NAVISERVER=${NSHOME}
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}
cd ../smsq
make clean NSHOME=${NSHOME} NAVISERVER=${NSHOME}
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}
cd ../generic-gsm
make clean NSHOME=${NSHOME} NAVISERVER=${NSHOME}
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}


### nsdbpg
cd ${WORKDIR}/modules-${NAVISERVER}/nsdbpg
mv Makefile Makefile-orig
cp /web/files/Makefile.nsdbpg Makefile
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME} POSTGRES=${PGHOME}

### nszlib
cd ${WORKDIR}/modules-${NAVISERVER}/nszlib
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}

### nsclamav
cd ${WORKDIR}/modules-${NAVISERVER}/nsclamav
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}

### nsaspell
cd ${WORKDIR}/modules-${NAVISERVER}/nsaspell
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}

### nsmemcache
cd ${WORKDIR}/modules-${NAVISERVER}/nsmemcache
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}

### nssmtpd
cd ${WORKDIR}/modules-${NAVISERVER}/nssmtpd
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}

### nsldapd
cd ${WORKDIR}/modules-${NAVISERVER}/nsldapd
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}

### nsudp
cd ${WORKDIR}/modules-${NAVISERVER}/nsudp
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}

### nstcp
cd ${WORKDIR}/modules-${NAVISERVER}/nstcp
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}

### nsicmp
cd ${WORKDIR}/modules-${NAVISERVER}/nsicmp
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}

### nssys
cd ${WORKDIR}/modules-${NAVISERVER}/nssys
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}

### nssyslogd
cd ${WORKDIR}/modules-${NAVISERVER}/nssyslogd
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}

### nstftpd
cd ${WORKDIR}/modules-${NAVISERVER}/nsftpd
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}

### nssip
cd ${WORKDIR}/modules-${NAVISERVER}/nssip
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}

### nssnmp
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/snmp++v3.2.21.tar.gz
sed -i 's/\/\/ #define _NO_SNMPv3/#define _NO_SNMPv3/' snmp++/include/snmp_pp/config_snmp_pp.h
make -C snmp++/src -f Makefile.linux USEROPTS="-g -fPIC" install
cd ${WORKDIR}modules-${NAVISERVER}/nssnmp
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}

### nsgdchart
cd ${WORKDIR}/modules-${NAVISERVER}/nsgdchart
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}

### nsgd2
cd ${WORKDIR}
mkdir naviserver-nsgd2
cd naviserver-nsgd2
tar -xzvf ${FILEDIR}/nsgd2.tgz
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}



### nsrtsp
#cd ${WORKDIR}/nsrtsp
#make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}



### nschartdir
#cd ${WORKDIR}
#tar -xzvf ${FILEDIR}/chartdir.tar.gz
#mv usr/local/chartdir .
#rmdir usr/local
#rmdir usr
# cd chartdir
# cp include/* ${NSHOME}/include
# cp lib/* ${NSHOME}/include


${WEBHOME}/bin/install-tcllib.sh

### TCL Thread Extension
cd ${WORKDIR}
tar -xjvf ${FILEDIR}/thread-20070808.tar.bz2
cd thread/unix/
../configure --enable-threads --prefix=${NSHOME} --exec-prefix=${NSHOME} --with-aolserver=${NSHOME}
make
make install

${WEBHOME}/bin/install-tdom.sh
${WEBHOME}/bin/install-xotcl.sh

### TclCurl
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/TclCurl-7.16.4.tar.gz
cd TclCurl-7.16.4
#cp ${FILEDIR}/tcl.m4-bash-4.x.x tclconfig/tcl.m4
#autoconf
#make clean
#make install
./configure --enable-threads --prefix=${NSHOME} --with-tcl=${NSHOME}/lib/ --with-tclinclude=${NSHOME}/include --includedir=${NSHOME}/include 
make
make install

### TRF for faster base encoding
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/trf-${SUFFIX}.tar.gz
cd trf/
./configure --enable-threads --prefix=${NSHOME} --exec-prefix=${NSHOME} --with-tcl=${NSHOME}/lib
make
make install

### Neophytos Utils
cd ${WORKDIR}
tar -xjvf ${FILEDIR}/neo-utils-1.4.tar.bz2
cd neo-utils-1.4
make INST=${NSHOME} NSHOME=${NSHOME} NAVISERVER=${NSHOME} install


### tcl_xcmds
cd ${WORKDIR}
tar -xjvf ${FILEDIR}/tcl_xcmds-0.2.tar.bz2
cd tcl_xcmds-0.2/unix
make clean
make distclean
autoconf
./configure --enable-threads --prefix=${NSHOME} --exec-prefix=${NSHOME} --with-tcl=${NSHOME}/lib --with-aolserver=${NSHOME}
make install

### ttext
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/ttext-0.4.tar.gz
cd ttext0.4/unix
make clean
rm config.cache
TCLSH_PROG=/usr/bin/tclsh ../configure --enable-threads --prefix=${NSHOME}/ --with-tcl=${NSHOME}/lib/ --with-aolserver=${NSHOME}/ --with-tclinclude=${NSHOME}/include/ 
make
cp libttext0.4.so ${NSHOME}/bin/

### jsmin
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/jsmin-0.2.tar.gz
cd jsmin-0.2/unix
make clean
rm config.cache
TCLSH_PROG=${NSHOME}/bin/tclsh8.4 ../configure --enable-threads --prefix=${NSHOME}/ --with-tcl=${NSHOME}//lib/ --with-aolserver=${NSHOME}/ --with-tclinclude=${NSHOME}/include/ 
make
cp libjsmin0.2.so ${NSHOME}/bin/

### jscompact
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/jscompact-1.1.1.tar.gz
cd jscompact-1.1.1
cp ${FILEDIR}/make.jscompact make
chmod +x make
./make
cp jscompact ${NSHOME}/bin/

### jspack
cd ${WORKDIR}
cp -R ${FILEDIR}/jspack .
cd jspack
cp * ${NSHOME}/bin/


### Takeaki Uno
cd ${WORKDIR}
mkdir Takeaki_Uno
cd ${WORKDIR}/Takeaki_Uno

mkdir lcm50
cd lcm50
unzip ${FILEDIR}/Takeaki_Uno/lcm50.zip -d .
make
cp lcm ${NSHOME}/bin/

cd ${WORKDIR}/Takeaki_Uno
mkdir lcm_rule
cd lcm_rule
unzip ${FILEDIR}/Takeaki_Uno/lcm_rule.zip -d .
make
cp fim_closed ${NSHOME}/bin/lcm_rule



cd ${WORKDIR}/
cp -R ${FILEDIR}/../cvs/TclMagick .
cd TclMagick
genconf.sh
libtoolize --copy --force
cp ${FILEDIR}/configure-TclMagick .
./configure --without-tk --without-tkinclude --enable-threads --with-tcl=/opt/naviserver/lib/ --prefix=/opt/naviserver/ --with-magick=/usr/bin/Magick-config




