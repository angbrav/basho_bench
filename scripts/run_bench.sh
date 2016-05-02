#!/bin/bash

if [ $1 == "init" ]
then
    ./scripts/init_bench.sh
fi

./scripts/conf_bench.sh 2 100 exponential 10000 8 2 72 18

Counter=0
nodes=`cat ./scripts/bench`
nodesArray=(`cat ./scripts/leafs`)
    
for node in $nodes
do
    let Counter=Counter+1
    let Index=Counter-1
    NodeName="leafs$Counter@${nodesArray[$Index]}"
    echo $NodeName
    ./scripts/set_bench_dc.sh $node "{saturn_dcs_nodes.*/{saturn_dcs_nodes, [['$NodeName']]}"
done

Command1="cd ./basho_bench && sudo ./basho_bench examples/saturn_benchmarks_rpc.config"

./scripts/parallel_command.sh bench "$Command1"