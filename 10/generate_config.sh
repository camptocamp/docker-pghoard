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

echo "$0: Dump configuration... (password removed)"
cat $PGHOARD_CONFIG | grep -v 'password' | grep -v 'secret'
exit 0
