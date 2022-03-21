clear all;

HEOG = 34;
zeroPt = 151;

path = '~/Documents/projects/COM_EEG/Data/18-Aug-2016_RLEMBC_Datasets_Including100COH_NewID_Dir/';

goodSubList = {'302','304','305','306','308','309','311','313','314','315'};

for sub = 1:length(goodSubList)
    
    fileName = strcat('RL',goodSubList{sub},'_ERP_Final_NewID_Dir.erp');
    ERP = pop_loaderp( 'filename', fileName, 'filepath', path);
    
    meanL(sub,:) = (ERP.bindata(HEOG,:,1)+ERP.bindata(HEOG,:,2))/2;
    meanR(sub,:) = (ERP.bindata(HEOG,:,3)+ERP.bindata(HEOG,:,4))/2;
    
    maxL(sub) = max(meanL(1:zeroPt));
    maxR(sub) = max(meanR(1:zeroPt));
    
    minL(sub) = abs(min(meanL(1:zeroPt)));
    minR(sub) = abs(min(meanR(1:zeroPt)));

end

maxSubL = max(maxL,minL)
maxSubR = max(maxR,minR)