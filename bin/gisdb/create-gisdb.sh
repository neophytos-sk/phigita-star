#!/bin/bash

# iuse postgis

export LC_ALL=el_GR.utf-8
export LANG=el_GR.utf-8
export PGCLIENTENCODING=utf-8

GISHOST=localhost
GISUSER=postgres
GISDB=gisdb
#LATEST_OSM=/home/nkd/my/data/openstreetmap/planet-latest.osm.bz2
LATEST_OSM=/home/nkd/my/data/openstreetmap/nicosia-map.osm.bz2
OSM_STYLE=/opt/openstreetmap/default.style

FLAGS=$*
if [ -z $FLAGS ]; then
    echo "Supported flags DROPDB, NOIMPORT, NONE"
    exit 0
fi

echo "Flags=$FLAGS dropdb_p=$(expr match "$FLAGS" ".*DROPDB.*")"
if [ $(expr match "$FLAGS" ".*DROPDB.*") -ne 0 ]; then
    echo "dropping database ${GISDB}..."
    /opt/postgresql/bin/dropdb  -U ${GISUSER} -h ${GISHOST} ${GISDB}
fi


cd /web/data/maps/
rm world_boundaries/world_boundaries_lonlat.shp
ogr2ogr -s_srs EPSG:3395 -a_srs EPSG:4326 -t_srs EPSG:4326 world_boundaries/world_boundaries_lonlat.shp world_boundaries/world_boundaries_m.shp
/opt/postgresql/bin/shp2pgsql -d -D -i -I -W utf-8 -N skip -s 4326 world_boundaries/world_boundaries_lonlat.shp world_boundaries > world_boundaries/world_boundaries_lonlat.sql

/opt/postgresql/bin/createdb -U ${GISUSER} -h ${GISHOST} ${GISDB}
/opt/postgresql/bin/createlang -U ${GISUSER} -h ${GISHOST} plpgsql ${GISDB}
/opt/postgresql/bin/psql  -U ${GISUSER} -h ${GISHOST} -f /opt/postgresql/share/contrib/postgis.sql ${GISDB}
/opt/postgresql/bin/psql  -f /opt/postgresql/share/contrib/spatial_ref_sys.sql -U ${GISUSER} -h ${GISHOST} ${GISDB}
/opt/postgresql/bin/psql  -f /opt/postgresql/share/contrib/_int.sql -U ${GISUSER} -h ${GISHOST} ${GISDB}

/opt/postgresql/bin/psql  -f world_boundaries/world_boundaries_lonlat.sql -U ${GISUSER} ${GISDB}



### ogr2ogr -s_srs "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs +over" -t_srs EPSG:4326 coastlines/processed_lonlat.shp coastlines/processed_p.shp
### cs2cs +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs +to +proj=latlong +datum=WGS84 coastlines/processed_p.shp  > coastlines/processed_lonlat.shp
### /opt/postgresql/bin/shp2pgsql -d -D -i -I -W utf-8 -N skip -s 4326 coastlines/processed_lonlat.shp coastlines > coastlines/processed_lonlat.sql
#echo "<900913> +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs <>" >> /usr/share/proj/epsg

/opt/postgresql/bin/shp2pgsql -d -D -i -I -W utf-8 -N skip -s 900913 coastlines/processed_p.shp coastlines > coastlines/processed_lonlat.sql
/opt/postgresql/bin/psql  -f /web/data/maps/extra-spatial-ref-sys.sql -U ${GISUSER} -h ${GISHOST} ${GISDB}
/opt/postgresql/bin/psql  -f coastlines/processed_lonlat.sql -U ${GISUSER} -h ${GISHOST} ${GISDB}

if [ $(expr match "$FLAGS" ".*NOIMPORT.*") -eq 0 ]; then
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/postgresql/lib/
    /opt/openstreetmap/bin/osm2pgsql -s -c -d ${GISDB} -l -u -p earth_osm -U ${GISUSER} -H ${GISHOST} -P 5432 -S ${OSM_STYLE} ${LATEST_OSM}
    /opt/postgresql/bin/psql -c "create unique index earth_osm_roads__osm_id__un on earth_osm_roads (osm_id);"  -U ${GISUSER} -h ${GISHOST} ${GISDB}
    /opt/postgresql/bin/psql -c "create unique index earth_osm_polygon__osm_id__un on earth_osm_polygon (osm_id);"  -U ${GISUSER} -h ${GISHOST} ${GISDB}
    /opt/postgresql/bin/psql -c "create index earth_osm_roads__z_order__idx on earth_osm_roads (z_order);"  -U ${GISUSER} -h ${GISHOST} ${GISDB}
    /opt/postgresql/bin/psql -c "create index earth_osm_line__z_order__idx on earth_osm_line (z_order);"  -U ${GISUSER} -h ${GISHOST} ${GISDB}
fi
