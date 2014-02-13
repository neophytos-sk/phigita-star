/web/bin/install-naviserver.sh NEW_BRANCH > /web/log/nsd-install.log 2>&1
svc -d /service/phigita-8001
ln -sf /opt/naviserver-4.99.3-phigita-2010.0-`date -u --rfc-3339=date` naviserver
emerge -av curl
/web/bin/install-tclcurl.sh
rm /opt/naviserver/pages/index.adp
cp /web/local-data/error-pages/50x.html /opt/naviserver/pages/index.html
svc -u /service/phigita-8001
