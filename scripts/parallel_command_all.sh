#!/bin/bash

set -u
set -e
FAIL=0
command="$1"

leafs=`cat ./scripts/leafs`
internals=`cat ./scripts/internals`
echo $command" for leafs:"$leafs 
for node in $leafs
do
    ssh -o ConnectTimeout=10 -t ubuntu@$node -i /home/mbravo/openstack-mbravo.pem ${command/localhost/$node} & 
done
echo $command" for internals:"$internals 
for node in $internals
do
    ssh -o ConnectTimeout=10 -t ubuntu@$node -i /home/mbravo/openstack-mbravo.pem ${command/localhost/$node} &
done
echo $command done

for job in `jobs -p`
do
    wait $job || let "FAIL+=1"
done

if [ "$FAIL" == "0" ];
then
echo "$command finished." 
else
echo "Fail! ($FAIL)"
fi
