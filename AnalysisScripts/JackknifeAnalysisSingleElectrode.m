clear all;

responseLock = 0;

% Define timepoints by sample
% if responseLock
%     windowCPP = 300:399; % 600-800 ms
%         windows = [101:125;126:150;151:175;176:200;...
%             201:225;226:250;251:275;276:300;...
%             301:325;326:350;351:375;376:400]; % 50ms intervals, -600-0ms
%     beginIndex = [51 64 77 89 102 114 127 139 152 164 177 189];
%     endIndex = [63 76 88 101 113 126 138 151 163 176 188 201];
%
%     epoch = [-800 800]; % ms
%     baseline = [-800 -600]; % ms
% else
%     windowCPP = 300:399; % 600-800 ms
%             windows = [101:125;126:150;151:175;176:200;...
%             201:225;226:250;251:275;276:300;...
%             301:325;326:350;351:375;376:400]; % 50ms intervals, 0-600ms
%     beginIndex = [51 64 77 89 102 114 127 139 152 164 177 189];
%     endIndex = [63 76 88 101 113 126 138 151 163 176 188 200];
%     epoch = [-200 600]; % ms
%     baseline = [-200 0]; % ms
% end

Pz = 31;

P34 = 11;
P78 = 12;
O12 = 13;
F34 = 2;
F78 = 3;
FC12 = 4;
FC56 = 5;

DRContraBin = 1;
DRIpsiBin = 2;
CoMContraBin = 3;
CoMIpsiBin = 4;

diffContraIpsiDRBin = 9;
diffContraIpsiCoMBin = 10;

if responseLock
    path = '~/Documents/projects/COM_EEG/Data/18-Aug-2016_RLEMBC_Datasets_Including100COH_NewID_Dir/';
else
    path = '~/Documents/projects/COM_EEG/Data/18-Aug-2016_SLEMBC_Datasets_Including100COH_NewID_Dir/';
end

cd(path);

numSubs = 10;

for sub = 1:numSubs
    
    negAreaDRTemp = [];
    negAreaCoMTemp = [];
    
    if sub < 10
    fileName = strcat('SL_GoodSubAvg_NewID_ContraIpsi_Jackknife-0',num2str(sub),'.erp');
    else
        fileName = strcat('SL_GoodSubAvg_NewID_ContraIpsi_Jackknife-',num2str(sub),'.erp');
    end
    ERP = pop_loaderp( 'filename', fileName, 'filepath', path);
    
    beginIndex = find(ERP.times == 300);
    endIndex = find(ERP.times == 596);
    zeroPt = find(ERP.times == 0);
    
    peakLatDR(sub) = min(ERP.bindata(F34,beginIndex:endIndex,diffContraIpsiDRBin))/2;
    peakLatCoM(sub) = min(ERP.bindata(F34,beginIndex:endIndex,diffContraIpsiCoMBin))/2;
    
    tempDiffDR(sub,:) = abs(ERP.bindata(F34,zeroPt:beginIndex,diffContraIpsiDRBin)-peakLatDR(sub));
    tempDiffCoM(sub,:) = abs(ERP.bindata(F34,zeroPt:beginIndex,diffContraIpsiCoMBin)-peakLatCoM(sub));
    
    idxDR(sub) = min(tempDiffDR(sub,:));
    idxCoM(sub) = min(tempDiffCoM(sub,:));

    latIndexDR(sub) = find(tempDiffDR(sub,:) == idxDR(sub))+zeroPt;
    latIndexCoM(sub) = find(tempDiffCoM(sub,:) == idxCoM(sub))+zeroPt;
    
    halfLatDR(sub) = ERP.times(latIndexDR(sub));
    halfLatCoM(sub) = ERP.times(latIndexCoM(sub));
    
end

halfLatDR = [120   116   124   112   120   120   124   120   120   124];
halfLatCoM = [288   288   288   292   288   288   284   288   292   288];

[p table] = anova_rm([halfLatDR',halfLatCoM'])

fCor = table{2,5}/((numSubs-1)^2)

fCor = 116.53;
tCor = sqrt(fCor);
p < .00001;
peakDR = 412;
peakDR = 552;
