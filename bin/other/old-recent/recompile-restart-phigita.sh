#/web/bin/ssh-node.sh turing "svc -du /service/turing-8021"
#/web/bin/ssh-node.sh zeus "svc -du /service/zeus-8050"
#sleep 15
#/web/bin/ssh-node.sh aias "svc -du /service/aias-8001"
#sleep 85
#/web/bin/ssh-node.sh mars "svc -du /service/mars-8000"
#sleep 15
/web/bin/ssh-node.sh ada "svc -d /service/phigita-8001"
for i in {1..10}; do echo "about to recompile all C/C++ modules for phigita: ${i}/10 (CTRL-C to abort)"; sleep 1; done
/web/bin/ssh-node.sh ada "rm -rf /web/.critcl/"
/web/bin/ssh-node.sh ada "rm -rf /web/local-data/critcl/"
/web/bin/ssh-node.sh ada "svc -u /service/phigita-8001"
