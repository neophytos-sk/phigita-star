#!/bin/bash


#mkdir /web
#groupadd web
#useradd nsadmin
NSADMIN_GROUPS=`groups nsadmin`
if [ $NSADMIN_GROUPS != "web" ]; then
    echo "add nsadmin to group web"
    usermod -g web -d /web nsadmin
fi
su - postgres -c '/opt/postgresql/bin/createuser -s nsadmin'
#chown -R nsadmin:web /web
#chmod -R 755 /web

###################################################################

#WEBHOME=~nsadmin
WEBHOME=/web
source ${WEBHOME}/bin/install-env.sh

###################################################################

function usage_info {
    echo "USAGE: "
    echo "  $0 NEW_BRANCH  (to build a new naviserver dir)"
    echo "  $0 CURRENT_BRANCH  (to build inside the current naviserver dir)"
}

if [ $# -lt 1 ]; then 
    usage_info
    exit
fi

if [ $1 = "NEW_BRANCH" ]; then
    NSHOME=${NSHOME} 
    rm -f /opt/naviserver
    ln -sf ${NSHOME} /opt/naviserver
elif [ $1 = "CURRENT_BRANCH" ]; then
    NSHOME=/opt/${WEBSERVER}/
else
    usage_info
    exit
fi


PGHOME_SHORT="/opt/postgresql"
NSHOME_SHORT="/opt/naviserver"

echo WEBSERVER=$WEBSERVER
echo NSHOME=$NSHOME
echo PGHOME_SHORT=$PGHOME_SHORT
echo NSHOME_SHORT=$NSHOME_SHORT


mkdir -p ${WORKDIR}


export TCLSH=${NSHOME}/bin/tclsh8.5
#export TCLSH=${NSHOME}/bin/tclsh8.6b2

### NAVISERVER
cd ${WORKDIR}
tar -xjvf ${FILEDIR}/naviserver/${NAVISERVER}.tar.bz2
mv naviserver ${NAVISERVER}
mv modules modules-${NAVISERVER}

cd ${NAVISERVER}
./autogen.sh --with-tcl=${NSHOME}/lib --prefix=${NSHOME} --enable-threads
make CFLAGS_EXTRA="-O3 -fPIC"
make install

ln -sf ${NSHOME}/lib/libtcl8.?.so ${NSHOME}/lib/libtcl.so

### nsdbi
cd ${WORKDIR}/modules-${NAVISERVER}/nsdbi
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME} POSTGRES=${PGHOME_SHORT} PGINCLUDE=${PGHOME_SHORT}/include/ PGLIB=${PGHOME_SHORT}/lib/

### nsdbipg
cd ${WORKDIR}/modules-${NAVISERVER}/nsdbipg
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME} POSTGRES=${PGHOME_SHORT} PGINCLUDE=${PGHOME_SHORT}/include/ PGLIB=${PGHOME_SHORT}/lib/

### nsdbpg
cd ${WORKDIR}/modules-${NAVISERVER}/nsdbpg
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME} POSTGRES=${PGHOME_SHORT} PGINCLUDE=${PGHOME_SHORT}/include/ PGLIB=${PGHOME_SHORT}/lib/

### nsssl
cd ${WORKDIR}/modules-${NAVISERVER}/nsssl
make install NAVISERVER=${NSHOME}

### nsstats
#cd ${WORKDIR}/modules-${NAVISERVER}/nsstats
#make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}


### nsclamav
#cd ${WORKDIR}/modules-${NAVISERVER}/nsclamav
#make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}

### nsaspell
cd ${WORKDIR}/modules-${NAVISERVER}/nsaspell
make install NSHOME=${NSHOME} NAVISERVER=${NSHOME}

#${WEBHOME}/bin/install-takeaki-uno.sh

# for stockquote module (see /web/service-phgt-0/lib/stockquote
${WEBHOME}/bin/install-ta-lib.sh
${WEBHOME}/bin/install-libxls.sh

cd /web/servers/service-phigita/lib/nssmtpd/c/
make clean
make install NAVISERVER=${NSHOME}


### TRF for faster base encoding
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/trf-${SUFFIX}.tar.gz
cd trf/
./configure --enable-threads --prefix=${NSHOME} --exec-prefix=${NSHOME} --with-tcl=${NSHOME}/lib
make
make install


#cd ${WORKDIR}/
#cp -R ${FILEDIR}/../cvs/TclMagick .
#cd TclMagick
#genconf.sh
#libtoolize --copy --force
#cp ${FILEDIR}/configure-TclMagick .
#./configure --without-tk --without-tkinclude --enable-threads --with-tcl=${NSOME}/lib/ --prefix=${NSHOME} --with-magick=/usr/bin/Magick-config



# Make sure to call nsd-postgres instead of nsd if you use postgresql

echo "export PATH=\$PATH:${PGHOME_SHORT}/bin" >${NSHOME}/bin/nsd-postgres
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${PGHOME_SHORT}/lib:${NSHOME_SHORT}/lib:/opt/clucene/lib" >>${NSHOME}/bin/nsd-postgres
#echo "export LD_PRELOAD=\"/opt/jemalloc/lib/libjemalloc.so\"" >> ${NSHOME}/bin/nsd-postgres

echo "exec ${NSHOME}/bin/nsd \$*" >>${NSHOME}/bin/nsd-postgres
chmod +x ${NSHOME}/bin/nsd-postgres
rm -f ${NSHOME}/pages/index.adp