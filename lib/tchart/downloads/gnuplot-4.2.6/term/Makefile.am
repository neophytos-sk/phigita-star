## Process this file with automake to produce Makefile.in -*-Makefile-*-
AUTOMAKE_OPTIONS = foreign 1.2h

EXTRA_DIST = README Makefile.am.in compact.c driver.h impcodes.h \
object.h post.h $(CORETERM) PostScript

# List of terminal drivers; must be created
# prior to running automake
##trm-files-begin
CORETERM = aed.trm ai.trm amiga.trm apollo.trm aquaterm.trm atariaes.trm \
atarivdi.trm be.trm cgi.trm cgm.trm corel.trm debug.trm djsvga.trm \
dumb.trm dxf.trm dxy.trm eepic.trm emf.trm emxvga.trm epson.trm \
estimate.trm excl.trm fg.trm fig.trm gd.trm ggi.trm gnugraph.trm gpic.trm \
gpr.trm grass.trm hp2648.trm hp26.trm hp500c.trm hpgl.trm hpljii.trm \
hppj.trm imagen.trm iris4d.trm kyo.trm latex.trm linux.trm mac.trm \
metafont.trm metapost.trm mgr.trm mif.trm multitos.trm next.trm \
openstep.trm pbm.trm pc.trm pdf.trm pm.trm post.trm pslatex.trm \
pstricks.trm qms.trm regis.trm rgip.trm sun.trm svg.trm t410x.trm tek.trm \
texdraw.trm tgif.trm tkcanvas.trm tpic.trm unixpc.trm unixplot.trm \
v384.trm vgagl.trm vws.trm win.trm wxt.trm x11.trm xlib.trm 
##trm-files-end

postscriptdir = $(pkgdatadir)/$(VERSION_MAJOR)/PostScript
postscript_DATA = PostScript/8859-15.ps PostScript/8859-1.ps\
	PostScript/8859-2.ps PostScript/cp1250.ps PostScript/cp437.ps\
	PostScript/cp850.ps PostScript/cp852.ps PostScript/koi8r.ps PostScript/koi8u.ps\
	PostScript/prologue.ps

Makefile.am: Makefile.am.in
	rm -f $@ $@t
	sed -n '1,/^##trm-files-begin/p' Makefile.am.in > $@t
	echo CORETERM = *.trm | fmt | (tr '\012' @; echo) \
	  |sed 's/@$$/%/;s/@/ \\@/g' | tr @% '\012 ' \
	  >> $@t
	sed -n '/^##trm-files-end/,$$p' Makefile.am.in >> $@t
	chmod a-w $@t
	mv $@t $@

