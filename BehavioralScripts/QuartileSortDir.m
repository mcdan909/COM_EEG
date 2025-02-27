%% Create curvature quartiles based upon equal number of trials for each
%% target location

clear all;

cd '~/Documents/projects/COM_EEG/Data/BehavioralDataOrig'

movementFiles = dir('*.mat');

totalCOMS = [];
% :length(movementFiles)
for currFile = 15
    load(movementFiles(currFile).name);

    % Make an index of trial numbers
    trialIdx = 1:length(maxDeviation);
    trialIdx = trialIdx';
    
    trialIdxL = 1:sum(targetLocation ==1);
    trialIdxL = trialIdxL';
    
    trialIdxR = 1:sum(targetLocation ==2);
    trialIdxR = trialIdxR';
    
    unsignedCurvLoCohAccIdxR = [];
    unsignedCurvLoCohAccR = [];
    unsignedCurvLoCohErrIdxR = [];
    unsignedCurvLoCohErrR = [];
    
    unsignedCurvLoCohAccIdxL = [];
    unsignedCurvLoCohAccL = [];
    unsignedCurvLoCohErrIdxL = [];
    unsignedCurvLoCohErrL = [];
    
    unsignedCurvHiCohAccIdxR = [];
    unsignedCurvHiCohAccR = [];
    unsignedCurvHiCohErrIdxR = [];
    unsignedCurvHiCohErrR = [];
    
    unsignedCurvHiCohAccIdxL = [];
    unsignedCurvHiCohAccL = [];
    unsignedCurvHiCohErrIdxL = [];
    unsignedCurvHiCohErrL = [];
    
    % Get coherence trial curvature values and trial indexes for both
    % accurate and error trials
    for a = 1:length(trialIdx)
        if coherence(a) ~= 1 
            if acc(a) && ~noMovement(a) && ~droppedTrials(a) && reachLand(a)
                if targetLocation(a) == 1
                    unsignedCurvLoCohAccIdxL = [unsignedCurvLoCohAccIdxL;trialIdx(a)];
                    unsignedCurvLoCohAccL = [unsignedCurvLoCohAccL;maxDeviation(a)];
                elseif targetLocation(a) == 2
                    unsignedCurvLoCohAccIdxR = [unsignedCurvLoCohAccIdxR;trialIdx(a)];
                    unsignedCurvLoCohAccR = [unsignedCurvLoCohAccR;maxDeviation(a)];
                end
            else
                if targetLocation(a) == 1
                    unsignedCurvLoCohErrIdxL = [unsignedCurvLoCohErrIdxL;trialIdx(a)];
                    unsignedCurvLoCohErrL = [unsignedCurvLoCohErrL;maxDeviation(a)];
                elseif targetLocation(a) == 2
                    unsignedCurvLoCohErrIdxR = [unsignedCurvLoCohErrIdxR;trialIdx(a)];
                    unsignedCurvLoCohErrR = [unsignedCurvLoCohErrR;maxDeviation(a)];
                end
            end
        elseif coherence(a) == 1
            if acc(a) && ~noMovement(a) && ~droppedTrials(a) && reachLand(a)
                if targetLocation(a) == 1
                    unsignedCurvHiCohAccIdxL = [unsignedCurvHiCohAccIdxL;trialIdx(a)];
                    unsignedCurvHiCohAccL = [unsignedCurvHiCohAccL;maxDeviation(a)];
                elseif targetLocation(a) == 2
                    unsignedCurvHiCohAccIdxR = [unsignedCurvHiCohAccIdxR;trialIdx(a)];
                    unsignedCurvHiCohAccR = [unsignedCurvHiCohAccR;maxDeviation(a)];
                end
            else
                if targetLocation(a) == 1
                    unsignedCurvHiCohErrIdxL = [unsignedCurvHiCohErrIdxL;trialIdx(a)];
                    unsignedCurvHiCohErrL = [unsignedCurvHiCohErrL;maxDeviation(a)];
                elseif targetLocation(a) == 2
                    unsignedCurvHiCohErrIdxR = [unsignedCurvHiCohErrIdxR;trialIdx(a)];
                    unsignedCurvHiCohErrR = [unsignedCurvHiCohErrR;maxDeviation(a)];
                end
            end
        end
    end
    
    % Combine indexes and values for trial IDed sorting
    unsignedCurvLoCohAccTrialwiseL = [unsignedCurvLoCohAccIdxL,unsignedCurvLoCohAccL];
    unsignedCurvLoCohErrTrialwiseL = [unsignedCurvLoCohErrIdxL,unsignedCurvLoCohErrL];
    
    unsignedCurvLoCohAccTrialwiseR = [unsignedCurvLoCohAccIdxR,unsignedCurvLoCohAccR];
    unsignedCurvLoCohErrTrialwiseR = [unsignedCurvLoCohErrIdxR,unsignedCurvLoCohErrR];
    
    unsignedCurvHiCohAccTrialwiseL = [unsignedCurvHiCohAccIdxL,unsignedCurvHiCohAccL];
    unsignedCurvHiCohErrTrialwiseL = [unsignedCurvHiCohErrIdxL,unsignedCurvHiCohErrL];
    
    unsignedCurvHiCohAccTrialwiseR = [unsignedCurvHiCohAccIdxR,unsignedCurvHiCohAccR];
    unsignedCurvHiCohErrTrialwiseR = [unsignedCurvHiCohErrIdxR,unsignedCurvHiCohErrR];
    
    % sort low to high for loCoh Trials
    unsignedCurvSortLoCohAccTrialwiseL = sortrows(unsignedCurvLoCohAccTrialwiseL,2);
    unsignedCurvSortLoCohAccTrialwiseR = sortrows(unsignedCurvLoCohAccTrialwiseR,2);
    
    % get number of low coherence trials
    nLoCohTrials = length(unsignedCurvSortLoCohAccTrialwiseL)+...
        length(unsignedCurvSortLoCohAccTrialwiseR);
    
    nLoCohTrialsL = length(unsignedCurvSortLoCohAccTrialwiseL);
    nLoCohTrialsR = length(unsignedCurvSortLoCohAccTrialwiseR);
    
    % get temp index values for quartiles
    trialsOneQuartL = nLoCohTrialsL/4;
    trialsMidptL = nLoCohTrialsL/2;
    
    trialsOneQuartR = nLoCohTrialsR/4;
    trialsMidptR = nLoCohTrialsR/2;
    
    % round if trial numbers are uneven
    if ~isint(trialsOneQuartL)
        trialsOneQuartL = round(trialsOneQuartL);
    end
    
    if ~isint(trialsMidptL)
        trialsMidptL = round(trialsMidptL);
    end
    
    if ~isint(trialsOneQuartR)
        trialsOneQuartR = round(trialsOneQuartR);
    end
    
    if ~isint(trialsMidptR)
        trialsMidptR = round(trialsMidptR);
    end
    
    trialsThreeQuartL = trialsOneQuartL+trialsMidptL;
    trialsThreeQuartR = trialsOneQuartR+trialsMidptR;
    
    % Sort accurate low coherence trials into quarters
    unsignedCurvSortLoCohAccTrialwiseQ1L = unsignedCurvSortLoCohAccTrialwiseL(1:trialsOneQuartL,:);
    unsignedCurvSortLoCohAccTrialwiseQ2L = unsignedCurvSortLoCohAccTrialwiseL(trialsOneQuartL+1:trialsMidptL,:);
    unsignedCurvSortLoCohAccTrialwiseQ3L = unsignedCurvSortLoCohAccTrialwiseL(trialsMidptL+1:trialsThreeQuartL,:);
    unsignedCurvSortLoCohAccTrialwiseQ4L = unsignedCurvSortLoCohAccTrialwiseL(trialsThreeQuartL+1:end,:);
    
    unsignedCurvSortLoCohAccTrialwiseQ1R = unsignedCurvSortLoCohAccTrialwiseR(1:trialsOneQuartR,:);
    unsignedCurvSortLoCohAccTrialwiseQ2R = unsignedCurvSortLoCohAccTrialwiseR(trialsOneQuartR+1:trialsMidptR,:);
    unsignedCurvSortLoCohAccTrialwiseQ3R = unsignedCurvSortLoCohAccTrialwiseR(trialsMidptR+1:trialsThreeQuartR,:);
    unsignedCurvSortLoCohAccTrialwiseQ4R = unsignedCurvSortLoCohAccTrialwiseR(trialsThreeQuartR+1:end,:);
    
    % Make a dummy array and assign quartiles based on groups
    unsignedCurvQuart = NaN(length(trialIdxL)+length(trialIdxL),1);
    
    unsignedCurvQuartL = NaN(length(trialIdxL),1);
    unsignedCurvQuartR = NaN(length(trialIdxR),1);
    
    % Collapse across target locations
    unsignedCurvQuart(unsignedCurvLoCohErrTrialwiseL(:,1)) = 0;
    unsignedCurvQuart(unsignedCurvSortLoCohAccTrialwiseQ1L(:,1)) = 1;
    unsignedCurvQuart(unsignedCurvSortLoCohAccTrialwiseQ2L(:,1)) = 2;
    unsignedCurvQuart(unsignedCurvSortLoCohAccTrialwiseQ3L(:,1)) = 3;
    unsignedCurvQuart(unsignedCurvSortLoCohAccTrialwiseQ4L(:,1)) = 4;
    unsignedCurvQuart(unsignedCurvHiCohAccTrialwiseL(:,1)) = 5;
    if ~isempty(unsignedCurvHiCohErrTrialwiseL)
        unsignedCurvQuart(unsignedCurvHiCohErrTrialwiseL(:,1)) = 6;
    end
    
    unsignedCurvQuart(unsignedCurvLoCohErrTrialwiseR(:,1)) = 0;
    unsignedCurvQuart(unsignedCurvSortLoCohAccTrialwiseQ1R(:,1)) = 1;
    unsignedCurvQuart(unsignedCurvSortLoCohAccTrialwiseQ2R(:,1)) = 2;
    unsignedCurvQuart(unsignedCurvSortLoCohAccTrialwiseQ3R(:,1)) = 3;
    unsignedCurvQuart(unsignedCurvSortLoCohAccTrialwiseQ4R(:,1)) = 4;
    unsignedCurvQuart(unsignedCurvHiCohAccTrialwiseR(:,1)) = 5;
    if ~isempty(unsignedCurvHiCohErrTrialwiseR)
        unsignedCurvQuart(unsignedCurvHiCohErrTrialwiseR(:,1)) = 6;
    end
    
    % Separate by target location
    unsignedCurvQuartL(unsignedCurvLoCohErrTrialwiseL(:,1)) = 0;
    unsignedCurvQuartL(unsignedCurvSortLoCohAccTrialwiseQ1L(:,1)) = 1;
    unsignedCurvQuartL(unsignedCurvSortLoCohAccTrialwiseQ2L(:,1)) = 2;
    unsignedCurvQuartL(unsignedCurvSortLoCohAccTrialwiseQ3L(:,1)) = 3;
    unsignedCurvQuartL(unsignedCurvSortLoCohAccTrialwiseQ4L(:,1)) = 4;
    unsignedCurvQuartL(unsignedCurvHiCohAccTrialwiseL(:,1)) = 5;
    if ~isempty(unsignedCurvHiCohErrTrialwiseL)
        unsignedCurvQuartL(unsignedCurvHiCohErrTrialwiseL(:,1)) = 6;
    end
    
    unsignedCurvQuartR(unsignedCurvLoCohErrTrialwiseR(:,1)) = 0;
    unsignedCurvQuartR(unsignedCurvSortLoCohAccTrialwiseQ1R(:,1)) = 1;
    unsignedCurvQuartR(unsignedCurvSortLoCohAccTrialwiseQ2R(:,1)) = 2;
    unsignedCurvQuartR(unsignedCurvSortLoCohAccTrialwiseQ3R(:,1)) = 3;
    unsignedCurvQuartR(unsignedCurvSortLoCohAccTrialwiseQ4R(:,1)) = 4;
    unsignedCurvQuartR(unsignedCurvHiCohAccTrialwiseR(:,1)) = 5;
    if ~isempty(unsignedCurvHiCohErrTrialwiseR)
        unsignedCurvQuartR(unsignedCurvHiCohErrTrialwiseR(:,1)) = 6;
    end
    
    % make a matrix of values for the number of trials in each quartile
	nTrialsCond = [sum(unsignedCurvQuart == 0), sum(unsignedCurvQuart == 1),...
        sum(unsignedCurvQuart == 2), sum(unsignedCurvQuart == 3),...
        sum(unsignedCurvQuart == 4), sum(unsignedCurvQuart == 5),...
        sum(unsignedCurvQuart == 6)];
    
    nTrialsCondL = [sum(unsignedCurvQuartL == 0), sum(unsignedCurvQuartL == 1),...
        sum(unsignedCurvQuartL == 2), sum(unsignedCurvQuartL == 3),...
        sum(unsignedCurvQuartL == 4), sum(unsignedCurvQuartL == 5),...
        sum(unsignedCurvQuartL == 6)];
    
    nTrialsCondR = [sum(unsignedCurvQuartR == 0), sum(unsignedCurvQuartR == 1),...
        sum(unsignedCurvQuartR == 2), sum(unsignedCurvQuartR == 3),...
        sum(unsignedCurvQuartR == 4), sum(unsignedCurvQuartR == 5),...
        sum(unsignedCurvQuartR == 6)];
    
