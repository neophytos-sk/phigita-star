#!/bin/sh
cd /web/service-phigita/packages/maps/www-global/js/
cat DHTMLapi.js xhr.js kaMap.js kaKeymap.js kaTool.js wz_dragdrop.js kaZoomer.js > /web/data/lib/xo-1.0.0/source/widgets/kaMap-all.js
java -jar /opt/yuicompressor/build/yuicompressor-2.2.5.jar --type js --charset utf-8 -o /web/data/lib/data/kaMap-all.js /web/data/lib/xo-1.0.0/source/widgets/kaMap-all.js
java -jar /opt/yuicompressor/build/yuicompressor-2.2.5.jar --type js --charset utf-8 -o /web/data/js/kaMap-all.js /web/data/lib/xo-1.0.0/source/widgets/kaMap-all.js
