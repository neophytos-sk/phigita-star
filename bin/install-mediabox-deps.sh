#!/bin/bash


###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################

CMD="emerge --noreplace --deep"

    cd ${WORKDIR}
    tar -xzvf ${FILEDIR}/html2ps-1.0b5.tar.gz
    cd html2ps-1.0b5
    ./install

    USE="doc" ${CMD} exiv2
    USE="imagemagick emf plotutils" ${CMD} -p pstoedit
    USE="tcl" ${CMD} pdflib
    ${CMD} -C gnu-gs-fonts-std gnu-gs-fonts-other
    ${CMD} pdf2html
    # poppler 
    ${CMD} gnu-gs-fonts-std gnu-gs-fonts-other
    USE="doc jpeg nls tiff" ${CMD} djvu
    ACCEPT_KEYWORDS="~x86" ${CMD} antiword antixls catdoc
    USE="nls -ruby" ${CMD} enscript 
    #htmldoc
    ${CMD} mdbtools

    ACCEPT_KEYWORDS="~amd64" ${CMD} app-text/html2text
    USE="-gtk" ${CMD} mp3info

${WEBHOME}/bin/install-odf-converter.sh
${WEBHOME}/bin/install-ffmpeg.sh
