#!/bin/bash

set -u
set -e
FAIL=0
Command1="cd ./basho_bench && sudo sed -i -e \"s/$2./\" examples/saturn_rpc.config"
ssh -o ConnectTimeout=10 -t ubuntu@$1 -i /home/mbravo/openstack-mbravo.pem ${Command1/localhost/$1} &
echo $Command1 done

for job in `jobs -p`
do
    wait $job || let "FAIL+=1"
done

if [ "$FAIL" == "0" ];
then
echo "$Command1 finished." 
else
echo "Fail! ($FAIL)"
fi