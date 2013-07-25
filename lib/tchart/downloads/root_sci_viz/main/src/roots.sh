#!/bin/sh

#
# $Id: roots.in 33454 2010-05-10 20:35:07Z rdm $
#
#
# Template for the 'roots.sh' script.
# In case of problems with 'ssh' not executing the relevant <shell>rc init
# script, an ad hoc version of this script can be put, for example, under
# $HOME/bin, defining explicitely $ROOTSYS, e.g.
#
# ----------------------------------------------------------------------
# #!/bin/sh
#
# ROOTSYS=/afs/cern.ch/sw/lcg/external/root/5.15.06/slc4_amd64_gcc34
# cd $ROOTSYS
# source bin/thisroot.sh
# cd
#
# echo "Using ROOT at $ROOTSYS"
#
# exec $ROOTSYS/bin/roots.exe "$@"
# -----------------------------------------------------------------------
#
# In such a case to start the remote session do
#
#    root [0] .R lxplus ~/bin/roots
#    lxplus:root [1]
#

cd $ROOTSYS
source bin/thisroot.sh
cd

echo "Using ROOT at $ROOTSYS"

exec $ROOTSYS/bin/roots.exe "$@"
