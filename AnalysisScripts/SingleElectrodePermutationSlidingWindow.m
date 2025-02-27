clear all;

nPerms = 100;

responseLock = 1;

% Define timepoints by sample
if responseLock
    %windowCPP = 300:399; % 600-800 ms
    %     windows = [101:125;126:150;151:175;176:200;...
    %         201:225;226:250;251:275;276:300;...
    %         301:325;326:350;351:375;376:400]; % 50ms intervals, -600-0ms
    beginIndex = [51 64 77 89 102 114 127 139 152 164 177 189];
    endIndex = [63 76 88 101 113 126 138 151 163 176 188 201];
    
    epoch = [-800 800]; % ms
    baseline = [-800 -600]; % ms
else
    %windowCPP = 300:399; % 600-800 ms
    %         windows = [101:125;126:150;151:175;176:200;...
    %         201:225;226:250;251:275;276:300;...
    %         301:325;326:350;351:375;376:400]; % 50ms intervals, 0-600ms
    beginIndex = [51 64 77 89 102 114 127 139 152 164 177 189];
    endIndex = [63 76 88 101 113 126 138 151 163 176 188 201];
    epoch = [-200 600]; % ms
    baseline = [-200 0]; % ms
end

Pz = 31;
F3 = 2;
F4 = 16;

DRBin = 1;
CoMBin = 2;
DiffDRCoMBin = 7;

if responseLock
    path = '~/Documents/projects/COM_EEG/Data/18-Aug-2016_RLEMBC_Datasets_Including100COH_NewID/';
else
    path = '~/Documents/projects/COM_EEG/Data/18-Aug-2016_SLEMBC_Datasets_Including100COH_NewID/';
end

cd(path);

if responseLock
    ERP = pop_loaderp( 'filename', 'RL_GoodSubAvg_NewID.erp', 'filepath', path);
else
    ERP = pop_loaderp( 'filename', 'SL_GoodSubAvg_NewID.erp', 'filepath', path);
end

for a = 1:length(beginIndex)
    grandAveCPP{a} = ERP.bindata(Pz,beginIndex(a):endIndex(a),DiffDRCoMBin);
    grandAveDRL{a} = ERP.bindata(F3,beginIndex(a):endIndex(a),DRBin);
    grandAveDRR{a} = ERP.bindata(F4,beginIndex(a):endIndex(a),DRBin);
    grandAveCoML{a} = ERP.bindata(F3,beginIndex(a):endIndex(a),CoMBin);
    grandAveCoMR{a} = ERP.bindata(F4,beginIndex(a):endIndex(a),CoMBin);
    
    grandAveDRDiff{a} = grandAveDRR{a}-grandAveDRL{a};
    grandAveCoMDiff{a} = grandAveCoMR{a}-grandAveCoML{a};
end

%areaGrandAveCPP = sum(grandAveCPP(grandAveCPP > 0))/length(windowCPP);

meanAmpDiffCPP = mean(grandAveCPP,2);
meanAmpDiffDR = mean(grandAveDRDiff,2);
meanAmpDiffCoM = mean(grandAveCoMDiff,2);

clearvars ERP;

goodSubList = {'302','304','305','306','308','309','310','311','313','314','315',};

