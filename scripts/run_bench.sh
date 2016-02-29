#!/bin/bash

if [ $1 == "init" ]
then
    ./scripts/init_bench.sh
fi

./scripts/conf_bench.sh 1 20 1 10

./scripts/set_bench_dc.sh "172.31.0.178" "{saturn_dcs_nodes.*/{saturn_dcs_nodes, [['leafs1@172.31.0.106']]}"
./scripts/set_bench_dc.sh "172.31.0.179" "{saturn_dcs_nodes.*/{saturn_dcs_nodes, [['leafs2@172.31.0.117']]}"

Command1="cd ./basho_bench && sudo ./basho_bench examples/saturn_rpc.config"

./scripts/parallel_command.sh bench "$Command1"
