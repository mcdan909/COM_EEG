%% Purpose of this program is to calculate "distractor attraction scores" at
%% each point in the movement.  That is, for each sample in the movement to a
%% given target location, is the finger closer to the position of the
%% distractor location, relative to the same sample # in the baseline,
%% distractor absent condition?

clear all;
% Load file from Step A1, where resampled points are stored in structs for
% distractor present and absent trials
fileName = strcat('ExtraFiles/AllTrajectoriesResampled_E4.mat');
load(fileName);
reSampleLength = 101;
numSubjects = 10;
% create a new struct to store distractor attraction scores
attractionScore = struct;
attractionScore.scores = [];
avgAttractionScores = [];

for i = 1:numSubjects
    for j = 2:3 % targetLoc
        
        % First, get the average ending position of the L/R movements

        figEndPointX(i,j) = figTrial(i,j).xPos(end);
        figEndPointY(i,j) = figTrial(i,j).yPos(end);
        
        noFigEndPointX(i,j) = noFigTrial(i,j).xPos(end);
        noFigEndPointY(i,j) = noFigTrial(i,j).yPos(end);
        
        colorRepEndPointX(i,j) = colorRepTrial(i,j).xPos(end);
        colorRepEndPointY(i,j) = colorRepTrial(i,j).yPos(end);
        
        colorSwiEndPointX(i,j) = colorSwiTrial(i,j).xPos(end);
        colorSwiEndPointY(i,j) = colorSwiTrial(i,j).yPos(end);
        
        [figStraightLine(i,j,:).xPos,figStraightLine(i,j,:).yPos] =  EZResampleSpaceXY([figEndPointX(i,j) 0],[figEndPointY(i,j) 0],101,1);
        [noFigStraightLine(i,j,:).xPos,noFigStraightLine(i,j,:).yPos] =  EZResampleSpaceXY([noFigEndPointX(i,j) 0],[noFigEndPointY(i,j) 0],101,1);
        
        [colorRepStraightLine(i,j,:).xPos,colorRepStraightLine(i,j,:).yPos] =  EZResampleSpaceXY([colorRepEndPointX(i,j) 0],[colorRepEndPointY(i,j) 0],101,1);
        [colorSwiStraightLine(i,j,:).xPos,colorSwiStraightLine(i,j,:).yPos] =  EZResampleSpaceXY([colorSwiEndPointX(i,j) 0],[colorSwiEndPointY(i,j) 0],101,1);
        
        figStraightLine(i,j).xPos = -figStraightLine(i,j).xPos;
        figStraightLine(i,j).yPos = -figStraightLine(i,j).yPos;
        
        noFigStraightLine(i,j).xPos = -noFigStraightLine(i,j).xPos;
        noFigStraightLine(i,j).yPos = -noFigStraightLine(i,j).yPos;
        
        colorRepStraightLine(i,j).xPos = -colorRepStraightLine(i,j).xPos;
        colorRepStraightLine(i,j).yPos = -colorRepStraightLine(i,j).yPos;
        
        colorSwiStraightLine(i,j).xPos = -colorSwiStraightLine(i,j).xPos;
        colorSwiStraightLine(i,j).yPos = -colorSwiStraightLine(i,j).yPos;
        
        currXScreenCenter = 0;
        currYScreenCenter = -8;
        
        % For each sample...
        for l = 1:reSampleLength
            
            % First, label the point at this movement position for
            % figure trials (x1, y1) and no figure trials
            % (x2,y2) separately
            
            xFig = figTrial(i,j).xPos(l);
            xNoFig = noFigTrial(i,j).xPos(l);
            xFigStraight = figStraightLine(i,j).xPos(l);
            xNoFigStraight = noFigStraightLine(i,j).xPos(l);
            
            yFig = figTrial(i,j).yPos(l);
            yNoFig = noFigTrial(i,j).yPos(l);
            yFigStraight = figStraightLine(i,j).yPos(l);
            yNoFigStraight = noFigStraightLine(i,j).yPos(l);
            
            xColorRep = colorRepTrial(i,j).xPos(l);
            xColorSwi = colorSwiTrial(i,j).xPos(l);
            xColorRepStraight = colorRepStraightLine(i,j).xPos(l);
            xColorSwiStraight = colorSwiStraightLine(i,j).xPos(l);
            
            yColorRep = colorRepTrial(i,j).yPos(l);
            yColorSwi = colorSwiTrial(i,j).yPos(l);
            yColorRepStraight = colorRepStraightLine(i,j).yPos(l);
            yColorSwiStraight = colorSwiStraightLine(i,j).yPos(l);
            
            % calculate the distance between these two points
            figLine = sqrt((xFig-xFigStraight)^2 + (yFig-yFigStraight)^2);
            noFigLine = sqrt((xNoFig-xNoFigStraight)^2 + (yNoFig-yNoFigStraight)^2);
            
            colorRepLine = sqrt((xColorRep-xColorRepStraight)^2 + (yColorRep-yColorRepStraight)^2);
            colorSwiLine = sqrt((xColorSwi-xColorSwiStraight)^2 + (yColorSwi-yColorSwiStraight)^2);
            
            % calculate the distance between each point and the
            % figure center location point.
            figLineToCenter = sqrt((xFig - currXScreenCenter)^2 + (yFig - currYScreenCenter)^2);
            noFigLineToCenter = sqrt((xNoFig - currXScreenCenter)^2 + (yNoFig - currYScreenCenter)^2);
            
            colorRepLineToCenter = sqrt((xColorRep - currXScreenCenter)^2 + (yColorRep - currYScreenCenter)^2);
            colorSwiLineToCenter = sqrt((xColorSwi - currXScreenCenter)^2 + (yColorSwi - currYScreenCenter)^2);
            
            [figSign,figAngleDiff,figMainVectorAngle,figCurvedVectorAngle] = curvatureSign(figStraightLine(i,j).xPos(1),figStraightLine(i,j).xPos(end),figStraightLine(i,j).yPos(1),figStraightLine(i,j).yPos(end),xFig,yFig,j);
            [noFigSign,noFigAngleDiff,noFigMainVectorAngle,noFigCurvedVectorAngle] = curvatureSign(noFigStraightLine(i,j).xPos(1),noFigStraightLine(i,j).xPos(end),noFigStraightLine(i,j).yPos(1),noFigStraightLine(i,j).yPos(end),xNoFig,yNoFig,j);
            
            [colorRepSign,colorRepAngleDiff,colorRepMainVectorAngle,colorRepCurvedVectorAngle] = curvatureSign(colorRepStraightLine(i,j).xPos(1),colorRepStraightLine(i,j).xPos(end),colorRepStraightLine(i,j).yPos(1),colorRepStraightLine(i,j).yPos(end),xColorRep,yColorRep,j);
            [colorSwiSign,colorSwiAngleDiff,colorSwiMainVectorAngle,colorSwiCurvedVectorAngle] = curvatureSign(colorSwiStraightLine(i,j).xPos(1),colorSwiStraightLine(i,j).xPos(end),colorSwiStraightLine(i,j).yPos(1),colorSwiStraightLine(i,j).yPos(end),xColorSwi,yColorSwi,j);

            if j == 2
                if figMainVectorAngle > figCurvedVectorAngle
                    figPositive = 0;
                else
                    figPositive = 1;
                end
                
                if noFigMainVectorAngle > noFigCurvedVectorAngle
                    noFigPositive = 0;
                else
                    noFigPositive = 1;
                end
                
                if colorRepMainVectorAngle > colorRepCurvedVectorAngle
                    colorRepPositive = 0;
                else
                    colorRepPositive = 1;
                end
                
                if colorSwiMainVectorAngle > colorSwiCurvedVectorAngle
                    colorSwiPositive = 0;
                else
                    colorSwiPositive = 1;
                end
            elseif j == 3
                if figMainVectorAngle > figCurvedVectorAngle
                    figPositive = 1;
                else
                    figPositive = 0;
                end
                
                if noFigMainVectorAngle > noFigCurvedVectorAngle
                    noFigPositive = 1;
                else
                    noFigPositive = 0;
                end
                
                if colorRepMainVectorAngle > colorRepCurvedVectorAngle
                    colorRepPositive = 1;
                else
                    colorRepPositive = 0;
                end
                
                if colorSwiMainVectorAngle > colorSwiCurvedVectorAngle
                    colorSwiPositive = 1;
                else
                    colorSwiPositive = 0;
                end
            end
            
            % If the distance to the distractor location is smaller
            % for this sample on distractor present trials, the
            % attraction score at this point is positive - that is
            % because this would suggest that movement is being
            % pulled towards the distractor location.  If it's not
            % closer, it's negative, reflecting movement away from
            % the distractor location relative to baseline.
            if figPositive == 1%distLineToDistractor < noDistLineToDistractor
                figAttractionScore(i,j).scores(l) = figLine * 2.54;
            else
                figAttractionScore(i,j).scores(l) = -figLine * 2.54;
            end
            
            if noFigPositive == 1%distLineToDistractor < noDistLineToDistractor
                noFigAttractionScore(i,j).scores(l) = noFigLine * 2.54;
            else
                noFigAttractionScore(i,j).scores(l) = -noFigLine * 2.54;
            end
            
            if colorRepPositive == 1%distLineToDistractor < noDistLineToDistractor
                colorRepAttractionScore(i,j).scores(l) = colorRepLine * 2.54;
            else
                colorRepAttractionScore(i,j).scores(l) = -colorRepLine * 2.54;
            end
            
            if colorSwiPositive == 1%distLineToDistractor < noDistLineToDistractor
                colorSwiAttractionScore(i,j).scores(l) = colorSwiLine * 2.54;
            else
                colorSwiAttractionScore(i,j).scores(l) = -colorSwiLine * 2.54;
            end
        end
    end
    
    %Store the average attraction scores for each subject (averaged across
    %different combinations of target and distractor location).
    avgFigAttractionScores(i,:) = mean(reshape([figAttractionScore(i,:,:).scores],reSampleLength,[])',1);
    avgNoFigAttractionScores(i,:) = mean(reshape([noFigAttractionScore(i,:,:).scores],reSampleLength,[])',1);
    
    avgColorRepAttractionScores(i,:) = mean(reshape([colorRepAttractionScore(i,:,:).scores],reSampleLength,[])',1);
    avgColorSwiAttractionScores(i,:) = mean(reshape([colorSwiAttractionScore(i,:,:).scores],reSampleLength,[])',1);
end

for dd = 1:reSampleLength
    [hFig(dd), pFig(dd)] = ttest(avgFigAttractionScores(:,dd),avgNoFigAttractionScores(:,dd));
    [hColor(dd), pColor(dd)] = ttest(avgColorRepAttractionScores(:,dd),avgColorSwiAttractionScores(:,dd));
end        

meanFigAttractionScores = 10*mean(avgFigAttractionScores);
meanNoFigAttractionScores = 10*mean(avgNoFigAttractionScores);

meanColorRepAttractionScores = 10*mean(avgColorRepAttractionScores);
meanColorSwiAttractionScores = 10*mean(avgColorSwiAttractionScores);

semFigAttractionScores = std(10*avgFigAttractionScores)/sqrt(numSubjects);
semNoFigAttractionScores = std(10*avgNoFigAttractionScores)/sqrt(numSubjects);

semColorRepAttractionScores = std(10*avgColorRepAttractionScores)/sqrt(numSubjects);
semColorSwiAttractionScores = std(10*avgColorSwiAttractionScores)/sqrt(numSubjects);

% Center attraction score (Fig)
figure('Color',[1 1 1],'units','pixels','outerposition',[0 0 1250 1000])
hold on;
fill([0:100,fliplr(0:100)],[meanFigAttractionScores+semFigAttractionScores,...
    fliplr(meanFigAttractionScores-semFigAttractionScores)],'',...
    'FaceColor',[.3 .75 .93],'FaceAlpha',.5,'EdgeColor',[.3 .75 .93],'EdgeAlpha',.5);
fill([0:100,fliplr(0:100)],[meanNoFigAttractionScores+semNoFigAttractionScores,...
    fliplr(meanNoFigAttractionScores-semNoFigAttractionScores)],'',...
    'FaceColor',[1 .6 .78],'FaceAlpha',.5,'EdgeColor',[1 .6 .78],'EdgeAlpha',.5);
m = plot(0:100,meanFigAttractionScores,'b-','LineWidth',2);
n = plot(0:100,meanNoFigAttractionScores,'r-','LineWidth',2);
% errorbar(0:100,meanCenterAttractFig,semCenterAttractFig,'b.','LineWidth',2);
% errorbar(0:100,meanCenterAttractNoFig,semCenterAttractNoFig,'r.','LineWidth',2);
title('Reach Attraction Toward Center','FontSize',48,'FontWeight','Normal');
text(50,-2.5,'Normalized Space (%)','FontSize',36,'HorizontalAlignment','Center');
text(-10,12.5,'Attraction Score (mm)','FontSize',36,'Rotation',90,'HorizontalAlignment','Center');
legend([m,n],'Figure','No Figure','Location','Northwest');
legend boxoff;
axis([0 100 -0 25]);
set(gca,'XTick',0:20:100, 'FontSize',36);
set(gca,'YTick',0:5:25, 'FontSize',36);

% Center attraction score (Color)
figure('Color',[1 1 1],'units','pixels','outerposition',[0 0 1250 1000])
hold on;
fill([0:100,fliplr(0:100)],[meanColorRepAttractionScores+semColorRepAttractionScores,...
    fliplr(meanColorRepAttractionScores-semColorRepAttractionScores)],'',...
    'FaceColor',[.3 .75 .93],'FaceAlpha',.5,'EdgeColor',[.3 .75 .93],'EdgeAlpha',.5);
fill([0:100,fliplr(0:100)],[meanColorSwiAttractionScores+semColorSwiAttractionScores,...
    fliplr(meanColorSwiAttractionScores-semColorSwiAttractionScores)],'',...
    'FaceColor',[1 .6 .78],'FaceAlpha',.5,'EdgeColor',[1 .6 .78],'EdgeAlpha',.5);
m = plot(0:100,meanColorRepAttractionScores,'b-','LineWidth',2);
n = plot(0:100,meanColorSwiAttractionScores,'r-','LineWidth',2);
% errorbar(0:100,meanCenterAttractFig,semCenterAttractFig,'b.','LineWidth',2);
% errorbar(0:100,meanCenterAttractNoFig,semCenterAttractNoFig,'r.','LineWidth',2);
title('Reach Attraction Toward Center','FontSize',48,'FontWeight','Normal');
text(50,-2.5,'Normalized Space (%)','FontSize',36,'HorizontalAlignment','Center');
text(-10,12.5,'Attraction Score (mm)','FontSize',36,'Rotation',90,'HorizontalAlignment','Center');
legend([m,n],'Color Repeat','Color Switch','Location','Northwest');
legend boxoff;
axis([0 100 -0 30]);
set(gca,'XTick',0:20:100, 'FontSize',36);
set(gca,'YTick',0:5:30, 'FontSize',36);

% Save new data to .mat file in ExtraFiles directory
backupFileName = 'AveragedAndResampled_Space_Rep.mat';
filePath = strcat(pwd,'/ExtraFiles/');
backupFile = [filePath, backupFileName];
save(backupFile);
