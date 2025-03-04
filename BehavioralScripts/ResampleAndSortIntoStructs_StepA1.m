%% Goal of this Program:
%% Sort all trials according to their condition
%% This includes sorting by target location.
%% First, each trial is re-sampled to 100 points equally spaced in time
%% Then, they are sorted such that each struct has the average finger location (x & y) for
%% each of the 100 samples (first sample re-centered to 0,0)

clear all;
% How many samples should the resampling create?
reSampleLength = 101;

xCen = 640;
yCen = 512;

lBox = [471.77 396.15];
rBox = [808.23 396.15];
markerPos = [xCen 782];

yPenOffset = 270;

% Mirror across midline?
tarMirror = 1;

%ppd = 40.5;
ppd = 33.958; % maybe?

xTarMarkDist = (xCen-lBox(1))/ppd; % 4.9541
%yTarMarkDist = (markerPos(2)-lBox(2)+yPenOffset)/ppd; % 19.314
yTarMarkDist = (markerPos(2)-yPenOffset)/ppd; % 15.077, seems right
%yTarMarkDist = 17.053; % Average endpt across participants

respLock = 1;

if respLock
    prefix = 'RL_';
else
    prefix = 'SL_';
end

path = strcat('~/Documents/Projects/COM_EEG/Data/Final_',prefix,'EEG_WithHiCoh_SignedQuartCurv/FieldTrip/');
cd(path);

% 311, 313 good examples, 308 if one sided

goodSubs = {'302','304','305','306','308','309','311','313','314','315'};

% Sub 315 already resampled?

numSub = length(goodSubs);

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

nConds = 6;

[colors, colorNames] = graphColors(nConds,0);

for aa = 1:numSub-1
    
    blockFiles = dir(strcat('MovementData_',num2str(goodSubs{aa}),'*'));
    
    for bb = 1:length(blockFiles);
        load(blockFiles(bb).name,'AllXMovementPoints','AllYMovementPoints',...
            'targetLocation','droppedTrials','acc','RT','MT','maxDeviation',...
            'signedCurvQuart','signedAucQuart','endy');
        
        meanEndY(aa) = mean(endy);
        
        % Because some trials are not counted, this allows us to keep track
        % of the target and distractor location for all counted trials
        overallX = [];
        overallY = [];
        overallTargetLoc = [];
        overallRT = [];
        overallMT = [];
        overallCurvature = [];
        overallSignedCurvQuart = [];
        overallSignedAucQuart = [];
        
        for cc = 1:length(acc)
            
            % only count trials that weren't dropped because of missing
            % samples and were accurate
            if ~droppedTrials(cc) && acc(cc)
                
                nSamplesX(cc) = sum(nonzeros(AllXMovementPoints(cc,:)));
                nSamplesY(cc) = sum(nonzeros(AllYMovementPoints(cc,:)));
                
                % reSample the movement to 100 points equally spaced in
                % time through EZResample function
                %reSampledXData = EZResample_Space5(nonzeros(AllXMovementPoints(x,:)),reSampleLength,1);
                %reSampledYData = EZResample_Space5(nonzeros(AllYMovementPoints(x,:)),reSampleLength,1);
                if ~isempty(nonzeros(AllXMovementPoints(cc,:)))
                    [reSampledXData,reSampledYData] = EZResampleSpaceXY(nonzeros(AllXMovementPoints(cc,:)),...
                        nonzeros(AllYMovementPoints(cc,:)),reSampleLength,1);
                    
                    % Store the resampled X and Y positions for this trial,
                    % along with trial type, target location, and other
                    % potentially relevant data
                    overallX = [overallX;reSampledXData];
                    overallY = [overallY;reSampledYData];
                    overallTargetLoc = [overallTargetLoc;targetLocation(cc)];
                    overallRT = [overallRT;RT(cc)];
                    overallMT = [overallMT;RT(cc)];
                    overallCurvature = [overallCurvature;maxDeviation(cc)];
                    overallSignedCurvQuart = [overallSignedCurvQuart;signedCurvQuart(cc)];
                    overallSignedAucQuart = [overallSignedAucQuart;signedAucQuart(cc)];
                    
                end
            end
        end
        
        % 1 = error, 2-5 = Q1-Q4, 6 = HiCoh
        overallSignedCurvQuart = overallSignedCurvQuart+1;
        overallSignedAucQuart = overallSignedAucQuart+1;
        
        overallY = -overallY;
        
        figure(aa)
        hold on;
        set(gca,'FontSize',24);
        xlabel('Horizontal Position (cm)');
        set(gca,'Ytick',0:2*ppd:18*ppd);
        set(gca,'YtickLabel',0:2:18);
        ylim([0 18*ppd]);
        ylabel('Vertical Position (cm)');
        axis equal;
        
        % 0 = error, 1-4 = Q1-4, 5 = HiCoh
        for dd = 1:length(overallRT)
            for ee = 1:nConds
                if overallSignedCurvQuart(dd) == ee
                    if overallTargetLoc(dd) == 1
                        %plot(-overallX(dd,:),-overallY(dd,:),'g-');
                        newOverallX(dd,:) = -overallX(dd,:);
                    else
                        %plot(overallX(dd,:),-overallY(dd,:),'g-');
                        newOverallX(dd,:) = overallX(dd,:);
                    end
                end
            end
        end
        
        condColor = {'r','g','b','y','m','k'};
        
        % Single Target Mirror
        if tarMirror
            
            for ff = 1:nConds
                
                subMeanOverallX(aa,ff,:) = mean(newOverallX(overallSignedCurvQuart == ff,:));
                subMeanOverallY(aa,ff,:) = mean(overallY(overallSignedCurvQuart == ff,:));

                % Plot target
                plot(xTarMarkDist*ppd,yTarMarkDist*ppd,'ks','MarkerSize',100);
                % Plot reach
                h(ff) = plot(squeeze(subMeanOverallX(aa,ff,:)),squeeze(subMeanOverallY(aa,ff,:)),...
                    condColor{ff},'LineWidth',2);
                
                
                
