clear all;

nPerms = 10000;

responseLock = 0;

area = 1;

% Define timepoints by sample
if responseLock
    windowADAN = 250:349; % 300-500 ms
    windows = [101:125;126:150;151:175;176:200;...
        201:225;226:250;251:275;276:300;...
        301:325;326:350;351:375;376:400]; % 50ms intervals, 0-600ms
    epoch = [-800 800]; % ms
    baseline = [-800 -600]; % ms
else
    windowADAN = 250:349; % 300-500ms
    windows = [101:125;126:150;151:175;176:200;...
        201:225;226:250;251:275;276:300;...
        301:325;326:350;351:375;376:400]; % 50ms intervals, 0-600ms
    epoch = [-200 600]; % ms
    baseline = [-200 0]; % ms
end

P34 = 11;
P78 = 12;
O12 = 13;
F34 = 2;
F78 = 3;
FC12 = 4;
FC56 = 5;

diffContraIpsiDRBin = 9;
diffContraIpsiCoMBin = 10;

path = '~/Documents/projects/COM_EEG/Data/25-Feb-2016_SLEMBC_Datasets_Including100COH_NewID_ContraIpsi/';

cd(path);

ERP = pop_loaderp( 'filename', 'GoodSubAvg_NewID_ContraIpsi.erp', 'filepath', path);

for a = 1:size(windows,1)
    grandAveDR(a,:) = ERP.bindata(FC56,windows(a,:),diffContraIpsiDRBin);
    grandAveCoM(a,:) = ERP.bindata(FC56,windows(a,:),diffContraIpsiCoMBin);
    
    areaGrandAveDR(a) = sum(grandAveDR(a,grandAveDR(a,:) < 0))/size(windows,2);
    areaGrandAveCoM(a) = sum(grandAveCoM(a,grandAveCoM(a,:) < 0))/size(windows,2);
end

meanAmpDiffDR = mean(grandAveDR,2);
meanAmpDiffCoM = mean(grandAveCoM,2);

clearvars ERP;

goodSubList = {'302','304','305','306','308','309','310','313','314','315'};

% Defube event bins
LoCohDRContra = 1;
LoCohDRIpsi = 2;
LoCohCoMContra = 3;
LoCohCoMIpsi = 4;

