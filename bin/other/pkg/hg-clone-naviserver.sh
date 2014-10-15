cd /web/cvs/
mv naviserver naviserver-`date --rfc-3339=date`
hg clone http://bitbucket.org/naviserver/naviserver/

mv naviserver-modules naviserver-modules-`date --rfc-3339=date`
mkdir -p /web/cvs/naviserver-modules/
cd /web/cvs/naviserver-modules/
for i in `cat /web/files/naviserver/naviserver-modules.txt`; do 
    hg clone http://bitbucket.org/naviserver/${i}; 
done