%                 plot(mean(newOverallX(overallSignedCurvQuart == 1,:)),...
%                     -mean(overallY(overallSignedCurvQuart == 1,:)),'g-','LineWidth',2);
%                 plot(mean(newOverallX(overallSignedCurvQuart == 2,:)),...
%                     -mean(overallY(overallSignedCurvQuart == 2,:)),'b-','LineWidth',2);
%                 plot(mean(newOverallX(overallSignedCurvQuart == 3,:)),...
%                     -mean(overallY(overallSignedCurvQuart == 3,:)),'k-','LineWidth',2);
%                 plot(mean(newOverallX(overallSignedCurvQuart == 4,:)),...
%                     -mean(overallY(overallSignedCurvQuart == 4,:)),'r-','LineWidth',2);
                


            end
            
            set(gca,'Xtick',-2*ppd:2*ppd:8*ppd);
            set(gca,'XtickLabel',-2:2:8);
            xlim([-2*ppd 8*ppd]);
            legend(h,{'Error','Q1','Q2','Q3','Q4','HiCoh'},'Location','Northwest');
            legend BOXOFF;
        else
            
            plot(-xTarMarkDist*ppd,yTarMarkDist*ppd,'ks','MarkerSize',100);
        plot(xTarMarkDist*ppd,yTarMarkDist*ppd,'ks','MarkerSize',100);
            % Actual Targets
            plot(mean(overallX(overallSignedCurvQuart == 1 & overallTargetLoc == 1,:)),...
                -mean(overallY(overallSignedCurvQuart == 1 & overallTargetLoc == 1,:)),'g-','LineWidth',2);
            plot(mean(overallX(overallSignedCurvQuart == 1 & overallTargetLoc == 2,:)),...
                -mean(overallY(overallSignedCurvQuart == 1 & overallTargetLoc == 2,:)),'g-','LineWidth',2);
            plot(mean(overallX(overallSignedCurvQuart == 2 & overallTargetLoc == 1,:)),...
                -mean(overallY(overallSignedCurvQuart == 2 & overallTargetLoc == 1,:)),'b-','LineWidth',2);
            plot(mean(overallX(overallSignedCurvQuart == 2 & overallTargetLoc == 2,:)),...
                -mean(overallY(overallSignedCurvQuart == 2 & overallTargetLoc == 2,:)),'b-','LineWidth',2);
            plot(mean(overallX(overallSignedCurvQuart == 3 & overallTargetLoc == 1,:)),...
                -mean(overallY(overallSignedCurvQuart == 3 & overallTargetLoc == 1,:)),'k-','LineWidth',2);
            plot(mean(overallX(overallSignedCurvQuart == 3 & overallTargetLoc == 2,:)),...
                -mean(overallY(overallSignedCurvQuart == 3 & overallTargetLoc == 2,:)),'k-','LineWidth',2);
            plot(mean(overallX(overallSignedCurvQuart == 4 & overallTargetLoc == 1,:)),...
                -mean(overallY(overallSignedCurvQuart == 4 & overallTargetLoc == 1,:)),'r-','LineWidth',2);
            plot(mean(overallX(overallSignedCurvQuart == 4 & overallTargetLoc == 2,:)),...
                -mean(overallY(overallSignedCurvQuart == 4 & overallTargetLoc == 2,:)),'r-','LineWidth',2);
        end
        
        %             figure(aa)
        %             hold on;
        %             set(gca,'FontSize',24);
        %             set(gca,'Xtick',-8*ppd:2*ppd:8*ppd);
        %             set(gca,'XtickLabel',-8:2:8);
        %             xlim([-8*ppd 8*ppd]);
        %             xlabel('Horizontal Position (cm)');
        %             set(gca,'Ytick',0:2*ppd:18*ppd);
        %             set(gca,'YtickLabel',0:2:18);
        %             ylim([0 18*ppd]);
        %             ylabel('Vertical Position (cm)');
        %             plot(-5*ppd,15*ppd,'ks','MarkerSize',4*ppd);
        %             plot(5*ppd,15*ppd,'ks','MarkerSize',4*ppd);
        %             plot(mean(newOverallX(overallSignedAucQuart == 1,:)),-mean(overallY(overallSignedAucQuart == 1,:)),'g-');
        %             plot(mean(newOverallX(overallSignedAucQuart == 4,:)),-mean(overallY(overallSignedAucQuart == 4,:)),'r-');
        
    end
