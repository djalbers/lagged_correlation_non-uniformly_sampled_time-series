clear all;
close all;

execution_path=pwd;
home_directory=pwd;

%time_interval=86400; %should be the number of seconds in a day if
                     %the data are in seconds and you want a
                     %resultion of a day
time_interval=1; %the fake data is in days and we want resolution
                 %of days
number_of_lags=60; %60 days
def_Number_of_bins=16; %number of bins (per dimension) for the
                       %mutual information calculation
data_file_name_1='lab1.data';
data_file_name_2='lab2.data';
number_of_trials=5; %number of bootstrap trials, here the number is
                    %low because there are very few fake patients
                    %in the fake ehr
max_number_of_patients_wanted=100000; %max number of patients per
                                      %trial --- only useful for
                                      %big data sets, otherwise irrelevant.

lab1_data=load(data_file_name_1);
lab2_data=load(data_file_name_2);

direct_the_bootstrap(execution_path, home_directory, time_interval, number_of_lags, def_Number_of_bins, data_file_name_1, data_file_name_2, number_of_trials,max_number_of_patients_wanted);


  



