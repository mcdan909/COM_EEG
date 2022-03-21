%% Combine electrodes component ROIs and create a grand average dataset

clear all;

% Response locked or stim locked data?
respLock = 1;
endLock = 0;
feedLock = 0;

% Use FT wide window datasets?
FT = 0;
filtType = 0; % 0 = noLPF, 1 = LPF, 2 = Smooth

% goodSubs = {'302','304','305','306','307','308','309','310','311','313','314','315'};
goodSubs = {'302','304','305','306','308','309','311','313','314','315'};

% change prefix for dataset type
if respLock
    prefix = 'RL';
elseif endLock
    prefix = 'EL';
elseif feedLock
    prefix = 'FL';
else
    prefix = 'SL';
end

% change suffix depending on whether using the wide window dataset for the
% TF analysis or the regular epoched data
if FT
    suffix = '_FT';
else
    suffix = '';
end

if filtType == 0
    filt = '';
elseif filtType == 1 % LPF
    filt = '_LPF';
elseif filtType == 2 % Smooth
    filt = '_Smooth';
end

% Create file suffix names
erpSuffixOrig = strcat('_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_Dir',filt,'.erp');
erpSuffixCSD = strcat('_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_Dir',filt,'.erp');

for i = 1:length(goodSubs)
    goodDataOrig{i} = strcat(goodSubs{i},erpSuffixOrig);
    goodDataCSD{i} = strcat(goodSubs{i},erpSuffixCSD);
end

dataDate = 'Final';
% Define the file folder
path = strcat('~/Documents/projects/COM_EEG/Data/',dataDate,'_',prefix,'_EEG_WithHiCoh_SignedQuartCurv',suffix,'_ContraIpsi');
cd(path);

% Load the original data
[ERP ALLERP] = pop_loaderp('filename', goodDataOrig,'filepath', path);

% Calculate Grand Average with Jackknife data & SEM
ALLERP = pop_jkgaverager(ALLERP , 'Erpname', strcat('GoodSubAvg_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_Dir',filt),...
    'Erpsets', 1:length(goodSubs), 'Criterion', 30, 'SEM', 'on',...
    'Filename', strcat('GoodSubAvg_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_Dir',filt,'.erp'));

% Make a folder for the Jackknife subaverages
mkdir 'Jackknife';

% Rename the original file and move the jackknife files to the folder
movefile(strcat('GoodSubAvg_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_Dir',filt,'-00.erp'),...
    strcat('GoodSubAvg_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_Dir',filt,'.erp'));
movefile('*-0*','Jackknife');
movefile('*-10*','Jackknife');

clearvars ERP ALLERP

cd CSD

% Load the CSD data
[ERP ALLERP] = pop_loaderp('filename', goodDataCSD,'filepath', pwd);

% Calculate Grand Average with Jackknife data & SEM
% ALLERP = pop_jkgaverager(ALLERP , 'Erpname', strcat('GoodSubAvg_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_CSD'),...
%     'Erpsets', 1:length(goodSubs), 'Criterion', 30, 'SEM', 'on' );
ALLERP = pop_jkgaverager(ALLERP , 'Erpname', strcat('GoodSubAvg_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_Dir',filt),...
    'Erpsets', 1:length(goodSubs), 'Criterion', 30, 'SEM', 'on',...
    'Filename', strcat('GoodSubAvg_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_Dir',filt,'.erp'));

% Make a folder for the Jackknife subaverages
mkdir 'Jackknife';

% Rename the original file and move the jackknife files to the folder
movefile(strcat('GoodSubAvg_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_Dir',filt,'-00.erp'),...
    strcat('GoodSubAvg_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_Dir',filt,'.erp'));
movefile('*-0*','Jackknife');
movefile('*-10*','Jackknife');
