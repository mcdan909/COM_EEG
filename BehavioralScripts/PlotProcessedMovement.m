%% Goal of this Program:
%% Sort all trials according to their condition
%% This includes sorting by target location.
%% First, each trial is re-sampled to 100 points equally spaced in time
%% Then, they are sorted such that each struct has the average finger location (x & y) for
%% each of the 100 samples (first sample re-centered to 0,0)

clear all;
% How many samples should the resampling create?
reSampleLength = 101;

red = [220 60 10]/255;
blue = [66 116 255]/255;
violet = [194 0 133]/255;

ppd = 40.5;

path = '~/Documents/Projects/COM_EEG/BehavioralData/';
cd(path);

goodSubs = {'302','304','305','306','308','309','311','313','314','315'};

numSub = length(goodSubs);

set(0,'defaultfigurecolor',[1 1 1]);
set(0,'DefaultFigureWindowStyle','docked');

% Best Examples: 311, 313

% 315 already resampled?

for aa = 1:numSub
    load(strcat('MovementData_',goodSubs{aa}));
    
    for bb = 1:size(AllXMovementPoints,1)
        
        figure(aa)
        hold on;
        set(gca,'FontSize',24);
        xlabel('Horizontal Position (cm)');
        ylabel('Vertical Position (cm)');
        if aa < 10
            set(gca,'Xtick',xCen-(6*ppd):2*ppd:xCen+(6*ppd));
            set(gca,'XtickLabel',-6:2:6);
            xlim([xCen-(6*ppd) xCen+(6*ppd)]);
            set(gca,'Ytick',-20*ppd:2*ppd:-4*ppd);
            set(gca,'YtickLabel',0:2:16);
            ylim([-20*ppd -4*ppd]);
        else
            set(gca,'Xtick',-8*ppd:2*ppd:8*ppd);
            set(gca,'XtickLabel',-8:2:8);
            xlim([-8*ppd 8*ppd]);
            set(gca,'Ytick',0:2*ppd:18*ppd);
            set(gca,'YtickLabel',0:2:18);
            ylim([0 18*ppd]);
        end
        %plot(pos(1,1),-(yCen-pos(1,2)),'ks','MarkerSize',ppd);
        %plot(pos(2,1),-(yCen-pos(2,2)),'ks','MarkerSize',ppd);
        
        if acc(bb) && signedCurvQuart(bb) == 1
            
            if aa < 10
                
                plot(nonzeros(AllXMovementPoints(bb,:)),-nonzeros(AllYMovementPoints(bb,:)),'g-');
            else
                
                plot(AllXMovementPoints(bb,1:101),-AllYMovementPoints(bb,1:101),'g-');
            end
%         elseif acc(bb) && unsignedCurvQuart(bb) == 5
%             plot(nonzeros(AllXMovementPoints(bb,:)),-nonzeros(AllYMovementPoints(bb,:)),'b-');
%         elseif acc(bb) && signedCurvQuart(bb) == 3
%             plot(nonzeros(AllXMovementPoints(bb,:)),-nonzeros(AllYMovementPoints(bb,:)),'k-');
        elseif acc(bb) && signedCurvQuart(bb) == 4
            
            if aa < 10
                plot(nonzeros(AllXMovementPoints(bb,:)),-nonzeros(AllYMovementPoints(bb,:)),'r-');
            else
                plot(AllXMovementPoints(bb,1:101),-AllYMovementPoints(bb,1:101),'r-');
            end
        end
    end
    
    
end


%%

% create structs for each position
blockNoDist = struct;
blockHiDist = struct;
blockLoDist = struct;
blockNoDist.xPos = [];
blockNoDist.yPos = [];
blockHiDist.xPos = [];
blockHiDist.yPos = [];
blockLoDist.xPos = [];
blockLoDist.yPos = [];

