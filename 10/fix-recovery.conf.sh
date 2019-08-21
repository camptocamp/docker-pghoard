#!/bin/bash

sed -i 's/--port 16000/--port 16000 --host pghoard/' $1
echo "recovery_end_command = 'touch /tmp/recovery_end'" >> $1
