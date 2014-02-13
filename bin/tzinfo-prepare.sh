cd /web/files/tzinfo/
rm -rf tzdata
mkdir tzdata
cd tzdata
tar -xzf ../tzdata*tar.gz
cat zone.tab | sed '/^\#/d' | awk '{print $1 "\t" $2 "\t" $3}'  > zone.psql_tab 
cp zone.psql_tab /web/service-phgt-0/packages/kernel/sql/common/