for aa = 1:numSub
    
    blockFiles = dir(strcat('*SAL',num2str(goodSubs{aa}),'*'));
    
    for bb = 1:length(blockFiles);
        load(blockFiles(bb).name,'AllXMovementPoints','AllYMovementPoints',...
            'distractorColor','distractorLocation','targetLocation',...
            'droppedTrials','acc','RT');
        
        % Because some trials are not counted, this allows us to keep track
        % of the target and distractor location for all counted trials
        overallX = [];
        overallY = [];
        overallTargetLoc = [];
        overallDistractorLoc = [];
        overallDistractorColor = [];
        overallDroppedTrials = [];
        overallAcc = [];
        overallRT = [];
        
        for cc = 1:length(acc)
            
            % only count trials that weren't dropped because of missing
            % samples and were accurate
            if ~droppedTrials(cc) && acc(cc) && logical(RT(cc))
                
                % reSample the movement to 100 points equally spaced in
                % time through EZResample function
                %reSampledXData = EZResample_Space5(nonzeros(AllXMovementPoints(x,:)),reSampleLength,1);
                %reSampledYData = EZResample_Space5(nonzeros(AllYMovementPoints(x,:)),reSampleLength,1);
                if ~isempty(nonzeros(AllXMovementPoints(cc,:)))
                    [reSampledXData,reSampledYData] = EZResampleSpaceXY(nonzeros(AllXMovementPoints(cc,:)),nonzeros(AllYMovementPoints(cc,:)),reSampleLength,1);
                    
                    % Store the resampled X and Y positions for this trial,
                    % along with trial type, target location, and other
                    % potentially relevant data
                    overallX = [overallX;reSampledXData];
                    overallY = [overallY;reSampledYData];
                    overallTargetLoc = [overallTargetLoc;targetLocation(cc)];
                    overallDistractorColor = [overallDistractorColor;distractorColor(cc)];
                    overallDistractorLoc = [overallDistractorLoc;distractorLocation(cc)];
                    overallRT = [overallRT;RT(cc)];
                    
                end
                
            end
        end
        
        for dd = 1:4
            nNoDistTrials(dd) = size(overallX(overallDistractorColor == 1 & overallTargetLoc == dd,:),1);
            if nNoDistTrials(dd) == 0
                blockNoDist(bb,dd).xPos = nan(1,101);
                blockNoDist(bb,dd).yPos = nan(1,101);
            elseif nNoDistTrials(dd) == 1
                blockNoDist(bb,dd).xPos = overallX(overallDistractorColor == 1 & overallTargetLoc == dd,:);
                blockNoDist(bb,dd).yPos = overallY(overallDistractorColor == 1 & overallTargetLoc == dd,:);
            elseif nNoDistTrials(dd) > 1
                blockNoDist(bb,dd).xPos = nanmean(overallX(overallDistractorColor == 1 & overallTargetLoc == dd,:));
                blockNoDist(bb,dd).yPos = nanmean(overallY(overallDistractorColor == 1 & overallTargetLoc == dd,:));
            end
        end
        
        % Struct = block, targetLoc, distLoc
        for ee = 1:4
            for ff = 1:4
                nHiDistTrials(ee,ff) = size(overallX(overallDistractorColor == 2 & overallTargetLoc == ee & overallDistractorLoc == ff,:),1);
                nLoDistTrials(ee,ff) = size(overallX(overallDistractorColor == 3 & overallTargetLoc == ee & overallDistractorLoc == ff,:),1);
                if nHiDistTrials(ee,ff) == 0
                    blockHiDist(bb,ee,ff).xPos = nan(1,101);
                    blockHiDist(bb,ee,ff).yPos = nan(1,101);
                elseif nHiDistTrials(ee,ff) == 1
                    blockHiDist(bb,ee,ff).xPos = overallX(overallDistractorColor == 2 & overallTargetLoc == ee & overallDistractorLoc == ff,:);
                    blockHiDist(bb,ee,ff).yPos = overallY(overallDistractorColor == 2 & overallTargetLoc == ee & overallDistractorLoc == ff,:);
                elseif nHiDistTrials(ee,ff) > 1
                    blockHiDist(bb,ee,ff).xPos = nanmean(overallX(overallDistractorColor == 2 & overallTargetLoc == ee & overallDistractorLoc == ff,:));
                    blockHiDist(bb,ee,ff).yPos = nanmean(overallY(overallDistractorColor == 2 & overallTargetLoc == ee & overallDistractorLoc == ff,:));
                end
                if nLoDistTrials(ee,ff) == 0
                    blockLoDist(bb,ee,ff).xPos = nan(1,101);
                    blockLoDist(bb,ee,ff).yPos = nan(1,101);
                elseif nLoDistTrials(ee,ff) == 1
                    blockLoDist(bb,ee,ff).xPos = overallX(overallDistractorColor == 3 & overallTargetLoc == ee & overallDistractorLoc == ff,:);
                    blockLoDist(bb,ee,ff).yPos = overallY(overallDistractorColor == 3 & overallTargetLoc == ee & overallDistractorLoc == ff,:);
                elseif nLoDistTrials(ee,ff) > 1
                    blockLoDist(bb,ee,ff).xPos = nanmean(overallX(overallDistractorColor == 3 & overallTargetLoc == ee & overallDistractorLoc == ff,:));
                    blockLoDist(bb,ee,ff).yPos = nanmean(overallY(overallDistractorColor == 3 & overallTargetLoc == ee & overallDistractorLoc == ff,:));
                end
            end
        end
        
    end
    
    % Now that data are resampled, look through each variable and sort
    % into structs for X and Y positions separately, based on trial
    % type, target location, color repetition, and fig/color combo
    % repetition.  For each combo, we take the mean of each
    % point at that condition.  For example, if the trial type is
    % figure and target location is 1, that should be ~N
    % trials for each subject.  For that subject, we'll take the mean
    % of those N trials at each point, leaving us with 100 points,
    % each reflecting the mean position of the movement for that
    % subject, that target location, and that trial type
    for xx = 1:length(blockFiles)
        for yy = 1:4
            indNoDistTempX(xx,yy,:) = blockNoDist(xx,yy).xPos;
            indNoDistTempY(xx,yy,:) = blockNoDist(xx,yy).yPos;
            
            for zz = 1:4
                
                if ~isempty(blockHiDist(xx,yy,zz).xPos) && size(blockHiDist(xx,yy,zz).xPos,1) > 1
                    indHiDistTempX(xx,yy,zz,:) = nanmean(blockHiDist(xx,yy,zz).xPos);
                    indHiDistTempY(xx,yy,zz,:) = nanmean(blockHiDist(xx,yy,zz).yPos);
                elseif ~isempty(blockHiDist(xx,yy,zz).xPos)
                    indHiDistTempX(xx,yy,zz,:) = blockHiDist(xx,yy,zz).xPos;
                    indHiDistTempY(xx,yy,zz,:) = blockHiDist(xx,yy,zz).yPos;
                else
                    indHiDistTempX(xx,yy,zz,:) = nan(1,101);
                    indHiDistTempY(xx,yy,zz,:) = nan(1,101);
                end
                
                if ~isempty(blockLoDist(xx,yy,zz).xPos) && size(blockLoDist(xx,yy,zz).xPos,1) > 1
                    indLoDistTempX(xx,yy,zz,:) = nanmean(blockLoDist(xx,yy,zz).xPos);
                    indLoDistTempY(xx,yy,zz,:) = nanmean(blockLoDist(xx,yy,zz).yPos);
                elseif ~isempty(blockLoDist(xx,yy,zz).xPos)
                    indLoDistTempX(xx,yy,zz,:) = blockLoDist(xx,yy,zz).xPos;
                    indLoDistTempY(xx,yy,zz,:) = blockLoDist(xx,yy,zz).yPos;
                else
                    indLoDistTempX(xx,yy,zz,:) = nan(1,101);
                    indLoDistTempY(xx,yy,zz,:) = nan(1,101);
                end
            end
        end
        
    end
    
    indNoDistX(aa,:,:) = squeeze(nanmean(indNoDistTempX));
    indNoDistY(aa,:,:) = -squeeze(nanmean(indNoDistTempY));
    
    indHiDistX(aa,:,:,:) = squeeze(nanmean(indHiDistTempX));
    indHiDistY(aa,:,:,:) = -squeeze(nanmean(indHiDistTempY));
    
    indLoDistX(aa,:,:,:) = squeeze(nanmean(indLoDistTempX));
    indLoDistY(aa,:,:,:) = -squeeze(nanmean(indLoDistTempY));
    
