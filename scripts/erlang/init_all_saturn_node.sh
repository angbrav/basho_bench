#!/bin/bash

Leafs=`cat ../leafs`
Internals=`cat ../internals`
LeafsN=0
for node in $Leafs
do
    let LeafsN=LeafsN+1
done
sudo erl -pa script -name "stat@130.104.228.60" -setcookie saturn_leaf -run init_saturn_node init_all $LeafsN $Leafs $Internals -run init stop
