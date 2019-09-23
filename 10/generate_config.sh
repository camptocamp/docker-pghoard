#!/bin/bash

echo "Listing files in /etc/pghoard/"
ls -l /etc/pghoard/

echo "$0: PGHoard config : $PGHOARD_CONFIG"

if [ ! -r $PGHOARD_CONFIG ]; then
  echo "$0: Create pghoard configuration with confd ..."
  if getent hosts rancher-metadata; then
    confd -onetime -backend rancher -prefix /2015-12-19
  else
    confd -onetime -backend env
  fi
else
  echo "$0: Configuration already present"
fi

echo "$0: Dump configuration... (credentials removed)"
RAW_CONFIG=$(cat $PGHOARD_CONFIG)
KEY_TO_REMOVE="nodes[].password encryption_keys[].private object_storage.aws_secret_access_key object_storage.password object_storage.private_key object_storage.credential_file object_storage.account_key object_storage.key"
for key in $KEY_TO_REMOVE; do
  RAW_CONFIG=$(echo "$RAW_CONFIG" | jq "del(.backup_sites[].$key)")
done
echo $RAW_CONFIG | jq
exit 0
