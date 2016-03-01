#!/bin/bash

set -u
set -e
FAIL=0
if [ $# -eq 1 ]
then
    Folder=$1
else
    Folder="current"
fi
Nodes=`cat ./scripts/bench`
Folder=`date +"%H%M%S_%d%m%y"`
mkdir ./results/$Folder
for node in $Nodes
do
    mkdir ./results/$Folder/$node
    scp -r -i /home/mbravo/openstack-mbravo.pem ubuntu@$node:basho_bench/tests/current/* ./results/$Folder/$node & 
done
rm -rf ./results/current
ln -s $Folder/ ./results/current
command="scp & ln"

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
