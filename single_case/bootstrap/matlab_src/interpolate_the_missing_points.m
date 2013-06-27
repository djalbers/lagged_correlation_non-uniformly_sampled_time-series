%function [time_union, master(:,1), master(:,2)] = interpolate_the_missing_points(d1, d2)
  function [time_union, d1_interpolated, d2_interpolated, fail] = interpolate_the_missing_points(d1, d2, e_path)
%note d1 is the lab data and d2 is the mention data

%note the structure of d1 or d2:
% column 1: mrn or identifier
% column 2: time
% column 3: lab value
%note, for the correlate project, d1 is the lab file, and d2 is the
%mention file
  
%clear all;
%d1=load('data1'); 
%d2=load('data2');
d1o=d1;
d2o=d2;

%save('foo.mat');

%%%%%%%%%%%%%% data pre-processing %%%%%%%%%
%1. we have to sort the times, because they are NOT always sorted correctly
%2. we have to remove duplicate times, because we can't interpolate with
%duplicate times
%3. we have to normalize the patient data such that is mean zero
%and variance 1

%sort rows in order of time
d1=sortrows(d1,2);
d2=sortrows(d2,2);

%note, first we need to check if d1 and d2 have any repeaded time steps,
%and if we do, we need to get rid of them.
dtmp=diff(d1(:,2));
dkill=find(dtmp==0);
m=max(size(dkill));
if(min(size(dkill))>0)
    for(i=1:m)
        %A(:, 2) = [] removes COLUMN 2
        d1(dkill(i)-i+1,:) = [];
    end;
end
clear dtmp dkill;
dtmp=diff(d2(:,2));
dkill=find(dtmp==0);
if(min(size(dkill))>0)
    m=max(size(dkill));
    for(i=1:m)
        %A(:, 2) = [] removes COLUMN 2
        d2(dkill(i)-i+1,:) = [];
    end;
end;

fail=0;
time_union=union(d1(:,2), d2(:,2));
%time_union=unique(time_union_foo);
length_of_time_union=max(size(time_union));
length_d1=max(size(d1(:,2)));
length_d2=max(size(d2(:,2)));

%now let's normalize the lab data to 0, 1
%but note we can only do this INSIDE the if statement that checks
% to see if we have more than one data point

if(length_d1>1 && length_d2>1)
%now let's normalize the lab data to 0, 1
%    lab_mean=mean(d1(1:length_d1,3));
%    lab_std=std(d1(1:length_d1,3));
%    d1_foo=d1(1:length_d1,3)-lab_mean;
%    d1_foo=d1_foo/lab_std;
%    d1(1:length_d1,3)=d1_foo(1:length_d1,1);
%    clear d1_foo;

    %deal with d1
    if(min(d1(:,2))==min(time_union))
        d1_foo=d1;
    else
        d1_foo(1,1)=d1(1,1);
        d1_foo(1,2)=min(time_union);
        d1_foo(1,3)=d1(1,3);
        d1_foo(2:length_d1+1,1:3)=d1(1:length_d1,1:3);
    end;
    if(max(d1(:,2))~=max(time_union))
        foo_l=max(size(d1_foo));
        d1_foo(foo_l,1)=d1(1,1);
        d1_foo(foo_l,2)=max(time_union);
        d1_foo(foo_l,3)=d1(length_d1,3);
    end;

    %deal with d2
    if(min(d2(:,2))==min(time_union))
        d2_foo=d2;
    else
        d2_foo(1,1)=d2(1,1);
        d2_foo(1,2)=min(time_union);
        d2_foo(1,3)=d2(1,3);
        d2_foo(2:length_d2+1,1:3)=d2(1:length_d2,1:3);
    end;
    if(max(d2(:,2))~=max(time_union))
        foo_l=max(size(d2_foo));
        d2_foo(foo_l,1)=d2(1,1);
        d2_foo(foo_l,2)=max(time_union);
        d2_foo(foo_l,3)=d2(length_d2,3);
    end;
else
    fail=1;
    d1_interpolated=d1;
    d2_interpolated=d2;
    return;
end;
    
clear d1;
d1=d1_foo;
length_d1=max(size(d1(:,2)));

clear d2;
d2=d2_foo;
length_d2=max(size(d2(:,2)));

%d1_interpolated=interp1q(d1(:,2),d1(:,3),time_union);
%d2_interpolated=interp1q(d2(:,2),d2(:,3),time_union);

%save('interpolate_before.mat');

%now let's normalize the lab data to 0, 1
lab_mean=mean(d1(1:length_d1,3));                                                                   
lab_std=std(d1(1:length_d1,3));                                                                                                                                                                     
d1_foo=d1(1:length_d1,3)-lab_mean;   
if(lab_std~=0) %some patients have identical values; so you have to
               %ignore them
  d1_foo=d1_foo/lab_std;
