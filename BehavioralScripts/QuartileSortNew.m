clear all;

cd '~/Documents/projects/COM_EEG/Data/BehavioralDataOrig'

movementFiles = dir('*.mat');

totalCOMS = [];
% :length(movementFiles)
for currFile = 1:length(movementFiles)
    load(movementFiles(currFile).name);

    % Make an index of trial numbers
    trialIdx = 1:length(maxDeviation);
    trialIdx = trialIdx';
    
    unsignedCurvLoCohAccIdx = [];
    unsignedCurvLoCohAcc = [];
    unsignedCurvLoCohErrIdx = [];
    unsignedCurvLoCohErr = [];
    
    unsignedCurvHiCohAccIdx = [];
    unsignedCurvHiCohAcc = [];
    unsignedCurvHiCohErrIdx = [];
    unsignedCurvHiCohErr = [];
    
    % Get coherence trial curvature values and trial indexes for both
    % accurate and error trials
    for a = 1:length(trialIdx)
        if coherence(a) ~= 1 
            if acc(a) && ~noMovement(a) && ~droppedTrials(a) && reachLand(a)
                unsignedCurvLoCohAccIdx = [unsignedCurvLoCohAccIdx;trialIdx(a)];
                unsignedCurvLoCohAcc = [unsignedCurvLoCohAcc;maxDeviation(a)];
            else
                unsignedCurvLoCohErrIdx = [unsignedCurvLoCohErrIdx;trialIdx(a)];
                unsignedCurvLoCohErr = [unsignedCurvLoCohErr;maxDeviation(a)];
            end
        elseif coherence(a) == 1
            if acc(a) && ~noMovement(a) && ~droppedTrials(a) && reachLand(a)
                unsignedCurvHiCohAccIdx = [unsignedCurvHiCohAccIdx;trialIdx(a)];
                unsignedCurvHiCohAcc = [unsignedCurvHiCohAcc;maxDeviation(a)];
            else
                unsignedCurvHiCohErrIdx = [unsignedCurvHiCohErrIdx;trialIdx(a)];
                unsignedCurvHiCohErr = [unsignedCurvHiCohErr;maxDeviation(a)];
            end
        end
    end
    
    % Combine indexes and values for trial IDed sorting
    unsignedCurvLoCohAccTrialwise = [unsignedCurvLoCohAccIdx,unsignedCurvLoCohAcc];
    unsignedCurvLoCohErrTrialwise = [unsignedCurvLoCohErrIdx,unsignedCurvLoCohErr];
    
    unsignedCurvHiCohAccTrialwise = [unsignedCurvHiCohAccIdx,unsignedCurvHiCohAcc];
    unsignedCurvHiCohErrTrialwise = [unsignedCurvHiCohErrIdx,unsignedCurvHiCohErr];
    
    % sort low to high for loCoh Trials
    unsignedCurvSortLoCohAccTrialwise = sortrows(unsignedCurvLoCohAccTrialwise,2);
    
    % get number of low coherence trials
    nLoCohTrials = length(unsignedCurvSortLoCohAccTrialwise);
    
    % get temp index values for quartiles
    trialsOneQuart = nLoCohTrials/4;
    trialsMidpt = nLoCohTrials/2;
    
    % round if trial numbers are uneven
    if ~isint(trialsOneQuart)
        trialsOneQuart = round(trialsOneQuart);
    end
    
    if ~isint(trialsMidpt)
        trialsMidpt = round(trialsMidpt);
    end
    
    trialsThreeQuart = trialsOneQuart+trialsMidpt;
    
    % Sort accurate low coherence trials into quarters
    unsignedCurvSortLoCohAccTrialwiseQ1 = unsignedCurvSortLoCohAccTrialwise(1:trialsOneQuart,:);
    unsignedCurvSortLoCohAccTrialwiseQ2 = unsignedCurvSortLoCohAccTrialwise(trialsOneQuart+1:trialsMidpt,:);
    unsignedCurvSortLoCohAccTrialwiseQ3 = unsignedCurvSortLoCohAccTrialwise(trialsMidpt+1:trialsThreeQuart,:);
    unsignedCurvSortLoCohAccTrialwiseQ4 = unsignedCurvSortLoCohAccTrialwise(trialsThreeQuart+1:end,:);
    
    % Make a dummy array and assign quartiles based on groups
    unsignedCurvQuart = NaN(length(trialIdx),1);
    
    unsignedCurvQuart(unsignedCurvLoCohErrTrialwise(:,1)) = 0;
    unsignedCurvQuart(unsignedCurvSortLoCohAccTrialwiseQ1(:,1)) = 1;
    unsignedCurvQuart(unsignedCurvSortLoCohAccTrialwiseQ2(:,1)) = 2;
    unsignedCurvQuart(unsignedCurvSortLoCohAccTrialwiseQ3(:,1)) = 3;
    unsignedCurvQuart(unsignedCurvSortLoCohAccTrialwiseQ4(:,1)) = 4;
    unsignedCurvQuart(unsignedCurvHiCohAccTrialwise(:,1)) = 5;
    unsignedCurvQuart(unsignedCurvHiCohErrTrialwise(:,1)) = 6;
    
    % make a matrix of values for the number of trials in each quartile
	nTrialsCond = [sum(unsignedCurvQuart == 0), sum(unsignedCurvQuart == 1),...
        sum(unsignedCurvQuart == 2), sum(unsignedCurvQuart == 3),...
        sum(unsignedCurvQuart == 4), sum(unsignedCurvQuart == 5),...
        sum(unsignedCurvQuart == 6)];
    
    % Now do the same for signed data (+ = toward target, - = away)
    
    % convert curvature to signed curvature
    signedCurv = maxDeviation;
    
    % Convert curvature to signed values
    for i = 1:totalTrials
        if signOfCurvature(i) == -1
            signedCurv(i) = -signedCurv(i);
        else
        end
    end
    
    posCurvLoCohAccIdx = [];
    posCurvLoCohAcc = [];
    posCurvLoCohErrIdx = [];
    posCurvLoCohErr = [];
    
    posCurvHiCohAccIdx = [];
    posCurvHiCohAcc = [];
    posCurvHiCohErrIdx = [];
    posCurvHiCohErr = [];
    
    negCurvIdx = [];
    negCurv = [];
    
    % Get coherence trial curvature values and trial indexes for both
    % accurate and error trials
    for a = 1:length(trialIdx)
        if coherence(a) ~= 1 
            if acc(a) && ~noMovement(a) && ~droppedTrials(a) && reachLand(a) && signedCurv(a) > 0
                posCurvLoCohAccIdx = [posCurvLoCohAccIdx;trialIdx(a)];
                posCurvLoCohAcc = [posCurvLoCohAcc;signedCurv(a)];
            else
                posCurvLoCohErrIdx = [posCurvLoCohErrIdx;trialIdx(a)];
                posCurvLoCohErr = [posCurvLoCohErr;signedCurv(a)];
            end
        elseif coherence(a) == 1
            if acc(a) && ~noMovement(a) && ~droppedTrials(a) && reachLand(a) && signedCurv(a) > 0
                posCurvHiCohAccIdx = [posCurvHiCohAccIdx;trialIdx(a)];
                posCurvHiCohAcc = [posCurvHiCohAcc;signedCurv(a)];
            else
                posCurvHiCohErrIdx = [posCurvHiCohErrIdx;trialIdx(a)];
                posCurvHiCohErr = [posCurvHiCohErr;signedCurv(a)];
            end
        end
        if signedCurv(a) < 0
            negCurvIdx = [negCurvIdx;trialIdx(a)];
            negCurv = [negCurv;signedCurv(a)];
        end
    end
    
    % Combine indexes and values for trial IDed sorting
    posCurvLoCohAccTrialwise = [posCurvLoCohAccIdx,posCurvLoCohAcc];
    posCurvLoCohErrTrialwise = [posCurvLoCohErrIdx,posCurvLoCohErr];
    
    posCurvHiCohAccTrialwise = [posCurvHiCohAccIdx,posCurvHiCohAcc];
    posCurvHiCohErrTrialwise = [posCurvHiCohErrIdx,posCurvHiCohErr];
    
    negCurvTrialwise = [negCurvIdx,negCurv];
    
    % sort low to high for loCoh Trials
    posCurvSortLoCohAccTrialwise = sortrows(posCurvLoCohAccTrialwise,2);
    
    % get number of low coherence trials
    nLoCohTrialsPos = length(posCurvSortLoCohAccTrialwise);
    
    % get temp index values for quartiles
    trialsOneQuartPos = nLoCohTrialsPos/4;
    trialsMidptPos = nLoCohTrialsPos/2;
    
    % round if trial numbers are uneven
    if ~isint(trialsOneQuartPos)
        trialsOneQuartPos = round(trialsOneQuartPos);
    end
    
    if ~isint(trialsMidptPos)
        trialsMidptPos = round(trialsMidptPos);
    end
    
    trialsThreeQuartPos = trialsOneQuartPos+trialsMidptPos;
    
    % Sort accurate low coherence trials into quarters
    posCurvSortLoCohAccTrialwiseQ1 = posCurvSortLoCohAccTrialwise(1:trialsOneQuartPos,:);
    posCurvSortLoCohAccTrialwiseQ2 = posCurvSortLoCohAccTrialwise(trialsOneQuartPos+1:trialsMidptPos,:);
    posCurvSortLoCohAccTrialwiseQ3 = posCurvSortLoCohAccTrialwise(trialsMidptPos+1:trialsThreeQuartPos,:);
    posCurvSortLoCohAccTrialwiseQ4 = posCurvSortLoCohAccTrialwise(trialsThreeQuartPos+1:end,:);
    
    % Make a dummy array and assign quartiles based on groups
    signedCurvQuart = NaN(length(trialIdx),1);
    
    signedCurvQuart(posCurvLoCohErrTrialwise(:,1)) = 0;
    signedCurvQuart(posCurvSortLoCohAccTrialwiseQ1(:,1)) = 1;
    signedCurvQuart(posCurvSortLoCohAccTrialwiseQ2(:,1)) = 2;
    signedCurvQuart(posCurvSortLoCohAccTrialwiseQ3(:,1)) = 3;
    signedCurvQuart(posCurvSortLoCohAccTrialwiseQ4(:,1)) = 4;
    signedCurvQuart(posCurvHiCohAccTrialwise(:,1)) = 5;
    signedCurvQuart(posCurvHiCohErrTrialwise(:,1)) = 6;
    signedCurvQuart(negCurvTrialwise(:,1)) = -1;
    
    % make a matrix of values for the number of trials in each quartile
	nTrialsCondSigned = [sum(signedCurvQuart == 0), sum(signedCurvQuart == 1),...
        sum(signedCurvQuart == 2), sum(signedCurvQuart == 3),...
        sum(signedCurvQuart == 4), sum(signedCurvQuart == 5),...
        sum(signedCurvQuart == 6), sum(signedCurvQuart == -1)];
        
    mkdir '~/Documents/projects/COM_EEG/Data/BehavioralDataOrig/SignedQuartileData'

    save(strcat('SignedQuartileData/','Quart',movementFiles(currFile).name));
    
end