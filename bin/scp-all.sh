for peeraddr in `cat /web/conf/cluster-hosts`; do
    /web/bin/scp-node.sh ${1} ${peeraddr} ${2}
done
