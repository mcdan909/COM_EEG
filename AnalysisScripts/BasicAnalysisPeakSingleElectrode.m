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
    path = '~/Documents/projects/COM_EEG/Data/25-Feb-2016_RLEMBC_Datasets_Including100COH_NewID/';
    epoch = -800:800; % ms
    numSams = 400;
    numMs = 1600;
    beginIndex = find(epoch == -200);
    endIndex = find(epoch == 0);
else
    path = '~/Documents/projects/COM_EEG/Data/25-Feb-2016_SLEMBC_Datasets_Including100COH_NewID/';
    epoch = -200:600; % ms
    numSams = 200;
    numMs = 800;
    beginIndex = find(epoch == 400);
    endIndex = find(epoch == 600)-1;
end

cd(path);
%Original
goodSubList = {'302','304','305','306','308','309','311','313','314','315'};

%goodSubList = {'302','303','304','305','306','307','308','309','310','311','312','313','314','315'};
%peakCppDiff = [-4.47,-3.81,3.55,-3.56,1.55,-1.80,3.73,1.90,1.50,-1.99,9.41,-1.84,0.88,10.22];
%peakCppDiffRL = [-4.25,-3.26,1.94,-2.90,3.56,-2.29,3.42,1.75,4.30,-2.27,2.07,-1.32,0.08,12.77];

for sub = 1:length(goodSubList)
    
    negAreaDRCoMTemp = [];
    
    if responseLock
        fileName = strcat('RL',goodSubList{sub},'_ERP_Final_NewID.erp');
    else
        fileName = strcat('SL',goodSubList{sub},'_ERP_Final_NewID.erp');
    end
    
    
    
%         if sub == 8
%             DRBin = 4;
%             CoMBin = 5;
%             diffDRCoMBin = 9;
%         else
%             DRBin = 1;
%             CoMBin = 2;
%             diffDRCoMBin = 7;
%         end
    
    
    ERP = pop_loaderp( 'filename', fileName, 'filepath', path);
    numSams = ERP.pnts;
    
    cppDR(sub,:) = squeeze((ERP.bindata(Pz,:,DRBin)+ERP.bindata(Pz,:,DRBin))/2);
    cppCoM(sub,:) = squeeze((ERP.bindata(Pz,:,CoMBin)+ERP.bindata(Pz,:,CoMBin))/2);
    
    diffDRCoM(sub,:) = squeeze((ERP.bindata(Pz,:,diffDRCoMBin)+ERP.bindata(Pz,:,diffDRCoMBin))/2);
    
    interpCppDR(sub,:) = spline(1:numSams,cppDR(sub,:),1:(numSams - 1)/(numMs - 1):numSams);
    interpCppCoM(sub,:) = spline(1:numSams,cppCoM(sub,:),1:(numSams - 1)/(numMs - 1):numSams);
    
    interpDiffDRCoM(sub,:) = spline(1:numSams,diffDRCoM(sub,:),1:(numSams - 1)/(numMs - 1):numSams);
    
    peakCppDR(sub) = max(interpCppDR(sub,beginIndex:endIndex));
    peakCppCoM(sub) = max(interpCppCoM(sub,beginIndex:endIndex));
    
    peakLatCppDR(sub) = find(interpCppDR(sub,:) == peakCppDR(sub))
    peakLatCppCoM(sub) = find(interpCppCoM(sub,:) == peakCppCoM(sub))
    
    %     for tPt = 1:length(beginIndex:endIndex)
    %         if diffDRCoM(sub,tPt) > 0
    %             negAreaDRCoMTemp = [negAreaDRCoMTemp;diffDRCoM(sub,tPt)];
    %         else
    %         end
    %
    %     end
    %
    %     negAreaDRCoM(sub) = sum(negAreaDRCoMTemp)/length(beginIndex:endIndex);
    
end

[hMax pMax CImax statsMax] = ttest(peakCppDR,peakCppCoM,'tail','both')

%meanSubDR = mean(diffDRCoM,2);

%negAreaDRCoMall(:,w) = negAreaDRCoM';

