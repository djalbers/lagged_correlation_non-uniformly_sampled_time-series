function [MI_est] = mi_hist3(defNumber_of_bins, data)


%nbins(1)=10;
nbins(1)=defNumber_of_bins;
nbins(2)=nbins(1);
raw_pdf=hist3(data, nbins);

sample_size=max(size(data(:,1)));

%normalized_joint_pdf=raw_pdf/number_of_points;
normalized_joint_pdf=raw_pdf/sample_size;

xmarginals_normalization=sum(raw_pdf);
ymarginals_normalization=sum(raw_pdf');

%generate marginals
for(k=1:nbins(1))
    px(k)=xmarginals_normalization(k)/sample_size;
    py(k)=ymarginals_normalization(k)/sample_size;
end;

MI_est=0;
for(k=1:nbins(1))
    for(j=1:nbins(1))
        pxy=normalized_joint_pdf(k,j);
        if(pxy~=0)
            MI_est=MI_est+pxy*log(pxy/(px(j)*py(k)));
        end;
    end;
end;
