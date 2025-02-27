%% Combine electrodes component ROIs and create a grand average dataset

clear all;

% Response locked or stim locked data?
respLock = 1;
endLock = 0;
feedLock = 0;

% Use FT wide window datasets?
FT = 0;
filtType = 2; % 0 = noLPF, 1 = LPF, 2 = Smooth

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
erpSuffixOrig = strcat('_',prefix,'_ERP_WithHiCoh_QuartCurv',filt,suffix,'.erp');
erpSuffixCSD = strcat('_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',filt,suffix,'.erp');

for i = 1:length(goodSubs)
    goodDataOrig{i} = strcat(goodSubs{i},erpSuffixOrig);
    goodDataCSD{i} = strcat(goodSubs{i},erpSuffixCSD);
end

dataDate = 'FinalNew';
% Define the file folder
path = strcat('~/Documents/projects/COM_EEG/Data/',dataDate,'_',prefix,'_EEG_WithHiCoh_SignedQuartCurv',suffix);
cd(path);

% Load the original data
[ERP ALLERP] = pop_loaderp('filename', goodDataOrig,'filepath', path);

for i = 1:length(goodSubs)
    % Create Difference Waves
    ALLERP(i) = pop_binoperator(ALLERP(i), {'b7 = b1 - b2 label Q1-Q2',...
        'b8 = b1 - b3 label Q1-Q3',  'b9 = b1 - b4 label Q1-Q4',...
        'b10 = b2 - b3 label Q2-Q3', 'b11 = b2 - b4 label Q2-Q4',...
        'b12 = b3 - b4 label Q3-Q4', 'b13 = b1 - b5 label Q1-HiCoh',... 
        'b14 = b4 - b6 label Q4-Err'});
    
%     %Combine channels for components of interest
%     ALLERP(i) = pop_erpchanoperator(ALLERP(i),...
%         {'ch36 = (ch8+ch22+ch30+ch31)/4 label CPP(CzPzCP12)',...
%         'ch37 = (ch8+ch22+ch31)/3 label CPP(PzCP12)',...
%         'ch38 = (ch4+ch18+ch30+ch35)/4 label ERN(FzCzFC12)',...
%         'ch39 = (ch18+ch30+ch35)/3 label ERN(CzFC12)',...
%         'ch40 = (ch4+ch18+ch35)/3 label ERN(FzFC12)',...
%         'ch41 = ch6-ch20 label LRP'} ,...
%         'ErrorMsg', 'popup', 'Warning', 'on');
end

% Calculate Grand Average with Jackknife data & SEM
ALLERP = pop_jkgaverager(ALLERP , 'Erpname', strcat('GoodSubAvg_',prefix,'_ERP_WithHiCoh_QuartCurv',filt,suffix),...
    'Erpsets', 1:length(goodSubs), 'Criterion', 30, 'SEM', 'on',...
    'Filename', strcat('GoodSubAvg_',prefix,'_ERP_WithHiCoh_QuartCurv',filt,suffix,'.erp'));

% Make a folder for the Jackknife subaverages
mkdir 'Jackknife';

% Rename the original file and move the jackknife files to the folder
movefile(strcat('GoodSubAvg_',prefix,'_ERP_WithHiCoh_QuartCurv',filt,suffix,'-00.erp'),...
    strcat('GoodSubAvg_',prefix,'_ERP_WithHiCoh_QuartCurv',filt,suffix,'.erp'));
movefile('*-0*','Jackknife');
movefile('*-10*','Jackknife');

clearvars ERP ALLERP

cd CSD

% Load the CSD data
[ERP ALLERP] = pop_loaderp('filename', goodDataCSD,'filepath', pwd);

for i = 1:length(goodSubs)
    % Create Difference Waves
    ALLERP(i) = pop_binoperator(ALLERP(i), {'b7 = b1 - b2 label Q1-Q2',...
        'b8 = b1 - b3 label Q1-Q3',  'b9 = b1 - b4 label Q1-Q4',...
        'b10 = b2 - b3 label Q2-Q3', 'b11 = b2 - b4 label Q2-Q4',...
        'b12 = b3 - b4 label Q3-Q4', 'b13 = b1 - b5 label Q1-HiCoh',... 
        'b14 = b4 - b6 label Q4-Err'});
    
    %Combine channels for components of interest
%     ALLERP(i) = pop_erpchanoperator(ALLERP(i),...
%         {'ch36 = (ch8+ch22+ch30+ch31)/4 label CPP(CzPzCP12)',...
%         'ch37 = (ch8+ch22+ch31)/3 label CPP(PzCP12)',...
%         'ch38 = (ch4+ch18+ch30+ch35)/4 label ERN(FzCzFC12)',...
%         'ch39 = (ch18+ch30+ch35)/3 label ERN(CzFC12)',...
%         'ch40 = (ch4+ch18+ch35)/3 label ERN(FzFC12)',...
%         'ch41 = ch6-ch20 label LRP'} ,...
%         'ErrorMsg', 'popup', 'Warning', 'on');
end

% Calculate Grand Average with Jackknife data & SEM
% ALLERP = pop_jkgaverager(ALLERP , 'Erpname', strcat('GoodSubAvg_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_CSD'),...
%     'Erpsets', 1:length(goodSubs), 'Criterion', 30, 'SEM', 'on' );
ALLERP = pop_jkgaverager(ALLERP , 'Erpname', strcat('GoodSubAvg_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',filt,suffix),...
    'Erpsets', 1:length(goodSubs), 'Criterion', 30, 'SEM', 'on',...
    'Filename', strcat('GoodSubAvg_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',filt,suffix,'.erp'));

% Make a folder for the Jackknife subaverages
mkdir 'Jackknife';

% Rename the original file and move the jackknife files to the folder
movefile(strcat('GoodSubAvg_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',filt,suffix,'-00.erp'),...
    strcat('GoodSubAvg_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',filt,suffix,'.erp'));
movefile('*-0*','Jackknife');
movefile('*-10*','Jackknife');
