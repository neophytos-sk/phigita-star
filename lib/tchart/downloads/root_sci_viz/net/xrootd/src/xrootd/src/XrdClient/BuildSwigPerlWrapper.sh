#!/bin/sh

# $Id: BuildSwigPerlWrapper.sh 22437 2008-03-04 14:35:16Z rdm $

echo "This works only (and has been tested with) swig 1.3.22"

swig -perl XrdClientAdmin_c.hh

echo "Done. Check if the perl wrapper seems OK."

