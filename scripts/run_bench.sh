#ol!/bin/bash

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
#KeyDistribution=${15}

./scripts/conf_bench.sh 1 2 uniform 10000 1 0 99 0 1 saturn_benchmarks_da 0 0 0 0 uniform_int

Counter=0
nodes=`cat ./scripts/bench`
nodesArray=(`cat ./scripts/leafs`)
receiversArray=(`cat ./scripts/receivers`)
    
for node in $nodes
do
    let Counter=Counter+1
    let Index=Counter-1
    NodeName="leafs$Counter@${nodesArray[$Index]}"
    ReceiverName="receivers$Counter@${receiversArray[$Index]}"
    echo $NodeName
    ./scripts/set_bench_dc.sh $node "{saturn_dc_nodes.*/{saturn_dc_nodes, ['$NodeName']}"
    ./scripts/set_bench_dc.sh $node "{saturn_dc_receiver.*/{saturn_dc_receiver, ['$ReceiverName']}"
    ./scripts/set_bench_dc.sh $node "{saturn_dc_id.*/{saturn_dc_id, $Index}"
done

Command1="sudo /usr/sbin/ntpdate -b ntp.ubuntu.com"
#./scripts/parallel_command_all.sh "$Command1"

Command2="cd ./basho_bench && sudo ./basho_bench examples/saturn_benchmarks_rpc.config"

#./scripts/parallel_command.sh bench "$Command2"
