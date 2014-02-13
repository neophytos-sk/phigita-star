#!/bin/bash

###################################################################

SERVER=aolserver ;# aolserver OR naviserver
VERSION=4.5.0
FILEDIR=~nsadmin/files/

PREFIX=/opt
WORKDIR=/usr/local/src/squanti-install-`date -u --iso-8601=date`
SUFFIX=cvs-20070128
TCL=tcl8.4.14
PGSQL=postgresql-8.2.3
MAPSERVER=mapserver-4.8.3

NSHOME=${PREFIX}/${SERVER}-${VERSION}
PGHOME=${PREFIX}/${PGSQL}
MSHOME=${PREFIX}/${MAPSERVER}

###################################################################



mkdir -p ${WORKDIR}

### TCL
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/${TCL}-src.tar.gz
cd ${TCL}/unix
./configure --enable-threads --prefix=${NSHOME}
make install


### AOLserver 4.5.0 
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/aolserver-4.5.0-${SUFFIX}.tar.gz
cd aolserver
patch -p0 < ${FILEDIR}/aolserver45-nsd-conn.patch
patch -p0 < ${FILEDIR}/aolserver45-driver.patch
${NSHOME}/bin/tclsh8.4 ./nsconfig.tcl -install $NSHOME
make -i install



# Remove the symbolic link to aolserver.
# If this is not a symbolic link but the full path to your aolserver
# Make sure it becomes a symbolic link by issuing
# mv /usr/local/aolserver /usr/local/aolserver<yourversion>
rm /usr/local/aolserver
ln -s ${NSHOME} /usr/local/aolserver


### nssha1
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/nssha1-${SUFFIX}.tar.gz
cd nssha1
make install NSHOME=${NSHOME} AOLSERVER=${NSHOME}

### nsaspell
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/nsaspell.tar.gz
cd nsaspell
make install NSHOME=${NSHOME} AOLSERVER=${NSHOME}

### nsclamav
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/nsclamav.tar.gz
cd nsclamav
make install NSHOME=${NSHOME} AOLSERVER=${NSHOME}

### nsimap
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/nsimap.tar.gz
cd nsimap
make install NSHOME=${NSHOME} AOLSERVER=${NSHOME}

### nsgd2
cd ${WORKDIR}
mkdir nsgd2
cd nsgd2
tar -xzvf ${FILEDIR}/nsgd2.tgz
make install NSHOME=${NSHOME} AOLSERVER=${NSHOME}


### nspostgres
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/nspostgres-${SUFFIX}.tar.gz
cd nspostgres
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${PG}/lib
make install POSTGRES=${PGHOME} ACS=1 NSHOME=${NSHOME} AOLSERVER=${NSHOME}


### Install tdom
# Note, if you use bash31 you need to apply a patch
# See http://openacs.org/forums/message-view?message_id=369867 for details
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/tDOM-0.8.0.tar.gz
cd tDOM-0.8.0/unix
../configure --enable-threads --disable-tdomalloc --prefix=${NSHOME} --exec-prefix=${NSHOME} --with-tcl=/${NSHOME}/lib --with-aolserver=${NSHOME}
make install
cd ../extensions/tnc
./configure --enable-threads --disable-tdomalloc --prefix=${NSHOME} --exec-prefix=${NSHOME} --with-tcl=/${NSHOME}/lib --with-aolserver=${NSHOME}
make install

### tcllib
cd ${WORKDIR}
tar -xjvf ${FILEDIR}/tcllib-1.9.tar.bz2
cd tcllib-1.9
./configure --prefix=${NSHOME} --exec-prefix=${NSHOME}
make install


### TCL Thread Extension
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/thread2.6.5.tar.gz
cd thread2.6.5/unix/
../configure --enable-threads --prefix=${NSHOME} --exec-prefix=${NSHOME} --with-aolserver=${NSHOME} --with-tcl=/${NSHOME}/lib
make
make install