end

flipSlope = [-1 Inf 1 0];

% Mirror across plane to make all trajectories upper right, then mirror
% again across the straight line from start to that target if necessary
for tt = 1:4
    [normIndNoDistX(:,tt,:), normIndNoDistY(:,tt,:)] = mirror(indNoDistX(:,tt,:),...
        indNoDistY(:,tt,:),flipSlope(:,tt),0,0);
    [normIndNoDistX(:,tt,:), normIndNoDistY(:,tt,:)] = mirror(normIndNoDistX(:,tt,:),...
        normIndNoDistY(:,tt,:),1,0,0);
    
    for uu = 1:4
        [normIndHiDistX(:,tt,uu,:), normIndHiDistY(:,tt,uu,:)] = mirror(indHiDistX(:,tt,uu,:),...
            indHiDistY(:,tt,uu,:),flipSlope(:,tt),0,0);
        [normIndLoDistX(:,tt,uu,:), normIndLoDistY(:,tt,uu,:)] = mirror(indLoDistX(:,tt,uu,:),...
            indLoDistY(:,tt,uu,:),flipSlope(:,tt),0,0);
        
        if tt == 1 && uu == 2 || tt == 2 && uu == 3 || tt == 3 && uu == 4 || tt == 4 && uu == 1
        else
            [normIndHiDistX(:,tt,uu,:), normIndHiDistY(:,tt,uu,:)] = mirror(normIndHiDistX(:,tt,uu,:),...
                normIndHiDistY(:,tt,uu,:),1,0,0);
            [normIndLoDistX(:,tt,uu,:), normIndLoDistY(:,tt,uu,:)] = mirror(normIndLoDistX(:,tt,uu,:),...
                normIndLoDistY(:,tt,uu,:),1,0,0);
        end

    end
