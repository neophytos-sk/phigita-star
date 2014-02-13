for peeraddr in `cat /web/conf/cluster-hosts`; do
    /web/bin/ssh-node.sh ${peeraddr} "${*}"
done
