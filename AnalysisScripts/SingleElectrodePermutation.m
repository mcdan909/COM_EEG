clear all;

nPerms = 100;

responseLock = 0;

% Define timepoints by sample
if responseLock
    windowCPP = 126:200; % 600-800 ms
    windowDFN = 100:149; % 150-250 ms
    epoch = -800:800; % ms
    baseline = [-800 -600]; % ms
    numMs = 1600;
else
    windowCPP = 126:199; % 600-800 ms
    windowDFN = 100:149; % 150-250 ms
    epoch = -200:600; % ms
    baseline = [-200 0]; % ms
    numMs = 800;
end

CP1 = 8;
CP2 = 22;
Cz = 30;
Pz = 31;
F3 = 2;
F4 = 16;

DRBin = 1;
CoMBin = 2;
DiffDRCoMBin = 7;

if responseLock
    path = '~/Documents/projects/COM_EEG/Data/25-Feb-2016_RLEMBC_Datasets_Including100COH_NewID/';
else
    path = '~/Documents/projects/COM_EEG/Data/25-Feb-2016_SLEMBC_Datasets_Including100COH_NewID/';
end

cd(path);

if responseLock
    ERP = pop_loaderp( 'filename', 'RL_GoodSubAvg_NewID.erp', 'filepath', path);
    windowCPP = find(ERP.times == -300):find(ERP.times == 0); % 300-500ms
else
    ERP = pop_loaderp( 'filename', 'SL_GoodSubAvg_NewID.erp', 'filepath', path);
    windowCPP = find(ERP.times == 300):find(ERP.times == 596); % 300-500ms
end

grandAveCPP = ERP.bindata(Pz,windowCPP,DiffDRCoMBin);
grandAveDRL = ERP.bindata(F3,windowDFN,DRBin);
grandAveDRR = ERP.bindata(F4,windowDFN,DRBin);
grandAveCoML = ERP.bindata(F3,windowDFN,CoMBin);
grandAveCoMR = ERP.bindata(F4,windowDFN,CoMBin);

grandAveDRDiff = grandAveDRR-grandAveDRL;
grandAveCoMDiff = grandAveCoMR-grandAveCoML;


areaGrandAveCPP = sum(grandAveCPP(grandAveCPP > 0))/length(windowCPP);

clearvars ERP;

goodSubList = {'302','304','305','306','308','309','311','313','314','315'};

% Defube event bins
LoCohDR = 1;
LoCohCoM = 2;

for sub = 1:length(goodSubList)
    
%     if sub == 8
%         DiffDRCoMBin = 9;
%     else
%         DiffDRCoMBin = 7;
%     end
    if responseLock
        erpName = strcat('RL',goodSubList{sub},'_ERP_Final_NewID.erp');
    else
        erpName = strcat('SL',goodSubList{sub},'_ERP_Final_NewID.erp');
    end
    
    ERP = pop_loaderp( 'filename', erpName,'filepath', path);
    
    groupLoCohDRCoMDiff(sub,:,:) = ERP.bindata(:,:,DiffDRCoMBin);
end

sub = [];

%groupLoCohDRCoMDiff = groupLoCohDR-groupLoCohCoM;

cppLoCohDRCoMDiff = squeeze((groupLoCohDRCoMDiff(:,Cz,:)+groupLoCohDRCoMDiff(:,Pz,:))/2);

%cppLoCohDRCoMDiff = squeeze((groupLoCohDRCoMDiff(:,Cz,:)+groupLoCohDRCoMDiff(:,CP1,:)+groupLoCohDRCoMDiff(:,CP2,:))/4);

timePts = 1:size(groupLoCohDRCoMDiff,3);