end

% Make reoriented baselines that correspond to target/distractor locations
% for easy calculation of ITA/attraction scores
for tt = 1:4
         
    for uu = 1:4
        
        if tt == 1 && uu == 2 || tt == 2 && uu == 3 || tt == 3 && uu == 4 || tt == 4 && uu == 1
            [normIndBaseX(:,tt,uu,:), normIndBaseY(:,tt,uu,:)] = mirror(normIndNoDistX(:,tt,:),...
                normIndNoDistY(:,tt,:),1,0,0);
        else
            normIndBaseX(:,tt,uu,:) = normIndNoDistX(:,tt,:);
            normIndBaseY(:,tt,uu,:) = normIndNoDistY(:,tt,:);
        end
    end

end



meanNoDistX = squeeze(nanmean(indNoDistX));
meanNoDistY = squeeze(nanmean(indNoDistY));

meanHiDistX = squeeze(nanmean(indHiDistX));
meanHiDistY = squeeze(nanmean(indHiDistY));

meanLoDistX = squeeze(nanmean(indLoDistX));
meanLoDistY = squeeze(nanmean(indLoDistY));

normMeanNoDistX = squeeze(nanmean(normIndNoDistX));
normMeanNoDistY = squeeze(nanmean(normIndNoDistY));

normMeanHiDistX = squeeze(nanmean(normIndHiDistX));
normMeanHiDistY = squeeze(nanmean(normIndHiDistY));

normMeanLoDistX = squeeze(nanmean(normIndLoDistX));
normMeanLoDistY = squeeze(nanmean(normIndLoDistY));

meanNormMeanNoDistX = nanmean(normMeanNoDistX);
meanNormMeanNoDistY = nanmean(normMeanNoDistY);

meanNormMeanHiDistX = squeeze(nanmean(normMeanHiDistX));
meanNormMeanHiDistY = squeeze(nanmean(normMeanHiDistY));

meanNormMeanLoDistX = squeeze(nanmean(normMeanLoDistX));
meanNormMeanLoDistY = squeeze(nanmean(normMeanLoDistY));

