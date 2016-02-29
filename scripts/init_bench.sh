#!/bin/bash

if [ $# -eq 1 ]
then
    branch=$1
    Command1="cd ./basho_bench/ && git reset --hard && git fetch && git checkout $branch && git pull"
else
    Command1="cd ./basho_bench && git pull origin master"
fi

./scripts/parallel_command.sh bench "$Command1"


Command2="cd ./basho_bench && sudo make all"

./scripts/parallel_command.sh bench "$Command2"

./scripts/change_benchname.sh

./scripts/init_name_bench.sh
