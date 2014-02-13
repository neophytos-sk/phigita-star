#!/bin/bash


###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################
NSHOME=/opt/naviserver/

MSHOME=$NSHOME

mkdir -p ${WORKDIR}
### swig
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/swig-1.3.35.tar.gz
cd swig-1.3.35
./configure --without-ruby --without-python --without-php4 --without-perl5 --without-pike --without-chicken --without-csharp --without-mzscheme --without-ocaml --without-java  --without-guile --without-lua --without-clisp --without-r --with-tclconfig=${NSHOME}/lib/
make
make install

#USE="TCL" emerge -av swig

### mapserver mapscript (requires swig for mapscript)
cd ${WORKDIR}
#tar -xzvf ${FILEDIR}/${MAPSERVER}.orig.tar.gz
tar -xzvf ${FILEDIR}/${MAPSERVER}.tar.gz
cd ${MAPSERVER}
patch -p0 < ${FILEDIR}/gentoo-mapserver-5.0.0_tcl.patch-r1

#./configure --with-threads --with-gdal=/usr/bin/gdal-config --with-proj=/usr/ --with-ogr=/usr/bin/gdal-config --prefix=${MSHOME} --exec-prefix=${MSHOME} --with-tcl=${NSHOME} --with-mapscript

#./configure --prefix=/usr --host=i686-pc-linux-gnu --mandir=/usr/share/man --infodir=/usr/share/info --datadir=/usr/share --sysconfdir=/etc --localstatedir=/var/lib --without-gdal --without-agg --without-perl --without-python --without-ruby --with-tcl --without-proj --with-postgis --without-tiff --without-pdf --without-ming --without-java --with-iconv --with-threads --with-png --with-jpeg --with-zlib --with-freetype --with-mapscript --build=i686-pc-linux-gnu

./configure --prefix=${MSHOME} --with-gdal=/usr/bin/gdal-config  --without-agg --without-perl --without-python --without-ruby --with-tcl=/opt/naviserver/ --with-proj=/usr/ --with-agg=/usr/ --with-postgis --with-tiff --with-pdf --without-ming --without-java --with-iconv --with-threads --with-png --with-jpeg --with-zlib --with-freetype --with-mapscript --with-ogr=/usr/bin/gdal-config  --enable-threads --enable-shared

make
make shared
mkdir -p ${MSHOME}/bin
mkdir -p ${MSHOME}/lib
make install-force


cd mapscript/tcl
sed "s:perlvars:mapscriptvars:" -i configure
sed -e "s:tail -:tail -n :g" -e "s:head -:head -n :g" -i configure
sed "s:\`basename \$1\`:\"ld\":" -i configure
ln -s ${WORKDIR}/swig-1.3.35/  ${WORKDIR}/swig1.3.35
ln -s ${WORKDIR}/swig-1.3.35/Source/Swig  ${WORKDIR}/swig-1.3.35/Source/include
./configure --with-tcl=/opt/naviserver/ -with-swig=${WORKDIR}/swig1.3.35/Source
touch tclmodule.i
sed -e "s:-DTCL_WIDE_INT_TYPE=long long:-DTCL_WIDE_INT_TYPE=long\\\ long:g" -i Makefile
sed "s:\$(TCL_EXEC_PREFIX):\$(DESTDIR)\$(TCL_EXEC_PREFIX):g" -i Makefile
sed "s:extern\ __attribute__((__visibility__(\"hidden\"))):\"extern\ __attribute__((__visibility__(\\\"hidden\\\")))\":g" -i Makefile

make
sed -i.orig 's/@libdir@/lib/g' Makefile
make install



#patch -p0 < ${FILEDIR}/mapserver-mapscript-tcl.patch
#cp ${FILEDIR}/tclmodule.i .
#ln -s ${WORKDIR}/swig-1.3.31/  ${WORKDIR}/swig1.3.31/
#ln -s ${WORKDIR}/swig-1.3.31/Source/Swig  ${WORKDIR}/swig-1.3.31/Source/include
#./configure --enable-threads --with-tcl=${NSHOME}/ --with-swig=${WORKDIR}/swig1.3.31/Source --prefix=${NSHOME} --exec-prefix=${NSHOME}
#cat Makefile | sed s/long\ long/long/g  > Makefile.tmp
#mv Makefile.tmp Makefile
#cp ${FILEDIR}/mapserver-mapscript-tcl-Makefile Makefile
#make
#make install
