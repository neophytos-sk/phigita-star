#!/bin/bash


#mkdir /web
#groupadd web
#useradd nsadmin
usermod -g web -d /web nsadmin
#chown -R nsadmin:web /web
#chmod -R 755 /web

###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################

mkdir -p ${WORKDIR}

${WEBHOME}/bin/install-postgresql.sh
${WEBHOME}/bin/install-gentoo.sh
${WEBHOME}/bin/install-naviserver.sh







exit










### TCL for AOLSERVER
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/${TCL}-src.tar.gz
cd ${TCL}/unix
./configure --enable-threads --prefix=${AOLSERVERHOME}
make install

### AOLserver 4.5.0 
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/aolserver-4.5.0-${SUFFIX}.tar.gz
cd aolserver
patch -p0 < ${FILEDIR}/aolserver45-nsd-conn.patch
patch -p0 < ${FILEDIR}/aolserver45-driver.patch
${AOLSERVERHOME}/bin/tclsh8.4 ./nsconfig.tcl -install $AOLSERVERHOME
make -i install


# Remove the symbolic link to aolserver.
# If this is not a symbolic link but the full path to your aolserver
# Make sure it becomes a symbolic link by issuing
# mv /usr/local/aolserver /usr/local/aolserver<yourversion>
rm /usr/local/aolserver
ln -s ${AOLSERVERHOME} /usr/local/aolserver



### nssha1
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/nssha1-${SUFFIX}.tar.gz
cd nssha1
make install NSHOME=${AOLSERVERHOME} AOLSERVER=${AOLSERVERHOME}

### nscache
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/nscache-20070128.tar.gz
cd nscache
make install NSHOME=${AOLSERVERHOME} AOLSERVER=${AOLSERVERHOME}

### nsaspell
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/nsaspell.tar.gz
cd nsaspell
make install NSHOME=${AOLSERVERHOME} AOLSERVER=${AOLSERVERHOME}

### nsclamav
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/nsclamav.tar.gz
cd nsclamav
make install NSHOME=${AOLSERVERHOME} AOLSERVER=${AOLSERVERHOME}

### nsimap
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/nsimap.tar.gz
cd nsimap
make install NSHOME=${AOLSERVERHOME} AOLSERVER=${AOLSERVERHOME}

### nsgd2
cd ${WORKDIR}
mkdir nsgd2
cd nsgd2
tar -xzvf ${FILEDIR}/nsgd2.tgz
make install NSHOME=${AOLSERVERHOME} AOLSERVER=${AOLSERVERHOME}


### nspostgres
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/nspostgres-${SUFFIX}.tar.gz
cd nspostgres
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${PG}/lib
make install POSTGRES=${PGHOME} ACS=1 NSHOME=${AOLSERVERHOME} AOLSERVER=${AOLSERVERHOME}


### Install tdom
# Note, if you use bash31 you need to apply a patch
# See http://openacs.org/forums/message-view?message_id=369867 for details
cd ${WORKDIR}
tar -xjvf ${FILEDIR}/tdom-cvs-20070418.tar.bz2
cd tdom/unix
../configure --enable-threads --disable-tdomalloc --prefix=${AOLSERVERHOME} --exec-prefix=${AOLSERVERHOME} --with-tcl=${AOLSERVERHOME}/lib --with-aolserver=${AOLSERVERHOME}
make install
cd ../extensions/tnc
./configure --enable-threads --disable-tdomalloc --prefix=${AOLSERVERHOME} --exec-prefix=${AOLSERVERHOME} --with-tcl=${AOLSERVERHOME}/lib --with-aolserver=${AOLSERVERHOME} --with-tdom=${AOLSERVERHOME}/lib
make install

### tcllib
cd ${WORKDIR}
tar -xjvf ${FILEDIR}/tcllib-1.9.tar.bz2
cd tcllib-1.9
./configure --prefix=${AOLSERVERHOME} --exec-prefix=${AOLSERVERHOME}
make install


### TCL Thread Extension
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/tcl-modules/thread2.6.5.tar.gz
cd thread2.6.5/unix/
../configure --enable-threads --prefix=${AOLSERVERHOME} --exec-prefix=${AOLSERVERHOME} --with-aolserver=${AOLSERVERHOME} --with-tcl=/${AOLSERVERHOME}/lib
make
make install


### XOTCL 1.5.3
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/xotcl-1.5.3.tar.gz
cd xotcl-1.5.3
patch -l -p0 < ${FILEDIR}/xotcl-1.5.3-fix1.patch
./configure --enable-threads --disable-symbols --prefix=${AOLSERVERHOME} --exec-prefix=${AOLSERVERHOME} --with-tcl=/${AOLSERVERHOME}/lib
make
make install-aol