% multiple datasets command:
% EEG = pop_loadset('filename',{'RL_302_FinalProcessedData.set' 'RL_304_FinalProcessedData.set'...
%     'RL_305_FinalProcessedData.set' 'RL_306_FinalProcessedData.set' 'RL_308_FinalProcessedData.set'...
%     'RL_309_FinalProcessedData.set' 'RL_313_FinalProcessedData.set' 'RL_314_FinalProcessedData.set'...
%     'RL_315_FinalProcessedData.set'},'filepath',path);
% EEG = eeg_checkset( EEG );
for i = 1:nPerms
    for j = 1:length(goodSubList)
        
        fileName = strcat('SL',goodSubList{j},'_FinalProcessedData5.set');
        EEG = pop_loadset('filename',fileName,'filepath',path);
        
        % Find trials of each type
        trialIndexDRContra = [EEG.event.bini] == 1;
        trialIndexDRIpsi = [EEG.event.bini] == 2;
        trialIndexCoMContra = [EEG.event.bini] == 3;
        trialIndexCoMIpsi = [EEG.event.bini] == 4;
        
        for b = 1:size(windows,1)
            % Put trials in new data matrix
            newDataDR = squeeze(EEG.data(FC56,windows(b,:),trialIndexDRContra == 1))';
            newDataDR = [newDataDR;squeeze(EEG.data(FC56,windows(b,:),trialIndexDRIpsi == 1))'];
            
            newDataCoM = squeeze(EEG.data(FC56,windows(b,:),trialIndexCoMContra == 1))';
            newDataCoM = [newDataCoM;squeeze(EEG.data(FC56,windows(b,:),trialIndexCoMIpsi == 1))'];
            
            % Create temporary index for trials
            trialTempDR = shuffle([ones(sum(trialIndexDRContra),1);2*ones(sum(trialIndexDRIpsi),1)]);
            trialTempCoM = shuffle([ones(sum(trialIndexCoMContra),1);2*ones(sum(trialIndexCoMIpsi),1)]);
            
            % Get the mean of the newly created 'DR' and 'CoM' data
            meanNewDRContra(b,:) = mean(newDataDR(trialTempDR == 1,:));
            meanNewDRIpsi(b,:) = mean(newDataDR(trialTempDR == 2,:));
            
            meanNewCoMContra(b,:) = mean(newDataCoM(trialTempCoM == 1,:));
            meanNewCoMIpsi(b,:) = mean(newDataCoM(trialTempCoM == 2,:));
            
            % Calculate new difference wave for each subject
            newDiffDR(j,b,:) = meanNewDRContra(b,:)-meanNewDRIpsi(b,:);
            newDiffCoM(j,b,:) = meanNewCoMContra(b,:)-meanNewCoMIpsi(b,:);
        end
        
    end
    
    % Get the grand average difference
    newMeanDiffDR = squeeze(mean(newDiffDR));
    newMeanDiffCoM = squeeze(mean(newDiffCoM));
    
    % Calculate positive area of the new difference wave
    for c = 1:size(windows,1)
        newAreaDR(i,c) = sum(newMeanDiffDR(c,newMeanDiffDR(c,:) < 0))/size(windows,2);
        newAreaCoM(i,c) = sum(newMeanDiffCoM(c,newMeanDiffCoM(c,:) < 0))/size(windows,2);
    end
    
    newMeanDR(i,:) = mean(newMeanDiffDR,2);
    newMeanCoM(i,:) = mean(newMeanDiffCoM,2);
end

[sortedNewAreaDR,rankNewAreaDR] = sort(newAreaDR);
[sortedNewAreaCoM,rankNewAreaCoM] = sort(newAreaCoM);

[sortedNewMeanDR,rankNewMeanDR] = sort(newMeanDR);
[sortedNewMeanCoM,rankNewMeanCoM] = sort(newMeanCoM);

% Top 5 cutoff
for c = 1:size(windows,1)
    cutoffNewAreaDR(c) = sortedNewAreaDR(.05*nPerms,c);
    cutoffNewAreaCoM(c) = sortedNewAreaCoM(.05*nPerms,c);
    
    cutoffNewMeanDR(c) = sortedNewMeanDR(.05*nPerms,c);
    cutoffNewMeanCoM(c) = sortedNewMeanCoM(.05*nPerms,c);
end

sigAreaWindowDR = areaGrandAveDR < cutoffNewAreaDR
sigAreaWindowCoM = areaGrandAveCoM < cutoffNewMeanCoM

sigMeanWindowDR = meanAmpDiffDR' < cutoffNewMeanDR
sigMeanWindowCoM = meanAmpDiffCoM' < cutoffNewMeanCoM

% hDR = histogram(newAreaDR);
% hCoM = histogram(newAreaCoM);
%
% figure(1)
% histogram(newAreaDR);
% figure(2)
% histogram(newAreaCoM);
%
% save('PermutationResultADAN');

% [nDR xbinsDR] = hist(newAreaDR);
% [nCDR xbinsCDR] = histc(newAreaDR,hDR.BinEdges);
% numBinsDR = length(nonzeros(nCDR));
%
% figure('Color',[1 1 1],'units','pixels','outerposition',[0 0 1600 1000])
% bar(-3.55:.1:-.025,nC(1:end-1),'BarWidth',1);
% hold on;
% yl = ylim;
% area([-4 -4 cutoffNewAreaDR cutoffNewAreaDR ],[yl(1) yl(2) yl(2) yl(1)],'FaceColor','y','EdgeColor','None');
% plot([areaGrandAveDR areaGrandAveDR],yl,'Color','r','LineWidth',2);
% bar(-3.55:.1:-.025,nC(1:end-1),'BarWidth',1);
% title('Negative Area','FontSize',48,'FontWeight','Normal');
% % set(gca,'Xtick',[1.8,4.8]);
% % set(gca,'XtickLabel',{'Reach','Button'},'FontSize',36);
% set(gca,'TickDir','out');
% set(gca,'FontSize',36);
% xlabel('Area Amplitude (μVms)');
% ylabel('Frequency');
% xlim([-4 0]);
% box off;
%
% [nCoM xbinsCoM] = hist(newAreaCoM);
% [nCCoM xbinsCCoM] = histc(newAreaCoM,hCoM.BinEdges);
% numBinsCoM = length(nonzeros(nCCoM));
%
% figure('Color',[1 1 1],'units','pixels','outerposition',[0 0 1600 1000])
% bar(-3.55:.1:-.025,nC(1:end-1),'BarWidth',1);
% hold on;
% yl = ylim;
% area([-4 -4 cutoffNewAreaCoM cutoffNewAreaCoM ],[yl(1) yl(2) yl(2) yl(1)],'FaceColor','y','EdgeColor','None');
% plot([areaGrandAveCoM areaGrandAveCoM],yl,'Color','r','LineWidth',2);
% bar(-3.55:.1:-.025,nC(1:end-1),'BarWidth',1);
% title('Negative Area','FontSize',48,'FontWeight','Normal');
% % set(gca,'Xtick',[1.8,4.8]);
% % set(gca,'XtickLabel',{'Reach','Button'},'FontSize',36);
% set(gca,'TickDir','out');
% set(gca,'FontSize',36);
% xlabel('Area Amplitude (μVms)');
% ylabel('Frequency');
% xlim([-4 0]);
% box off;