% Defube event bins
LoCohDR = 1;
LoCohCoM = 2;


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
        for b = 1:length(beginIndex)
            newDataCPP = squeeze(EEG.data(Pz,beginIndex(b):endIndex(b),trialIndexDR == 1))';
            newDataCPP = [newDataCPP;squeeze(EEG.data(Pz,beginIndex(b):endIindex(b),trialIndexCoM == 1))'];
            
            newDataDR = squeeze(EEG.data(F3,beginIndex(b):endIndex(b),trialIndexDR == 1))';
            newDataDR = [newDataDR;squeeze(EEG.data(F4,beginIndex(b):endIindex(b),trialIndexDR == 1))'];
            
            newDataCoM = squeeze(EEG.data(F3,beginIndex(b):endIndex(b),trialIndexCoM == 1))';
            newDataCoM = [newDataDR;squeeze(EEG.data(F4,beginIndex(b):endIindex(b),trialIndexCoM == 1))'];
            %newWindowDataCPP(b,:,:) = newDataCPP;
            
            % Create temporary index for trials
            trialTempCPP = shuffle([ones(sum(trialIndexDR),1);2*ones(sum(trialIndexCoM),1)]);
            trialTempDR = shuffle([ones(sum(trialIndexDR),1);2*ones(sum(trialIndexDR),1)]);
            trialTempCoM = shuffle([ones(sum(trialIndexCoM),1);2*ones(sum(trialIndexCoM),1)]);
            
            % Get the mean of the newly created 'DR' and 'CoM' data
            meanNewDRCPP(b,:) = mean(newDataCPP(trialTempCPP == 1,:));
            meanNewCoMCPP(b,:) = mean(newDataCPP(trialTempCPP == 2,:));
            
            meanNewDRL(b,:) = mean(newDataDR(trialTempDR == 1,:));
            meanNewDRR(b,:) = mean(newDataDR(trialTempDR == 2,:));
            
            meanNewCoML(b,:) = mean(newDataCoM(trialTempCoM == 1,:));
            meanNewCoMR(b,:) = mean(newDataCoM(trialTempCoM == 2,:));
            
            newDiffCPP(j,b,:) = meanNewDRCPP(b,:)-meanNewCoMCPP(b,:);
            newDiffDR(j,b,:) = meanNewDRL(b,:)-meanNewDRR(b,:);
            newDiffCoM(j,b,:) = meanNewCoML(b,:)-meanNewCoMR(b,:);
        end
        
    end
    
    % Get the grand average difference
    newMeanDiffCPP = squeeze(mean(newDiffCPP));
    newMeanDiffDR = squeeze(mean(newDiffDR));
    newMeanDiffCoM = squeeze(mean(newDiffCoM));
    
    % Calculate mean of the new difference wave
    %newAreaCPP(i,b) = sum(newMeanDiffCPP(newMeanDiffCPP > 0))/size(windows,2);
    newMeanCPP(i,:) = mean(newMeanDiffCPP,2);
    newMeanDR(i,:) = mean(newMeanDiffDR,2);
    newMeanCoM(i,:) = mean(newMeanDiffCoM,2);
    
    
end

[sortedNewMeanCPP,rankNewMeanCPP] = sort(newMeanCPP);
[sortedNewMeanDR,rankNewMeanDR] = sort(newMeanDR);
[sortedNewMeanCoM,rankNewMeanCoM] = sort(newMeanCoM);

% Top 5 cutoff
for c = 1:size(windows,1)
    cutoffNewMeanCPP(c) = sortedNewMeanCPP(.95*nPerms,c);
    cutoffNewMeanDR(c) = sortedNewMeanDR(.05*nPerms,c);
    cutoffNewMeanCoM(c) = sortedNewMeanCoM(.05*nPerms,c);
end

sigWindowCPP = meanAmpDiffCPP' > cutoffNewMeanCPP
sigWindowDR = meanAmpDiffDR' < cutoffNewMeanDR
sigWindowCoM = meanAmpDiffCoM' < cutoffNewMeanCoM

% h = histogram(newAreaCPP);
%
% save('PermutationResultCPP');
%
% [n xbins] = hist(newAreaCPP);
% [nC xbinsC] = histc(newAreaCPP,0:.05:2.65);
% numBins = length(nonzeros(nC));
%
% figure('Color',[1 1 1],'units','pixels','outerposition',[0 0 1600 1000])
% bar(.025:.05:2.625,nC(1:end-1),'BarWidth',1);
% hold on;
% yl = ylim;
% area([cutoffNewAreaCPP cutoffNewAreaCPP 3 3],[yl(1) yl(2) yl(2) yl(1)],'FaceColor','y','EdgeColor','None');
% plot([areaGrandAveCPP areaGrandAveCPP],yl,'Color','r','LineWidth',2);
% bar(.025:.05:2.625,nC(1:end-1),'BarWidth',1);
% title('Positive Area','FontSize',48,'FontWeight','Normal');
% set(gca,'Xtick',[1.8,4.8]);
% set(gca,'XtickLabel',{'Reach','Button'},'FontSize',36);
% set(gca,'TickDir','out');
% set(gca,'FontSize',36);
% xlabel('Area Amplitude (μVms)');
% ylabel('Frequency');
% box off;


