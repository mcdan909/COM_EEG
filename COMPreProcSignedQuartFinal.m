%% EEGLAB history file generated on the 18-Sep-2013
% Modified by Dan McCarthy, 4/10/2017
% More notes on analysis streams, labelling, etc. at bottom of this
% script

%8 = Low Coherence, Left
%16 = Low Coherence, Right
%32 = High Coherence, Left
%64 = High Coherence, Right

clear all;
% Ask user to confirm analyses before executing?
confirm = 0;
% Lock to end of movement?
endLock = 0;
% Lock to start of movement?
respLock = 0;
% Lock to feedback beep?
feedLock = 0;
% Look at pre-trial activity?
preTrial = 0;
% Lock to peak curvature?
curvLock = 0;
% Widen windows for FT analysis?
FT = 0;

% for xx = 1
% 
%     if xx == 1
%         FT = 1;
%         endLock = 0;
%         respLock = 0;
%         feedLock = 1;
%     elseif xx == 2
%         FT = 0;
%         endLock = 0;
%         respLock = 0;
%         feedLock = 0;
%     elseif xx == 3
%         FT = 1;
%         endLock = 0;
%         respLock = 0;
%         feedLock = 0;
%     elseif xx == 4
%         FT = 0;
%         endLock = 0;
%         respLock = 0;
%         feedLock = 1;
%     elseif xx == 5
%         FT = 1;
%         endLock = 0;
%         respLock = 0;
%         feedLock = 1;
%     end
        
    
% If for time frequency, append to filename
if FT
    suffix = '_FT';
else
    suffix = '';
end

% Define epochs, baselining, and artifact rejection windows based on
% toggles above
if respLock
    prefix = 'RL';
    if FT
        epoch = [-2500 3500]; % ms
    else
        epoch = [-800 600]; % ms
    end
    baseline = [-800 -600]; % ms
    artRejectEpoch = [-800 0]; % ms
elseif preTrial
    prefix = 'PT';
    if FT
        epoch = [-3000 3000]; % ms
    else
        epoch = [-2000 2000]; % ms
    end
    baseline = [-200 0]; % ms
    artRejectEpoch = [-200 600]; % ms
elseif curvLock
    prefix = 'CL';
    if FT
        epoch = [-3000 3000]; % ms
    else
        epoch = [-800 800]; % ms
    end
    baseline = [-800 -600]; % ms
    artRejectEpoch = [-800 0]; % ms
elseif endLock
    prefix = 'EL';
    if FT
        epoch = [-1400 1600]; % ms
    else
        epoch = [-200 400]; % ms
    end
    baseline = [-200 -50]; % ms
    artRejectEpoch = [-200 400]; % ms
elseif feedLock
    prefix = 'FL';
    if FT
        epoch = [-1600 1800]; % ms
    else
        epoch = [-200 400]; % ms
    end
    baseline = [-200 -0]; % ms
    artRejectEpoch = [-200 400]; % ms
else
    prefix = 'SL';
    if FT
        epoch = [-2500 3500]; % ms
    else
        epoch = [-200 600]; % ms
    end
    baseline = [-200 0]; % ms
    artRejectEpoch = [-200 600]; % ms
end

curDate = 'Paper';

% Pat to data folder for output
dataPath = strcat('~/Documents/Brown/COM_EEG/Data/',curDate,'_',prefix,'_EEG_WithHiCoh_SignedQuartCurv',suffix);
mkdir(dataPath);

elPath = strcat('~/Documents/Brown/COM_EEG/Data/',curDate,'_',prefix,'_EEG_WithHiCoh_SignedQuartCurv',suffix,'/EventLists/');
mkdir(elPath);

elPathRL = strcat('~/Documents/Brown/COM_EEG/Data/',curDate,'_RL_EEG_WithHiCoh_SignedQuartCurv',suffix,'/EventLists/');
mkdir(elPathRL);

% Numbers of good subjects
goodSubs = [302,304,305,306,308,309,311,313,314,315];
%goodSubs = 302:315;

