#!/bin/bash

set -e
umask 002

# add a way to override location of pghoard config
export PGHOARD_CONFIG="${PGHOARD_CONFIG:-/etc/pghoard/pghoard.json}"

# Check if current user is registered in nss DB
if ! getent passwd "$(id -u)" &> /dev/null && [ -e /usr/lib/libnss_wrapper.so ]; then
  export LD_PRELOAD='/usr/lib/libnss_wrapper.so'
  export NSS_WRAPPER_PASSWD="$(mktemp)"
  export NSS_WRAPPER_GROUP="$(mktemp)"
  echo "postgres:x:$(id -u):$(id -g):PostgreSQL:/home/postgres:/bin/bash" > "$NSS_WRAPPER_PASSWD"
  echo "postgres:x:$(id -g):" > "$NSS_WRAPPER_GROUP"
  RANDOM_USER=true
else
  echo "Create pghoard directories..."
  chown -R postgres /home/postgres
  chown -R postgres /var/lib/pghoard
  RANDOM_USER=false
fi

# Generate pghoard config based on vars env if config is not already present
/generate_config.sh

# extract configuration to check replication slots
for config in $(jq -Mrc '.backup_sites | reduce .[].nodes[0] as $node ([]; . + [$node])' $PGHOARD_CONFIG | jq -cr '.[]'); do
  if [ $config = 'null' ]; then
    continue
  fi
  # don't try to create slot if configuration does not mention it
  for node_replication_slot in $(echo $config | jq -Mrc '.nodes[].slot'); do
    if  $node_replication_slot = 'null' ]; then
      continue 2
    fi
  done
  export PGHOST=$(echo $config | jq -r '.host')
  export PGUSER=$(echo $config | jq -r '.user')
  export PGPORT=$(echo $config | jq -r '.port')
  export PGPASSWORD=$(echo $config | jq -r '.password')
  until psql -qAt -c "select user;" postgres; do
    echo "sleep 1s and try again ..."
    sleep 1
  done
  psql -c "WITH foo AS (SELECT COUNT(*) AS count FROM pg_replication_slots WHERE slot_name='${REPLICATION_SLOT_NAME}') SELECT pg_create_physical_replication_slot('${REPLICATION_SLOT_NAME}') FROM foo WHERE count=0;" postgres
  unset PGHOST
  unset PGUSER
  unset PGPORT
  unset PGPASSWORD
done

echo "Run the pghoard daemon ... random user: $RANDOM_USER"
if [ $RANDOM_USER = "true" ]; then
  exec pghoard --short-log --config $PGHOARD_CONFIG
else
  exec gosu postgres pghoard --short-log --config $PGHOARD_CONFIG
fi