for sub = 1:length(goodSubList)
    interpLoCohDRCoMDiff(sub,:) = spline(timePts,squeeze(groupLoCohDRCoMDiff(sub,Pz,:))',1:((length(timePts) - 1)/(numMs - 1)):length(timePts));
    
    cppInterpLoCohDRCoMDiff(sub,:) = spline(timePts,squeeze(cppLoCohDRCoMDiff(sub,:))',1:((length(timePts) - 1)/(numMs - 1)):length(timePts));
    
    subBaseDRCoM(sub) = mean(interpLoCohDRCoMDiff(sub,1:200),2);
    
    cppSubBaseDRCoM(sub) = mean(cppInterpLoCohDRCoMDiff(sub,1:200),2);
end

for t = 1:numMs
    [hDRCoM(t) pDRCoM(t) CIDRCoM(t,:) statsDRCoM(t)] = ttest(zeros(length(goodSubList),1),cppInterpLoCohDRCoMDiff(:,t),'tail','right');
    
    tDRCoM(t) = statsDRCoM(t).tstat;
end

tOneTail = 1.833; 	
tTwoTail = 2.262;

% 11 subs
%tOneTail = 1.812;
%tTwoTail = 2.228;

if responseLock
    cppMsWindow = 400:800;
    cppSamples = 400;
    cppStartMs = -401;
else
    cppMsWindow = 500:800;
    cppSamples = 300;
    cppStartMs = 301;
end

[mainClusterSizeDRCoM, summedClusterValueDRCoM,  clusterStartDRCoM,clusterEndDRCoM] = findMyCluster(hDRCoM(cppMsWindow),tDRCoM(cppMsWindow),1);

if clusterEndDRCoM > cppSamples
    clusterEndDRCoM = cppSamples;
    mainClusterSizeDRCoM = clusterEndDRCoM-clusterStartDRCoM;
    summedClusterValueDRCoM = sum(tCoM(cppMsWindow(1)+clusterStartDRCoM:cppMsWindow(1)+clusterEndCoM));
end

for p = 1:nPerms
    tempNewOrder = randperm(cppSamples)+cppMsWindow(1);    
    [mainClusterSizeDRCoMtemp, summedClusterDistDRCoM(p)] = findMyCluster(hDRCoM(tempNewOrder),tDRCoM(tempNewOrder),1); 
end

pDRCoM = sum(summedClusterDistDRCoM < summedClusterValueDRCoM)/nPerms

clusterStartDRCoMms = cppStartMs+clusterStartDRCoM

clusterEndDRCoMms = cppStartMs+clusterEndDRCoM

clusts = find(hDRCoM == 1);
sigClusts = epoch(clusts)

%plot(1:length(cppInterpLoCohDRCoMDiff),cppInterpLoCohDRCoMDiff);

%%
% multiple datasets command:
% EEG = pop_loadset('filename',{'RL_302_FinalProcessedData.set' 'RL_304_FinalProcessedData.set'...
%     'RL_305_FinalProcessedData.set' 'RL_306_FinalProcessedData.set' 'RL_308_FinalProcessedData.set'...
%     'RL_309_FinalProcessedData.set' 'RL_313_FinalProcessedData.set' 'RL_314_FinalProcessedData.set'...
%     'RL_315_FinalProcessedData.set'},'filepath',path);
% EEG = eeg_checkset( EEG );
for i = 1:nPerms
    for j = 1:length(goodSubList)
        
        if responseLock
            fileName = strcat('RL_',goodSubList{j},'_FinalProcessedData.set');
        else
            fileName = strcat('SL_',goodSubList{j},'_FinalProcessedData.set');
        end
        EEG = pop_loadset('filename',fileName,'filepath',path);
        
        % Find trials of each type
        trialIndexDR = [EEG.event.bini] == 1;
        trialIndexCoM = [EEG.event.bini] == 2;
        
        % Put trials in new data matrix
        newData = squeeze(EEG.data(Pz,windowCPP,trialIndexDR == 1))';
        newData = [newData;squeeze(EEG.data(Pz,windowCPP,trialIndexCoM == 1))'];
        
        % Create temporary index for trials
        trialTemp = shuffle([ones(sum(trialIndexDR),1);2*ones(sum(trialIndexCoM),1)]);
        
        % Get the mean of the newly created 'DR' and 'CoM' data
        meanNewDR = mean(newData(trialTemp == 1,:));
        meanNewCoM = mean(newData(trialTemp == 2,:));
        
        % Calculate new difference wave for each subject
        newDiff(j,:) = meanNewDR-meanNewCoM;
        
        
        
        %     areaGrandAveNewPerm = sum(grandAveCPP(grandAveCPP > 0));
        %
        %     EEG = epoch2continuous(EEG);
        %
        %     EEG = pop_eventshuffler(EEG, 'Values', [1 2], 'Field', 'bini');
        %
        %     EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist',...
        %         strcat('~/Documents/projects/COM_EEG/RawData/',goodSubList{i},'/',goodSubList{i},'_elist_NewIDPerm.txt') );
        %     EEG = eeg_checkset( EEG );
        %
        %     EEG  = pop_binlister( EEG , 'BDF', '~/Documents/projects/COM_EEG/PreprocessingScripts/globalBinsNewIDPerm.txt', 'ExportEL', ...
        %             strcat('~/Documents/projects/COM_EEG/RawData/',goodSubList{i},'/',goodSubList{i},'_elist_binned_NewIDPerm.txt'),...
        %             'Ignore', -99, 'IndexEL',  1, 'SendEL2', 'All', 'UpdateEEG', 'on', 'Voutput', 'EEG' );
        %
        %     EEG = pop_epochbin( EEG , epoch,  baseline);
        %     EEG = eeg_checkset( EEG );
        %
        %     ERP = pop_averager( EEG , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );
        %
        %     % Apply Lo-Pass Filter to ERPs (30 Hz) & remove DC bias
        %     % for plotting
        %     ERP = pop_filterp( ERP,  1:35 , 'Cutoff',  30, 'Design', 'butter', 'Filter', 'lowpass', 'Order',  2 );
        %
        %     ERP = pop_binoperator( ERP, {  'b7 = b1 - b2 label DR-CoM_LoCohDiff',  'b8 = b2 - b1 label CoM-DR_LoCohDiff',  'b9 = b4 - b5 label DR-CoM_HiCohDiff',...
        %         'b10 = b5 - b4 label CoM-DR_HiCohDiff'});
        
        %grandAveCPP = ERP.bindata(Pz,windowCPP,DiffDRCoMBin);
        
        %areaCPP(i) = polyarea(1:length(grandAveCPP),grandAveCPP)
    end
    
    % Get the grand average difference
    newMeanDiff(i) = mean(newDiff(i));
    
    % Calculate positive area of the new difference wave
    newAreaCPP(i) = sum(newMeanDiff(newMeanDiff > 0))/length(windowCPP);
end

pctGreaterObservedMean = sum(newMeanDiff > areaGrandAveCPP)/length(newMeanDiff)

pctGreaterObserved = sum(newAreaCPP > areaGrandAveCPP)/length(newAreaCPP);

[sortedNewMeanCPP,rankNewMeanCPP] = sort(newMeanDiff);
[sortedNewAreaCPP,rankNewAreaCPP] = sort(newAreaCPP);

% Top 5 cutoff
cutoffNewMeanCPP = sortedNewMeanCPP(.95*nPerms);
cutoffNewAreaCPP = sortedNewAreaCPP(.95*nPerms);

h = histogram(newAreaCPP);

save('PermutationResultCPP');

[n xbins] = hist(newAreaCPP);
[nC xbinsC] = histc(newAreaCPP,0:.05:2.65);
numBins = length(nonzeros(nC));

figure('Color',[1 1 1],'units','pixels','outerposition',[0 0 1600 1000])
bar(.025:.05:2.625,nC(1:end-1),'BarWidth',1);
hold on;
yl = ylim;
area([cutoffNewAreaCPP cutoffNewAreaCPP 3 3],[yl(1) yl(2) yl(2) yl(1)],'FaceColor','y','EdgeColor','None');
plot([areaGrandAveCPP areaGrandAveCPP],yl,'Color','r','LineWidth',2);
bar(.025:.05:2.625,nC(1:end-1),'BarWidth',1);
title('Positive Area','FontSize',48,'FontWeight','Normal');
% set(gca,'Xtick',[1.8,4.8]);
% set(gca,'XtickLabel',{'Reach','Button'},'FontSize',36);
set(gca,'TickDir','out');
set(gca,'FontSize',36);
xlabel('Area Amplitude (μVms)');
ylabel('Frequency');
box off;


