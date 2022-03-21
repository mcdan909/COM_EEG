%% Convert preprocessed EEG datasets

clear all;

% Response locked or stim locked data?
respLock = 1;
endLock = 0;
feedLock = 0;

% Use FT wide window datasets?
FT = 1;
filtType = 0; % 0 = noLPF, 1 = LPF, 2 = Smooth

%load('~/Documents/projects/DistractorSaliencyEEG/CapInfo/elecStruct.mat');

% Old
%goodSubs = {'302','304','305','306','308','309','310','313','314','315'};

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

dataDate = 'FinalNew';
% Define the file folder
path = strcat('~/Documents/projects/COM_EEG/Data/',dataDate,'_',prefix,'_EEG_WithHiCoh_SignedQuartCurv',suffix);
cd(path);

ftPath = strcat(path,'/FieldTrip');
ftPathCSD = strcat(path,'/CSD/FieldTrip');

mkdir(ftPath);
mkdir(ftPathCSD);

for i = 1:length(goodSubs);
    eegData{i} = strcat(goodSubs{i},'_',prefix,'_EEG_WithHiCoh_QuartCurv',suffix,'.set');
    eegDataCSD{i} = strcat('/CSD/',goodSubs{i},'_',prefix,'_EEGcsd_WithHiCoh_QuartCurv',suffix,'.set');
end

ALLEEG = pop_loadset('filename', eegData, 'filepath', path);
ALLEEGcsd = pop_loadset('filename', eegDataCSD, 'filepath', path);

%% Load a dataset to read the electrode locations for FieldTrip

for i = 1:length(goodSubs)
    
    % Create temporary FieldTrip Data Structure for the EEG/ERP data
    eeg{i} = eeglab2fieldtrip(ALLEEG(i),'preprocessing'); % All Trials
    eegCSD{i} = eeglab2fieldtrip(ALLEEGcsd(i),'preprocessing'); % All Trials
    
    % Instead of a bin matrix, fieldtrip uses structures for each bin
    % First we need to give it some info it can understand
    % For the trialwise data, each cell is a subject so that trial order
    % is preserved. Now we need to add back in the data that
    % eeglab2fieldtrip doesn't pull in
    eeg{i}.bini = [ALLEEG(i).event.bini];
    eeg{i}.RT = [ALLEEG(i).event.RT];
    eeg{i}.MT = [ALLEEG(i).event.MT];
    eeg{i}.signedCurv = [ALLEEG(i).event.signedCurv];
    eeg{i}.trialNumber = [ALLEEG(i).event.trialNumber];
    eeg{i}.targetLocation = [ALLEEG(i).event.targetLocation];
    eeg{i}.flag = [ALLEEG(i).reject.rejmanual]; % Artifact rejection flag
    
    for j = 1:ALLEEG(i).trials
        eeg{i}.timePoints{j} = ALLEEG(i).event(j).timePoints; % Reach time stamps
        eeg{i}.xPoints{j} = ALLEEG(i).event(j).xPoints; % xPos
        eeg{i}.yPoints{j} = ALLEEG(i).event(j).yPoints; % yPos
        
        % For any trial that had an artifact, change the data (i.e., eeg.trial)
        % to NaNs so that data is not included in the TF analysis
        if eeg{i}.flag(j) ~= 0
            eeg{i}.trial{j} = single(NaN(ALLEEG(i).nbchan,ALLEEG(i).pnts));
        end     
    end
    
    eegCSD{i}.bini = [ALLEEGcsd(i).event.bini];
    eegCSD{i}.RT = [ALLEEGcsd(i).event.RT];
    eegCSD{i}.MT = [ALLEEGcsd(i).event.MT];
    eegCSD{i}.signedCurv = [ALLEEGcsd(i).event.signedCurv];
    eegCSD{i}.trialNumber = [ALLEEGcsd(i).event.trialNumber];
    eegCSD{i}.targetLocation = [ALLEEGcsd(i).event.targetLocation];
    eegCSD{i}.flag = [ALLEEGcsd(i).reject.rejmanual]; % Artifact rejection flag
    
    for j = 1:ALLEEG(i).trials
        eegCSD{i}.timePoints{j} = ALLEEGcsd(i).event(j).timePoints; % Reach time stamps
        eegCSD{i}.xPoints{j} = ALLEEGcsd(i).event(j).xPoints; % xPos
        eegCSD{i}.yPoints{j} = ALLEEGcsd(i).event(j).yPoints; % yPos
        
        % For any trial that had an artifact, change the data (i.e., eeg.trial)
        % to NaNs so that data is not included in the TF analysis
        if eegCSD{i}.flag(j) ~= 0
            eegCSD{i}.trial{j} = single(NaN(ALLEEGcsd(i).nbchan,ALLEEG(i).pnts));
        end   
    end
end

cd FieldTrip

% Save the data in FieldTrip format for later analysis
save(strcat('GoodSub_',prefix,'_EEG_WithHiCoh_QuartCurv_TrialWise',suffix,'_FieldTrip'),'eeg');

cd ..

cd CSD/FieldTrip

save(strcat('GoodSub_',prefix,'_EEGcsd_WithHiCoh_QuartCurv_TrialWise',suffix,'_FieldTrip'),'eegCSD');