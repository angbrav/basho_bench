#!/bin/bash

if [ $1 == "init" ]
then
    ./scripts/init_bench.sh
fi

./scripts/conf_bench.sh 1 100 exponential 10000 8 2 86 4 9 saturn_benchmarks_da

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

Command1="cd ./basho_bench && sudo ./basho_bench examples/saturn_benchmarks_rpc.config"

./scripts/parallel_command.sh bench "$Command1"