%% Now do the same for signed data (+ = toward target, - = away)
    
    % convert curvature to signed curvature
    signedCurv = maxDeviation;
    
    % Convert curvature to signed values
    for i = 1:totalTrials
        if signOfCurvature(i) == -1
            signedCurv(i) = -signedCurv(i);
        else
        end
    end
    
    posCurvLoCohAccIdxL = [];
    posCurvLoCohAccL = [];
    posCurvLoCohErrIdxL = [];
    posCurvLoCohErrL = [];
    
    posCurvLoCohAccIdxR = [];
    posCurvLoCohAccR = [];
    posCurvLoCohErrIdxR = [];
    posCurvLoCohErrR = [];
    
    posCurvHiCohAccIdxL = [];
    posCurvHiCohAccL = [];
    posCurvHiCohErrIdxL = [];
    posCurvHiCohErrL = [];
    
    posCurvHiCohAccIdxR = [];
    posCurvHiCohAccR = [];
    posCurvHiCohErrIdxR = [];
    posCurvHiCohErrR = [];
    
    negCurvIdxL = [];
    negCurvL = [];
    
    negCurvIdxR = [];
    negCurvR = [];
    
    % Get coherence trial curvature values and trial indexes for both
    % accurate and error trials
    for a = 1:length(trialIdx)
        if coherence(a) ~= 1 
            if acc(a) && ~noMovement(a) && ~droppedTrials(a) && reachLand(a) && signedCurv(a) > 0
                if targetLocation(a) == 1
                    posCurvLoCohAccIdxL = [posCurvLoCohAccIdxL;trialIdx(a)];
                    posCurvLoCohAccL = [posCurvLoCohAccL;signedCurv(a)];
                elseif targetLocation(a) == 2
                    posCurvLoCohAccIdxR = [posCurvLoCohAccIdxR;trialIdx(a)];
                    posCurvLoCohAccR = [posCurvLoCohAccR;signedCurv(a)];
                end
            else
                if targetLocation(a) == 1
                    posCurvLoCohErrIdxL = [posCurvLoCohErrIdxL;trialIdx(a)];
                    posCurvLoCohErrL = [posCurvLoCohErrL;signedCurv(a)];
                elseif targetLocation(a) == 2
                    posCurvLoCohErrIdxR = [posCurvLoCohErrIdxR;trialIdx(a)];
                    posCurvLoCohErrR = [posCurvLoCohErrR;signedCurv(a)];
                end  
            end
        elseif coherence(a) == 1
            if acc(a) && ~noMovement(a) && ~droppedTrials(a) && reachLand(a) && signedCurv(a) > 0
                if targetLocation(a) == 1
                    posCurvHiCohAccIdxL = [posCurvHiCohAccIdxL;trialIdx(a)];
                    posCurvHiCohAccL = [posCurvHiCohAccL;signedCurv(a)];
                elseif targetLocation(a) == 2
                    posCurvHiCohAccIdxR = [posCurvHiCohAccIdxR;trialIdx(a)];
                    posCurvHiCohAccR = [posCurvHiCohAccR;signedCurv(a)];
                end
            else
                if targetLocation(a) == 1
                    posCurvHiCohErrIdxL = [posCurvHiCohErrIdxL;trialIdx(a)];
                    posCurvHiCohErrL = [posCurvHiCohErrL;signedCurv(a)];
                elseif targetLocation(a) == 2
                    posCurvHiCohErrIdxR = [posCurvHiCohErrIdxR;trialIdx(a)];
                    posCurvHiCohErrR = [posCurvHiCohErrR;signedCurv(a)];
                end
            end
        end
        if signedCurv(a) < 0
            if targetLocation(a) == 1
                negCurvIdxL = [negCurvIdxL;trialIdx(a)];
                negCurvL = [negCurvL;signedCurv(a)];
            elseif targetLocation(a) == 2
                if ~isempty(negCurvIdxR)
                    negCurvIdxR = [negCurvIdxR;trialIdx(a)];
                    negCurvR = [negCurvR;signedCurv(a)];
                end
            end
        end
    end
    
    % Combine indexes and values for trial IDed sorting
    posCurvLoCohAccTrialwiseL = [posCurvLoCohAccIdxL,posCurvLoCohAccL];
    posCurvLoCohErrTrialwiseL = [posCurvLoCohErrIdxL,posCurvLoCohErrL];
    
    posCurvLoCohAccTrialwiseR = [posCurvLoCohAccIdxR,posCurvLoCohAccR];
    posCurvLoCohErrTrialwiseR = [posCurvLoCohErrIdxR,posCurvLoCohErrR];
    
    posCurvHiCohAccTrialwiseL = [posCurvHiCohAccIdxL,posCurvHiCohAccL];
    posCurvHiCohErrTrialwiseL = [posCurvHiCohErrIdxL,posCurvHiCohErrL];
    
    posCurvHiCohAccTrialwiseR = [posCurvHiCohAccIdxR,posCurvHiCohAccR];
    posCurvHiCohErrTrialwiseR = [posCurvHiCohErrIdxR,posCurvHiCohErrR];
    
    negCurvTrialwiseL = [negCurvIdxL,negCurvL];
    negCurvTrialwiseR = [negCurvIdxR,negCurvR];
    
    % sort low to high for loCoh Trials
    posCurvSortLoCohAccTrialwiseL = sortrows(posCurvLoCohAccTrialwiseL,2);
    posCurvSortLoCohAccTrialwiseR = sortrows(posCurvLoCohAccTrialwiseR,2);
    
    % get number of low coherence trials
    nLoCohTrialsPos = length(posCurvSortLoCohAccTrialwiseL)+...
        length(posCurvSortLoCohAccTrialwiseR);
    
    nLoCohTrialsPosL = length(posCurvSortLoCohAccTrialwiseL);
    nLoCohTrialsPosR = length(posCurvSortLoCohAccTrialwiseR);
    
    % get temp index values for quartiles
    trialsOneQuartPosL = nLoCohTrialsPosL/4;
    trialsMidptPosL = nLoCohTrialsPosL/2;
    
    trialsOneQuartPosR = nLoCohTrialsPosR/4;
    trialsMidptPosR = nLoCohTrialsPosR/2;
    
    % round if trial numbers are uneven
    if ~isint(trialsOneQuartPosL)
        trialsOneQuartPosL = round(trialsOneQuartPosL);
    end
    
    if ~isint(trialsMidptPosL)
        trialsMidptPosL = round(trialsMidptPosL);
    end
    
    if ~isint(trialsOneQuartPosR)
        trialsOneQuartPosR = round(trialsOneQuartPosR);
    end
    
    if ~isint(trialsMidptPosR)
        trialsMidptPosR = round(trialsMidptPosR);
    end
    
    trialsThreeQuartPosL = trialsOneQuartPosL+trialsMidptPosL;
    trialsThreeQuartPosR = trialsOneQuartPosR+trialsMidptPosR;
    
    % Sort accurate low coherence trials into quarters
    posCurvSortLoCohAccTrialwiseQ1L = posCurvSortLoCohAccTrialwiseL(1:trialsOneQuartPosL,:);
    posCurvSortLoCohAccTrialwiseQ2L = posCurvSortLoCohAccTrialwiseL(trialsOneQuartPosL+1:trialsMidptPosL,:);
    posCurvSortLoCohAccTrialwiseQ3L = posCurvSortLoCohAccTrialwiseL(trialsMidptPosL+1:trialsThreeQuartPosL,:);
    posCurvSortLoCohAccTrialwiseQ4L = posCurvSortLoCohAccTrialwiseL(trialsThreeQuartPosL+1:end,:);
    
    posCurvSortLoCohAccTrialwiseQ1R = posCurvSortLoCohAccTrialwiseR(1:trialsOneQuartPosR,:);
    posCurvSortLoCohAccTrialwiseQ2R = posCurvSortLoCohAccTrialwiseR(trialsOneQuartPosR+1:trialsMidptPosR,:);
    posCurvSortLoCohAccTrialwiseQ3R = posCurvSortLoCohAccTrialwiseR(trialsMidptPosR+1:trialsThreeQuartPosR,:);
    posCurvSortLoCohAccTrialwiseQ4R = posCurvSortLoCohAccTrialwiseR(trialsThreeQuartPosR+1:end,:);
    
    % Make a dummy array and assign quartiles based on groups
    signedCurvQuart = NaN(length(trialIdx),1);
    
    signedCurvQuartL = NaN(length(trialIdxL),1);
    signedCurvQuartR = NaN(length(trialIdxR),1);
    
    % Collapse across target locations
    signedCurvQuart(posCurvLoCohErrTrialwiseL(:,1)) = 0;
    signedCurvQuart(posCurvSortLoCohAccTrialwiseQ1L(:,1)) = 1;
    signedCurvQuart(posCurvSortLoCohAccTrialwiseQ2L(:,1)) = 2;
    signedCurvQuart(posCurvSortLoCohAccTrialwiseQ3L(:,1)) = 3;
    signedCurvQuart(posCurvSortLoCohAccTrialwiseQ4L(:,1)) = 4;
    signedCurvQuart(posCurvHiCohAccTrialwiseL(:,1)) = 5;
    signedCurvQuart(posCurvHiCohErrTrialwiseL(:,1)) = 6;
    signedCurvQuart(negCurvTrialwiseL(:,1)) = -1;
    
    signedCurvQuart(posCurvLoCohErrTrialwiseR(:,1)) = 0;
    signedCurvQuart(posCurvSortLoCohAccTrialwiseQ1R(:,1)) = 1;
    signedCurvQuart(posCurvSortLoCohAccTrialwiseQ2R(:,1)) = 2;
    signedCurvQuart(posCurvSortLoCohAccTrialwiseQ3R(:,1)) = 3;
    signedCurvQuart(posCurvSortLoCohAccTrialwiseQ4R(:,1)) = 4;
    signedCurvQuart(posCurvHiCohAccTrialwiseR(:,1)) = 5;
    if ~isempty(posCurvHiCohErrTrialwiseR)
        signedCurvQuart(posCurvHiCohErrTrialwiseR(:,1)) = 6;
    end
    if ~isempty(negCurvTrialwiseR)
        signedCurvQuart(negCurvTrialwiseR(:,1)) = -1;
    end
    
    % Separate by target location
    signedCurvQuartL(posCurvLoCohErrTrialwiseL(:,1)) = 0;
    signedCurvQuartL(posCurvSortLoCohAccTrialwiseQ1L(:,1)) = 1;
    signedCurvQuartL(posCurvSortLoCohAccTrialwiseQ2L(:,1)) = 2;
    signedCurvQuartL(posCurvSortLoCohAccTrialwiseQ3L(:,1)) = 3;
    signedCurvQuartL(posCurvSortLoCohAccTrialwiseQ4L(:,1)) = 4;
    signedCurvQuartL(posCurvHiCohAccTrialwiseL(:,1)) = 5;
    signedCurvQuartL(posCurvHiCohErrTrialwiseL(:,1)) = 6;
    signedCurvQuartL(negCurvTrialwiseL(:,1)) = -1;
    
    signedCurvQuartR(posCurvLoCohErrTrialwiseR(:,1)) = 0;
    signedCurvQuartR(posCurvSortLoCohAccTrialwiseQ1R(:,1)) = 1;
    signedCurvQuartR(posCurvSortLoCohAccTrialwiseQ2R(:,1)) = 2;
    signedCurvQuartR(posCurvSortLoCohAccTrialwiseQ3R(:,1)) = 3;
    signedCurvQuartR(posCurvSortLoCohAccTrialwiseQ4R(:,1)) = 4;
    signedCurvQuartR(posCurvHiCohAccTrialwiseR(:,1)) = 5;
    if ~isempty(posCurvHiCohErrTrialwiseR)
        signedCurvQuartR(posCurvHiCohErrTrialwiseR(:,1)) = 6;
    end
    if ~isempty(negCurvTrialwiseR)
        signedCurvQuart(negCurvTrialwiseR(:,1)) = -1;
    end
    
    % make a matrix of values for the number of trials in each quartile
	nTrialsCondSigned = [sum(signedCurvQuart == 0), sum(signedCurvQuart == 1),...
        sum(signedCurvQuart == 2), sum(signedCurvQuart == 3),...
        sum(signedCurvQuart == 4), sum(signedCurvQuart == 5),...
        sum(signedCurvQuart == 6), sum(signedCurvQuart == -1)];
    
    nTrialsCondSignedL = [sum(signedCurvQuartL == 0), sum(signedCurvQuartL == 1),...
        sum(signedCurvQuartL == 2), sum(signedCurvQuartL == 3),...
        sum(signedCurvQuartL == 4), sum(signedCurvQuartL == 5),...
        sum(signedCurvQuartL == 6), sum(signedCurvQuartL == -1)];
    
    nTrialsCondSignedR = [sum(signedCurvQuartR == 0), sum(signedCurvQuartR == 1),...
        sum(signedCurvQuartR == 2), sum(signedCurvQuartR == 3),...
        sum(signedCurvQuartR == 4), sum(signedCurvQuartR == 5),...
        sum(signedCurvQuartR == 6), sum(signedCurvQuartR == -1)];
        
    mkdir '~/Documents/projects/COM_EEG/Data/BehavioralDataOrig/SignedQuartileDataDir'

    save(strcat('SignedQuartileDataDir/','QuartDir',movementFiles(currFile).name));
    
end