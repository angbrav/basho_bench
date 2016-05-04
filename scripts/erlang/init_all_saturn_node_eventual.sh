#!/bin/bash

Leafs=`cat ../leafs`
LeafsN=0
for node in $Leafs
do
    let LeafsN=LeafsN+1
done
sudo erl -pa script -name "stat@130.104.228.60" -setcookie saturn_leaf -run init_saturn_node init_all_eventual $LeafsN $Leafs -run init stop
