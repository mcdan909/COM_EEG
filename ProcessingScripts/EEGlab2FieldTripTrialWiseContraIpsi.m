%% Convert preprocessed EEG datasets

clear all;

% Response locked or stim locked data?
respLock = 1;
endLock = 0;
feedLock = 0;

% Use FT wide window datasets?
FT = 0;
filtType = 0; % 0 = noLPF, 1 = LPF, 2 = Smooth

%load('~/Documents/projects/DistractorSaliencyEEG/CapInfo/elecStruct.mat');

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

dataDate = 'Final';
% Define the file folder
path = strcat('~/Documents/projects/COM_EEG/Data/',dataDate,'_',prefix,'_EEG_WithHiCoh_SignedQuartCurv',suffix,'_ContraIpsi');
cd(path);

ftPath = strcat(path,'/FieldTrip');
ftPathCSD = strcat(path,'/CSD/FieldTrip');

mkdir(ftPath);
mkdir(ftPathCSD);

for i = 1:length(goodSubs);
    eegData{i} = strcat(goodSubs{i},'_',prefix,'_EEG_WithHiCoh_QuartCurv',suffix,'_ContraIpsi.set');
    eegDataCSD{i} = strcat('/CSD/',goodSubs{i},'_',prefix,'_EEGcsd_WithHiCoh_QuartCurv',suffix,'_ContraIpsi.set');
end

ALLEEG = pop_loadset('filename', eegData, 'filepath', path);
ALLEEGcsd = pop_loadset('filename', eegDataCSD, 'filepath', path);

%% Load a dataset to read the electrode locations for FieldTrip
% cfg = [];
% cfg = eeglab2fieldtrip(ALLEEG(1),'preprocessing');
% elec = ft_read_sens(ALLEEG(1).filename,'fileformat','eeglab_set','senstype', 'eeg');

