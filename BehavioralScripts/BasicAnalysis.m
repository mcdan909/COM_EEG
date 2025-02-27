%% Goal of this Program:
%% Sort all trials according to their condition
%% This includes sorting by target location.
%% First, each trial is re-sampled to 100 points equally spaced in time
%% Then, they are sorted such that each struct has the average finger location (x & y) for
%% each of the 100 samples (first sample re-centered to 0,0)

clear all;

% Use original behavior or only include trials used for EEG?
orig = 0;
LPF = 0;

respLock = 0;
feedLock = 0;

if LPF
    filt = '';
else
    filt = ''
end

if respLock
    prefix = 'RL'
elseif feedLock
    prefix = 'FL';
else
    prefix = 'SL';
end

path = '~/Documents/projects/COM_EEG/Data/FinalNew_SL_EEG_WithHiCoh_SignedQuartCurv/';
cd(path);

% 313 good example, 308 if one sided

goodSubs = {'302','304','305','306','308','309','310','313','314','315'};

% Sub 315 already resampled?

numSub = length(goodSubs);

nBins = 6;

[colors, colorNames] = graphColors(nBins,0);

ALLEEG = pop_loadset('filename',{strcat('302_',prefix,'_EEG',filt,'_WithHiCoh_QuartCurv.set') strcat('303_',prefix,'_EEG',filt,'_WithHiCoh_QuartCurv.set')...
            strcat('304_',prefix,'_EEG',filt,'_WithHiCoh_QuartCurv.set') strcat('305_',prefix,'_EEG',filt,'_WithHiCoh_QuartCurv.set')...
            strcat('306_',prefix,'_EEG',filt,'_WithHiCoh_QuartCurv.set') strcat('307_',prefix,'_EEG',filt,'_WithHiCoh_QuartCurv.set')...
            strcat('308_',prefix,'_EEG',filt,'_WithHiCoh_QuartCurv.set') strcat('309_',prefix,'_EEG',filt,'_WithHiCoh_QuartCurv.set')...
            strcat('310_',prefix,'_EEG',filt,'_WithHiCoh_QuartCurv.set') strcat('311_',prefix,'_EEG',filt,'_WithHiCoh_QuartCurv.set')...
            strcat('312_',prefix,'_EEG',filt,'_WithHiCoh_QuartCurv.set') strcat('313_',prefix,'_EEG',filt,'_WithHiCoh_QuartCurv.set')...
            strcat('314_',prefix,'_EEG',filt,'_WithHiCoh_QuartCurv.set') strcat('315_',prefix,'_EEG',filt,'_WithHiCoh_QuartCurv.set')},'filepath',path);
        
for i = 1:length(ALLEEG)
    for j = 1:nBins
        indMeanRT(i,j) = 1000*mean([ALLEEG(i).event([ALLEEG(i).epoch.eventenable]...
        & ~[ALLEEG(i).epoch.eventflag] & [ALLEEG(i).event.bini] == j).RT]);
        indMeanMT(i,j) = 1000*mean([ALLEEG(i).event([ALLEEG(i).epoch.eventenable]...
        & ~[ALLEEG(i).epoch.eventflag] & [ALLEEG(i).event.bini] == j).MT]);
        indMeanSignedCurv(i,j) = mean([ALLEEG(i).event([ALLEEG(i).epoch.eventenable]...
        & ~[ALLEEG(i).epoch.eventflag] & [ALLEEG(i).event.bini] == j).signedCurv]);
    end
end

%%
% :numSub-1
for aa = 1:numSub
    
    if orig
        blockFiles = dir(strcat('MovementData_',num2str(goodSubs{aa}),'*'));
    else
        blockFiles = dir(strcat(num2str(goodSubs{aa}),'*.mat'));
    end
    
    for bb = 1:length(blockFiles);
        
        if orig
            load(blockFiles(bb).name,'acc','RT','MT','maxDeviation',...
                'signedCurv','signedCurvQuart');
            signedCurvQuart = signedCurvQuart+1;
        else
            
            load(blockFiles(bb).name);
        end

        for cc = 1:nConds
            
            if orig
                indMeanAcc(aa,cc) = 100*mean(acc(signedCurvQuart == cc));
                indMeanRT(aa,cc) = 1000*mean(RT(signedCurvQuart == cc));
                indMeanMT(aa,cc) = 1000*mean(MT(signedCurvQuart == cc));
                indMeanCurv(aa,cc) = mean(maxDeviation(signedCurvQuart == cc));
                indMeanSignedCurv(aa,cc) = mean(signedCurv(signedCurvQuart == cc));
            else
                EEG.event
            end

        end
    end
    

end

% meanAcc = mean(indMeanAcc);
% meanRT = mean(indMeanRT);
% meanMT = mean(indMeanMT);
% meanCurv = mean(indMeanCurv);
% meanSignedCurv = mean(indMeanSignedCurv);

