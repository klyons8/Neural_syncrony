%%% Calculating ISC by ROI %%%
% Kathleen Lyons (last updated Dec 10 2021)

% Takes the mean timecourse for that ROI for each participant, and
%   calculate a leave one out correlation for every participant with the
%   mean of their group
%   Then we fisher transforms the r values to normalize 

%  NOTES:
%   -Can have multiple groups
%   -Can have multiple ROIs
%   -Current data structure is each participant has a folder with their mat
%   file in it 
%   - this matfile has the time course for each ROI (among other
%   information). The time course is saved under filename.mean currently
%   -Timecourse should be pre-processed prior to running this analysis


clear all; clc

localpath = "/Volumes/T7/IQ_roi/" ;
cd(localpath);

%Variables to change
numROI = 7; %This could be the number of channels too (for fNIRS)
atlas = {'Visual','Somatosensory','Dorsal  Attention','Ventral Attention','Limbic','FP','Default'};
nt = 1;
Groups = 2;
Age = 2;
GroupName = ["Low", "High"];
AgeName = ["Young", "Old"];
TR = 745; %The number of time points you have
filename = 'ROI_epi.mat';

for a = 1:Age
    for g = 1:Groups
        
        datpath = sprintf("%s%s_%s/copied_ROI/", localpath, AgeName(a), GroupName(g));
        cd(datpath);
        IDs = dir(sprintf('*ND*'));
        IDs = IDs';
        N = length(IDs);
        SubName = {IDs.name}';
        
        %Loop to load the data
        selroi = NaN(TR, N);
        selroi_ROI = cell(1,numROI);
        selroi_ROI(:,1:numROI) = {NaN(TR, N)};
        currroicorr = NaN(1,N);
        roicorr = NaN(numROI, N);
        roicorr_fish = NaN(numROI, N);
        
        for roi = 1:numROI
            for i = 1:N
                ddir =sprintf("%s%s/", datpath, IDs(i).name);
                cd(ddir);
                load(filename)
                currdat = ROI(roi).mean;
                selroi(:,i) = currdat;
            end
            selroi_ROI{roi} = selroi;
        end
        
        %Leave one out correlations
        
        for roiid = 1:numROI
            for sid = 1:N
                others = setdiff([1:N],sid);
                currroicorr(:,sid) = nancorr(selroi_ROI{1, roiid}(:,sid),nanmean(selroi_ROI{1, roiid}(:,others),2))';
                roicorr(roiid,sid) = currroicorr(:, sid);
            end
        end
        
        %Fisher transform
        
        for roiid = 1:numROI
            for sub = 1:N
                roicorr_fish(roiid,sub) = .5*log((1+roicorr(roiid, sub))/(1-roicorr(roiid, sub)));
            end
        end
        
        %Save datafile
        fisherR_cell = num2cell(roicorr_fish, 3)';
        fisherR_comb = [SubName, fisherR_cell];
        cd(localpath);
        nameFisherR = sprintf('%s_%s_fisherR.mat', AgeName(a), GroupName(g));
        nameR = sprintf('%s_%s_R.mat', AgeName(a), GroupName(g));
        save(nameFisherR, 'fisherR_comb');
        save(nameR, 'roicorr');
        
    end
end

    
    

    
   