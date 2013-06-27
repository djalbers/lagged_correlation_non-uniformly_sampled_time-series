#!/bin/bash                                                                                                                          
cd low_level_src;
tar -cf low_level_src.tar *;
mv low_level_src.tar ../;
cd ..;

for (( c=0; c<=3; c++ ))
do
  for (( k=0; k<=3; k++ ))
    do
      #tar -cf mls.tar ./matlab_src;
      mkdir $c.$k;
      cd $c.$k;
      cp ../../data_files/$c.$k.lab lab1.data;    
      cp ../../data_files/$c.$k.lab2 lab2.data;
      cp ../low_level_src.tar .;
      tar -xf low_level_src.tar;
      rm low_level_src.tar;
      cd ..;
      done;
done