% Calculate area under the curve of normalized data
for a = 1:numSub
    for i = 1:4
        for j = 1:4
            hiDistPolyX(a,i,j,:) = [squeeze(normIndHiDistX(a,i,j,:));linspace(normIndHiDistX(a,i,j,1),normIndHiDistX(a,i,j,end),101)'];
            hiDistPolyY(a,i,j,:) = [squeeze(normIndHiDistY(a,i,j,:));linspace(normIndHiDistY(a,i,j,1),normIndHiDistY(a,i,j,end),101)'];
            
            loDistPolyX(a,i,j,:) = [squeeze(normIndLoDistX(a,i,j,:));linspace(normIndLoDistX(a,i,j,1),normIndLoDistX(a,i,j,end),101)'];
            loDistPolyY(a,i,j,:) = [squeeze(normIndLoDistY(a,i,j,:));linspace(normIndLoDistY(a,i,j,1),normIndLoDistY(a,i,j,end),101)'];
            
            hiDistLineX(a,i,j,:) = linspace(normIndHiDistX(a,i,j,1),normIndHiDistX(a,i,j,end),101);
            hiDistLineY(a,i,j,:) = linspace(normIndHiDistY(a,i,j,1),normIndHiDistY(a,i,j,end),101);
            
            loDistLineX(a,i,j,:) = linspace(normIndLoDistX(a,i,j,1),normIndLoDistX(a,i,j,end),101);
            loDistLineY(a,i,j,:) = linspace(normIndLoDistY(a,i,j,1),normIndLoDistY(a,i,j,end),101);
            
            hiDistDiffNorm(a,i,j,:) = sqrt((squeeze(normIndHiDistX(a,i,j,:))-squeeze(hiDistLineX(a,i,j,:))).^2 +...
                (squeeze(normIndHiDistY(a,i,j,:))-squeeze(hiDistLineY(a,i,j,:))).^2);
            loDistDiffNorm(a,i,j,:) = sqrt((squeeze(normIndLoDistX(a,i,j,:))-squeeze(loDistLineX(a,i,j,:))).^2 +...
                (squeeze(normIndLoDistY(a,i,j,:))-squeeze(loDistLineY(a,i,j,:))).^2);
            
            for l = 1:reSampleLength
                if hiDistLineY(a,i,j,l) > normIndHiDistY(a,i,j,l)
                    hiDistDiffNorm(a,i,j,l) = -hiDistDiffNorm(a,i,j,l);
                end
                
                if loDistLineY(a,i,j,l) > normIndLoDistY(a,i,j,l)
                    loDistDiffNorm(a,i,j,l) = -loDistDiffNorm(a,i,j,l);
                end
            end
        end
    end
end

% indHiDistDiffNorm = squeeze([hiDistDiffNorm(:,1,2,:),hiDistDiffNorm(:,1,4,:),...
%     hiDistDiffNorm(:,2,1,:),hiDistDiffNorm(:,2,3,:),hiDistDiffNorm(:,3,2,:),...
%     hiDistDiffNorm(:,3,4,:),hiDistDiffNorm(:,4,1,:),hiDistDiffNorm(:,4,3,:)]);
% 
% indLoDistDiffNorm = squeeze([loDistDiffNorm(:,1,2,:),loDistDiffNorm(:,1,4,:),...
%     loDistDiffNorm(:,2,1,:),loDistDiffNorm(:,2,3,:),loDistDiffNorm(:,3,2,:),...
%     loDistDiffNorm(:,3,4,:),loDistDiffNorm(:,4,1,:),loDistDiffNorm(:,4,3,:)]);

indHiDistDiffNorm = squeeze([hiDistDiffNorm(:,2,1,:),hiDistDiffNorm(:,2,3,:),hiDistDiffNorm(:,3,2,:),...
    hiDistDiffNorm(:,3,4,:)]);

indLoDistDiffNorm = squeeze([loDistDiffNorm(:,2,1,:),loDistDiffNorm(:,2,3,:),loDistDiffNorm(:,3,2,:),...
    loDistDiffNorm(:,3,4,:)]);

sumHiDistDiffNorm = sum(indHiDistDiffNorm,3);
sumLoDistDiffNorm = sum(indLoDistDiffNorm,3);

% for cc = 1:numSub
%     for dd = 1:4
%         sumPosDistDiffNorm(cc,dd).HiDist = indHiDistDiffNorm(cc,dd,mean(indHiDistDiffNorm(cc,dd,:) > 0));
%         sumPosDistDiffNorm(cc,dd).LoDist = indLoDistDiffNorm(cc,dd,mean(indLoDistDiffNorm(cc,dd,:) > 0));
%         
%         %sumPosDistDiffNorm(cc,dd).HiDist = squeeze(sumPosDistDiffNorm(cc,dd,:).HiDist)
%         
%         meanHiSubPosDistDiffNorm(cc,dd) = squeeze(nanmean([sumPosDistDiffNorm(cc,dd).HiDist]))
%     end
% end

indMeanHiDistDiffNorm = squeeze(nanmean(sumHiDistDiffNorm,2));
indMeanLoDistDiffNorm = squeeze(nanmean(sumLoDistDiffNorm,2));

meanHiDistDiffNorm = nanmean(indMeanHiDistDiffNorm);
meanLoDistDiffNorm = nanmean(indMeanLoDistDiffNorm);

semHiDistDiffNorm = nanstd(indMeanHiDistDiffNorm)/sqrt(numSub);
semLoDistDiffNorm = nanstd(indMeanLoDistDiffNorm)/sqrt(numSub);

pos = [636 924; 636 276; 1284 276; 1284 924];
xCen = 960;
yCen = 600;

posCen = [pos(:,1)-xCen,pos(:,2)-yCen];
posCen(:,2) = -posCen(:,2);

centerOutLinesX = [linspace(0,posCen(1,1),101);linspace(0,posCen(2,1),101);...
    linspace(0,posCen(3,1),101);linspace(0,posCen(4,1),101)];
centerOutLinesY = [linspace(0,posCen(1,2),101);linspace(0,posCen(2,2),101);...
    linspace(0,posCen(3,2),101);linspace(0,posCen(4,2),101)];

% Save processed data into new .mat file called "AllTrajectories" in the
% ExtraFiles directory
if topDown
    backupFileName = 'AllSubTrajectoriesResampledTopDown.mat';
else
    backupFileName = 'AllSubTrajectoriesResampledBottomUp.mat';
end
filePath = strcat(pwd,'/ExtraFiles/');
backupFile = [filePath, backupFileName];
save(backupFile);
close all

%% Plot Trajectories

figure('Color',[1 1 1],'units','pixels','outerposition',[0 0 1000 1000]);
hold on;
%set(gca, 'Units', 'inches')
for mm = 1:4
    plot(posCen(mm,1),posCen(mm,2),'o','Color',red,'MarkerSize',ppd*4);
    plot(centerOutLinesX(mm,:),centerOutLinesY(mm,:),'k');
    %plot(squeeze(normIndNoDistX(2,mm,:)),squeeze(normIndNoDistY(2,mm,:)),...
        %'Color',red);
%     for nn = 1:numSub
%         plot(normIndNoDistX(1,:,:)
%     end

    
    
end
    
% plot(squeeze(meanNoDistX(3,:)),squeeze(meanNoDistY(3,:)),...
%         'Color',red,'LineWidth',2);
% plot(squeeze(meanHiDistX(3,2,:)),squeeze(meanHiDistY(3,2,:)),...
%         'Color',blue,'LineWidth',2);
% plot(squeeze(meanLoDistX(3,2,:)),squeeze(meanLoDistY(3,2,:)),...
%     'Color',violet,'LineWidth',2);

% plot(squeeze(normMeanNoDistX(3,:)),squeeze(normMeanNoDistY(3,:)),...
%         'Color',red,'LineWidth',2);
plot(squeeze(normMeanLoDistX(1,2,:)),squeeze(normMeanLoDistY(1,2,:)),...
        'Color',blue,'LineWidth',2);
plot(linspace(normMeanLoDistX(1,2,1),normMeanLoDistX(1,2,end),101),...
    linspace(normMeanLoDistY(1,2,1),normMeanLoDistY(1,2,end),101),...
    'Color',blue,'LineWidth',1);  
% plot(squeeze(normMeanLoDistX(3,2,:)),squeeze(normMeanLoDistY(3,2,:)),...
%     'Color',violet,'LineWidth',2);
% plot(normMeanNoDistX(1,:),normMeanNoDistY(1,:),'Color',red);
% for ll = 1:8
%     plot(normMeanHiDistX(ll,:),normMeanHiDistY(ll,:),'Color',blue);
%     plot(normMeanLoDistX(ll,:),normMeanLoDistY(ll,:),'Color',violet);
% end
% plot(squeeze(meanNoDistX(3,:)),squeeze(meanNoDistY(3,:)),'Color',red);
% plot(squeeze(meanHiDistX(3,2,:)),squeeze(meanHiDistY(3,2,:)),'Color',blue);
% plot(squeeze(meanLoDistX(3,2,:)),squeeze(meanLoDistY(3,2,:)),'g');
% plot(normMeanNoDistX,normMeanNoDistY,'Color',red);
% plot(meanNormMeanHiDistX,meanNormMeanHiDistY,'Color',blue);
% plot(meanNormMeanLoDistX,meanNormMeanLoDistY,'Color',violet);

set(gca,'XTick',-12*ppd:2*ppd:12*ppd);
set(gca,'YTick',-12*ppd:2*ppd:12*ppd);

set(gca,'XTickLabel',-12:2:12);
set(gca,'YTickLabel',-12:2:12);

% xlim([-12*ppd 12*ppd]);
% ylim([-12*ppd 12*ppd]);

% plot(meanNoDistX(1,:),meanNoDistY(1,:),'Color',red);
% plot(meanNoDistX(2,:),meanNoDistY(2,:),'Color',red);
% plot(meanNoDistX(3,:),meanNoDistY(3,:),'Color',red);
% plot(meanNoDistX(4,:),meanNoDistY(4,:),'Color',red);


% plot(squeeze(meanHiDistX(1,2,:)),squeeze(meanHiDistY(1,2,:)),'Color',blue);
% plot(squeeze(meanHiDistX(1,4,:)),squeeze(meanHiDistY(1,4,:)),'Color',blue);
% plot(squeeze(meanHiDistX(2,1,:)),squeeze(meanHiDistY(2,1,:)),'Color',blue);
% plot(squeeze(meanHiDistX(2,3,:)),squeeze(meanHiDistY(2,3,:)),'Color',blue);
% plot(squeeze(meanHiDistX(3,2,:)),squeeze(meanHiDistY(3,2,:)),'Color',blue);
% plot(squeeze(meanHiDistX(3,4,:)),squeeze(meanHiDistY(3,4,:)),'Color',blue);
% plot(squeeze(meanHiDistX(4,1,:)),squeeze(meanHiDistY(4,1,:)),'Color',blue);
% plot(squeeze(meanHiDistX(4,3,:)),squeeze(meanHiDistY(4,3,:)),'Color',blue);
%
% plot(squeeze(meanLoDistX(1,2,:)),squeeze(meanLoDistY(1,2,:)),'Color',violet);
% plot(squeeze(meanLoDistX(1,4,:)),squeeze(meanLoDistY(1,4,:)),'Color',violet);
% plot(squeeze(meanLoDistX(2,1,:)),squeeze(meanLoDistY(2,1,:)),'Color',violet);
% plot(squeeze(meanLoDistX(2,3,:)),squeeze(meanLoDistY(2,3,:)),'Color',violet);
% plot(squeeze(meanLoDistX(3,2,:)),squeeze(meanLoDistY(3,2,:)),'Color',violet);
% plot(squeeze(meanLoDistX(3,4,:)),squeeze(meanLoDistY(3,4,:)),'Color',violet);
% plot(squeeze(meanLoDistX(4,1,:)),squeeze(meanLoDistY(4,1,:)),'Color',violet);
% plot(squeeze(meanLoDistX(4,3,:)),squeeze(meanLoDistY(4,3,:)),'Color',violet);