% Open EEGLAB and set up structures
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
[ALLEEGcsd EEGcsd CURRENTSETcsd ALLCOMcsd] = eeglab;

for u = 302
    %301 was a pilot subject, not included for analysis
    subNum = num2str(u);
    % ------------------------------------------------
    
    % Print current subject in the command window
    ['currSub = ',subNum]
    
    % load the file.  name change structure changed after sub 307
    if u < 307
        EEG = pop_fileio(strcat('~/Documents/Brown/COM_EEG/RawData/',subNum,'/','songdots_',subNum,'.vhdr'));%, [], [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35]);
    else
        EEG = pop_fileio(strcat('~/Documents/Brown/COM_EEG/RawData/',subNum,'/', 'SongLabDots_',subNum,'.vhdr'));%, [], [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35]);
    end
    
    EEG = pop_editset(EEG, 'setname', strcat(subNum,'_',prefix,'_EEG'));
    EEG = eeg_checkset(EEG);

    % subjects up to 306 had an error in channel labeling.  This
    % fixes channel labelling
    if u < 306
        EEG = pop_chanedit(EEG, 'changefield',{15 'labels' 'Fp2'},'changefield',{16 'labels' 'F4'},...
            'changefield',{17 'labels' 'F8'},'changefield',{18 'labels' 'FC2'},'changefield',{19 'labels' 'FC6'},...
            'changefield',{20 'labels' 'C4'},'changefield',{21 'labels' 'T8'},'changefield',{22 'labels' 'CP2'},...
            'changefield',{23 'labels' 'CP6'},'changefield',{24 'labels' 'TP10'},'changefield',{25 'labels' 'P4'},...
            'changefield',{26 'labels' 'P8'},'changefield',{27 'labels' 'O2'},'changefield',{28 'labels' 'PO10'});
    end
    
    % Append photodiode channel and relabel EOG channels for BESA lookup
    EEG = pop_chanedit(EEG, 'lookup','~/Documents/MATLAB/eeglab14_1_2b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp',...
        'append',35,'changefield',{36 'labels' 'Fz'},'changefield',{33 'labels' 'IO2'},'changefield',{34 'labels' 'LO1'},...
        'lookup','~/Documents/MATLAB/eeglab14_1_2b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp');
    EEG = eeg_checkset(EEG);
    
    % Save the current dataset
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = eeg_checkset(EEG);
    
    % Re-align event times according to when stimulus actually onset via
    % photodiode data, then eliminate photodiode (electrode 35) from the
    % channel array
    [EEG, relevantEventList] = Fix_EventLatenciesWithPhotodiode(EEG, 35);
    
    % Eliminate the photodiode from the array after correction
    EEG = pop_select( EEG,'nochannel',{'Photo'});
    EEG = eeg_checkset(EEG);
    
    EEG = pop_editset(EEG, 'setname', strcat(subNum,'_',prefix,'_EEG_NewChan'));
    EEG = eeg_checkset(EEG);
    
    % Load behavioral data
    fileName = strcat('~/Documents/Brown/COM_EEG/Data/BehavioralDataAUC/SignedQuartileData/',...
        'MovementData_',subNum,'.mat');
    
    % minor corrections for missing trials of a few subjects - as in,
    % we forgot to start the EEG recording until a few trials in or there was a crash at some point, and
    % thus the EEG and behaivoral data won't line up if we don't
    % correct
    
    if u == 301
        subjCorrection = 50;
    elseif u == 306
        subjCorrection =  81;
    elseif u == 309
        subjCorrection = 0;
        relevantEventList(101) = [];
    else
        subjCorrection = 0;
    end
    
    % Interpolate data for noisy channels with neighboring electrodes
    if u == 307
        EEG = pop_interp(EEG, 16, 'spherical'); % F4 Noisy
    elseif u == 308
        EEG = pop_interp(EEG, 3, 'spherical'); % F7 Noisy
    elseif u == 310
        EEG = pop_interp(EEG, 28, 'spherical'); % All noisy, esp PO10
    elseif u == 311
        EEG = pop_interp(EEG, 21, 'spherical'); % F7 Noisy
    end
    
    % function to add behavioral data into EEG structure
    EEG = appendBehavioralDataAllQuart(EEG,fileName, relevantEventList, subjCorrection,u);
    
    % if looking at response locked data, correct time "0" to line up
    % with movement onset rather than stimulus onset
    if respLock
        EEG = ResponseLocking(EEG);
    end
    % if looking at curve locked data, correct time "0" to line up
    % with movement onset rather than stimulus onset (not much luck)
    if curvLock
        EEG = CurvLocking(EEG);
    end
    
    if endLock
        EEG = EndLocking(EEG);
    end
    
    % Rename event codes based on accuracy and response
    for rebin = 1:length(relevantEventList)
        % Exclude innacurate trials and those with RT < 200 ms to remove
        % trials with inefficient time to make decision
        % Murphy et al., 2015 went out to 350 ms for the CPP
        % Original stimulus timing events are sorted based on response from
        % low to high curvature quartiles (R101-104) for lo coherence trials,
        % High coherence trials (R105), and errors (R106)
        if EEG.event(relevantEventList(rebin)).acc &&...
                EEG.event(relevantEventList(rebin)).RT >= .2
            if strcmp(EEG.event(relevantEventList(rebin)).type,'S  8') ||...
                    strcmp(EEG.event(relevantEventList(rebin)).type,'S 16')
                if EEG.event(relevantEventList(rebin)).allSignedCurvQuart == 1
                    EEG.event(relevantEventList(rebin)).type = 'R 101'; % AucQ1 (DR), LoCoh
                elseif EEG.event(relevantEventList(rebin)).allSignedCurvQuart == 2
                    EEG.event(relevantEventList(rebin)).type = 'R 102'; % AucQ2, LoCoh
                elseif EEG.event(relevantEventList(rebin)).allSignedCurvQuart == 3
                    EEG.event(relevantEventList(rebin)).type = 'R 103'; % AucQ3, LoCoh
                elseif EEG.event(relevantEventList(rebin)).allSignedCurvQuart == 4
                    EEG.event(relevantEventList(rebin)).type = 'R 104'; % AucQ4 (CoM), LoCoh
                end
            elseif strcmp(EEG.event(relevantEventList(rebin)).type,'S 32') ||...
                    strcmp(EEG.event(relevantEventList(rebin)).type,'S 64')
                if EEG.event(relevantEventList(rebin)).allSignedCurvQuart == 5
                    EEG.event(relevantEventList(rebin)).type = 'R 105'; % HighCoh
                end
            end
            % Get innacurate LoCoh trials
        elseif ~EEG.event(relevantEventList(rebin)).acc &&...
                EEG.event(relevantEventList(rebin)).RT >= .2
            if strcmp(EEG.event(relevantEventList(rebin)).type,'S  8') ||...
                    strcmp(EEG.event(relevantEventList(rebin)).type,'S 16')
                if EEG.event(relevantEventList(rebin)).allSignedCurvQuart == 0
                    EEG.event(relevantEventList(rebin)).type = 'R 106'; % Error, LoCoh
                end
            end
        end
    end
    
    EEG = pop_editset(EEG, 'setname', strcat(subNum,'_',prefix,'_EEG_NewChan_NewEv'));
    EEG = eeg_checkset(EEG);
    
    % re-reference to mastoid channels, and rescue Fz (used as online
    % reference) back into array
    EEG = pop_reref( EEG, [10 24] ,'refloc',struct('labels',{'Fz'},'type',{''},'theta',{0},...
        'radius',{0.25338},'X',{60.7385},'Y',{0},'Z',{59.4629},'sph_theta',{0},'sph_phi',{44.392},...
        'sph_radius',{85},'urchan',{[]},'ref',{''},'datachan',{0}),'exclude', 33:34,'keepref','on');
    EEG = eeg_checkset(EEG);
    
    EEG = pop_editset(EEG, 'setname', strcat(subNum,'_',prefix,'_EEG_NewChan_NewEv_ReRef'));
    EEG = eeg_checkset(EEG);
    
    % Rename EOG channels for ease of visualization
    EEG = pop_chanedit(EEG, 'changefield',{33 'labels' 'VEOG'},'changefield',{34 'labels' 'HEOG'});
    
    % Apply Hi-Pass Filter to continuous EEG (0.1 Hz) & remove DC bias
    % (this should be done for DC and won't hurt AC). This is done on
    % the continuous data and removes slow drifts
    EEG  = pop_basicfilter( EEG,  1:35 , 'Boundary', 'boundary',...
        'Cutoff',  0.1, 'Design', 'butter', 'Filter', 'highpass',...
        'Order',  2, 'RemoveDC', 'on' );
    EEG = eeg_checkset(EEG);
    
    EEG = pop_editset(EEG, 'setname', strcat(subNum,'_',prefix,'_EEG_NewChan_NewEv_ReRef_HPF'));
    EEG = eeg_checkset(EEG);
    
    % Downsample the data to 250 Hz
    EEG = pop_resample( EEG, 250);
    EEG = eeg_checkset( EEG );
    
    EEG = pop_editset(EEG, 'setname', strcat(subNum,'_',prefix,'_EEG_NewChan_NewEv_ReRef_HPF_DownSamp'));
    EEG = eeg_checkset(EEG);
    
    %if respLock
        % Create ERPLAB event list and assign to bins
        EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist',...
            strcat(elPathRL,subNum,'_',prefix,'_eList.txt') );
        EEG = eeg_checkset( EEG );
        
        % Create bins for ERP data ignoring the old event codes, only
        % processing events of interest
        EEG  = pop_binlister( EEG , 'BDF', '~/Documents/Brown/COM_EEG/PreprocessingScriptsNew/globalBinsQuart.txt', 'ExportEL', ...
            strcat(elPathRL,subNum,'_',prefix,'_eList_Binned.txt'),...
            'Ignore', [-88 2 4 8 16 32 64], 'IndexEL',  1, 'SendEL2', 'All', 'UpdateEEG', 'on', 'Voutput', 'EEG' );