%%
        
        
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
        
        if orig
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
                        overallMT = [overallMT;MT(cc)];
                        overallCurvature = [overallCurvature;maxDeviation(cc)];
                        overallSignedCurvQuart = [overallSignedCurvQuart;signedCurvQuart(cc)];
                        overallSignedAucQuart = [overallSignedAucQuart;signedAucQuart(cc)];
                        
                    end
                end
            end
        else
            
            %nGoodTrials = sum([EEG.EVENTLIST.eventinfo(~[EEG.EVENTLIST.eventinfo.flag]).enable]);
            
            %sum([EEG.EVENTLIST.eventinfo([EEG.EVENTLIST.eventinfo.bini] == 6).enable])
            
            % ~[EEG.epoch.eventflag] & [EEG.epoch.eventbini] == 4
            
            goodBins = ~[EEG.epoch.eventflag];
            
            for cc = 1:sum(goodBins)
                if goodBins(cc) && EEG.event(cc).acc
                    nSamplesX(cc) = sum(EEG.event(cc).xPoints);
                    nSamplesY(cc) = sum(EEG.event(cc).yPoints);
                    
                    % reSample the movement to 100 points equally spaced in
                    % time through EZResample function
                    %reSampledXData = EZResample_Space5(nonzeros(AllXMovementPoints(x,:)),reSampleLength,1);
                    %reSampledYData = EZResample_Space5(nonzeros(AllYMovementPoints(x,:)),reSampleLength,1);
                    if ~isempty(EEG.event(cc).xPoints)
                        [reSampledXData,reSampledYData] = EZResampleSpaceXY(EEG.event(cc).xPoints,...
                            EEG.event(cc).yPoints,reSampleLength,1);
                        
                        % Store the resampled X and Y positions for this trial,
                        % along with trial type, target location, and other
                        % potentially relevant data
                        overallX = [overallX;reSampledXData];
                        overallY = [overallY;reSampledYData];
                        overallTargetLoc = [overallTargetLoc;EEG.event(cc).targetLocation];
                        overallRT = [overallRT;EEG.event(cc).RT];
                        overallMT = [overallMT;EEG.event(cc).MT];
                        overallCurvature = [overallCurvature;EEG.event(cc).signedCurv];
                        overallSignedCurvQuart = [overallSignedCurvQuart;EEG.event(cc).signedCurvQuart];
                        overallSignedAucQuart = [overallSignedAucQuart;EEG.event(cc).signedAucQuart];
                        
                    end
                    
                end
            end
        end
        
        % 1 = error, 2-5 = Q1-Q4, 6 = HiCoh
        overallSignedCurvQuart = overallSignedCurvQuart;
        overallSignedAucQuart = overallSignedAucQuart;
        
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
        
        condColor = {'g','b','m','r','k'};
        
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
            legend(h,{'Q1','Q2','Q3','Q4','HiCoh'},'Location','Northwest');
            legend BOXOFF;
        else
            
            plot(-xTarMarkDist*ppd,yTarMarkDist*ppd,'ks','MarkerSize',100);
            plot(xTarMarkDist*ppd,yTarMarkDist*ppd,'ks','MarkerSize',100);
            % Actual Targets
            plot(mean(overallX(overallSignedCurvQuart == 1 & overallTargetLoc == 1,:)),...
                mean(overallY(overallSignedCurvQuart == 1 & overallTargetLoc == 1,:)),'g-','LineWidth',2);
            plot(mean(overallX(overallSignedCurvQuart == 1 & overallTargetLoc == 2,:)),...
                mean(overallY(overallSignedCurvQuart == 1 & overallTargetLoc == 2,:)),'g-','LineWidth',2);
            plot(mean(overallX(overallSignedCurvQuart == 2 & overallTargetLoc == 1,:)),...
                mean(overallY(overallSignedCurvQuart == 2 & overallTargetLoc == 1,:)),'b-','LineWidth',2);
            plot(mean(overallX(overallSignedCurvQuart == 2 & overallTargetLoc == 2,:)),...
                mean(overallY(overallSignedCurvQuart == 2 & overallTargetLoc == 2,:)),'b-','LineWidth',2);
            plot(mean(overallX(overallSignedCurvQuart == 3 & overallTargetLoc == 1,:)),...
                mean(overallY(overallSignedCurvQuart == 3 & overallTargetLoc == 1,:)),'k-','LineWidth',2);
            plot(mean(overallX(overallSignedCurvQuart == 3 & overallTargetLoc == 2,:)),...
                mean(overallY(overallSignedCurvQuart == 3 & overallTargetLoc == 2,:)),'k-','LineWidth',2);
            plot(mean(overallX(overallSignedCurvQuart == 4 & overallTargetLoc == 1,:)),...
                mean(overallY(overallSignedCurvQuart == 4 & overallTargetLoc == 1,:)),'r-','LineWidth',2);
            plot(mean(overallX(overallSignedCurvQuart == 4 & overallTargetLoc == 2,:)),...
                mean(overallY(overallSignedCurvQuart == 4 & overallTargetLoc == 2,:)),'r-','LineWidth',2);
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


%% 
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