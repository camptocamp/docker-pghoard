#!/bin/bash

set -e

echo "Create physical_replication_slot on master ..."
export PGPASSWORD=$PG_PASSWORD
until psql -qAt -U replicator -h $PG_HOST -d postgres -c "select user;"; do 
  echo "sleep 1s and try again ..."
  sleep 1
done
psql -h $PG_HOST -c "SELECT * FROM pg_create_physical_replication_slot('${HOSTNAME}');" -U replicator -d postgres

echo "Create pghoard configuration with confd ..."
confd -onetime -backend env

echo "Run the pghoard daemon ..."
exec pghoard --short-log --config /home/postgres/pghoard.json
