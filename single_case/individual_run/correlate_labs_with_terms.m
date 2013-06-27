%need to: set number of bins for the hist3, set all the variables, set the
function [correlation, mi] = correlate_labs_with_terms(execution_path, home_directory, time_interval, number_of_lags, ... 
    def_Number_of_bins, lab_data, mention_data)

addpath ([execution_path, '/matlab_src']);
%addpath ([home_directory, '/matlab_utilities']);

%now check to make sure that the mrns that exist in both lab and mention
%data

same_mrns=setdiff(lab_data(:,1), mention_data(:,1));
mrns_are_the_same=sum(same_mrns);

if(mrns_are_the_same==0) 
    %let's identify the different patients
    change_points_labs=diff(lab_data(:,1));
    change_patient_points_labs=find(change_points_labs~=0);
    change_points_mentions=diff(mention_data(:,1));
    change_patient_points_mentions=find(change_points_mentions~=0);
    %calculate the number of patients
    %number_of_patients=max(size(change_points))+1;
    number_of_patients=sum(change_points_labs>0)+1;
    N=number_of_patients;
    
    for(k=1:2*number_of_lags+1)
        j=-number_of_lags+k-1;
        %patients 1-N
        %set the first begin point and end point
        beginpoint_lab=1; 
        beginpoint_mention=1;
        if(N==1)
            endpoint_lab=max(size(lab_data(:,1)));
            endpoint_mention=max(size(mention_data(:,1)));
        else
            endpoint_lab=change_patient_points_labs(1);
            endpoint_mention=change_patient_points_mentions(1);
        end;
        if(N>1)
          was_here_already=0; %we need to set this to trigger the creation of pairs_to_correlate IF fail=1 when i=1 
          for(i=1:(N-1))
            %save;
            %send a patient block, get a master back, add it to the pile
            clear lab_data_foo mention_data_foo labsfoo mentionsfoo times_foo;
            lab_data_foo=lab_data(beginpoint_lab:endpoint_lab,:);
            mention_data_foo=mention_data(beginpoint_mention:endpoint_mention,:); %+j*time_interval;
            mention_data_foo(:,2)=mention_data_foo(:,2)+j*time_interval;
            %for(j=1:number_of_time_delay_days)
            %now send it off to be interpolated
            %[time_union, master(:,1), master(:,2)]
            %save;
            [times_foo, labs_foo, mentions_foo, fail]=interpolate_the_missing_points(lab_data_foo, mention_data_foo, execution_path);
            %now add the new master to the pile
            %save('foo.mat');
            if(fail~=1)       
              %save([execution_path,'/','foo.mat']);
              if(i==1 || was_here_already==0) 
                foo_size=max(size(labs_foo));
                pairs_to_correlate(1:foo_size,1)=labs_foo;     
                pairs_to_correlate(1:foo_size,2)=mentions_foo;  
                was_here_already=1; % ok, now we have
                                    % pairs_to_correlate even if we
                                    % had fail==1 for i==1.
              else
                foo_begin=max(size(pairs_to_correlate(:,1)))+1;  
                foo_size=max(size(labs_foo))+foo_begin-1;       
                pairs_to_correlate(foo_begin:foo_size,1)=labs_foo;
                pairs_to_correlate(foo_begin:foo_size,2)= ...
                    mentions_foo;
              end; 
              %now adjuste the begin and end points for the i+1
              %patient     
            end;             
            if(i<(N-1))
              beginpoint_lab=change_patient_points_labs(i)+1;
              endpoint_lab=change_patient_points_labs(i+1);
              beginpoint_mention=change_patient_points_mentions(i)+1;
              endpoint_mention=change_patient_points_mentions(i+1);
            end;
          end;
          
          %now do the last patient
          beginpoint_lab=change_patient_points_labs(N-1)+1;
          endpoint_lab=max(size(lab_data(:,1)));
          beginpoint_mention=change_patient_points_mentions(N-1)+1;
          endpoint_mention=max(size(mention_data(:,1)));
        end;
        
        clear lab_data_foo mention_data_foo labsfoo mentionsfoo times_foo;
        lab_data_foo=lab_data(beginpoint_lab:endpoint_lab,:);
        mention_data_foo=mention_data(beginpoint_mention:endpoint_mention,:);
        %now send it off to be interpolated
        %[time_union, master(:,1), master(:,2)]
        [times_foo, labs_foo, mentions_foo, fail]=interpolate_the_missing_points(lab_data_foo, mention_data_foo, execution_path);
        %save;
        if(fail==2)
          return;
        end;
        if(fail~=1)
          %now add the new master to the pile
          if(N>1)
            foo_begin=max(size(pairs_to_correlate(:,1)))+1;
            foo_size=max(size(labs_foo))+foo_begin-1;
          else
            foo_begin=1;
            foo_size=max(size(labs_foo));
          end;
          
          pairs_to_correlate(foo_begin:foo_size,1)=labs_foo;
          pairs_to_correlate(foo_begin:foo_size,2)=mentions_foo;
        end;
        %now check to see if there is anything in pairs_to_correlate
        
        
        
        %now do the correlations
        % pearson correlation, meaning, linear correlation pearson style
        correlation_foo=corr(pairs_to_correlate);
        correlation(k)=correlation_foo(2,1);
        %mutual information histogram style
        mi(k)=mi_hist3(def_Number_of_bins, pairs_to_correlate);
        clear pairs_to_correlate;
    end;  
    
    %fprintf(fid_linear_correlation, '%d \n', correlation);
    %fprintf(fid_mutual_information, '%d \n', mi);
    
else %the mrns are different, so this data set is junk
    %fid=fopen('error.data', 'w+');
    errormessage='the mrns did not match, do the data files are junk.';
    fprintf(fid_linear_correlation, '%s \n', errormessage);
    fprintf(fid_mutual_information, '%s \n', errormessage);
    %fclose(fid);
end;

%save([execution_path,'/output_state.mat']);


