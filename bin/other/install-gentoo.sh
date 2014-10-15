#!/bin/bash

###################################################################

WEBHOME=/web
source ${WEBHOME}/bin/install-env.sh

###################################################################

function usage_info {
    echo "USAGE: "
    echo "  $0 SERVER  (to build a phigita server)"
    echo "  $0 DEVELOP  (to build a development server - includes more packages than SERVER)"
    echo "  $0 DESKTOP  (to build a desktop, including X, openoffice and so on)"
    echo "  $0 ROUTER  (to build a desktop, including X, openoffice and so on)"
    echo "FLAGS (second argument, e.g. install-gentoo.sh SERVER BOOTSTRAP): "
    echo "  BOOTSTRAP | NOREPLACE "
}

if [ $# -lt 1 ]; then 
    usage_info
    exit
fi


# --noreplace (-n)
#
#   Skips  the  packages  specified  on the command-line that have already been installed.
#   Without this option, any packages, ebuilds, or deps you specify on the command-line 
#   will cause Portage to remerge the package, even if it is already installed.  
#   Note that Portage will not remerge dependencies by default.

if [ $# -lt 2 ]; then
    usage_info
    exit
else
    if [ $2 = "BOOTSTRAP" ]; then
        CMD="emerge"
    elif [ $2 = "NOREPLACE" ]; then
        CMD="emerge --noreplace --deep"
    else
        usage_info
        exit
    fi
fi


if [ $1 = "SERVER" ]; then

    ${CMD} unzip lsof pciutils strace

    USE="-X" ${CMD} corefonts freefonts ttf-bitstream-vera
    USE="-X -kde -gtk -gnome" ${CMD} freetype libpng jpeg 
    USE="jpeg png truetype -xpm fontconfig" ${CMD} gd
    ${WEBHOME}/bin/install-imagemagick.sh
    ### USE="jpeg2k" ACCEPT_KEYWORDS="~x86" ${CMD} ghostscript-gnu
    ${CMD} gnu-gs-fonts-std gnu-gs-fonts-other


    USE="logrotate -curl bzip2" ${CMD} clamav
    ${CMD} aspell aspell-en aspell-el

    USE="threads" ${CMD} curl
    ${CMD} boost
    ${CMD} bc ;# needed by tclcurl when it calculates the version number

    # www/math - equation to png
    USE="t1lib" emerge dvipng



    # mapserver
    USE="-X -kde -gtk -gnome" ${CMD} proj gdal geos
    USE="-X -sdl truetype" ${CMD} agg
    echo "<900913> +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs <>" >> /usr/share/proj/epsg

    # gentoolkit - Collection of administration scripts for Gentoo
    # eselect - Gentoo's multi-purpose configuration and management tool
    ${CMD} gentoolkit eselect


    # access log analyzer www-misc/visitors
    ${CMD} visitors


    ### nginx dependency: openssl 

    ${CMD} optipng jpegoptim
    ${CMD} openssl ntp daemontools
    ${WEBHOME}/bin/install-mediabox-deps.sh
    ${WEBHOME}/bin/install-ttext-deps.sh
    ${WEBHOME}/bin/install-nginx.sh
    ${WEBHOME}/bin/install-yuicompressor.sh
    ${WEBHOME}/bin/install-poppler.sh
    ${WEBHOME}/bin/install-java.sh
    ${WEBHOME}/bin/install-postgresql.sh
    ${WEBHOME}/bin/install-naviserver.sh NEW_BRANCH


    rc-update add ntp-client boot
    rc-update add ntpd default
    rc-update add svscan default
    rc-update add nginx default

elif [ $1 = "DEVELOP" ]; then


    ${CMD} unzip
    USE="-X" ${CMD} corefonts sharefonts ttf-bitstream-vera
    USE="-X -kde -gtk -gnome" ${CMD} freetype libpng jpeg 
    USE="jpeg png truetype -xpm fontconfig" ${CMD} gd
    ${WEBHOME}/bin/install-imagemagick.sh

    ### USE="jpeg2k" ACCEPT_KEYWORDS="~x86" ${CMD} ghostscript-gnu
    ${CMD} gnu-gs-fonts-std gnu-gs-fonts-other

    USE="doc" ${CMD} exiv2
    USE="imagemagick emf plotutils" ${CMD} -p pstoedit     

    # An open-source memory debugger for GNU/Linux
    ${CMD} valgrind

    USE="logrotate -curl bzip2" ${CMD} clamav
    ${CMD} bc ;# needed by tclcurl when it calculates the version number

    ${CMD} aspell
    ${CMD} aspell-en
    ${CMD} aspell-el
    USE="-perl doc" ${CMD} memcached
    ${CMD} c-client
    ${CMD} libosip
    ${CMD} libidn
    USE="threads" ${CMD} curl
    ${CMD} boost
    ${CMD} strace
    ${CMD} libconfig

    # ttext
    USE="xml" ${CMD} htmltidy 
    #unac
    ACCEPT_KEYWORDS="~amd64" ${CMD} iconv 

    # jscompact
    #USE="threadsafe" ${CMD} spidermonkey
    #cd ${WORKDIR}/
    #tar -xzvf ${FILEDIR}/jscompact-1.1.1.tar.gz
    #cd jscompact-1.1.1
    #cp ${FILEDIR}/make.jscompact make
    #./make
    #cp jscompact ${NSHOME}/bin/

    # mapserver
    USE="-X -kde -gtk -gnome" ${CMD} proj gdal geos
    USE="-X -sdl truetype" ${CMD} agg
    echo "<900913> +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs <>" >> /usr/share/proj/epsg

    # TclCurl
    ${CMD} bc


    ### nginx dependencies
    ${CMD} openssl


    cd ${WORKDIR}
    tar -xzvf ${FILEDIR}/html2ps-1.0b5.tar.gz
    cd html2ps-1.0b5
    ./install


    USE="tcl" ${CMD} pdflib
    ${CMD} -C gnu-gs-fonts-std gnu-gs-fonts-other
    ${CMD} pdf2html
    # poppler (see install-poppler.sh below)
    ${CMD} gnu-gs-fonts-std gnu-gs-fonts-other
    USE="doc jpeg nls tiff" ${CMD} djvu
    ACCEPT_KEYWORDS="~x86" ${CMD} antiword antixls 
    ACCEPT_KEYWORDS="~x86" ${CMD} catdoc
    USE="nls -ruby" ${CMD} enscript 
    #htmldoc
    ${CMD} mdbtools

    ${CMD} gentoolkit eselect

    #### Only One Machine
    # ${CMD} blackdown-jre openoffice-bin

    ${WEBHOME}/bin/install-odf-converter.sh
    ${WEBHOME}/bin/install-ffmpeg.sh
    ACCEPT_KEYWORDS="x86" ${CMD} app-text/html2text
    USE="-gtk" ${CMD} mp3info
    ${CMD} optipng jpegoptim

    # nslookup, dig
    ${CMD} bind-tools  

    ${CMD} ntp daemontools
    ${WEBHOME}/bin/install-nginx.sh


    rc-update add ntp-client boot
    rc-update add ntpd default
    rc-update add svscan default

    # for mongodb
    ${CMD} scons v8 libpcap


    ${WEBHOME}/bin/install-yuicompressor.sh
    ${WEBHOME}/bin/install-poppler.sh

    ${WEBHOME}/bin/install-java.sh

    ${WEBHOME}/bin/install-postgresql.sh
    ${WEBHOME}/bin/install-naviserver.sh NEW_BRANCH

    USE="qt4" ${CMD} virtualbox virtualbox-modules  ;# saas-class
    ${CMD} netlogo-bin ;# modelthinking-class
    ${CMD} netcat      ;# saas-class
    ${CMD} eclipse-sdk ;# nlp-class

    ${CMD} scala
    ${CMD} R

    USE="qt4 alsa x264 vorbis v4l xml opengl" ${CMD} vlc
    # /web/bin/install-vlc.sh

    # Quant Software ToolKit - Computational Investing
    /web/bin/install-qstk.sh

    ${CMD} fabric
    ${CMD} app-misc/mc ;# gnu midnight commander is a text based file manager

elif [ $1 = "ROUTER" ]; then

    ${CMD} ntp
    ${CMD} iptables
    ${CMD} tcpdump
    ${CMD} dnsmasq
    ${CMD} lsof

    mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
    ln -sf /web/service-phgt-0/etc/dnsmasq.conf /etc/dnsmasq.conf
    rc-update add ntp-client boot
    rc-update add ntpd default
    rc-update add iptables default
    rc-update add dnsmasq default

elif [ $1 = "DESKTOP" ]; then

    # DWM tools - START
    ${CMD} rxvt-unicode
    ${CMD} xcalc
    ${CMD} feh
    ${CMD} compton
    ${CMD} pidgin
    ${CMD} libxdg-basedir File-BaseDir
    ${CMD} minicom
    USE="djvu" ${CMD} apvlv ;# document viewer
    ${CMD} kino avidemux cinellera  ;# video editing
    # DWM tools - END

    ${CMD} blackdown-jre
    ${CMD} dos2unix
    USE="kpathsea" ${CMD} texlive
    ${CMD} codeblocks
    ${CMD} eclipse-sdk

    # sci-visualization
    ${CMD} ggobi
    ${WEBHOME}/bin/install-java.sh
    ${CMD} adobe-flash

    # VIRTUAL MACHINES
    USE="alsa sdl -vnc" ${CMD} qemu  ;# win7-ultimate-x64
    ${CMD} virtualbox  ;# saas-class

    ${CMD} netlogo-bin ;# modelthinking-class

    ACCEPT_KEYWORDS="~amd64" ${CMD} blas lapack armadillo ;# for mlpack (among other things)

    ${CMD} gpointing-device-settings
    ${CMD} usbutils
    ${CMD} camorama xawtv
    ${CMD} xf86-input-synaptics xf86-input-keyboard xf86-input-mouse xf86-input-evdev
    ${CMD} xf86-video-nvidia xf86-video-vesa xf86-video-vmware xf86-video-intel
    ${CMD} bluez gnome-bluetooth gnome-phone-manager
    USE="usb imagemagick" ${CMD} obex-data-server ;# gnome-user-share NO DUE TO APACHE2 DEPENDENCY

    ${CMD} powertop 
    USE="acpi bluetooth" ${CMD} laptop-mode-tools
    USE="acpi" ${CMD} cpufreqd

    rc-update add cpufreqd default
    rc-update add laptop_mode default
    rc-update add acpid default

    ${CMD} netselect

    ${CMD} iwl6050-ucode
    ${CMD} iproute2 ;# contains the ip command used in xinitrc

    #usermod -G audio,uucp,nkd nkd
    #rc-update add bluetooth default

    USE="tor-hardening doc threads" ${CMD} tor
    ${CMD} rar

    # python modules
    ${CMD} nltk
    USE="lapack" ${CMD} scipy numpy
    ACCEPT_KEYWORDS="~amd64" ${CMD} perf

    ACCEPT_KEYWORDS="~amd64" ${CMD} istanbul ;# screencast / desktop recording
    ACCEPT_KEYWORDS="~amd64" ${CMD} omnicppcomplete
    
    ${CMD} netcat


else
    usage_info
    exit
fi


