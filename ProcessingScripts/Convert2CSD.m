%% Convert preprocessed EEG/ERP datasets to current source density

clear all;

% Response locked or stim locked data?
respLock = 1;

% How were CoMs defined? AUC or Curv?
auc = 1;

% Use FT wide window datasets?
FT = 0;

%load('~/Documents/projects/DistractorSaliencyEEG/CapInfo/elecStruct.mat');

goodSubs = {'302','304','305','306','308','309','311','313','314','315'};

% change prefix for dataset type
if respLock
    prefix = 'RL';
else
    prefix = 'SL';
end

% change suffix depending on how CoMs were defined
if auc
    comDef = 'AUC';
else
    comDef = 'Curv';
end

% change suffix depending on whether using the wide window dataset for the
% TF analysis or the regular epoched data
if FT
    suffix = '_WinFT';
else
    suffix = '';
end

% Date data was processed
dataDate = '12-Apr-2017';

% Define the file folder
path = strcat('~/Documents/projects/COM_EEG/Data/',dataDate,'_',prefix,'_EEG_WithHiCoh_Quart',comDef,suffix);
cd(path);
mkdir 'CSD'

for i = 1:length(goodSubs);
    eegData{i} = strcat(goodSubs{i},'_',prefix,'_EEG_WithHiCoh_Quart',comDef,suffix,'.set');
end

ALLEEG = pop_loadset('filename', eegData, 'filepath', path);

% % Load a dataset to read the electrode locations for FieldTrip
cfg = [];
cfg = eeglab2fieldtrip(ALLEEG(1),'chanloc');
elec = ft_read_sens(ALLEEG(1).filename,'fileformat','eeglab_set','senstype', 'eeg');
 
% Set up configuration for FieldTrip CSD conversion
cfg = [];
cfg.method = 'spline'; % Spherical spline interpolation
cfg.elec = elec; % structure with electrode definition

for i = 1:length(goodSubs)

    % ERP filename for each subject
    fileName = strcat(goodSubs{i},'_',prefix,'_ERP_WithHiCoh_Quart',comDef,suffix,'.erp');
    
    % Load subject's ERP file
    ERP = pop_loaderp( 'filename', fileName, 'filepath',path);
    
    nTrials = ALLEEG(i).trials;
    
    % Instead of a bin matrix, fieldtrip uses structures for each bin
    % First we need to give it some info it can understand
    % Define electrode labels
    % j: 1-4 = LoCohQ1-4, 5 = HiCoh, 6 = LoCohErr
    for j = 1:6
        erp{j,i}.label = elec.label; % electrode labels
        erp{j,i}.fsample = ERP.srate; % sampling rate
        erp{j,i}.time = ERP.times/1000; % sample time in secs
        erp{j,i}.dimord = 'chan_time'; % data is timepoints per channel
        erp{j,i}.avg = ERP.bindata(:,:,j); % Condition average ERPs
        
        % Calculate CSD
        erpCSD{j,i} = ft_scalpcurrentdensity(cfg,erp{j,i});
       
        % Replace original ERP data with CSD data
        ERP.bindata(:,:,j) = erpCSD{j,i}.avg;
    end
    
    % give the necessary struct info for FieldTrip
    eeg{i}.label = elec.label; % electrode labels
    eeg{i}.time = ERP.times/1000; % sample time in secs
    eeg{i}.dimord = 'rpt_chan_time'; % data is timepoints per channel
    
    for k = 1:nTrials
        eeg{i}.trial(k,:,:) = squeeze(ALLEEG(i).data(:,:,k));
        eeg{i}.trialinfo(1,k) = ALLEEG(i).event(k).bini;
    end
    
    % Calculate CSD
    eegCSD{i} = ft_scalpcurrentdensity(cfg,eeg{i});
    eegCSD{i}.trialinfo = eeg{i}.trialinfo;
    
    for k = 1:nTrials
        % Replace the data in the ALLEEG struct with CSD data
        ALLEEG(i).data(:,:,k) = squeeze(eegCSD{i}.trial(k,:,:));
    end

    % Save the CSD data in an ERP file
    ERP = pop_savemyerp(ERP, 'erpname', strcat(goodSubs{i},'_',prefix,'_ERP_WithHiCoh_Quart',comDef,suffix,'_CSD'),...
        'filename', strcat(goodSubs{i},'_',prefix,'_ERP_WithHiCoh_Quart',comDef,suffix,'_CSD.erp'), 'filepath', strcat(path,'/CSD/'),...
        'Warning', 'off', 'overwriteatmenu','off');
    
    % Save the CSD data in an EEG file
    EEG = pop_saveset(ALLEEG(i),'filename',strcat(goodSubs{i},'_',prefix,'_EEG_WithHiCoh_Quart',comDef,suffix,'_CSD'),'filepath', strcat(path,'/CSD/'));
    
    % Save EEG .mat file
    outFileName = strcat(path,'/CSD/',goodSubs{i},'_',prefix,'_EEG_WithHiCoh_Quart',comDef,suffix,'_CSD');
    save(outFileName,'EEG');
 
end

% Save the data in FieldTrip format for later analysis
save(strcat('GoodSub_',prefix,'_ERP_WithHiCoh_Quart',comDef,suffix,'_FieldTrip'),'erp');
save(strcat('GoodSub_',prefix,'_EEG_WithHiCoh_Quart',comDef,suffix,'_FieldTrip'),'eeg');

cd CSD

save(strcat('GoodSub_',prefix,'_ERP_WithHiCoh_Quart',comDef,suffix,'_CSD_FieldTrip'),'erpCSD');
save(strcat('GoodSub_',prefix,'_EEG_WithHiCoh_Quart',comDef,suffix,'_CSD_FieldTrip'),'eegCSD');
