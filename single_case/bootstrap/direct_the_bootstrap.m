
%1. read in the data
%2. sort the data in the usual way...
%2. random generate N intergers between 1 and N --- there can be
%duplicates, these are the patients you will use
% 3. 

function direct_the_bootstrap(execution_path, home_directory, ...
                              time_interval, number_of_lags, ...
                              def_Number_of_bins, lab_data_file_name, ...
                              mention_data_file_name, number_of_trials, max_number_of_patients_wanted)

  addpath ([execution_path, '/matlab_src']);
  %addpath ([home_directory, '/matlab_utilities']);
  
  %time_interval=1;
  %number_of_lags=60;
  
  lab_data_raw=load([execution_path,'/',lab_data_file_name]); %in trial was data1
  mention_data_raw=load([execution_path,'/',mention_data_file_name]);   %'data2'
                                                                        %fid_linear_correlation=fopen([execution_path,'/linear_correlation.data'], 'w+');
                                                                        %fid_mutual_information=fopen([execution_path,'/mutual_information.data'], 'w+');

  %sort by mrn
  lab_data=sortrows(lab_data_raw, 1);
  mention_data=sortrows(mention_data_raw,1);
  
  %check to make sure the mrns are the same
  same_mrns=setdiff(lab_data(:,1), mention_data(:,1));
  mrns_are_the_same=sum(same_mrns);
 
  %%%%%%%  this is new, and for large lab-lab data sets  
  %now let us get rid of some of these mrns if we need to

  u_mrns=unique(lab_data(:,1));
  n_patients=max(size(u_mrns));
  %max_number_of_patients_wanted=100000;

  if(n_patients > max_number_of_patients_wanted)
  
    %now select max_number_patients_wanted UNIQUE patients
  
    %create a vector of randomly ordered intergers ranging from 1 to
    %the number of patients
    v=randperm(n_patients).';
  
    % assign the random ordered numbers to the second column of the
    % unique mrn list
    u_mrns(:,2)=v;
  
    %now sort the random vector, randomizing the mrn ordering 
    u_keep_mrns=sortrows(u_mrns,2);
  
    %now collect the first max_number_of_patients_wanted elements of
    %this vector, these are the patients we want
  
    mrns_to_keep=u_keep_mrns(1:max_number_of_patients_wanted,1);
    
    %now remove all the mrns that are not in the set of mrns we want to keep
    lab_data(find(ismember(lab_data(:,1),mrns_to_keep)==0),:)=[];
    mention_data(find(ismember(mention_data(:,1),mrns_to_keep)==0),:)=[];
  
  end;    



  if(mrns_are_the_same==0) 
    
    unique_mrns=unique(lab_data(:,1));
    %calculate the number of unique mrns
    N=max(size(unique_mrns));
    
    %mrn_labels=linspace(1, N, N).';
    %mrn_labels(:,2)=unique_mrns;
    
    for(j=1:number_of_trials)
      clear new_lab_data new_mention_data lab_data_foo mention_data_foo;
      %this creates an array of N intergers between 1 and N, where N can
      %be repeated!
      random_set_mrns=randi([1,N], [N,1]);
      
      mrn_labels=linspace(1, N, N).';
      mrn_labels(:,2)=unique_mrns;
      
      %this find and removes all rows where is not a 9 in the first column
      % 1-d r(find(r~=9))=[];
      %2-d r(find(r(:,1)~=9),:)=[];
      
      %now choose N patients
      for(i=1:N)
        %make a fake copy of the data
        lab_data_foo=lab_data;
        mention_data_foo=mention_data;
        %remove all the extra data, leaving only patient
        %mrn_labels(i,2)
        lab_data_foo(find(lab_data_foo(:,1)~=mrn_labels(random_set_mrns(i),2)),:)=[];
        mention_data_foo(find(mention_data_foo(:,1)~=mrn_labels(random_set_mrns(i),2)),:)=[];
        %lab_data_foo(find(lab_data_foo(:,1)~=mrn_labels(i,2)),:)=[];
        %mention_data_foo(find(mention_data_foo(:,1)~=mrn_labels(i,2)),:)=[];
        %now rename the mrn to be sequential so that we don't have more
        %than one mrn which would crash the correlation scheme
        lab_data_foo(:,1)=i;
        mention_data_foo(:,1)=i;
        
        if(i==1)
          df_N=max(size(lab_data_foo(:,1)));
          new_lab_data(1:df_N, :) = lab_data_foo;
          
          df_N=max(size(mention_data_foo(:,1)));
          new_mention_data(1:df_N, :) = mention_data_foo;
        elseif(i>1)
          temp_N=max(size(new_lab_data(:,1)));
          df_N=max(size(lab_data_foo(:,1)));
          %save;
          new_lab_data(temp_N+1:temp_N+df_N, :) = lab_data_foo;
          
          temp_N=max(size(new_mention_data(:,1)));
          df_N=max(size(mention_data_foo(:,1)));
          new_mention_data(temp_N+1:temp_N+df_N, :) = mention_data_foo;
        end;
      end;
      
      if(max(size(new_lab_data))>N && max(size(new_mention_data))>N)
        % if we have more than one point per patient for both labs and mentions
        %now call correlate
        %save;
        [lc mi] = correlate_labs_with_terms(execution_path, home_directory, ...
                                            time_interval, number_of_lags, ...
                                            def_Number_of_bins, new_lab_data, new_mention_data);
        
        lcc(:,j)=lc;
        lmi(:,j)=mi;  
      else %we have to do this j over THIS CAN INSTALL an infinite or
           %nearly infinite loop if all or more of the patients have
           %only one value
        j=j-1;
      end;
    end; %end of the j loop over bootstrap trials
         %now write out the data
         %save;
    %estimate the 95% confidience interval
    for(i=1:(2*number_of_lags+1))
      lcstd(i)=std(lcc(i,:));
    end;
    lc_ci=1.96*mean(lcstd);
    dlmwrite([execution_path,'/linear_correlation.data'], lcc, ...
             'Delimiter', '\t');
    dlmwrite([execution_path,'/ci.data'], lc_ci);
    dlmwrite([execution_path,'/mutual_information.data'], lmi, ...
             'Delimiter', '\t');
    
  else %the mrns are different, so this data set is junk
       %fid=fopen('error.data', 'w+');
    fid_linear_correlation=fopen([execution_path,'/linear_correlation.data'], 'w+');
    errormessage='the mrns did not match, do the data files are junk.';
    fprintf(fid_linear_correlation, '%s \n', errormessage);
    fclose(fid_linear_correlation);
  end;
  
  