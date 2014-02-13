#!/bin/bash


###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################

AuthorizedKeysFile=~/.ssh/authorized_keys

for peeraddr in $*; do
echo "ssh-keygen for ${peeraddr}"
mkdir -p ~/.ssh/${NAMESPACE}-${peeraddr}
chmod 700 ~/.ssh/${NAMESPACE}-${peeraddr}
ssh-keygen -t dsa -P '' -f ~/.ssh/${NAMESPACE}-${peeraddr}/id_dsa
chmod 600 ~/.ssh/${NAMESPACE}-${peeraddr}/id_dsa
cp -r ~/.ssh/${NAMESPACE}-${peeraddr}/ /web/files/SSH/
chmod -R 775 /web/files/SSH/${NAMESPACE}-${peeraddr}/
chown -R nsadmin:web /web/files/SSH/${NAMESPACE}-${peeraddr}/
echo "Preparing node ${peeraddr} (get ready to enter password twice)"
scp ~/.ssh/${NAMESPACE}-${peeraddr}/id_dsa.pub root@${peeraddr}:
ssh root@${peeraddr} "mkdir ~/.ssh; chmod 600 ~/.ssh; chown root:root ~/.ssh; cat ~/id_dsa.pub >> ${AuthorizedKeysFile}; rm ~/id_dsa.pub; chmod 600 ${AuthorizedKeysFile};chown root:root /root;mkdir -p /web/bin/;groupadd web; useradd -d /web -g web nsadmin"
echo "Test SSH to ${peeraddr} - YOU SHOULD NOT BE ASKED FOR A PASSWORD NOW"
ssh -o PreferredAuthentications=publickey -i ~/.ssh/${NAMESPACE}-${peeraddr}/id_dsa root@${peeraddr} 'hostname'
/web/bin/scp-node.sh /web/files/bin/ $peeraddr /web/
/web/bin/scp-node.sh /web/files/etc/hosts $peeraddr /etc/
/web/bin/ssh-node.sh  ${peeraddr} /web/bin/init-node.sh
done
