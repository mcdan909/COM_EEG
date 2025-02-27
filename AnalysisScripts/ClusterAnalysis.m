% The idea of this code is that it runs a t-test at each time point in a
% set of data with lots of subjects across two different conditions.  You
% can easily re-write it to do a one-sample t-test against zero as well.
% It then takes the largest consecutive chunk of significant values, and
% randomly permutes the order of the observed t-values a bunch of times.  
% Then, it tells you how frequently it finds a chunk of consecutive significant 
% differences with a
% higher sum of t-values across the entire chunk.

clear all;
fileName = strcat('FILEPATHHERE');
load(fileName);
% This is looking for a 2x2 matrix in which each row is a different subject, 
% each column is a different timepoint, and the values are voltage data
% each column is
Scores1 = VARIABLENAMEHERE;
fileName = strcat('FILEPATHHERE');
load(fileName);
Scores2 = VARIABLENAMEHERE;
% The above assumes you are comparing two different sets of waveforms

numPerms = 10000; %Set your number of permutations

% Plot the data
figure;
plot(mean(Scores1),'r');
hold on;
plot(mean(Scores2),'g');


% Sets the t value threshold - IMPORTANT: NEED TO CHANGE TO APPROPRIATE
% CRITICAL T VALUE FOR THE NUMBER OF SUBJECTS.  Alternatively, the code
% could be written to use the bulid in ttest function, I think.
setTValThreshold = 2.131;

% First, calculate t-values, threshold calculations at each of however many timepoints
[allThresh,allPValues,throwaway,allValues] = ttest(Scores1(:,1:end),Scores2(:,1:end));

%change AllThresh to a new T-threshold, if you want.  Can't remember why I
%put this here - you might not need it, if you trust the built in threshold
%from the t-test
allThresh = (abs(allValues.tstat) > setTValThreshold);

[mainClusterSize, summedClusterValue,  clusterStart,clusterEnd] = findMyCluster(allThresh,allValues.tstat,1);



% Next, randomly permute the threshold calculations 1000 times to create a
% distribution of the largest clusters. Could instead shuffle the actual
% values in some way by adding a few lines of code (including a line to
% conduct additional t-tests).
summedClusterDist = [];
for i = 1:numPerms
    tempNewOrder = randperm(size(Scores1,2));    
    [mainClusterSize, summedClusterDist(i)] = findMyCluster(allThresh(tempNewOrder),allValues.tstat(tempNewOrder),1); 
end

% Find the number of times that the cluster value from the random
% permutation is higher than the observed value
'P value for actually observed cluster size is...'
pVal = length(find(summedClusterDist > summedClusterValue))/length(summedClusterDist)

clusterStart
clusterEnd