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
%number_of_trials=25;

lab1_data=load(data_file_name_1);
lab2_data=load(data_file_name_2);

[correlation, mi] = correlate_labs_with_terms(execution_path, home_directory, time_interval, number_of_lags, def_Number_of_bins, lab1_data, lab2_data);

%the return values are the vectors of dimension 2*number_of_lags+1,
%with the +/- lagged lagged linear correlation and lagged mutual
%information.


