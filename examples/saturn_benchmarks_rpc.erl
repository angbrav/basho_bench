{mode, max}.

{duration, 2}.

{driver, saturn_benchmarks_rpc}.

{key_generator, {uniform_int, 1000}}.

{value_generator, {fixed_bin, 100}}.

{saturn_dc_nodes, ['dev1@127.0.0.1']}.
{saturn_correlation, exponential}.
%Around 12M6 keys in total
{saturn_number_internalkeys, 100000}.
{saturn_mynode, ['saturn_bench@127.0.0.1', longnames]}.
{saturn_cookie, saturn_leaf}.
{saturn_dc_id, 0}.

{saturn_buckets_file, '../../files/ec2_seven_regions.txt'}.
{saturn_tree_file, '../../files/seven_leafs_buckets.txt'}.

{operations, [{update, 8},{remote_update, 2}, {read, 72}, {remote_read, 18}]}.
%{operations, [{read, 1}]}.