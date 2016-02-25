#!/bin/bash

set -u
set -e
FAIL=0
if [ "$1" = "-nodes" ]
then
    nodes=$2
    command="$3"
else
    nodes=`cat ./scripts/$1`
    command=$2
fi
echo $command" for nodes:"$nodes 
for node in $nodes
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