end;
         
d1(1:length_d1,3)=d1_foo(1:length_d1,1);                                                                                                                                                            
clear d1_foo;       

%save([e_path, '/interpolate_before.mat']);

d1_interpolated=interp1(d1(:,2),d1(:,3),time_union);
d2_interpolated=interp1(d2(:,2),d2(:,3),time_union);

foo1=sum(isnan(d1_interpolated));
foo2=sum(isnan(d2_interpolated));

if(foo1>0 || foo2 >0)
    fail=2;
    save([e_path, '/interpolate_before.mat']);
end;






%if(length_d1~=1 || length_d2~=1)
%
%    %first deal with d1
%    if(max(size(time_union))~=max(size(d1(:,2)))) %there are missing points
%        %find if points are missing at the beginning
%        location_of_missing_starting_values=find(time_union==min(intersect(d1(:,2),time_union)));
%        location_of_missing_ending_values=find(time_union==max(intersect(d1(:,2),time_union)));
%    
%        %first fill in the missing starting values
%        if(location_of_missing_starting_values~=1)
%            %fill in the mrns
%            d1_foo(1:location_of_missing_starting_values-1,1)=d1(1,1);
%            %fill in the times
%            d1_foo(1:location_of_missing_starting_values-1,2)=time_union(1:location_of_missing_starting_values-1);
%            %fill in the data
%            d1_foo(1:location_of_missing_starting_values-1,3)=d1(1,3);
%        end;
%        %now put the intermediate points in
%        d1_foo(location_of_missing_starting_values:length_d1+location_of_missing_starting_values-1,:)=d1(1:length_d1,1:3);
%        %now check to see if you need to fill in end points
%        %save;
%        if(max(d1(:,2))~=max(time_union))
%            %fill in the mrns
%            d1_foo(location_of_missing_ending_values+1:length_of_time_union,1)=d1(length_d1,1);
%            %fill in the times
%            d1_foo(location_of_missing_ending_values+1:length_of_time_union,2)=time_union(location_of_missing_ending_values+1:length_of_time_union);
%            %fill in the data
%            d1_foo(location_of_missing_ending_values+1:length_of_time_union,3)=d1(length_d1,3);
%        end;
%    else
%        d1_foo=d1;
%    end;
%    
%    %first deal with d2
%    if(max(size(time_union))~=max(size(d2(:,2)))) %there are missing points
%        %find if points are missing at the beginning
%        location_of_missing_starting_values=find(time_union==min(intersect(d2(:,2),time_union)));
%        location_of_missing_ending_values=find(time_union==max(intersect(d2(:,2),time_union)));
%    
%        %first fill in the missing starting values
%        if(location_of_missing_starting_values~=1)
%            %fill in the mrns
%            d2_foo(1:location_of_missing_starting_values-1,1)=d2(1,1);
%            %fill in the times
%            d2_foo(1:location_of_missing_starting_values-1,2)=time_union(1:location_of_missing_starting_values-1);
%            %fill in the data
%            d2_foo(1:location_of_missing_starting_values-1,3)=d2(1,3);
%        end;
%        %now put the intermediate points in
%        d2_foo(location_of_missing_starting_values:length_d2+location_of_missing_starting_values-1,1:3)=d2(1:length_d2,1:3);
%        %now check to see if you need to fill in end points
%        if(max(d2(:,2))~=max(time_union))
%            %fill in the mrns
%            d2_foo(location_of_missing_ending_values+1:length_of_time_union,1)=d2(length_d2,1);
%            %fill in the times
%            d2_foo(location_of_missing_ending_values+1:length_of_time_union,2)=time_union(location_of_missing_ending_values+1:length_of_time_union);
%            %fill in the data
%            d2_foo(location_of_missing_ending_values+1:length_of_time_union,3)=d2(length_d2,3);
%        end;
%    else
%        d2_foo=d2;
%    end;
%    
%else
 %   fail=1;
 %   d1_interpolated=d1;
 %   d2_interpolated=d2;
 %   return;
%end;
% 
%clear d1;
%d1=d1_foo;
%length_d1=max(size(d1(:,2)));

%clear d2;
%d2=d2_foo;
%length_d2=max(size(d2(:,2)));
%
%d1_interpolated=interp1q(d1(:,2),d1(:,3),time_union);
%d2_interpolated=interp1q(d2(:,2),d2(:,3),time_union);
%
%%d1_interpolated=interp1(d1(:,2),d1(:,3),time_union);
%%d2_interpolated=interp1(d2(:,2),d2(:,3),time_union);
%
%foo1=sum(isnan(d1_interpolated));
%foo2=sum(isnan(d2_interpolated));
%
%if(foo1>0 || foo2 >0)
%    fail=2;
%    save('interpolate.mat');
%end;
%
