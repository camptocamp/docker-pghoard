#!/bin/bash

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
# Remove credentials from config
RAW_CONFIG=$(cat $PGHOARD_CONFIG)
KEY_TO_REMOVE="nodes[].password encryption_keys[].private object_storage.aws_secret_access_key object_storage.password object_storage.private_key object_storage.credential_file object_storage.account_key object_storage.key"
for key in $KEY_TO_REMOVE; do
  RAW_CONFIG_TMP=$(echo "$RAW_CONFIG" | jq "del(.backup_sites[].$key)" 2> /dev/null)
  if [ -n "$RAW_CONFIG_TMP" ]; then
    RAW_CONFIG=$RAW_CONFIG_TMP
  fi
done
echo $RAW_CONFIG | jq '.'
exit 0
