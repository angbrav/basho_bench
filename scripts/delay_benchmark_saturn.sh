#!/bin/bash

./scripts/parallel_command_all.sh ls
./scripts/parallel_command.sh bench ls

delays="0 25 50 75 100 125"
for delay in $delays
do

    ./scripts/change_delay.sh [0] [1,3] $delay
    ./scripts/rel_leafs.sh

    cd scripts/erlang && ./init_saturntx.sh && cd ../..

    ./scripts/run_bench_short.sh
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    echo "0-1 $delay"

    cd scripts/erlang && ./compute_average_staleness.sh && cd ../..
done

delays="25 50 75 100 125"
for delay in $delays
do

    ./scripts/change_delay.sh [1, 3] [2] $delay
    ./scripts/rel_leafs.sh

    cd scripts/erlang && ./init_saturntx.sh && cd ../..

    ./scripts/run_bench_short.sh
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    echo "1-2 $delay"

    cd scripts/erlang && ./compute_average_staleness.sh && cd ../..
done
