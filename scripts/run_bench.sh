#!/bin/bash

if [ $1 == "init" ]
then
    ./scripts/init_bench.sh
fi

./scripts/conf_bench.sh 3 100 exponential 10000 10 0 90 0 12 saturn_benchmarks_cops_partial_da

Counter=0
nodes=`cat ./scripts/bench`
nodesArray=(`cat ./scripts/leafs`)
    
for node in $nodes
do
    let Counter=Counter+1
    let Index=Counter-1
    NodeName="leafs$Counter@${nodesArray[$Index]}"
    echo $NodeName
    ./scripts/set_bench_dc.sh $node "{saturn_dc_nodes.*/{saturn_dc_nodes, ['$NodeName']}"
    ./scripts/set_bench_dc.sh $node "{saturn_dc_id.*/{saturn_dc_id, $Index}"
done

Command1="sudo /usr/sbin/ntpdate -b ntp.ubuntu.com"
./scripts/parallel_command.sh leafs "$Command1"

Command2="cd ./basho_bench && sudo ./basho_bench examples/saturn_benchmarks_rpc.config"

./scripts/parallel_command.sh bench "$Command2"
