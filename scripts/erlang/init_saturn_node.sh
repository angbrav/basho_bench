#!/bin/bash

Leafs=`cat ./scripts/leafs`
Internals=`cat ./scripts/internals`
LeafsN=0
for node in $Leafs
do
    let LeafsN=LeafsN+1
done
Counter=0
for node in $Leafs
do
    let Counter=Counter+1
    NodeName="leafs$Counter@$node"
    Id=Counter+1
    sudo erl -pa script -name stat@localhost -setcookie saturn_leaf -run init_saturn_node init $NodeName leafs $Id $LeafsN $Leafs $Internals -run init stop
done
let Counter=0
for node in $Internals
do
    let Counter=Counter+1
    NodeName="internals$Counter@$node"
    sudo erl -pa script -name stat@localhost -setcookie saturn_leaf -run init_saturn_node init $NodeName internals $Id $LeafsN $Leafs $Internals -run init stop
done
