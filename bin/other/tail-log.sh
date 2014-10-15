echo == aias ==
/web/bin/ssh-node.sh aias "tail -n $1 /web/log/error.8001.log"
#echo == mars ==
#/web/bin/ssh-node.sh mars "tail -n $1 /web/log/error.8000.log"
#echo == zeus ==
#/web/bin/ssh-node.sh zeus "tail -n $1 /web/log/error.8050.log"
echo == ada ==
/web/bin/ssh-node.sh ada "tail -n $1 /web/log/error.8001.log"
#echo == turing ==
#/web/bin/ssh-node.sh turing "tail -n $1 /web/log/error.8021.log"