%     else
%         Otherwise load in the Eventlist from the RL data and apply to SL
%         data
%         EEG = pop_importeegeventlistNoGUI(EEG, strcat(elPathRL,subNum,'_RL_eList_Binned_Flags.txt'));
%     end
    
    % Epoch to relevant events
    EEG = pop_epochbin( EEG , epoch,  baseline);
    EEG = eeg_checkset( EEG );
    
    EEG = pop_editset(EEG, 'setname', strcat(subNum,'_',prefix,'_EEG_NewChan_NewEv_ReRef_HPF_DownSamp_Epoch'));
    EEG = eeg_checkset( EEG );
    
%     % Get mean MT for artifact rejection window
    %meanMT = round(1000*mean([EEG.event.MT]));
%     if respLock
%         artRejectEpoch = [-800 meanMT];
%     end
    
    % Subject 306 had a huge noise signal at site TP9 in epochs 161-218.
    % Rereferencing to this site causes all elecrodes to be bad but is not
    % captured by the basic thresholding. Instead, reject these epochs
    % using indexing which captures all identified ocular artifacts as well
    % and sync with the EVENTLIST
        if u == 306
            %EEG = pop_rejepoch( EEG, 161:218, 0); % Totally removes epochs
            
            % Mark epochs for rejection
            badTrials = 161:218;
            for x = 1:length(badTrials)
                EEG = markartifacts(EEG, 1, 1:35, 1:35, badTrials(x), 0, 1);
            end
            
            % Synchronize manual and automatic artifact rejection
            % N.B. all flags will be 1
            EEG = pop_syncroartifacts(EEG);
        else
            
            % Remove trial if peak-to-peak voltage exceeded 200 μV in any
            % 200-msec window in any channel in each epoch
            EEG  = pop_artmwppth( EEG , 'Channel',  1:35, 'Flag',  1,...
                'Threshold',  200, 'Twindow', artRejectEpoch,...
                'Windowsize',  200, 'Windowstep',100 );
            EEG = eeg_checkset( EEG );
            
            % Remove trials with eye blinks using ERPLAB on VEOG channels
            % STEP FUNCTION, 80 μV. Fp1 = 1, Fp2 = 15, VEOG = 33
            EEG  = pop_artstep( EEG , 'Channel',  33, 'Flag', 2,...
                'Threshold',  100, 'Twindow', artRejectEpoch,...
                'Windowsize',  200, 'Windowstep',  100 );
            EEG = eeg_checkset( EEG );
            
            % Remove epochs with blocking (flatlining or amplifier saturation) in
            % which 200 ms worth of data points are within 1 �V of the max
            EEG  = pop_artflatline(EEG, 'Channel', 1:35, 'Duration', 200, 'Flag', 3,...
                'Threshold', [ -1 1]);
            EEG = eeg_checkset(EEG);
            
            % Remove horizontal eye movements exceeding 30 μV step function
            % N.B. a 16 μV HEOG deflection corresponds to a 1 deg eye movement
            % Eye movements can contaminate lateral posterior components
            % (e.g., N2pc, CDA) and this is recommended as a theshold if you
            % are interested in these. As an additional correction, you can
            % also examine HEOG waveforms and exclude subjects exceeding some
            % criterion (e.g., residual EOG activity more than 3.2 µV
            % (Woodman and Luck, 2003), which means that the residual eye
            % averaged less than ±0.1° with a propagated voltage of less than
            % 0.1 µV at the posterior scalp sites (Lins et al., 1993).
            EEG  = pop_artstep( EEG , 'Channel',  34, 'Flag', 4,...
                'Threshold',  15, 'Twindow', artRejectEpoch,...
                'Windowsize',  200, 'Windowstep',  100 );
            EEG = eeg_checkset( EEG );
        end
    
    % Convert data to current source density (basic parameters from gui)
    % This is a reference-free, spherical spline interpolation method that
    % reduces volume conduction across electrodes
    % using the CSD toolbox (Kayser
    EEGcsd = pop_currentsourcedensityNoGui(EEG);
    EEGcsd = eeg_checkset(EEGcsd);
    
    % Save the data to Matlab file
    outFileName = strcat(subNum,'_',prefix,'_EEG_WithHiCoh_QuartCurv',suffix);
    outFileNameCSD = strcat(subNum,'_',prefix,'_EEGcsd_WithHiCoh_QuartCurv',suffix);
    cd(dataPath);
    
    save(outFileName,'EEG');
    save(outFileNameCSD,'EEGcsd');
    
    % Save EEG.set file
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, find(goodSubs == u),'savenew',strcat(subNum,'_',prefix,'_EEG_WithHiCoh_QuartCurv',suffix),'gui','off');
    [ALLEEGcsd EEGcsd CURRENTSETcsd] = pop_newset(ALLEEGcsd, EEGcsd, find(goodSubs == u),'savenew',strcat(subNum,'_',prefix,'_EEGcsd_WithHiCoh_QuartCurv',suffix),'gui','off');
    
    % Export the eventlist with artifact detection flags 
    % Used to create consistency across datasets locked to different
    % timepoints
    EEG = pop_exporteegeventlist(EEG, 'Filename', strcat(elPath,subNum,'_',prefix,'_eList_Binned_Flags.txt'));
    
    % Create average ERPs
    ERP = pop_averager( EEG , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );
    ERPcsd = pop_averager( EEGcsd , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );
    
    % Apply Lo-Pass Filter (30 Hz) & remove DC bias for plotting
    ERPlpf = pop_filterp( ERP,  1:35 , 'Cutoff',  30, 'Design', 'butter', 'Filter', 'lowpass', 'Order',  2 );
    ERPcsdLPF = pop_filterp( ERPcsd,  1:35 , 'Cutoff',  30, 'Design', 'butter', 'Filter', 'lowpass', 'Order',  2 );
    
    % Alternative: filter in time-domain by smoothing data by a 7-point
    % moving average (either is kosher; all analyses are done on data prior
    % to either smoothing technique, so just pick what pakes the plots the
    % prettiest)
    ERPsmooth = pop_smootherpNoGui(ERP, 7, 0);
    ERPcsdSmooth = pop_smootherpNoGui(ERPcsd, 7, 0);
    
    % Save the ERP files
    ERP = pop_savemyerp(ERP, 'erpname', strcat(subNum,'_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix),...
        'filename', strcat(subNum,'_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'.erp'), 'Warning', 'on', 'gui', 'off');
    ERPcsd = pop_savemyerp(ERPcsd, 'erpname', strcat(subNum,'_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix),...
        'filename', strcat(subNum,'_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'.erp'), 'Warning', 'on', 'gui', 'off');
    
    % Save the LPF ERP files
    ERPlpf = pop_savemyerp(ERPlpf, 'erpname', strcat(subNum,'_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_LPF'),...
        'filename', strcat(subNum,'_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_LPF.erp'), 'Warning', 'on', 'gui', 'off');
    ERPcsdLPF = pop_savemyerp(ERPcsdLPF, 'erpname', strcat(subNum,'_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_LPF'),...
        'filename', strcat(subNum,'_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_LPF.erp'), 'Warning', 'on', 'gui', 'off');
    
    % Save the time-smoothed ERP files
    ERPsmooth = pop_savemyerp(ERPsmooth, 'erpname', strcat(subNum,'_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_Smooth'),...
        'filename', strcat(subNum,'_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_Smooth.erp'), 'Warning', 'on', 'gui', 'off');
    ERPcsdSmooth = pop_savemyerp(ERPcsdSmooth, 'erpname', strcat(subNum,'_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_Smooth'),...
        'filename', strcat(subNum,'_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_Smooth.erp'), 'Warning', 'on', 'gui', 'off');
    
    % Clear these for looping to next subject
    clearvars EEG ERP EEGcsd ERPcsd ERPlpf ERPcsdLPF ERPsmooth ERPcsdSmooth
    
end

% Move CSD files to folder
mkdir('CSD');
movefile(strcat(pwd,'/*csd*'),strcat(pwd,'/CSD/'));
%end

%The sampling rate for the EEG data is 500 Hz.
%I've included the key for the various variables in the EEG structure below.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Struct Key %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% 	EEG.data - this is the EEG data.  It's a 3D structure.  It is organized as channelNumber(1:34) x sampleNumber (1:1100 - from 200 ms pre-stimulus to 2000 ms post-stimulus at 500Hz) x trialNumber (varies depending on subject because of trial rejection, etc.).  The unit of these data is microvolts.
%
% 	EEG.chanlocs - this is information about what each channel number means (position, name[e.g., F3, F7, etc.])
%
% 	EEG.event - a structure containing relevant data, including:
%
% 		EEG.event.RT - the response latency on each trial (in seconds)
%
% 		EEG.event.MT - the movement time on each trial (in seconds)
%
% 		EEG.event.xPoints - the position of the mouse from beginning to end of movement
%
% 		EEG.event.yPoints - the y position of the mouse from beginning to end of movement
%
% 		EEG.event.timePoints - the time relative to stimulus onset (in seconds) for each of the x and y samples
%
% 		EEG.event.maxDeviation - the point of maximum deviation for each movement, divided by the length of a line connection the start and end points
%
% 		EEG.event.signOfCurvature - a sign that goes with the maxDeviation variable (+1 indicates that the point of maximum deviation is pulled towards the competing option, -1 indicates movement away from the competitor)
%
% 		EEG.event.turnAroundRT - the latency of the point of maximum deviation on each trial (in seconds)
%
% 		EEG.event.changeMind - whether or not each trial is considered a "change of mind" (1 or 0) according to our criteria
%
% 		EEG.event.targetLocation - whether the target was to the left (1) or right (2)
%
% 		EEG.event.reachLand - whether the observer moved to the target on the left (1) or right (2)
%
% 		EEG.event.acc - whether the response was accurate
%
% 		EEG.event.coherence - whether the motion of dots was low coherence and difficult (.1) or high coherence and easy (1).  Please note, the low coherence level differed between each subject based on an earlier staircase procedure, so it's not actually .1 for each subject.

