#!/bin/bash

Command1="sudo /usr/sbin/ntpdate -b ntp.ubuntu.com"
./scripts/parallel_command_all.sh "$Command1"

Command2="cd ./basho_bench && sudo ./basho_bench examples/saturn_benchmarks_rpc.config"

./scripts/parallel_command.sh bench "$Command2"
