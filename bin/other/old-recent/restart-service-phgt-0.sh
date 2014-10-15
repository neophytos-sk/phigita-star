#/web/bin/ssh-node.sh turing "svc -du /service/turing-8021"
#/web/bin/ssh-node.sh zeus "svc -du /service/zeus-8050"
#sleep 15
#/web/bin/ssh-node.sh aias "svc -du /service/aias-8001"
#sleep 85

# start backup service, restart main service, and then shut down backup
/web/bin/ssh-node.sh atlas "/web/bin/restart-phigita.sh"
#/web/bin/ssh-all.sh "/web/bin/restart-phigita.sh"