end

% Sub 315's movement is already resampled, no need to interpolate
load('MovementData_315.mat','AllXMovementPoints','AllYMovementPoints',...
    'targetLocation','droppedTrials','acc','RT','MT','maxDeviation',...
    'signedCurvQuart','signedAucQuart');

figure(10)
hold on;
set(gca,'FontSize',24);
set(gca,'Xtick',-8*ppd:2*ppd:8*ppd);
set(gca,'XtickLabel',-8:2:8);
xlim([-8*ppd 8*ppd]);
xlabel('Horizontal Position (cm)');
set(gca,'Ytick',0:2*ppd:18*ppd);
set(gca,'YtickLabel',0:2:18);
ylim([0 18*ppd]);
ylabel('Vertical Position (cm)');
plot(-xTarMarkDist*ppd,yTarMarkDist*ppd,'ks','MarkerSize',100);
plot(xTarMarkDist*ppd,yTarMarkDist*ppd,'ks','MarkerSize',100);
axis equal;

for ee = 1:length(acc)
    if targetLocation(ee) == 1
        newAllXMovementPoints(ee,1:101) = -AllXMovementPoints(ee,1:101);
    else
        newAllXMovementPoints(ee,1:101) = AllXMovementPoints(ee,1:101);
    end
    
    if ~droppedTrials(ee) && acc(ee)
        if signedCurvQuart(ee) == 1
            if targetLocation(ee) == 1
                %plot(-AllXMovementPoints(ee,1:101),-AllYMovementPoints(ee,1:101),'g-');
                %newAllXMovementPoints(ee,1:101) = -AllXMovementPoints(ee,1:101);
            else
                %plot(AllXMovementPoints(ee,1:101),-AllYMovementPoints(ee,1:101),'g-');
                %newAllXMovementPoints(ee,1:101) = AllXMovementPoints(ee,1:101);
            end
        elseif signedCurvQuart(ee) == 4
            if targetLocation(ee) == 1
                %plot(-AllXMovementPoints(ee,1:101),-AllYMovementPoints(ee,1:101),'r-');
                %newAllXMovementPoints(ee,1:101) = -AllXMovementPoints(ee,1:101);
            else
                %plot(AllXMovementPoints(ee,1:101),-AllYMovementPoints(ee,1:101),'r-');
                %newAllXMovementPoints(ee,1:101) = AllXMovementPoints(ee,1:101);
            end
        end
    end
