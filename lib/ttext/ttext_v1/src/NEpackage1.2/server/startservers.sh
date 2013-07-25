#!/bin/sh

#-----------------------------------------------------

if [ $# -ne 3 ]; then
  echo "Usage: $0 list_port fex_port snow_port"
  exit 9
fi

#-----------------------------------------------------

BASEDIR=/home/nkd/my/experiments/NEpackage1.2
$BASEDIR/newlistne/UpperCaseNEAll.server.pl $1 >& $BASEDIR/newlistne/uppercaseneallserver.err &
$BASEDIR/snow/snow_ne_server -server $3 -F $BASEDIR/BILOUtrain.net >& /dev/null &
cd $BASEDIR
$BASEDIR/fex/fex_ne_server -p -s $2 $BASEDIR/localwideconll.scr $BASEDIR/BILOU.lex >& /dev/null &
cd - 
