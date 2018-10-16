#!/bin/sh

HOSTS="kagamihara shima saitou"

echo "Enter new SSH pubkey: "
read $key

for host in $HOSTS ; do
  ssh danbooru@$host echo $key >> .ssh/authorized_keys
done
