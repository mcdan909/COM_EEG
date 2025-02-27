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
    
    allCurvLoCohAccIdxL = [];
    allCurvLoCohAccL = [];
    allCurvLoCohErrIdxL = [];
    allCurvLoCohErrL = [];
    
    allCurvLoCohAccIdxR = [];
    allCurvLoCohAccR = [];
    allCurvLoCohErrIdxR = [];
    allCurvLoCohErrR = [];
    
    allCurvHiCohAccIdxL = [];
    allCurvHiCohAccL = [];
    allCurvHiCohErrIdxL = [];
    allCurvHiCohErrL = [];
    
    allCurvHiCohAccIdxR = [];
    allCurvHiCohAccR = [];
    allCurvHiCohErrIdxR = [];
    allCurvHiCohErrR = [];
    
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
            % Make variables separating positive vs. negative curvature as
            % well as all in one
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
            
            if acc(a) && ~noMovement(a) && ~droppedTrials(a) && reachLand(a)
                if targetLocation(a) == 1
                    allCurvLoCohAccIdxL = [allCurvLoCohAccIdxL;trialIdx(a)];
                    allCurvLoCohAccL = [allCurvLoCohAccL;signedCurv(a)];
                elseif targetLocation(a) == 2
                    allCurvLoCohAccIdxR = [allCurvLoCohAccIdxR;trialIdx(a)];
                    allCurvLoCohAccR = [allCurvLoCohAccR;signedCurv(a)];
                end
            else
                if targetLocation(a) == 1
                    allCurvLoCohErrIdxL = [allCurvLoCohErrIdxL;trialIdx(a)];
                    allCurvLoCohErrL = [allCurvLoCohErrL;signedCurv(a)];
                elseif targetLocation(a) == 2
                    allCurvLoCohErrIdxR = [allCurvLoCohErrIdxR;trialIdx(a)];
                    allCurvLoCohErrR = [allCurvLoCohErrR;signedCurv(a)];
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
            
            if acc(a) && ~noMovement(a) && ~droppedTrials(a) && reachLand(a) && signedCurv(a) > 0
                if targetLocation(a) == 1
                    allCurvHiCohAccIdxL = [allCurvHiCohAccIdxL;trialIdx(a)];
                    allCurvHiCohAccL = [allCurvHiCohAccL;signedCurv(a)];
                elseif targetLocation(a) == 2
                    allCurvHiCohAccIdxR = [allCurvHiCohAccIdxR;trialIdx(a)];
                    allCurvHiCohAccR = [allCurvHiCohAccR;signedCurv(a)];
                end
            else
                if targetLocation(a) == 1
                    allCurvHiCohErrIdxL = [allCurvHiCohErrIdxL;trialIdx(a)];
                    allCurvHiCohErrL = [allCurvHiCohErrL;signedCurv(a)];
                elseif targetLocation(a) == 2
                    allCurvHiCohErrIdxR = [allCurvHiCohErrIdxR;trialIdx(a)];
                    allCurvHiCohErrR = [allCurvHiCohErrR;signedCurv(a)];
                end
            end
        end
        % Dump all negative curvatures 
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
    allCurvLoCohAccTrialwiseL = [allCurvLoCohAccIdxL,allCurvLoCohAccL];
    allCurvLoCohErrTrialwiseL = [allCurvLoCohErrIdxL,allCurvLoCohErrL];
    
    allCurvLoCohAccTrialwiseR = [allCurvLoCohAccIdxR,allCurvLoCohAccR];
    allCurvLoCohErrTrialwiseR = [allCurvLoCohErrIdxR,allCurvLoCohErrR];
    
    allCurvHiCohAccTrialwiseL = [allCurvHiCohAccIdxL,allCurvHiCohAccL];
    allCurvHiCohErrTrialwiseL = [allCurvHiCohErrIdxL,allCurvHiCohErrL];
    
    allCurvHiCohAccTrialwiseR = [allCurvHiCohAccIdxR,allCurvHiCohAccR];
    allCurvHiCohErrTrialwiseR = [allCurvHiCohErrIdxR,allCurvHiCohErrR];

    posCurvLoCohAccTrialwiseL = [posCurvLoCohAccIdxL,posCurvLoCohAccL];
    posCurvLoCohErrTrialwiseL = [posCurvLoCohErrIdxL,posCurvLoCohErrL];
    
    posCurvLoCohAccTrialwiseR = [posCurvLoCohAccIdxR,posCurvLoCohAccR];
    posCurvLoCohErrTrialwiseR = [posCurvLoCohErrIdxR,posCurvLoCohErrR];
    
    posCurvHiCohAccTrialwiseL = [posCurvHiCohAccIdxL,posCurvHiCohAccL];
    posCurvHiCohErrTrialwiseL = [posCurvHiCohErrIdxL,posCurvHiCohErrL];
    
    posCurvHiCohAccTrialwiseR = [posCurvHiCohAccIdxR,posCurvHiCohAccR];
    posCurvHiCohErrTrialwiseR = [posCurvHiCohErrIdxR,posCurvHiCohErrR];
    
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
    allCurvSortLoCohAccTrialwiseL = sortrows(allCurvLoCohAccTrialwiseL,2);
    allCurvSortLoCohAccTrialwiseR = sortrows(allCurvLoCohAccTrialwiseR,2);
    
    % Take sorted column of curvature for use below
    allCurvSortLoCohAccL = allCurvSortLoCohAccTrialwiseL(:,2);
    allCurvSortLoCohAccR = allCurvSortLoCohAccTrialwiseR(:,2);
    
    posCurvSortLoCohAccTrialwiseL = sortrows(posCurvLoCohAccTrialwiseL,2);
    posCurvSortLoCohAccTrialwiseR = sortrows(posCurvLoCohAccTrialwiseR,2);
    
    % get number of low coherence trials
    nLoCohTrialsAll = length(allCurvSortLoCohAccTrialwiseL)+...
        length(allCurvSortLoCohAccTrialwiseR);
    
    nLoCohTrialsPos = length(posCurvSortLoCohAccTrialwiseL)+...
        length(posCurvSortLoCohAccTrialwiseR);
    
    nLoCohTrialsAllL = length(allCurvSortLoCohAccTrialwiseL);
    nLoCohTrialsAllR = length(allCurvSortLoCohAccTrialwiseR);
    
    nLoCohTrialsPosL = length(posCurvSortLoCohAccTrialwiseL);
    nLoCohTrialsPosR = length(posCurvSortLoCohAccTrialwiseR);
    
    % find index of first positive value
    allCurvPos1L = find(allCurvSortLoCohAccTrialwiseL(:,2) > 0,1);
    allCurvPos1R = find(allCurvSortLoCohAccTrialwiseR(:,2) > 0,1);
    
    % use the above index to calculate how many trials fall above that
    % value to define quartile lengths
    nLoCohAllCurvPosL = length(allCurvSortLoCohAccL(allCurvPos1L:end))/3;
    nLoCohAllCurvPosR = length(allCurvSortLoCohAccR(allCurvPos1R:end))/3;
    
    % round down if not an integer
    if ~isint(nLoCohAllCurvPosL)
        nLoCohAllCurvPosL = floor(nLoCohAllCurvPosL);
    end
    
    if ~isint(nLoCohAllCurvPosR)
        nLoCohAllCurvPosR = floor(nLoCohAllCurvPosR);
    end
    
    % make an index array ordered by the distance from zero for all
    % curvature values
    allCurvPosZeroDiffL = knnsearch(allCurvSortLoCohAccL,0,'K',length(allCurvSortLoCohAccL));
    allCurvPosZeroDiffR = knnsearch(allCurvSortLoCohAccR,0,'K',length(allCurvSortLoCohAccR))';
    
    % Get quartile values for signed curvature
    % Because the lowest quartile (Direct Reach) contains both positive and
    % negative values closest to 0 and the other three quartiles
    % (successively greater 'CoMs'only contain positive signed values
    % toward the target, this is a bit complicated.
    % To do so, start with the number of positive signed values and assign
    % trials to quartiles 1 and 2. Then check if any numbers match in the
    % two vectors. If so, reduce the number of trials/quartile by 1 and
    % reassign trials
    allSignedCurvSortL(1,:) = allCurvSortLoCohAccL(allCurvPosZeroDiffL(1:nLoCohAllCurvPosL));
    allSignedCurvSortR(1,:) = allCurvSortLoCohAccR(allCurvPosZeroDiffR(1:nLoCohAllCurvPosR));
    
    allSignedCurvSortL(2,:) = allCurvSortLoCohAccL(end-nLoCohAllCurvPosL*3+1:end-nLoCohAllCurvPosL*2);
    allSignedCurvSortR(2,:) = allCurvSortLoCohAccR(end-nLoCohAllCurvPosR*3+1:end-nLoCohAllCurvPosR*2);
    
    while sum(ismember(allSignedCurvSortL(1,:),allSignedCurvSortL(2,:)))
        allSignedCurvSortL = [];
        nLoCohAllCurvPosL = nLoCohAllCurvPosL-1;
        allSignedCurvSortL(1,:) = allCurvSortLoCohAccL(allCurvPosZeroDiffL(1:nLoCohAllCurvPosL));
        allSignedCurvSortL(2,:) = allCurvSortLoCohAccL(end-nLoCohAllCurvPosL*3+1:end-nLoCohAllCurvPosL*2);
        
    end
    
    while sum(ismember(allSignedCurvSortR(1,:),allSignedCurvSortR(2,:)))
        allSignedCurvSortR = [];
        nLoCohAllCurvPosR = nLoCohAllCurvPosR-1;
        allSignedCurvSortR(1,:) = allCurvSortLoCohAccR(allCurvPosZeroDiffR(1:nLoCohAllCurvPosR));
        allSignedCurvSortR(2,:) = allCurvSortLoCohAccR(end-nLoCohAllCurvPosR*3+1:end-nLoCohAllCurvPosR*2);
        
    end
    
    allSignedCurvSortL(3,:) = allCurvSortLoCohAccL(end-nLoCohAllCurvPosL*2+1:end-nLoCohAllCurvPosL);
    allSignedCurvSortL(4,:) = allCurvSortLoCohAccL(end-nLoCohAllCurvPosL+1:end);
    
    allSignedCurvSortR(3,:) = allCurvSortLoCohAccR(end-nLoCohAllCurvPosR*2+1:end-nLoCohAllCurvPosR);
    allSignedCurvSortR(4,:) = allCurvSortLoCohAccR(end-nLoCohAllCurvPosR+1:end);
    
    % Rejoin with trial indexes
    for i = 1:length(allCurvLoCohAccTrialwiseL)
        for j = 1:4
            for k = 1:length(allSignedCurvSortL)
                if allCurvLoCohAccTrialwiseL(i,2) == allSignedCurvSortL(j,k)
                    allSignedCurvSortIdxL(j,k) = allCurvLoCohAccTrialwiseL(i,1);
                end
            end
        end
    end
    
    for i = 1:length(allCurvLoCohAccTrialwiseR)
        for j = 1:4
            for k = 1:length(allSignedCurvSortR)
                if allCurvLoCohAccTrialwiseR(i,2) == allSignedCurvSortR(j,k)
                    allSignedCurvSortIdxR(j,k) = allCurvLoCohAccTrialwiseR(i,1);
                end
            end
        end
    end

    % Make a dummy array and assign quartiles based on groups
    allSignedCurvQuart = NaN(length(trialIdx),1);
    
    allSignedCurvQuartL = NaN(length(trialIdxL),1);
    allSignedCurvQuartR = NaN(length(trialIdxR),1);
    
    % Collapse and separate across target locations
    for a = 1:4
        allSignedCurvQuart(allSignedCurvSortIdxL(a,:)) = a;
        allSignedCurvQuart(allSignedCurvSortIdxR(a,:)) = a;
        
        allSignedCurvQuartL(allSignedCurvSortIdxL(a,:)) = a;
        allSignedCurvQuartR(allSignedCurvSortIdxR(a,:)) = a;
    end
    allSignedCurvQuart(allCurvHiCohAccTrialwiseL(:,1)) = 5;
    allSignedCurvQuart(allCurvHiCohErrTrialwiseL(:,1)) = 6;
    allSignedCurvQuart(allCurvLoCohErrTrialwiseL(:,1)) = 0;
    
    allSignedCurvQuart(allCurvHiCohAccTrialwiseR(:,1)) = 5;
    allSignedCurvQuart(allCurvHiCohErrTrialwiseR(:,1)) = 6;
    allSignedCurvQuart(allCurvLoCohErrTrialwiseR(:,1)) = 0;
    
    allSignedCurvQuart(isnan(allSignedCurvQuart)) = -1;
    
    allSignedCurvQuartL(allCurvHiCohAccTrialwiseL(:,1)) = 5;
    allSignedCurvQuartL(allCurvHiCohErrTrialwiseL(:,1)) = 6;
    allSignedCurvQuartL(allCurvLoCohErrTrialwiseL(:,1)) = 0;
    
    allSignedCurvQuartL(isnan(allSignedCurvQuartL)) = -1;
    
    allSignedCurvQuartR(allCurvHiCohAccTrialwiseR(:,1)) = 5;
    allSignedCurvQuartR(allCurvHiCohErrTrialwiseR(:,1)) = 6;
    allSignedCurvQuartR(allCurvLoCohErrTrialwiseR(:,1)) = 0;
    
    allSignedCurvQuartR(isnan(allSignedCurvQuartR)) = -1;
    
    % make a matrix of values for the number of trials in each quartile
	nTrialsCondAllSigned = [sum(allSignedCurvQuart == 0), sum(allSignedCurvQuart == 1),...
        sum(allSignedCurvQuart == 2), sum(allSignedCurvQuart == 3),...
        sum(allSignedCurvQuart == 4), sum(allSignedCurvQuart == 5),...
        sum(allSignedCurvQuart == 6), sum(allSignedCurvQuart == -1)];
    
    nTrialsCondAllSignedL = [sum(allSignedCurvQuartL == 0), sum(allSignedCurvQuartL == 1),...
        sum(allSignedCurvQuartL == 2), sum(allSignedCurvQuartL == 3),...
        sum(allSignedCurvQuartL == 4), sum(allSignedCurvQuartL == 5),...
        sum(allSignedCurvQuartL == 6), sum(allSignedCurvQuartL == -1)];
    
    nTrialsCondAllSignedR = [sum(allSignedCurvQuartR == 0), sum(allSignedCurvQuartR == 1),...
        sum(allSignedCurvQuartR == 2), sum(allSignedCurvQuartR == 3),...
        sum(allSignedCurvQuartR == 4), sum(allSignedCurvQuartR == 5),...
        sum(allSignedCurvQuartR == 6), sum(allSignedCurvQuartR == -1)];
    
   
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

    save(strcat('SignedQuartileDataDir/','QuartDirAll',movementFiles(currFile).name));
    
end