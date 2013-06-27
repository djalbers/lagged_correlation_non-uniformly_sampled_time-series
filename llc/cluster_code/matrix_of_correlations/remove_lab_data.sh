#!/bin/bash                                                                                                                          

for (( c=0; c<=3; c++ ))
do
  for (( k=0; k<=3; k++ ))
    do
      cd $c.$k;
      rm *.m;
      rm *.sh;
      rm lab1.data;
      rm lab2.data;
      rm -r J*;
      rm -r matlab_src;
      cd ..;
      done;
done



