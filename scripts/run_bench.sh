#!/bin/bash

if [ $1 == "init" ]
then
    ./scripts/init_bench.sh
fi

#Duration=$1
#Value=$2
#Correlation=$3
#Keys=$4
#Update=$5
#UpdateRemote=$6
#Read=$7
#ReadRemote=$8
#Clients=$9
#Driver=${10}
#ReadTx=${11}
#NKeysTx=${12}
#TxRemote=${13}
#WriteTx=${14}


./scripts/conf_bench.sh 3 100 exponential 10000 10 0 90 0 12 saturn_benchmarks_eventual_da 0 5 0 0

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
./scripts/parallel_command_all.sh "$Command1"

Command2="cd ./basho_bench && sudo ./basho_bench examples/saturn_benchmarks_rpc.config"

./scripts/parallel_command.sh bench "$Command2"
