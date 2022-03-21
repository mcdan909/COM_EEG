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
% Feedback locked
feedLock = 0;
% Look at pre-trial activity?
preTrial = 0;
% Lock to peak curvature?
curvLock = 0;
% Widen windows for FT analysis?
FT = 0;

for xx = 1:4

    if xx == 1
        FT = 0;
        endLock = 0;
        respLock = 0;
        feedLock = 0;
    elseif xx == 2
        FT = 1;
        endLock = 0;
        respLock = 0;
        feedLock = 0;
    elseif xx == 3
        FT = 0;
        endLock = 0;
        respLock = 1;
        feedLock = 0;
    elseif xx == 4
        FT = 1;
        endLock = 0;
        respLock = 1;
        feedLock = 0;
    end
        
    
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
        epoch = [-2200 2000]; % ms
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
        epoch = [-1200 1400]; % ms
    else
        epoch = [-200 400]; % ms
    end
    baseline = [-200 -50]; % ms
    artRejectEpoch = [-200 400]; % ms
elseif feedLock
    prefix = 'FL';
    if FT
        epoch = [-200 1400]; % ms
    else
        epoch = [-200 400]; % ms
    end
    baseline = [-200 -0]; % ms
    artRejectEpoch = [-200 400]; % ms
else
    prefix = 'SL';
    if FT
        epoch = [-1600 2000]; % ms
    else
        epoch = [-200 600]; % ms
    end
    baseline = [-200 0]; % ms
    artRejectEpoch = [-200 600]; % ms
end

curDate = 'Final';

% Pat to data folder for output
dataPath = strcat('~/Documents/projects/COM_EEG/Data/',curDate,'_',prefix,'_EEG_WithHiCoh_SignedQuartCurv',suffix,'_ContraIpsi');
mkdir(dataPath);

elPath = strcat(dataPath,'/EventLists/');
mkdir(elPath);

% Numbers of good subjects
goodSubs = [302,304,305,306,308,309,311,313,314,315];
%goodSubs = 302:315;

% Open EEGLAB and set up structures
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
[ALLEEGcsd EEGcsd CURRENTSETcsd ALLCOMcsd] = eeglab;

