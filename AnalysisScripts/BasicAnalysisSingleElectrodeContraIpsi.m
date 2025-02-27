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

goodSubList = {'302','304','305','306','308','309','311','313','314','315'};


beginIndexList = [300 352 400 452 500 548];
endIndexList = [348 400 448 500 548 596];

for w = 1:length(beginIndexList)
    for sub = 1:length(goodSubList)
        
        negAreaDRTemp = [];
        negAreaCoMTemp = [];
        
        fileName = strcat('SL',goodSubList{sub},'_ERP_Final_NewID_ContraIpsi.erp');
        ERP = pop_loaderp( 'filename', fileName, 'filepath', path);
        
        beginIndex = find(ERP.times == beginIndexList(w));
        endIndex = find(ERP.times == endIndexList(w));
        
        meanDR(sub) = mean(ERP.bindata(F34,beginIndex:endIndex,diffContraIpsiDRBin));
        meanCoM(sub) = mean(ERP.bindata(F34,beginIndex:endIndex,diffContraIpsiCoMBin));
        
        diffDR(sub,:) = ERP.bindata(F34,beginIndex:endIndex,diffContraIpsiDRBin);
        diffCoM(sub,:) = ERP.bindata(F34,beginIndex:endIndex,diffContraIpsiCoMBin);
        
        for tPt = 1:length(beginIndex:endIndex)
            if diffDR(sub,tPt) < 0
                negAreaDRTemp = [negAreaDRTemp;diffDR(sub,tPt)];
            else
            end
            if diffCoM(sub,tPt) < 0
                negAreaCoMTemp = [negAreaCoMTemp;diffCoM(sub,tPt)];
            else
            end
            
        end
        
        negAreaDR(sub) = sum(negAreaDRTemp)/length(beginIndex:endIndex);
        negAreaCoM(sub) = sum(negAreaCoMTemp)/length(beginIndex:endIndex);
        
    end
    
    meanSubDR = mean(diffDR,2);
    meanSubCoM = mean(diffCoM,2);
    
    negAreaDRall(:,w) = negAreaDR';
    negAreaCoMall(:,w) = negAreaCoM';
end
