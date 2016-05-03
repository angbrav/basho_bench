#!/bin/bash

Duration=$1
Value=$2
Correlation=$3
Keys=$4
Update=$5
UpdateRemote=$6
Read=$7
ReadRemote=$8
Clients=$9
Driver=${10}

./scripts/set_bench_param.sh "{duration.*/{duration, $Duration}"
./scripts/set_bench_param.sh "{driver.*/{driver, $Driver}"
./scripts/set_bench_param.sh "{concurrent.*/{concurrent, $Clients}"
./scripts/set_bench_param.sh "{value_generator.*/{value_generator, {fixed_bin, $Value}}"
./scripts/set_bench_param.sh "{saturn_correlation.*/{saturn_correlation, $Correlation}"
./scripts/set_bench_param.sh "{saturn_number_internalkeys.*/{saturn_number_internalkeys, $Keys}"
./scripts/set_bench_param.sh "{operations.*/{operations, [{update, $Update},{remote_update, $UpdateRemote},{read, $Read}, {remote_read, $ReadRemote}]}"
#./scripts/set_bench_param.sh "{operations.*/{operations, [{update, $Update},{read, $Read}]}"
#./scripts/set_bench_param.sh "{operations.*/{operations, [{read, $Read}]}"
