PGHoard Docker image
====================

Usage:
------

```shell
$ docker run -d \
  -e PGHOARD_ACTIVE_BACKUP_MODE=pg_receivexlog \
  -e 
  camptocamp/pghoard
```

Environment variables:
----------------------

### PGHOARD_ACTIVE_BACKUP_MODE

Can be either `pg_receivexlog` or `archive_command`. If set to `pg_receivexlog`, pghoard will start up a pg_receivexlog process to be run against the database server. You can also set this to the experimental `walreceiver` mode whereby pghoard will start communicating directly with PostgreSQL through the replication protocol.

### PGHOARD_BASEBACKUP_COUNT

How many basebackups should be kept around for restoration purposes. The more there are the more diskspace will be used. (default 1)

## PGHOARD_BASEBACKUP_INTERVAL_HOURS

How often to take a new basebackup of a cluster. The shorter the interval, the faster your recovery will be, but the more CPU/IO usage is required from the servers it takes the basebackup from. If set to a null value basebackups are not automatically taken at all. (default 24)

## PG_HOST

## PG_PORT

## PG_PASSWORD

## PG_USER

## PGHOARD_STORAGE_TYPE

Can be either `local`, `s3` or `swift`.

## PGHOARD_DIRECTORY

Directory for the path to the backup target (local) storage directory.

## PGHOARD_LOG_LEVEL

Determines log level of pghoard. (default `INFO`)

## AWS_ACCESS_KEY_ID

## AWS_SECRET_ACCESS_KEY

## AWS_BUCKETNAME

## AWS_DEFAULT_REGION

## OS_USERNAME

## OS_PASSWORD

## OS_AUTH_URL

## OS_CONTAINER_NAME

## OS_REGION_NAME

## OS_TENANT_NAME