### TclCurl
emerge libidn curl
cd ${WORKDIR}
tar -xjvf ${FILEDIR}/TclCurl-0.14.1.tar.bz2
cd TclCurl-0.14.1
cp ${FILEDIR}/tcl.m4-bash-4.x.x tclconfig/tcl.m4
autoconf
make clean
make install
./configure --enable-threads --prefix=${AOLSERVERHOME} --with-tcl=${AOLSERVERHOME}/lib/ --with-tclinclude=${AOLSERVERHOME}/include --includedir=${AOLSERVERHOME}/include 
make
make install

### TRF for faster base encoding
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/trf-${SUFFIX}.tar.gz
cd trf/
./configure --enable-threads --prefix=${AOLSERVERHOME} --exec-prefix=${AOLSERVERHOME} --with-tcl=${AOLSERVERHOME}/lib
make
make install

### dqd Utils
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/dqd_utils-1.3.tar.gz
cd dqd_utils-1.3
make INST=${AOLSERVERHOME} NSHOME=${AOLSERVERHOME} AOLSERVER=${AOLSERVERHOME}
cp dqd_utils8.so ${AOLSERVERHOME}/bin

### tcl_xcmds
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/tcl_xcmds-0.2.tar.gz
cd tcl_xcmds-0.2/unix
make clean
make distclean
autoconf
./configure --enable-threads --prefix=${AOLSERVERHOME} --exec-prefix=${AOLSERVERHOME} --with-tcl=${AOLSERVERHOME}/lib --with-aolserver=${AOLSERVERHOME}
make install

### ttext
USE="xml" emerge htmltidy unac
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/ttext-0.4.tar.gz
cd ttext0.4/unix
make clean
rm config.cache
TCLSH_PROG=${AOLSERVERHOME}/bin/tclsh8.4 ../configure --enable-threads --prefix=${AOLSERVERHOME}/ --with-tcl=${AOLSERVERHOME}//lib/ --with-aolserver=${AOLSERVERHOME}/ --with-tclinclude=${AOLSERVERHOME}/include/ 
make
cp libttext0.4.so ${AOLSERVERHOME}/bin/

### jsmin
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/jsmin-0.2.tar.gz
cd jsmin-0.2/unix
make clean
rm config.cache
TCLSH_PROG=${AOLSERVERHOME}/bin/tclsh8.4 ../configure --enable-threads --prefix=${AOLSERVERHOME}/ --with-tcl=${AOLSERVERHOME}//lib/ --with-aolserver=${AOLSERVERHOME}/ --with-tclinclude=${AOLSERVERHOME}/include/ 
make
cp libjsmin0.2.so ${AOLSERVERHOME}/bin/





### swig
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/swig-1.3.31.tar.gz
cd swig-1.3.31
./configure --without-ruby --without-python --without-php4 --without-perl5 --without-pike --without-chicken --without-csharp --without-mzscheme --without-ocaml --without-java  --without-guile --without-lua --without-clisp --without-r --with-tclconfig=${AOLSERVERHOME}/lib/
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
./configure --enable-threads --with-tcl=${AOLSERVERHOME}/ --with-swig=${WORKDIR}/swig1.3.31/Source --prefix=${AOLSERVERHOME} --exec-prefix=${AOLSERVERHOME}
cat Makefile | sed s/long\ long/long/g  > Makefile.tmp
mv Makefile.tmp Makefile
make
make install

# Make sure to call nsd-postgres instead of nsd if you use postgresql

echo "export PATH=\$PATH:${POSTGRES}/bin" >${AOLSERVERHOME}/bin/nsd-postgres
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${POSTGRES}/lib:${AOLSERVERHOME}/lib" >>${AOLSERVERHOME}/bin/nsd-postgres
echo "exec ${AOLSERVERHOME}/bin/nsd \$*" >>${AOLSERVERHOME}/bin/nsd-postgres
chmod +x ${AOLSERVERHOME}/bin/nsd-postgres




### SWI Prolog
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/${SWIPL}.tar.gz
cd ${SWIPL}/src
./configure \
    --enable-mt \
    --enable-readline \
    --enable-shared \
    --disable-custom-flags \
    --prefix=${PLHOME}

make
make install
cd ${WORKDIR}/${SWIPL}/packages
./configure \
    --enable-mt \
    --enable-shared \
    --without-C-sicstus \
    --with-chr \
    --with-clib \
    --with-clpqr \
    --with-cpp \
    --with-cppproxy \
    --without-jpl \
    --without-plunit \
    --without-pldoc \
    --without-http \
    --without-ssl \
    --without-nlp \
    --without-xpce \
    --without-semweb \
    --without-jasmine \
    --without-ltx2htm \
    --without-sgml \
    --without-sgml/RDF \
    --prefix=${PLHOME}
