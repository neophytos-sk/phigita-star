# http://www.mongodb.org/display/DOCS/Replica+Set+Tutorial

/opt/mongodb/bin/mongod --replSet foo --port 27017 --journal --directoryperdb --dbpath /web/data/mongodb/r0 &
/opt/mongodb/bin/mongod --replSet foo --port 27018 --journal --directoryperdb --dbpath /web/data/mongodb/r1 &
/opt/mongodb/bin/mongod --replSet foo --port 27019 --journal --directoryperdb --dbpath /web/data/mongodb/r2 &

#config = {_id: 'foo', members: [{_id: 0, host: 'localhost:27017'},{_id: 1, host: 'localhost:27018'},{_id: 2, host: 'localhost:27019'}]}
#rs.initiate(config);

