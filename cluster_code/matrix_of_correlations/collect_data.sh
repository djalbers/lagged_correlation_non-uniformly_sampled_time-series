#!/bin/bash                                                                                                                          
mkdir lc_data;
cd lc_data;
for (( c=0; c<=19; c++ ))
do
  for (( k=0; k<=19; k++ ))
    do
      cp ../$c.$k/linear_correlation.data $c.$k.lc;    
    done;
done



