clear all;

responseLock = 1;

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

Cz = 30;
Pz = 31;

DRBin = 1;
CoMBin = 2;
diffDRCoMBin = 5;

if responseLock
    path = '~/Documents/projects/COM_EEG/Data/18-Aug-2016_RLEMBC_Datasets_Including100COH_NewID/';
else
    path = '~/Documents/projects/COM_EEG/Data/18-Aug-2016_SLEMBC_Datasets_Including100COH_NewID/';
end

cd(path);

goodSubList = {'304','305','306','307','308','309','311','313','314','315'};


for sub = 1:length(goodSubList)
    
    negAreaDRCoMTemp = [];
    
    fileName = strcat('SL',goodSubList{sub},'_ERP_Final_NewID.erp');
    ERP = pop_loaderp( 'filename', fileName, 'filepath', path);
    
    beginIndex = find(ERP.times == beginIndexList(w));
    endIndex = find(ERP.times == endIndexList(w));
    
    diffDRCoM(sub,:) = ERP.bindata(Pz,beginIndex:endIndex,diffDRCoMBin);
    
    for tPt = 1:length(beginIndex:endIndex)
        if diffDRCoM(sub,tPt) > 0
            negAreaDRCoMTemp = [negAreaDRCoMTemp;diffDRCoM(sub,tPt)];
        else
        end
        
    end
    
    negAreaDRCoM(sub) = sum(negAreaDRCoMTemp)/length(beginIndex:endIndex);
    
end

meanSubDR = mean(diffDRCoM,2);

negAreaDRCoMall(:,w) = negAreaDRCoM';


