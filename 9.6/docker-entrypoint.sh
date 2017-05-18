#!/bin/bash

set -e

echo "Create pghoard directories..."
chown -R postgres /home/postgres

echo "Create pghoard configuration with confd ..."
if getent hosts rancher-metadata; then
  confd -onetime -backend rancher -prefix /2015-12-19
else
  confd -onetime -backend env
fi

if [ -z "${PGHOARD_RESTORE_SITE}" ]; then

  echo "Dump configuration..."
  cat /home/postgres/pghoard.json

  echo "Create physical_replication_slot on master ..."
  export PGPASSWORD=$PG_PASSWORD
  until psql -qAt -U $PG_USER -h $PG_HOST -d postgres -c "select user;"; do
    echo "sleep 1s and try again ..."
    sleep 1
  done
  psql -h $PG_HOST -c "WITH foo AS (SELECT COUNT(*) AS count FROM pg_replication_slots WHERE slot_name='pghoard') SELECT pg_create_physical_replication_slot('pghoard') FROM foo WHERE count=0;" -U $PG_USER -d postgres

  echo "Run the pghoard daemon ..."
  exec gosu postgres pghoard --short-log --config /home/postgres/pghoard.json

else

  echo "Dump configuration..."
  cat /home/postgres/pghoard_restore.json

  echo "Set pghoard to maintenance mode"
  touch /tmp/pghoard_maintenance_mode_file

  echo "Get the latest available basebackup ..."
  gosu postgres pghoard_restore get-basebackup --config pghoard_restore.json --site $PGHOARD_RESTORE_SITE --target-dir restore --restore-to-master --recovery-target-action promote --recovery-end-command "pkill pghoard" --overwrite "$@"

  # remove custom server configuration (espacially the hot standby parameter)
  gosu postgres mv restore/postgresql.auto.conf restore/postgresql.auto.conf.backup

  echo "Start the pghoard daemon ..."
  gosu postgres pghoard --short-log --config /home/postgres/pghoard_restore.json &

  if [ -z "$RESTORE_CHECK_COMMAND" ]; then
    # Manual mode
    # Just start PostgreSQL
    echo "Start PostgresSQL ..."
    exec gosu postgres postgres -D restore
  else
    # Automatic test mode
    # Run test commands against PostgreSQL server and exit
    echo "Start PostgresSQL ..."
    gosu postgres pg_ctl -D restore start

    # Give postgres some time before starting the harassment
    sleep 20

    until gosu postgres psql -At -c "SELECT * FROM pg_is_in_recovery()" | grep -q f
    do
      sleep 5
      echo "AutoCheck: waiting for restoration to finish..."
    done

    echo "AutoCheck: running command on db..."
    OUT_LINES=$(gosu postgres psql -c "$RESTORE_CHECK_COMMAND" "$RESTORE_CHECK_DB" | wc -l)
    echo "AutoCheck: $OUT_LINES lines returned"

    if [ $OUT_LINES -gt 0 ]; then
      echo "AutoCheck: SUCCESS"
      RES=1
    else
      echo "AutoCheck: FAILURE"
      RES=0
    fi

    if [ ! -z "$PUSHGATEWAY_URL" ]; then
      cat << EOF | curl --binary-data @- ${PUSHGATEWAY_URL}/metrics/jobs/pghoard_restore/instances/${PGHOARD_RESTORE_SITE}
  check_success ${RES}
EOF
    fi
  fi
fi
