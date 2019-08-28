#!/bin/bash

# This entrypoint is dedicated to restoration of databases, it takes severals arguments:
# * $1 Name of the site to restore as configured in pghoard.json
# * $2 Type of restore target: xid, timestamp, name
# * $3 Target: 2019-08-20T12:36:50+02:00, my_backup_name, ... (depends on the first argument)
# * $4 Should restore include the target: true, false
# * $5 End of restore action: shutdown, promote, pause
# * $6 Where to restore DB: /mnt/pgdata

SITE=$1
TARGET_TYPE=$2
TARGET=$3
TARGET_INCLUDE=$4
TARGET_ACTION=$5
RESTORE_LOCATION=$6
PGHOARD_CONFIG=/etc/pghoard/pghoard.json

if [ $# -ne 6 ]; then
  echo "Usage $0 <site> <target type> <target> <target include> <end of restore action> <restore location>"
  exit 1
fi

# Check pghoard.json
if [ ! -r $PGHOARD_CONFIG ]; then
  echo "Cannot read pghoard configuration at $PGHOARD_CONFIG"
  exit 2
fi

# Check site in pghoard config
jq -e ".backup_sites[\"$SITE\"]" $PGHOARD_CONFIG > /dev/null
if [ $? -ne 0 ]; then
  echo Invalid site : $SITE not found in $PGHOARD_CONFIG
  exit 3
fi

# Check target type
case $TARGET_TYPE in
  'xid')
    RECOVERY_TARGET="--recovery-target-xid $TARGET"
    ;;
  'timestamp')
    RECOVERY_TARGET="--recovery-target-time $TARGET"
    ;;
  'name')
    RECOVERY_TARGET="--recovery-target-name $TARGET"
    ;;
  *)
    echo "Invalid Target type value : '$TARGET_TYPE' one of 'xid', 'timestamp' or 'name' is required"
    exit 4
esac

# Check include target parameter
case $TARGET_INCLUDE in
  'true')
    ;;
  'false')
    ;;
  *)
    echo "Invalid include target parameter value : '$TARGET_INCLUDE' one of 'true' or 'false' is required"
    exit 5
esac
RECOVERY_INCLUDE="recovery_target_inclusive = $TARGET_INCLUDE"

# Check restore action parameter
case $TARGET_ACTION in
  'shutdown')
    ;;
  'promote')
    ;;
  'pause')
    ;;
  *)
    echo "Invalid restore action parameter value : '$TARGET_ACTION' one of 'shutdown', 'promote' or 'pause' is required"
    exit 6
esac
RECOVERY_ACTION="--recovery-target-action $TARGET_ACTION"

# Search and download a basebackup
pghoard_restore get-basebackup --config $PGHOARD_CONFIG --target-dir $RESTORE_LOCATION --restore-to-master --site $SITE -v $RECOVERY_TARGET $RECOVERY_ACTION

# Fix recovery.conf
sed -i 's/--port 16000/--port 16000 --host pghoard/' $RESTORE_LOCATION/recovery.conf
echo "recovery_end_command = 'touch /tmp/recovery_end'" >> $RESTORE_LOCATION/recovery.conf
echo $RECOVERY_INCLUDE >> $RESTORE_LOCATION/recovery.conf

# Fix postgresql.conf
# The location of data might have change, we need to fix this
grep -v data_directory $RESTORE_LOCATION/postgresql.conf > /tmp/postgresql.conf
echo "data_directory = '$RESTORE_LOCATION'" >> /tmp/postgresql.conf
mv /tmp/postgresql.conf $RESTORE_LOCATION/postgresql.conf

# Fix pg_hba.conf
echo "host all all all md5" > $RESTORE_LOCATION/pg_hba.conf
echo "hostssl all all all md5" >> $RESTORE_LOCATION/pg_hba.conf
echo "local all all ident" >> $RESTORE_LOCATION/pg_hba.conf

# Create a restore folder in data directory for pghoard
mv /home/postgres/restore $RESTORE_LOCATION
mkdir -p $RESTORE_LOCATION/restore/pg_wal/
#chown -R postgres /var/lib/pgsql/10/data/restore/
ln -s $RESTORE_LOCATION/restore /home/postgres/restore

# Disable backup sites in pghoard configuration so pghoard does not try to create new backups
jq '.backup_sites[].active = false' $PGHOARD_CONFIG > /tmp/pghoard_restore.json

# Add a flag to indicates that postgres can start
touch $RESTORE_LOCATION/restored
export PGHOARD_CONFIG=/tmp/pghoard_restore.json
exec /docker-entrypoint.sh