for u = 311
    %301 was a pilot subject, not included for analysis
    subNum = num2str(u);
    % ------------------------------------------------
    
    % Print current subject in the command window
    ['currSub = ',subNum]
    
    % load the file.  name change structure changed after sub 307
    if u < 307
        EEG = pop_fileio(strcat('~/Documents/projects/COM_EEG/RawData/',subNum,'/','songdots_',subNum,'.vhdr'));%, [], [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35]);
    else
        EEG = pop_fileio(strcat('~/Documents/projects/COM_EEG/RawData/',subNum,'/', 'SongLabDots_',subNum,'.vhdr'));%, [], [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35]);
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
    EEG = pop_chanedit(EEG, 'lookup','~/Documents/MATLAB/eeglab13_6_5b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp',...
        'append',35,'changefield',{36 'labels' 'Fz'},'changefield',{33 'labels' 'IO2'},'changefield',{34 'labels' 'LO1'},...
        'lookup','~/Documents/MATLAB/eeglab13_6_5b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp');
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
    fileName = strcat('~/Documents/projects/COM_EEG/Data/BehavioralDataOrig/SignedQuartileDataDir/',...
        'QuartDirMovementData_',subNum,'.mat');
    
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
    EEG = appendBehavioralDataQuart(EEG,fileName, relevantEventList, subjCorrection,u);
    
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
        if EEG.event(relevantEventList(rebin)).acc &&...
                EEG.event(relevantEventList(rebin)).RT >= .2
            if strcmp(EEG.event(relevantEventList(rebin)).type,'S  8')
                    if EEG.event(relevantEventList(rebin)).signedCurvQuart == 1
                        EEG.event(relevantEventList(rebin)).type = 'R 101'; % AucQ1 (DR), LoCohL
                    elseif EEG.event(relevantEventList(rebin)).signedCurvQuart == 2
                        EEG.event(relevantEventList(rebin)).type = 'R 102'; % AucQ2, LoCohL
                    elseif EEG.event(relevantEventList(rebin)).signedCurvQuart == 3
                        EEG.event(relevantEventList(rebin)).type = 'R 103'; % AucQ3, LoCohL
                    elseif EEG.event(relevantEventList(rebin)).signedCurvQuart == 4
                        EEG.event(relevantEventList(rebin)).type = 'R 104'; % AucQ4 (CoM), LoCohL
                    end
            elseif strcmp(EEG.event(relevantEventList(rebin)).type,'S 16')
                    if EEG.event(relevantEventList(rebin)).signedCurvQuart == 1
                        EEG.event(relevantEventList(rebin)).type = 'R 105'; % AucQ1 (DR), LoCohR
                    elseif EEG.event(relevantEventList(rebin)).signedCurvQuart == 2
                        EEG.event(relevantEventList(rebin)).type = 'R 106'; % AucQ2, LoCohR
                    elseif EEG.event(relevantEventList(rebin)).signedCurvQuart == 3
                        EEG.event(relevantEventList(rebin)).type = 'R 107'; % AucQ3, LoCohR
                    elseif EEG.event(relevantEventList(rebin)).signedCurvQuart == 4
                        EEG.event(relevantEventList(rebin)).type = 'R 108'; % AucQ4 (CoM), LoCohR
                    end
            elseif strcmp(EEG.event(relevantEventList(rebin)).type,'S 32') 
                    if EEG.event(relevantEventList(rebin)).signedCurvQuart == 5
                        EEG.event(relevantEventList(rebin)).type = 'R 109'; % HighCohL
                    end
            elseif strcmp(EEG.event(relevantEventList(rebin)).type,'S 64')
                    if EEG.event(relevantEventList(rebin)).signedCurvQuart == 5
                        EEG.event(relevantEventList(rebin)).type = 'R 110'; % HighCohR
                    end
            end
            % Get innacurate LoCoh trials just to have
        elseif ~EEG.event(relevantEventList(rebin)).acc &&...
                EEG.event(relevantEventList(rebin)).RT >= .2
            if strcmp(EEG.event(relevantEventList(rebin)).type,'S  8')
                    if EEG.event(relevantEventList(rebin)).signedCurvQuart == 0
                        EEG.event(relevantEventList(rebin)).type = 'R 111'; % Error, LoCohL
                    end
            elseif strcmp(EEG.event(relevantEventList(rebin)).type,'S 16')
                    if EEG.event(relevantEventList(rebin)).signedCurvQuart == 0
                        EEG.event(relevantEventList(rebin)).type = 'R 112'; % Error, LoCohR
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
    
    % Create ERPLAB event list and assign to bins
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist',...
        strcat(elPath,subNum,'_',prefix,'_eList_Dir.txt') );
    EEG = eeg_checkset( EEG );
    
    % Create bins for ERP data ignoring the old event codes, only
    % processing events of interest
    EEG  = pop_binlister( EEG , 'BDF', '~/Documents/projects/COM_EEG/PreprocessingScriptsNew/globalBinsQuartDir.txt', 'ExportEL', ...
        strcat(elPath,subNum,'_',prefix,'_eList_Binned_Dir.txt'),...
        'Ignore', [-88 2 4 8 16 32 64], 'IndexEL',  1, 'SendEL2', 'All', 'UpdateEEG', 'on', 'Voutput', 'EEG' );
    
    % Epoch to relevant events
    EEG = pop_epochbin( EEG , epoch,  baseline);
    EEG = eeg_checkset( EEG );
    
    EEG = pop_editset(EEG, 'setname', strcat(subNum,'_',prefix,'_EEG_NewChan_NewEv_ReRef_HPF_DownSamp_Epoch'));
    EEG = eeg_checkset( EEG );
    
    % Get mean MT for artifact rejection window
