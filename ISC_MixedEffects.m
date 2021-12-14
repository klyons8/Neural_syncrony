%%% ISC group level stats
% Kathleen Lyons
%Last modified Dec 13, 2021

clc; clear all

%Load the data
OldHigh = load('Old_High_fisherR.mat');
OldLow = load('Old_Low_fisherR.mat');
YoungHigh = load('Young_High_fisherR.mat');
YoungLow = load('Young_Low_fisherR.mat');

%How many ROIs?
roi = 7;
roiRow = roi+1;


%Adding group names to do regression models
string1 = 'High';
string2 = 'Low';
Age1 = 'Old';
Age2 = 'Young';

for i = 1:size(OldHigh.fisherR_comb,1)
    OldHigh.fisherR_comb{i,9} = string1;
    OldHigh.fisherR_comb{i,10} = Age1;
    
end

for i = 1:size(YoungHigh.fisherR_comb,1)
    YoungHigh.fisherR_comb{i,9} = string1;
    YoungHigh.fisherR_comb{i,10} = Age2;
end

for i = 1:size(OldLow.fisherR_comb,1)
    OldLow.fisherR_comb{i,9} = string2;
    OldLow.fisherR_comb{i,10} = Age1;
end

for i = 1:size(YoungLow.fisherR_comb,1)
    YoungLow.fisherR_comb{i,9} = string2;
    YoungLow.fisherR_comb{i,10} = Age2;
end

%Concatonate datafiles
ISCdat = [OldHigh.fisherR_comb; OldLow.fisherR_comb; YoungHigh.fisherR_comb;YoungLow.fisherR_comb];

%Currently a cell, need to be a matrix for grpstats & lme
T = cell2table(ISCdat,'VariableNames',{'Participant', 'Visual','Somatosensory','Dorsal','Ventral','Limbic','FP','Default', 'IQgroup', 'AgeGroup'});


%This gives us our group stats, you can add whatever other stats (min, max,
%etc) 
statarray = grpstats(T(:,2:10),{'AgeGroup', 'IQgroup'}, {'mean', 'std'});

%Making our matrix long instead of wide for the full model
LongT = stack(T,{'Visual','Somatosensory','Dorsal','Ventral','Limbic','FP','Default'},...
     'NewDataVariableName','ISC',...
     'IndexVariableName','Network');
 
%Do the groups differ in their degree of ISC? Are there network by age by
%IQ interactions?
lme = fitlme(LongT,'ISC~AgeGroup * IQgroup * Network+(1|Participant)','FitMethod','REML','DummyVarCoding','effects');
anova(lme)
atlas = {'Visual','Somatosensory','Dorsal','Ventral','Limbic','FP','Default'};


%Print out predictors p values for each network seperately
for i = 1:size(atlas,2)
    b = {atlas{i}, 'IQgroup', 'AgeGroup'};
    T_mod = T(:,b);
    Model = sprintf('%s ~ AgeGroup * IQgroup', atlas{i});
    lme = fitlme(T_mod,Model, 'DummyVarCoding', 'effects');
    anova(lme)
end