### XOTCL 1.5.3
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/xotcl-1.5.3.tar.gz
cd xotcl-1.5.3
patch -l -p0 < ${FILEDIR}/xotcl-1.5.3-fix1.patch
./configure --enable-threads --disable-symbols --prefix=${NSHOME} --exec-prefix=${NSHOME} --with-tcl=/${NSHOME}/lib
make
make install-aol



### TclCurl
emerge libidn curl
cd ${WORKDIR}
tar -xjvf ${FILEDIR}/TclCurl-0.14.1.tar.bz2
cd TclCurl-0.14.1
cp ${FILEDIR}/tcl.m4-bash-4.x.x tclConfig/tcl.m4
autoconf
./configure --enable-threads --prefix=${NSHOME} --with-tcl=${NSHOME}/lib/
make clean
make
make install

### TRF for faster base encoding
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/trf-${SUFFIX}.tar.gz
cd trf/
./configure --enable-threads --prefix=${NSHOME} --exec-prefix=${NSHOME} --with-tcl=${NSHOME}/lib
make
make install

### dqd Utils
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/dqd_utils-1.3.tar.gz
cd dqd_utils-1.3
make INST=${NSHOME} NSHOME=${NSHOME} AOLSERVER=${NSHOME}
cp dqd_utils8.so ${NSHOME}/bin

### tcl_xcmds
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/tcl_xcmds-0.2.tar.gz
cd tcl_xcmds-0.2/unix
make clean
./configure --enable-threads --prefix=${NSHOME} --exec-prefix=${NSHOME} --with-tcl=${NSHOME}/lib --with-aolserver=${NSHOME}
make install

### ttext
USE="xml" emerge htmltidy unac
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/ttext-0.4.tar.gz
cd ttext0.4/unix
make clean
rm config.cache
TCLSH_PROG=${NSHOME}/bin/tclsh8.4 ../configure --enable-threads --prefix=${NSHOME}/ --with-tcl=${NSHOME}//lib/ --with-aolserver=${NSHOME}/ --with-tclinclude=${NSHOME}/include/ 
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

### swig
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/swig-1.3.31.tar.gz
cd swig-1.3.31
./configure --without-ruby --without-python --without-php4 --without-perl5 --without-pike --without-chicken --without-csharp --without-mzscheme --without-ocaml --without-java  --without-guile --without-lua --without-clisp --without-r --with-tclconfig=${NSHOME}/lib/
make
make install

### mapserver mapscript (requires swig for mapscript)
USE="-X -kde -gtk -gnome" emerge proj gdal freetype libpng jpeg gd
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/${MAPSERVER}.orig.tar.gz
cd ${MAPSERVER}
./configure --with-threads --with-gdal=/usr/bin/gdal-config --with-proj=/usr/ --with-ogr=/usr/bin/gdal-config --prefix=${MSHOME} --exec-prefix=${MSHOME}
make
mkdir -p ${MAPSERVER}/bin
make install-force
cd mapscript/tcl
patch -p0 < ${FILEDIR}/mapserver-mapscript-tcl.patch
cp ${FILEDIR}/tclmodule.i .
ln -s ${WORKDIR}/swig1.3.31/Source/swig  ${WORKDIR}/swig1.3.31/Source/include
./configure --enable-threads --with-tcl=${NSHOME}/ --with-swig=${WORKDIR}/swig1.3.31/Source --prefix=${NSHOME} --exec-prefix=${NSHOME}
cat Makefile | sed s/long\ long/long/g  > Makefile.tmp
mv Makefile.tmp Makefile
make
make install

# Make sure to call nsd-postgres instead of nsd if you use postgresql

echo "export PATH=\$PATH:${POSTGRES}/bin" >${NSHOME}/bin/nsd-postgres
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${POSTGRES}/lib:${NSHOME}/lib" >>${NSHOME}/bin/nsd-postgres
echo "exec ${NSHOME}/bin/nsd \$*" >>${NSHOME}/bin/nsd-postgres
chmod +x ${NSHOME}/bin/nsd-postgres