%     meanMT = round(1000*mean([EEG.event.MT]));
%     if respLock
%         artRejectEpoch = [-800 600];
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
        EEG = pop_syncroartifactsNoGUIbidir(EEG);
    else
        % Remove trial if peak-to-peak voltage exceeded 200 μV in any
        % 200-msec window in any channel in each epoch
        EEG  = pop_artmwppth( EEG , 'Channel',  1:35, 'Flag',  1,...
            'Threshold',  200, 'Twindow', artRejectEpoch,...
            'Windowsize',  200, 'Windowstep',100 );
        EEG = eeg_checkset( EEG );

        % Remove trials with eye blinks using ERPLAB on VEOG channels
        % STEP FUNCTION, 80 μV. Fp1 = 1, Fp2 = 15, VEOG = 33
        EEG  = pop_artstep( EEG , 'Channel',  [1 15 33], 'Flag', 2,...
            'Threshold',  80, 'Twindow', artRejectEpoch,...
            'Windowsize',  200, 'Windowstep',  100 );
        EEG = eeg_checkset( EEG );

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
        EEG  = pop_artstep( EEG , 'Channel',  34, 'Flag', 3,...
            'Threshold',  30, 'Twindow', artRejectEpoch,...
            'Windowsize',  200, 'Windowstep',  100 );
        EEG = eeg_checkset( EEG );
    end
    
    % Convert data to current source density (basic parameters from gui)
    % This is a reference-free, spherical spline interpolation method that
    % reduces volume conduction across electrodes
    % using the CSD toolbox (Kayser
    EEGcsd = pop_currentsourcedensityNoGui(EEG);
    EEGcsd = eeg_checkset(EEGcsd);
    
    % Create average ERPs
    ERP = pop_averager( EEG , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );
    ERPcsd = pop_averager( EEGcsd , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );
    
    % Get contra/ipsi electrode pairs
    contraIpsiElecs = splitbrain(ERP);
    % Define Midline & EOG electrodes
    midlineElecs = find(~ismember(1:35,contraIpsiElecs{1,1}));
    
    % Separate left/right for ease
    leftElecs = contraIpsiElecs{1,1}(:,1);
    rightElecs = contraIpsiElecs{1,1}(:,2);
    
    % Make Contra/Ipsi Temp Structures
    EEGci = EEG;
    EEGcsdCI = EEGcsd;
    
        % Contra/Ipsi calculation for each trial
    % Left will be Contra-Ipsi, Right will be Ipsi-Contra
    for j = 1:EEGci.trials
        if EEG.event(j).targetLocation == 1 % Target on Left
            EEGci.data(leftElecs,:,j) = .5*EEG.data(rightElecs,:,j) + .5*EEG.data(leftElecs,:,j);
            EEGci.data(rightElecs,:,j) = .5*EEG.data(leftElecs,:,j) + .5*EEG.data(rightElecs,:,j);
            EEGci.data(midlineElecs,:,j) = 0; % Subtracting midline from midline = 0
            
            EEGcsdCI.data(leftElecs,:,j) = .5*EEGcsd.data(rightElecs,:,j) + .5*EEGcsd.data(leftElecs,:,j);
            EEGcsdCI.data(rightElecs,:,j) = .5*EEGcsd.data(leftElecs,:,j) + .5*EEGcsd.data(rightElecs,:,j);
            EEGcsdCI.data(midlineElecs,:,j) = 0; % Subtracting midline from midline = 0
        elseif EEG.event(j).targetLocation == 2 % Target on Right
            EEGci.data(leftElecs,:,j) = .5*EEG.data(leftElecs,:,j) + .5*EEG.data(rightElecs,:,j);
            EEGci.data(rightElecs,:,j) = .5*EEG.data(rightElecs,:,j) + .5*EEG.data(leftElecs,:,j);
            EEGci.data(midlineElecs,:,j) = 0; % Subtracting midline from midline = 0
            
            EEGcsdCI.data(leftElecs,:,j) = .5*EEGcsd.data(leftElecs,:,j) + .5*EEGcsd.data(rightElecs,:,j);
            EEGcsdCI.data(rightElecs,:,j) = .5*EEGcsd.data(rightElecs,:,j) + .5*EEGcsd.data(leftElecs,:,j);
            EEGcsdCI.data(midlineElecs,:,j) = 0; % Subtracting midline from midline = 0
        end
    end
    
    % Save the data to Matlab file
    outFileName = strcat(subNum,'_',prefix,'_EEG_WithHiCoh_QuartCurv',suffix,'_Dir');
    outFileNameCSD = strcat(subNum,'_',prefix,'_EEGcsd_WithHiCoh_QuartCurv',suffix,'_Dir');
    
    % Save the data to Matlab file
    outFileNameCI = strcat(subNum,'_',prefix,'_EEG_WithHiCoh_QuartCurv',suffix,'_ContraIpsi');
    outFileNameCSDci = strcat(subNum,'_',prefix,'_EEGcsd_WithHiCoh_QuartCurv',suffix,'_ContraIpsi');
    cd(dataPath);
    
    save(outFileName,'EEG');
    save(outFileNameCSD,'EEGcsd');
    
    save(outFileNameCI,'EEGci');
    save(outFileNameCSDci,'EEGcsdCI');
    
    % Save EEG.set file
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, find(goodSubs == u),'savenew',strcat(subNum,'_',prefix,'_EEG_WithHiCoh_QuartCurv',suffix,'_Dir'),'gui','off');
    [ALLEEGcsd EEGcsd CURRENTSETcsd] = pop_newset(ALLEEGcsd, EEGcsd, find(goodSubs == u),'savenew',strcat(subNum,'_',prefix,'_EEGcsd_WithHiCoh_QuartCurv',suffix,'_Dir'),'gui','off');
    
    % Save EEG.set file
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, find(goodSubs == u),'savenew',strcat(subNum,'_',prefix,'_EEG_WithHiCoh_QuartCurv',suffix,'_ContraIpsi'),'gui','off');
    [ALLEEGcsd EEGcsd CURRENTSETcsd] = pop_newset(ALLEEGcsd, EEGcsd, find(goodSubs == u),'savenew',strcat(subNum,'_',prefix,'_EEGcsd_WithHiCoh_QuartCurv',suffix,'_ContraIpsi'),'gui','off');

    % Create temp files for CI calculations
    ERPci = ERP;
    ERPcsdCI = ERPcsd;
    
    % Contra/Ipsi Calculation
    ERPci = pop_binoperator( ERPci, {  'prepareContraIpsi',  'Lch = [ 1:14 29:35]',  'Rch = 15:35',  'nbin1 = 0.5*bin1@Rch + 0.5*bin5@Lch label LoCohQ1 Contra',...
        'nbin2 = 0.5*bin1@Lch + 0.5*bin5@Rch label LoCohQ1 Ipsi',  'nbin3 = 0.5*bin2@Rch + 0.5*bin6@Lch label LoCohQ2 Contra',...
        'nbin4 = 0.5*bin2@Lch + 0.5*bin6@Rch label LoCohQ2 Ipsi',  'nbin5 = 0.5*bin3@Rch + 0.5*bin7@Lch label LoCohQ3 Contra',...
        'nbin6 = 0.5*bin3@Lch + 0.5*bin7@Rch label LoCohQ3 Ipsi',  'nbin7 = 0.5*bin4@Rch + 0.5*bin8@Lch label LoChoQ4 Contra',  'nbin8 = 0.5*bin4@Lch + 0.5*bin8@Rch label LoChoQ4 Ipsi',...
        'nbin9 = 0.5*bin9@Rch + 0.5*bin10@Lch label HiCoh Contra',  'nbin10 = 0.5*bin9@Lch + 0.5*bin10@Rch label HiCoh Ipsi',...
        'nbin11 = 0.5*bin11@Rch + 0.5*bin12@Lch label LoCohErr Contra',  'nbin12 = 0.5*bin11@Lch + 0.5*bin12@Rch label LoCohErr Ipsi'});
    
    % Make Difference Waves
    ERPci = pop_binoperator( ERPci, {  'bin13 = bin1 - bin2 label LoCohQ1 Contra-Ipsi',  'bin14 = bin3 - bin4 label LoCohQ2 Contra-Ipsi',...
        'bin15 = bin5 - bin6 label LoCohQ3 Contra-Ipsi',  'bin16 = bin7 - bin8 label LoChoQ4 Contra-Ipsi',  'bin17 = bin9 - bin10 label HiCoh Contra-Ipsi',...
        'bin18 = bin11 - bin12 label LoCohErr Contra-Ipsi'});
    
    % Contra/Ipsi Calculation
    ERPcsdCI = pop_binoperator( ERPcsdCI, {  'prepareContraIpsi',  'Lch = [ 1:14 29:35]',  'Rch = 15:35',  'nbin1 = 0.5*bin1@Rch + 0.5*bin5@Lch label LoCohQ1 Contra',...
        'nbin2 = 0.5*bin1@Lch + 0.5*bin5@Rch label LoCohQ1 Ipsi',  'nbin3 = 0.5*bin2@Rch + 0.5*bin6@Lch label LoCohQ2 Contra',...
        'nbin4 = 0.5*bin2@Lch + 0.5*bin6@Rch label LoCohQ2 Ipsi',  'nbin5 = 0.5*bin3@Rch + 0.5*bin7@Lch label LoCohQ3 Contra',...
        'nbin6 = 0.5*bin3@Lch + 0.5*bin7@Rch label LoCohQ3 Ipsi',  'nbin7 = 0.5*bin4@Rch + 0.5*bin8@Lch label LoChoQ4 Contra',  'nbin8 = 0.5*bin4@Lch + 0.5*bin8@Rch label LoChoQ4 Ipsi',...
        'nbin9 = 0.5*bin9@Rch + 0.5*bin10@Lch label HiCoh Contra',  'nbin10 = 0.5*bin9@Lch + 0.5*bin10@Rch label HiCoh Ipsi',...
        'nbin11 = 0.5*bin11@Rch + 0.5*bin12@Lch label LoCohErr Contra',  'nbin12 = 0.5*bin11@Lch + 0.5*bin12@Rch label LoCohErr Ipsi'});
    
    % Make Difference Waves
    ERPcsdCI = pop_binoperator( ERPcsdCI, {  'bin13 = bin1 - bin2 label LoCohQ1 Contra-Ipsi',  'bin14 = bin3 - bin4 label LoCohQ2 Contra-Ipsi',...
        'bin15 = bin5 - bin6 label LoCohQ3 Contra-Ipsi',  'bin16 = bin7 - bin8 label LoChoQ4 Contra-Ipsi',  'bin17 = bin9 - bin10 label HiCoh Contra-Ipsi',...
        'bin18 = bin11 - bin12 label LoCohErr Contra-Ipsi'});
    
    % Apply Lo-Pass Filter (30 Hz) & remove DC bias for plotting
    ERPlpf = pop_filterp( ERP,  1:35 , 'Cutoff',  30, 'Design', 'butter', 'Filter', 'lowpass', 'Order',  2 );
    ERPcsdLPF = pop_filterp( ERPcsd,  1:35 , 'Cutoff',  30, 'Design', 'butter', 'Filter', 'lowpass', 'Order',  2 );
    
    % Apply Lo-Pass Filter (30 Hz) & remove DC bias for plotting
    ERPlpfCI = pop_filterp( ERPci,  1:35 , 'Cutoff',  30, 'Design', 'butter', 'Filter', 'lowpass', 'Order',  2 );
    ERPcsdLPFci = pop_filterp( ERPcsdCI,  1:35 , 'Cutoff',  30, 'Design', 'butter', 'Filter', 'lowpass', 'Order',  2 );
    
    % Alternative: filter in time-domain by smoothing data by a 7-point
    % moving average (either is kosher; all analyses are done on data prior
    % to either smoothing technique, so just pick what pakes the plots the
    % prettiest)
    ERPsmooth = pop_smootherpNoGui(ERP, 7, 0);
    ERPcsdSmooth = pop_smootherpNoGui(ERPcsd, 7, 0);
    
    ERPsmoothCI = pop_smootherpNoGui(ERPci, 7, 0);
    ERPcsdSmoothCI = pop_smootherpNoGui(ERPcsdCI, 7, 0);
    
    % Save the ERP files
    ERP = pop_savemyerp(ERP, 'erpname', strcat(subNum,'_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_Dir'),...
        'filename', strcat(subNum,'_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_Dir.erp'), 'Warning', 'on', 'gui', 'off');
    ERPcsd = pop_savemyerp(ERPcsd, 'erpname', strcat(subNum,'_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_Dir'),...
        'filename', strcat(subNum,'_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_Dir.erp'), 'Warning', 'on', 'gui', 'off');
    
    ERPci = pop_savemyerp(ERPci, 'erpname', strcat(subNum,'_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_ContraIpsi'),...
        'filename', strcat(subNum,'_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_ContraIpsi.erp'), 'Warning', 'on', 'gui', 'off');
    ERPcsdCI = pop_savemyerp(ERPcsdCI, 'erpname', strcat(subNum,'_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_ContraIpsi'),...
        'filename', strcat(subNum,'_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_ContraIpsi.erp'), 'Warning', 'on', 'gui', 'off');
    
    % Save the LPF ERP files
    ERPlpf = pop_savemyerp(ERPlpf, 'erpname', strcat(subNum,'_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_Dir_LPF'),...
        'filename', strcat(subNum,'_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_Dir_LPF.erp'), 'Warning', 'on', 'gui', 'off');
    ERPcsdLPF = pop_savemyerp(ERPcsdLPF, 'erpname', strcat(subNum,'_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_Dir_LPF'),...
        'filename', strcat(subNum,'_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_Dir_LPF.erp'), 'Warning', 'on', 'gui', 'off');
    
    ERPlpfCI = pop_savemyerp(ERPlpfCI, 'erpname', strcat(subNum,'_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_ContraIpsi_LPF'),...
        'filename', strcat(subNum,'_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_ContraIpsi_LPF.erp'), 'Warning', 'on', 'gui', 'off');
    ERPcsdLPFci = pop_savemyerp(ERPcsdLPFci, 'erpname', strcat(subNum,'_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_ContraIpsi_LPF'),...
        'filename', strcat(subNum,'_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_ContraIpsi_LPF.erp'), 'Warning', 'on', 'gui', 'off');
    
    % Save the time-smoothed ERP files
    ERPsmooth = pop_savemyerp(ERPsmooth, 'erpname', strcat(subNum,'_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_Dir_Smooth'),...
        'filename', strcat(subNum,'_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_Dir_Smooth.erp'), 'Warning', 'on', 'gui', 'off');
    ERPcsdSmooth = pop_savemyerp(ERPcsdSmooth, 'erpname', strcat(subNum,'_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_Dir_Smooth'),...
        'filename', strcat(subNum,'_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_Dir_Smooth.erp'), 'Warning', 'on', 'gui', 'off');
    
    ERPsmoothCI = pop_savemyerp(ERPsmoothCI, 'erpname', strcat(subNum,'_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_ContraIpsi_Smooth'),...
        'filename', strcat(subNum,'_',prefix,'_ERP_WithHiCoh_QuartCurv',suffix,'_ContraIpsi_Smooth.erp'), 'Warning', 'on', 'gui', 'off');
    ERPcsdSmoothCI = pop_savemyerp(ERPcsdSmoothCI, 'erpname', strcat(subNum,'_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_ContraIpsi_Smooth'),...
        'filename', strcat(subNum,'_',prefix,'_ERPcsd_WithHiCoh_QuartCurv',suffix,'_ContraIpsi_Smooth.erp'), 'Warning', 'on', 'gui', 'off');
    
    % Clear these for looping to next subject
    clearvars EEG ERP EEGcsd ERPcsd ERPlpf ERPcsdLPF ERPsmooth ERPcsdSmooth...
        EEGci ERPci EEGcsdCI ERPcsdCI ERPlpfCI ERPcsdLPFci ERPsmoothCI ERPcsdSmoothCI
    
end

% Move CSD files to folder
mkdir('CSD');
movefile(strcat(pwd,'/*csd*'),strcat(pwd,'/CSD/'));
end

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

