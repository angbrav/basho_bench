#!/bin/bash

#$1 duration
#$2 concurrent
#$3 update rate
#$4 read rate
Duration=$1
Concurrent=$2
Update=$3
Read=$4

./scripts/set_bench_param.sh "{duration.*/{duration, $Duration}"
./scripts/set_bench_param.sh "{concurrent.*/{concurrent, $Concurrent}"
./scripts/set_bench_param.sh "{operations.*/{operations, [{update, $Update},{read, $Read}]}"
