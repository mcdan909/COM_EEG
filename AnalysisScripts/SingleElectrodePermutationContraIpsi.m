clear all;

nPerms = 100;

responseLock = 0;

% Define timepoints by sample
% if responseLock
%     windowADAN = 126:176; % 300-500 ms
%     windowADAN = 200:249; % 200-300 ms, N2pc
%     epoch = [-800 800]; % ms
%     baseline = [-800 -600]; % ms
% else
%     windowADAN = 126:176; % 300-500ms
%     windowADAN = 200:249; % 200-300 ms, N2pc
%     epoch = [-200 600]; % ms
%     baseline = [-200 0]; % ms
% end

P34 = 11;
P78 = 12;
O12 = 13;
F34 = 2;
F78 = 3;
FC12 = 4;
FC56 = 5;

diffContraIpsiDRBin = 9;
diffContraIpsiCoMBin = 10;

path = '~/Documents/projects/COM_EEG/Data/18-Aug-2016_SLEMBC_Datasets_Including100COH_NewID_Dir/';

cd(path);

ERP = pop_loaderp( 'filename', 'SL_GoodSubAvg_NewID_ContraIpsi.erp', 'filepath', path);

beginIndex = find(ERP.times == 300);
endIndex = find(ERP.times == 448);
windowADAN = beginIndex:endIndex;

grandAveDR = ERP.bindata(F34,windowADAN,diffContraIpsiDRBin);
grandAveCoM = ERP.bindata(F34,windowADAN,diffContraIpsiCoMBin);

areaGrandAveDR = sum(grandAveDR(grandAveDR < 0))*length(windowADAN);
areaGrandAveCoM = sum(grandAveCoM(grandAveCoM < 0))*length(windowADAN);

clearvars ERP;

goodSubList = {'302','304','305','306','308','309','311','313','314','315'};

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
        
        fileName = strcat('SL',goodSubList{j},'_FinalProcessedDataContraIpsi.set');
        EEG = pop_loadset('filename',fileName,'filepath',path);
        
        % Find trials of each type
        trialIndexDRContra = [EEG.event.bini] == 1;
        trialIndexDRIpsi = [EEG.event.bini] == 2;
        trialIndexCoMContra = [EEG.event.bini] == 3;
        trialIndexCoMIpsi = [EEG.event.bini] == 4;
        
        % Put trials in new data matrix
        newDataDR = squeeze(EEG.data(F34,windowADAN,trialIndexDRContra == 1))';
        newDataDR = [newDataDR;squeeze(EEG.data(F34,windowADAN,trialIndexDRIpsi == 1))'];
        
        newDataCoM = squeeze(EEG.data(F34,windowADAN,trialIndexCoMContra == 1))';
        newDataCoM = [newDataCoM;squeeze(EEG.data(F34,windowADAN,trialIndexCoMIpsi == 1))'];
        
        % Create temporary index for trials
        trialTempDR = shuffle([ones(sum(trialIndexDRContra),1);2*ones(sum(trialIndexDRIpsi),1)]);
        
        trialTempCoM = shuffle([ones(sum(trialIndexCoMContra),1);2*ones(sum(trialIndexCoMIpsi),1)]);
        
        % Get the mean of the newly created 'DR' and 'CoM' data
        meanNewDRContra = mean(newDataDR(trialTempDR == 1,:));
        meanNewDRIpsi = mean(newDataDR(trialTempDR == 2,:));
       
        meanNewCoMContra = mean(newDataCoM(trialTempCoM == 1,:));
        meanNewCoMIpsi = mean(newDataCoM(trialTempCoM == 2,:));
        
        % Calculate new difference wave for each subject
        newDiffDR(j,:) = meanNewDRContra-meanNewDRIpsi;
        newDiffCoM(j,:) = meanNewCoMContra-meanNewCoMIpsi;
        
        
        
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
    newMeanDiffDR = mean(newDiffDR);
    newMeanDiffCoM = mean(newDiffCoM);
    
    % Calculate positive area of the new difference wave
    newAreaDR(i) = sum(newMeanDiffDR(newMeanDiffDR < 0))*length(windowADAN);
    
    newAreaCoM(i) = sum(newMeanDiffCoM(newMeanDiffCoM < 0))*length(windowADAN);
    
    newMeanDR(i) = mean(newMeanDiffDR);
    newMeanCoM(i) = mean(newMeanDiffCoM);
end

pctGreaterObservedDR = sum(newAreaDR > areaGrandAveDR)/length(newAreaDR);
pctGreaterObservedCoM = sum(newAreaCoM > areaGrandAveCoM)/length(newAreaCoM);

[sortedNewAreaDR,rankNewAreaDR] = sort(newAreaDR);
[sortedNewAreaCoM,rankNewAreaCoM] = sort(newAreaCoM);

[sortedNewMeanDR,rankNewMeanDR] = sort(newMeanDR);
[sortedNewMeanCoM,rankNewMeanCoM] = sort(newMeanCoM);

% Top 5 cutoff
cutoffNewAreaDR = sortedNewAreaDR(.05*nPerms)
cutoffNewAreaCoM = sortedNewAreaCoM(.05*nPerms)

cutoffNewMeanDR = sortedNewMeanDR(.05*nPerms)
cutoffNewMeanCoM = sortedNewMeanCoM(.05*nPerms)

hDR = histogram(newAreaDR);
hCoM = histogram(newAreaCoM);

figure(1)
histogram(newAreaDR);
figure(2)
histogram(newAreaCoM);

%save('PermutationResultADAN');

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
