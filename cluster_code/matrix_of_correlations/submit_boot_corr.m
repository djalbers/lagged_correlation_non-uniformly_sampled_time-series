%function submit_job_script_patient_multi_job();


for(i=1:4)
  for(j=1:4) %remember, we can't start at zero
    %should be 1 to 60
    addpath('/home/dja7001/matlab_utilities');
    cd([pwd, '/', int2str(i-1), '.', int2str(j-1)]);
    
    root_path=pwd;
    addpath(root_path);

    %select and set the scheduler

    corr_boot_schd = findResource('scheduler','type','torque');

    %set the paths for where to run, home, where to execute, etc.

    %execution_path=root_path_slash;
    execution_path=root_path;
    home_directory=('/home/dja7001');
 
    %set the output directory
    set(corr_boot_schd, 'DataLocation', char(execution_path));
    set(corr_boot_schd, 'HasSharedFilesystem', true);
    set(corr_boot_schd, 'ClusterMatlabRoot', '\share\apps\matlab\');
    %set(corr_boot_schd, 'ClusterSize', 12);
    %set(corr_boot_schd, 'SubmitArguments', '-m aeb -l nodes=1,mem=7gb');
    set(corr_boot_schd, 'SubmitArguments', '-l nodes=1,mem=2gb');
    %define a job

    corr_boot_jobs=createJob(corr_boot_schd);
    
    %now, you have to let the job know where the exacutables and such are
    %so you need to create a cell array of strings, 
    p={execution_path, [execution_path, '/matlab_src'], [home_directory, '/matlab_utilities']};
    set(corr_boot_jobs, 'PathDependencies', p);

    %define the arguments sent to the function
    number_of_call_parameters=8;

    %define the call parameters

    %execution_path
    %home_directory
    time_interval=86400; %should be the number of seconds in a day
    number_of_lags=60; %60 days
    def_Number_of_bins=16; 
    lab_data_file_name='lab1.data';
    mention_data_file_name='lab2.data';
    number_of_trials=25;
    
    %create the task
    
    createTask(corr_boot_jobs, @direct_the_bootstrap, 0, {execution_path, ...
                        home_directory, time_interval, number_of_lags, def_Number_of_bins, lab_data_file_name, mention_data_file_name, number_of_trials}); 

    %submit the job

    %fid=fopen([execution_path, '/', 'foo.txt'], 'a+');                                                                                   
    %fprintf(fid, '%s /n', execution_path);                                                                                                                                         %fclose(fid); 

    submit(corr_boot_jobs);
    cd('..');
    keep i j;
  end;
end;

