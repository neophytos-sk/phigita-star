#!/bin/sh

if [ $# -ne 2 ]; then
  echo "Usage: $0 script resultfile"
  exit 9
fi
echo $2 $1

rm -rf BILOU*.ex BILOU*.lex BILOU*.net
./fex/fex -p $1 BILOU.lex MOSTRECENT.BILOU.train BILOUtrain.ex
./fex/fex -p $1 BILOU.lex MOSTRECENT.BILOU.testb BILOUtestb.ex

./Snow_v3.1/snow -train -F BILOUtrain.net -I BILOUtrain.ex -P 0.05,6,2.2:1-17 -W 1.25,0.85,8,0.2:1-17 -r 8 -S 1.4
./Snow_v3.1/snow -test -F BILOUtrain.net -I BILOUtestb.ex -o allpredictions > $2

