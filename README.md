PGHoard Docker image
====================

Usage:
------

```shell
$ docker run camptocamp/pghoard
```

or

```shell
$ docker run --entrypoint <command> camptocamp/pghoard
```

where <command> is one of `pghoard`, `pghoard_archive_sync`, `pghoard_create_keys`, `pghoard_postgres_command` or `pghoard_restore`.

Launch in backup mode:
----------------------

```shell
$ docker run -d --entrypoint /backup.sh camptocamp/pghoard
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

## PGHOARD_STATSD_ADDRESS

Enables metrics sending to a statsd daemon that supports Telegraf or DataDog syntax with tags.

## PGHOARD_STATSD_PORT

## PGHOARD_STATSD_FORMAT

Can be either `telegraf` or `datadog`. (default `telegraf`)

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

## ENCRYPTION_KEYS_PUBLIC

Enable encryption of backups, you also need to setup `ENCRYPTION_KEYS_PRIVATE`.
This must be a RSA key like:
```
-----BEGIN PUBLIC KEY-----
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
...
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-----END PUBLIC KEY-----
```

## ENCRYPTION_KEYS_PRIVATE

Provide the private key for encryption. This must look like this :

```
-----BEGIN PRIVATE KEY-----
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
...
xxxxxxxxxxxxxxxxxxxxxxxxxxxx
-----END PRIVATE KEY-----
```

# Build and push Docker images

You can use `make.sh` to build:

```bash
./make.sh
```

and optionnaly upload your images:

```bash
./make.sh myhubid/myrepositoryname
```