end

% Single Target Mirror
if tarMirror
    plot(mean(newAllXMovementPoints(signedCurvQuart == 1 & ~droppedTrials' & acc',1:101)),...
        -mean(AllYMovementPoints(signedCurvQuart == 1 & ~droppedTrials' & acc',1:101)),'g-','LineWidth',2);
    plot(mean(newAllXMovementPoints(signedCurvQuart == 2 & ~droppedTrials' & acc',1:101)),...
        -mean(AllYMovementPoints(signedCurvQuart == 2 & ~droppedTrials' & acc',1:101)),'b-','LineWidth',2);
    plot(mean(newAllXMovementPoints(signedCurvQuart == 3 & ~droppedTrials' & acc',1:101)),...
        -mean(AllYMovementPoints(signedCurvQuart == 3 & ~droppedTrials' & acc',1:101)),'k-','LineWidth',2);
    plot(mean(newAllXMovementPoints(signedCurvQuart == 4 & ~droppedTrials' & acc',1:101)),...
        -mean(AllYMovementPoints(signedCurvQuart == 4 & ~droppedTrials' & acc',1:101)),'r-','LineWidth',2);
else
    % Actual Targets
    plot(mean(AllXMovementPoints(signedCurvQuart == 1 & ~droppedTrials' & acc' & targetLocation' == 1,1:101)),...
        -mean(AllYMovementPoints(signedCurvQuart == 1 & ~droppedTrials' & acc' & targetLocation' == 1,1:101)),'g-','LineWidth',2);
    plot(mean(AllXMovementPoints(signedCurvQuart == 1 & ~droppedTrials' & acc' & targetLocation' == 2,1:101)),...
        -mean(AllYMovementPoints(signedCurvQuart == 1 & ~droppedTrials' & acc' & targetLocation' == 2,1:101)),'g-','LineWidth',2);
    plot(mean(AllXMovementPoints(signedCurvQuart == 2 & ~droppedTrials' & acc' & targetLocation' == 1,1:101)),...
        -mean(AllYMovementPoints(signedCurvQuart == 2 & ~droppedTrials' & acc' & targetLocation' == 1,1:101)),'b-','LineWidth',2);
    plot(mean(AllXMovementPoints(signedCurvQuart == 2 & ~droppedTrials' & acc' & targetLocation' == 2,1:101)),...
        -mean(AllYMovementPoints(signedCurvQuart == 2 & ~droppedTrials' & acc' & targetLocation' == 2,1:101)),'b-','LineWidth',2);
    plot(mean(AllXMovementPoints(signedCurvQuart == 3 & ~droppedTrials' & acc' & targetLocation' == 1,1:101)),...
        -mean(AllYMovementPoints(signedCurvQuart == 3 & ~droppedTrials' & acc' & targetLocation' == 1,1:101)),'k-','LineWidth',2);
    plot(mean(AllXMovementPoints(signedCurvQuart == 3 & ~droppedTrials' & acc' & targetLocation' == 2,1:101)),...
        -mean(AllYMovementPoints(signedCurvQuart == 3 & ~droppedTrials' & acc' & targetLocation' == 2,1:101)),'k-','LineWidth',2);
    plot(mean(AllXMovementPoints(signedCurvQuart == 4 & ~droppedTrials' & acc' & targetLocation' == 1,1:101)),...
        -mean(AllYMovementPoints(signedCurvQuart == 4 & ~droppedTrials' & acc' & targetLocation' == 1,1:101)),'r-','LineWidth',2);
    plot(mean(AllXMovementPoints(signedCurvQuart == 4 & ~droppedTrials' & acc' & targetLocation' == 2,1:101)),...
        -mean(AllYMovementPoints(signedCurvQuart == 4 & ~droppedTrials' & acc' & targetLocation' == 2,1:101)),'r-','LineWidth',2);
end