for i = 1:length(goodSubs)
    
    eegTemp = [];
    erpTemp = [];
    
    % Create temporary FieldTrip Data Structure for the EEG/ERP data
    eegTemp = eeglab2fieldtrip(ALLEEG(i),'preprocessing'); % All Trials
    erpTemp = eeglab2fieldtrip(ALLEEG(i),'timelockanalysis'); % Avg
    
    % Get time sample and number of trials info
    nTrials = length(eegTemp.trial);
    
    % Remove unwanted fields to be filled in below
    eegFields = {'trial','time'};
    eegTemp = rmfield(eegTemp,eegFields);
    erpFields = {'avg','var'};
    erpTemp = rmfield(erpTemp,erpFields);

    % ERP filename for each subject
    fileName = strcat(goodSubs{i},'_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_ContraIpsi',filt,'.erp');
    fileNameCSD = strcat('/CSD/',goodSubs{i},'_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_ContraIpsi',filt,'.erp');
    
    % Load subject's ERP file
    ERP = pop_loaderp( 'filename', fileName, 'filepath',path);
    ERPcsd = pop_loaderp( 'filename', fileNameCSD, 'filepath',path);
    
    % Make dummy variable for trial counting in each bin
    counter = ones(1,12);
    
    % Instead of a bin matrix, fieldtrip uses structures for each bin
    % First we need to give it some info it can understand
    % Define electrode labels
    % j: 1 = LoCohQ1 Contra, 2 = LoCohQ1 Ipsi 
    % 3 = LoCohQ2 Contra, 4 = LoCohQ2 Ipsi 
    % 5 = LoCohQ3 Contra, 6 = LoCohQ3 Ipsi 
    % 7 = LoCohQ4 Contra, 8 = LoCohQ4 Ipsi 
    % 9 = HiCoh Contra, 10 = HiCoh Ipsi
    % 11 = LoCohErr Contra, 12 = LoCohErr Ipsi
    for j = 1:12
        
        % Load in temp data structure for other fields
        erp{j,i}.label = erpTemp.label;
        erp{j,i}.fsample = erpTemp.fsample;
        erp{j,i}.elec = erpTemp.elec;
        erp{j,i}.time = erpTemp.time;
        erp{j,i}.avg = ERP.bindata(:,:,j); % Condition average ERPs
        erp{j,i}.dimord = 'chan_time';
        
        erpCSD{j,i}.label = erpTemp.label;
        erpCSD{j,i}.fsample = erpTemp.fsample;
        erpCSD{j,i}.elec = erpTemp.elec;
        erpCSD{j,i}.time = erpTemp.time;
        erpCSD{j,i}.avg = ERPcsd.bindata(:,:,j); % Condition average ERPs
        erpCSD{j,i}.dimord = 'chan_time';

        % For each trial, check the bin number and put the data into
        % that struct position
        for k = 1:nTrials
            if ALLEEG(i).event(k).bini == j
                % Pull along trial-wise EEG data and other important
                % varaibles
                eeg{j,i}.trial{counter(j)} = ALLEEG(i).data(:,:,k);
                eeg{j,i}.RT{counter(j)} = ALLEEG(i).event(k).RT;
                eeg{j,i}.MT{counter(j)} = ALLEEG(i).event(k).MT;
                eeg{j,i}.signedCurv{counter(j)} = ALLEEG(i).event(k).signedCurv;
                eeg{j,i}.trialNumber{counter(j)} = ALLEEG(i).event(k).trialNumber;
                eeg{j,i}.targetLocation{counter(j)} = ALLEEG(i).event(k).targetLocation;
                eeg{j,i}.timePoints{counter(j)} = ALLEEG(i).event(k).timePoints; % Reach time stamps
                eeg{j,i}.xPoints{counter(j)} = ALLEEG(i).event(k).xPoints; % xPos
                eeg{j,i}.yPoints{counter(j)} = ALLEEG(i).event(k).yPoints; % yPos
                eeg{j,i}.time{counter(j)} = erpTemp.time;
                eeg{j,i}.flag{counter(j)} = ALLEEG(i).epoch(k).eventflag; % Artifact rejection flag
                
                eegCSD{j,i}.trial{counter(j)} = ALLEEGcsd(i).data(:,:,k);
                eegCSD{j,i}.RT{counter(j)} = ALLEEGcsd(i).event(k).RT;
                eegCSD{j,i}.MT{counter(j)} = ALLEEGcsd(i).event(k).MT;
                eegCSD{j,i}.signedCurv{counter(j)} = ALLEEGcsd(i).event(k).signedCurv;
                eegCSD{j,i}.trialNumber{counter(j)} = ALLEEGcsd(i).event(k).trialNumber;
                eegCSD{j,i}.targetLocation{counter(j)} = ALLEEGcsd(i).event(k).targetLocation;
                eegCSD{j,i}.timePoints{counter(j)} = ALLEEGcsd(i).event(k).timePoints; % Reach time stamps
                eegCSD{j,i}.xPoints{counter(j)} = ALLEEGcsd(i).event(k).xPoints; % xPos
                eegCSD{j,i}.yPoints{counter(j)} = ALLEEGcsd(i).event(k).yPoints; % yPos
                eegCSD{j,i}.time{counter(j)} = erpTemp.time;
                eegCSD{j,i}.flag{counter(j)} = ALLEEGcsd(i).epoch(k).eventflag; % Artifact rejection flag
                
                counter(j) = counter(j) + 1;
            end
        end
        
        eeg{j,i}.label = eegTemp.label;
        eeg{j,i}.fsample = eegTemp.fsample;
        eeg{j,i}.elec = eegTemp.elec;
        eeg{j,i}.cfg = eegTemp.cfg;
        
        eegCSD{j,i}.label = eegTemp.label;
        eegCSD{j,i}.fsample = eegTemp.fsample;
        eegCSD{j,i}.elec = eegTemp.elec;
        eegCSD{j,i}.cfg = eegTemp.cfg;
        
        % Unfortunately, eeglab2fieldtrip doesn't take into account which
        % trials had artifact rejection flags. This step ensures
        % that the data, if averaged, matches the ERPset data by removing
        % those cells which contained an artifact. Annoying, but necessary
        % to ensure data consistency. For sanity, make sure all columns of
        % the flag field are zero following this transformation.
        % Remove rejected trials from eeg for FieldTrip based on flag
        % variable
        badTrialEEG{j,i} = find(cell2mat(eeg{j,i}.flag) ~= 0);
        badTrialEEGcsd{j,i} = find(cell2mat(eegCSD{j,i}.flag) ~= 0);
        
        eeg{j,i}.trial(badTrialEEG{j,i}) = [];
        eeg{j,i}.RT(badTrialEEG{j,i}) = [];
        eeg{j,i}.MT(badTrialEEG{j,i}) = [];
        eeg{j,i}.signedCurv(badTrialEEG{j,i}) = [];
        eeg{j,i}.trialNumber(badTrialEEG{j,i}) = [];
        eeg{j,i}.targetLocation(badTrialEEG{j,i}) = [];
        eeg{j,i}.timePoints(badTrialEEG{j,i}) = [];
        eeg{j,i}.xPoints(badTrialEEG{j,i}) = [];
        eeg{j,i}.yPoints(badTrialEEG{j,i}) = [];
        eeg{j,i}.time(badTrialEEG{j,i}) = [];
        eeg{j,i}.flag(badTrialEEG{j,i}) = [];
        
        eegCSD{j,i}.trial(badTrialEEGcsd{j,i}) = [];
        eegCSD{j,i}.RT(badTrialEEGcsd{j,i}) = [];
        eegCSD{j,i}.MT(badTrialEEGcsd{j,i}) = [];
        eegCSD{j,i}.signedCurv(badTrialEEGcsd{j,i}) = [];
        eegCSD{j,i}.trialNumber(badTrialEEGcsd{j,i}) = [];
        eegCSD{j,i}.targetLocation(badTrialEEGcsd{j,i}) = [];
        eegCSD{j,i}.timePoints(badTrialEEGcsd{j,i}) = [];
        eegCSD{j,i}.xPoints(badTrialEEGcsd{j,i}) = [];
        eegCSD{j,i}.yPoints(badTrialEEGcsd{j,i}) = [];
        eegCSD{j,i}.time(badTrialEEGcsd{j,i}) = [];  
        eegCSD{j,i}.flag(badTrialEEGcsd{j,i}) = []; 
        
        % Convert individual EEG to ERPs for each condition
        cfg = [];
        erp{j,i} = ft_timelockanalysis(cfg, eeg{j,i});
        erpCSD{j,i} = ft_timelockanalysis(cfg, eegCSD{j,i});
        
    end
end

cfg = [];

for i = 1:12
    erpGrandAve{i} = ft_timelockgrandaverage(cfg,erp{i,:});
    erpGrandAveCSD{i} = ft_timelockgrandaverage(cfg,erpCSD{i,:});
end

cd FieldTrip

% Save the data in FieldTrip format for later analysis
save(strcat('GoodSub_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_ContraIpsi',filt,'_FieldTrip'),'erp','erpGrandAve');
save(strcat('GoodSub_',prefix,'_EEG_WithHiCoh_QuartCurv',suffix,'_ContraIpsi_FieldTrip'),'eeg');

cd ..

cd CSD/FieldTrip

save(strcat('GoodSub_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_ContraIpsi',filt,'_FieldTrip'),'erpCSD','erpGrandAveCSD');
save(strcat('GoodSub_',prefix,'_EEGcsd_WithHiCoh_QuartCurv',suffix,'_ContraIpsi_FieldTrip'),'eegCSD');
