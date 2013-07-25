#!/bin/sh

#-----------------------------------------------------

if [ $# -ne 2 ]; then
  echo "Usage: $0 BILOU.activ BILOU.corp"
  exit 9
fi

#-----------------------------------------------------

BASEDIR=/home/roth/metzler1/ne/cscl
p1=$BASEDIR/BILOU.p1
pss=$BASEDIR/BILOU.pss
allow=$BASEDIR/BILOU.allow

#echo "Changing activations to normalize exponentials..."
$BASEDIR/ExponentialActivPrepBILOU.pl $2 $1 > $1.prep
#echo "creating HMM input file..."
$BASEDIR/hmminputBILOU.pl $1.prep > $1.hmm
#echo "Applying inference..."
$BASEDIR/HMMPure $p1 $pss $1.hmm $allow > $1.out
#echo "converting to column..."
cat $1.out | perl -ne 's/\n/\n\n/g;s/ /\n/g;print $_;'

rm -rf $1.prep $1.hmm $1.out
 
