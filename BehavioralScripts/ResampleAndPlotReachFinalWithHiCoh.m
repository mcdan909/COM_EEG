%% Goal of this Program:
%% Sort all trials according to their condition
%% This includes sorting by target location.
%% First, each trial is re-sampled to 100 points equally spaced
%% Then, they are sorted such that each struct has the average finger location (x & y) for
%% each of the 100 samples (first sample re-centered to 0,0)

clear all;
close all;
% How many samples should the resampling create?
reSampleLength = 101;

% touch pad was 19", 25.4 mm per inch
touchDiagMm = 19*25.4;
touchDiagPix = 1639.2;
pixPerMm = touchDiagPix/touchDiagMm;

xCen = 640;
yCen = 512;
ppd = 40.5;

% Dimensions of current screen
scrnw = 1280;
scrnh = 1024;
center = [scrnw/2 scrnh/2];

% How far from the starting marker is the response box?
buttonDistance = 850;
% What is the angle between the response boxes?
boxAngle = 45;
ymarkerOffset = 20;

% What are the x and y coordinates of the box centered at that angle
% from that distance (starting from 0,0)?
[x1,y1] = pol2cart(((90 - boxAngle/2)*pi)/160,buttonDistance);

pos = [433.47, 219.47; 846.53 219.47];

lBox = pos(1,:);
rBox = pos(2,:);
markerPos = [xCen 782];

yPenOffset = 270;

answerBoxSize = 40;

% Mirror across midline?
tarMirror = 1;

red = [237 28 36];
green = [0 165 80];


xTarMarkDist = xCen-lBox(1); % 4.9541
%yTarMarkDist = (markerPos(2)-lBox(2)+yPenOffset)/ppd; % 19.314
yTarMarkDist = markerPos(2)-lBox(2); % 15.077, seems right
%yTarMarkDist = 17.053; % Average endpt across participants

% Use response-locked data?
respLock = 0;

if respLock
    prefix = 'RL_';
else
    prefix = 'SL_';
end

path = strcat('~/Documents/Brown/COM_EEG/Data/Final_',prefix,'EEG_WithHiCoh_SignedQuartCurv/FieldTrip/');
cd(path);

% 311, 313 good examples, 308 if one sided
load(strcat('GoodSub_',prefix,'EEG_WithHiCoh_QuartCurv_FieldTrip.mat'));

nCond = size(eeg,1);
nSub = size(eeg,2);

for i = 1:nSub
    for j = 1:nCond
        
        %eeg{j,i}.xResamp = cell;
        %eeg{j,i}.yResamp = cell;
        
        for k = 1:length(eeg{j,i}.trial)
            
            [eeg{j,i}.xResamp{k},eeg{j,i}.yResamp{k}] = EZResampleSpaceXY(eeg{j,i}.xPoints{k},...
                eeg{j,i}.yPoints{k},reSampleLength,1);
            
        end
        
        % Plot individual traces
        figure(i)
        hold on;
        if j == 1
            for a = 1:length(eeg{j,i}.trial)
                plot(eeg{j,i}.xResamp{a},-eeg{j,i}.yResamp{a},'Color',green/255,'LineWidth',1.5);
            end
        elseif j == 4
            for b = 1:length(eeg{j,i}.trial)
                if b ~= 11 % Bad Trail
                plot(eeg{j,i}.xResamp{b},-eeg{j,i}.yResamp{b},'Color',red/255,'LineWidth',1.5);
                end
            end
        end
        plot(-xTarMarkDist,yTarMarkDist,'ks','MarkerSize',answerBoxSize*2);
        plot(xTarMarkDist,yTarMarkDist,'ks','MarkerSize',answerBoxSize*2);
        if j == 1
            for a = 1:length(eeg{j,i}.trial)
                plot(eeg{j,i}.xResamp{a},-eeg{j,i}.yResamp{a},'Color',green/255,'LineWidth',1.5);
            end
        elseif j == 4
            for b = 1:length(eeg{j,i}.trial)
                if b ~= 11 % Bad trial
                plot(eeg{j,i}.xResamp{b},-eeg{j,i}.yResamp{b},'Color',red/255,'LineWidth',1.5);
                end
            end
        end
        axis equal;
        set(gca, 'Units', 'Points');
        set(gca,'FontSize',16);
        set(gca,'XTick',-120*pixPerMm:40*pixPerMm:120*pixPerMm);
        set(gca,'XTickLabel',-120:40:120);
        set(gca,'YTick',0:40*pixPerMm:200*pixPerMm);
        set(gca,'YTickLabel',0:40:200);
        xlim([-100*pixPerMm 100*pixPerMm]);
        ylim([0 200*pixPerMm]);
        xlabel('Horizontal Finger Position (mm)');
        ylabel('Vertical Finger Position (mm)');
        legend({'Non-Partial Error, Low Coherence','Partial Error, Low Coherence'},'Location','NorthOutside');
        legend boxoff;
    end
end

%% Plot Individual means
for i = 1:nSub
    for j = 1:nCond
        
        countL = 1;
        countR = 1;
        
        subMeanXL = [];
        subMeanXR = [];
        
        subMeanYL = [];
        subMeanYR = [];
        
        for k = 1:length(eeg{j,i}.trial)
            if eeg{j,i}.targetLocation{k} == 1
                subMeanXL(countL,:) = eeg{j,i}.xResamp{k};
                subMeanYL(countL,:) = eeg{j,i}.yResamp{k};
                countL = countL+1;
            elseif eeg{j,i}.targetLocation{k} == 2
                subMeanXR(countR,:) = eeg{j,i}.xResamp{k};
                subMeanYR(countR,:) = eeg{j,i}.yResamp{k};
                countR = countR+1;
            end
            
        end
        
        indMeanXL(j,i,:) = nanmean(subMeanXL);
        indMeanYL(j,i,:) = nanmean(subMeanYL);
        indMeanXR(j,i,:) = nanmean(subMeanXR);
        indMeanYR(j,i,:) = nanmean(subMeanYR);
        
        
    end
    
    
    % Sub 4 only had one good trial to the left after ocular correction
    % and data gets odd after averaging. Insert original data
    indMeanXL(4,4,:) = eeg{4,4}.xResamp{1,8};
    indMeanYL(4,4,:) = eeg{4,4}.yResamp{1,8};
    
    figure(nSub+i)
    hold on;
    plot(-xTarMarkDist,yTarMarkDist,'ks','MarkerSize',answerBoxSize*2);
    plot(xTarMarkDist,yTarMarkDist,'ks','MarkerSize',answerBoxSize*2);
    plot(squeeze(indMeanXL(1,i,:)),-squeeze(indMeanYL(1,i,:)),'-g','LineWidth',2);
    plot(squeeze(indMeanXL(4,i,:)),-squeeze(indMeanYL(4,i,:)),'-r','LineWidth',2);
    plot(squeeze(indMeanXL(5,i,:)),-squeeze(indMeanYL(5,i,:)),'-k','LineWidth',2);
    plot(squeeze(indMeanXR(1,i,:)),-squeeze(indMeanYR(1,i,:)),'-g','LineWidth',2);
    plot(squeeze(indMeanXR(4,i,:)),-squeeze(indMeanYR(4,i,:)),'-r','LineWidth',2);
    plot(squeeze(indMeanXR(5,i,:)),-squeeze(indMeanYR(5,i,:)),'-k','LineWidth',2);
    axis equal;
    set(gca, 'Units', 'Points');
    set(gca,'XTick',-120*pixPerMm:40*pixPerMm:120*pixPerMm);
    set(gca,'XTickLabel',-120:40:120);
    set(gca,'YTick',0:40*pixPerMm:200*pixPerMm);
    set(gca,'YTickLabel',0:40:200);
    xlim([-120*pixPerMm 120*pixPerMm]);
    ylim([0 200*pixPerMm]);
    xlabel('Horizontal Finger Position (mm)');
    ylabel('Vertical Finger Position (mm)');
    legend({'Non-Partial Error, Low Coherence', 'Partial Error, Low Coherence', 'High Coherence'},'Location','NorthOutside');
    legend boxoff;
end

%% Plot group level mean

% Subject 4 only had one movement to the left, remove that trial from mean
groupMeanXL = squeeze(nanmean(indMeanXL,2));
groupMeanXR = squeeze(nanmean(indMeanXR,2));

groupMeanYL = squeeze(nanmean(indMeanYL,2));
groupMeanYR = squeeze(nanmean(indMeanYR,2));

groupStdXL = squeeze(nanstd(indMeanXL,0,2));
groupStdXR = squeeze(nanstd(indMeanXR,0,2));

groupStdYL = squeeze(nanstd(indMeanYL,0,2));
groupStdYR = squeeze(nanstd(indMeanYR,0,2));

groupSemXL = groupStdXL/sqrt(nSub);
groupSemXR = groupStdXR/sqrt(nSub);

groupSemYL = groupStdYL/sqrt(nSub);
groupSemYR = groupStdYR/sqrt(nSub);

figure

hold on;
plot(groupMeanXL(4,:),-groupMeanYL(4,:),'Color',red/255,'LineWidth',1.5);
plot(groupMeanXL(1,:),-groupMeanYL(1,:),'Color',green/255,'LineWidth',1.5);
plot(groupMeanXL(5,:),-groupMeanYL(5,:),'k','LineWidth',1.5);
plot(-xTarMarkDist,yTarMarkDist,'ks','MarkerSize',answerBoxSize*2);
plot(xTarMarkDist,yTarMarkDist,'ks','MarkerSize',answerBoxSize*2);
plot(groupMeanXL(4,:),-groupMeanYL(4,:),'Color',red/255,'LineWidth',1.5);
plot(groupMeanXL(1,:),-groupMeanYL(1,:),'Color',green/255,'LineWidth',1.5);
plot(groupMeanXL(5,:),-groupMeanYL(5,:),'k','LineWidth',1.5);
plot(groupMeanXR(4,:),-groupMeanYR(4,:),'Color',red/255,'LineWidth',1.5);
plot(groupMeanXR(1,:),-groupMeanYR(1,:),'Color',green/255,'LineWidth',1.5);
plot(groupMeanXR(5,:),-groupMeanYR(5,:),'k','LineWidth',1.5);
% Fill in the SEM data in the x dimension
fill([groupMeanXL(1,:)+groupSemXL(1,:),fliplr(groupMeanXL(1,:)-groupSemXL(1,:))],-[groupMeanYL(1,:),...
    fliplr(groupMeanYL(1,:))],'',...
    'FaceColor',green/255,'FaceAlpha',.25,'EdgeColor',green/255,'EdgeAlpha',0);
fill([groupMeanXR(1,:)+groupSemXR(1,:),fliplr(groupMeanXR(1,:)-groupSemXR(1,:))],-[groupMeanYR(1,:),...
    fliplr(groupMeanYR(1,:))],'',...
    'FaceColor',green/255,'FaceAlpha',.25,'EdgeColor',green/255,'EdgeAlpha',0);
fill([groupMeanXL(4,:)+groupSemXL(4,:),fliplr(groupMeanXL(4,:)-groupSemXL(4,:))],-[groupMeanYL(4,:),...
    fliplr(groupMeanYL(4,:))],'',...
    'FaceColor',red/255,'FaceAlpha',.25,'EdgeColor',red/255,'EdgeAlpha',0);
fill([groupMeanXR(4,:)+groupSemXR(4,:),fliplr(groupMeanXR(4,:)-groupSemXR(4,:))],-[groupMeanYR(4,:),...
    fliplr(groupMeanYR(4,:))],'',...
    'FaceColor',red/255,'FaceAlpha',.25,'EdgeColor',red/255,'EdgeAlpha',0);
fill([groupMeanXL(5,:)+groupSemXL(5,:),fliplr(groupMeanXL(5,:)-groupSemXL(5,:))],-[groupMeanYL(5,:),...
    fliplr(groupMeanYL(5,:))],'',...
    'FaceColor','k','FaceAlpha',.25,'EdgeColor','k','EdgeAlpha',0);
fill([groupMeanXR(5,:)+groupSemXR(5,:),fliplr(groupMeanXR(5,:)-groupSemXR(5,:))],-[groupMeanYR(5,:),...
    fliplr(groupMeanYR(5,:))],'',...
    'FaceColor','k','FaceAlpha',.25,'EdgeColor','k','EdgeAlpha',0);
% Now do for y
% fill([groupMeanXL(1,:),fliplr(groupMeanXL(1,:))],-[groupMeanYL(1,:)+groupSemYL(1,:),...
%     fliplr(groupMeanYL(1,:)-groupSemYL(1,:))],'',...
%     'FaceColor',[0 1 0],'FaceAlpha',.25,'EdgeColor',[0 1 0],'EdgeAlpha',0);
% fill([groupMeanXR(1,:),fliplr(groupMeanXR(1,:))],-[groupMeanYR(1,:)+groupSemYR(1,:),...
%     fliplr(groupMeanYR(1,:)-groupSemYR(1,:))],'',...
%     'FaceColor',[0 1 0],'FaceAlpha',.25,'EdgeColor',[0 1 0],'EdgeAlpha',0);
% fill([groupMeanXL(4,:),fliplr(groupMeanXL(4,:))],-[groupMeanYL(4,:)+groupSemYL(4,:),...
%     fliplr(groupMeanYL(4,:)-groupSemYL(4,:))],'',...
%     'FaceColor',[1 0 0],'FaceAlpha',.25,'EdgeColor',[1 0 0],'EdgeAlpha',0);
% fill([groupMeanXR(4,:),fliplr(groupMeanXR(4,:))],-[groupMeanYR(4,:)+groupSemYR(4,:),...
%     fliplr(groupMeanYR(4,:)-groupSemYR(4,:))],'',...
%     'FaceColor',[1 0 0],'FaceAlpha',.25,'EdgeColor',[1 0 0],'EdgeAlpha',0);
axis equal;
set(gca, 'Units', 'Points');
set(gca,'FontSize',16);
set(gca,'XTick',-120*pixPerMm:40*pixPerMm:120*pixPerMm);
set(gca,'XTickLabel',-120:40:120);
set(gca,'YTick',0:40*pixPerMm:200*pixPerMm);
set(gca,'YTickLabel',0:40:200);
xlim([-100*pixPerMm 100*pixPerMm]);
ylim([0 200*pixPerMm]);
xlabel('Horizontal Finger Position (mm)');
ylabel('Vertical Finger Position (mm)');
%legend({'High Coherence'},'Location','NorthOutside');
legend boxoff;

%% Normalize the y-axis relative to other target for sample plot
% xTarMarkDist (- = L, + = R)

diffCoM = [];
diffDR = [];

for i = 1:nSub
    for j = 1:reSampleLength
        
        % Calculate the distance between the low and high coherence
        % conditions
        rLineDR(i,j) = sqrt((indMeanXR(1,i,j) - indMeanXR(5,i,j))^2 + (indMeanYR(1,i,j) - indMeanYR(5,i,j))^2);
        rLineCoM(i,j) = sqrt((indMeanXR(4,i,j) - indMeanXR(5,i,j))^2 + (indMeanYR(4,i,j) - indMeanYR(5,i,j))^2);
        lLineDR(i,j) = sqrt((indMeanXL(1,i,j) - indMeanXL(5,i,j))^2 + (indMeanYL(1,i,j) - indMeanYL(5,i,j))^2);
        lLineCoM(i,j) = sqrt((indMeanXL(4,i,j) - indMeanXL(5,i,j))^2 + (indMeanYL(4,i,j) - indMeanYL(5,i,j))^2);
        
%         % Calculate the difference between low and high coherence
%         % trajectories
%         rDiffDR(i,j)
        
        % calculate the distance between each point and the distractor
        rCentDistDR(i,j) = sqrt((indMeanXR(1,i,j) - lBox(1))^2 + (indMeanYR(1,i,j) - lBox(2))^2);
        rCentDistCoM(i,j) = sqrt((indMeanXR(4,i,j) - lBox(1))^2 + (indMeanYR(4,i,j) - lBox(2))^2);
        rCentDistHi(i,j) = sqrt((indMeanXR(5,i,j) - lBox(1))^2 + (indMeanYR(5,i,j) - lBox(2))^2);
        lCentDistDR(i,j) = sqrt((indMeanXL(1,i,j) - rBox(1))^2 + (indMeanYL(1,i,j) - rBox(2))^2);
        lCentDistCoM(i,j) = sqrt((indMeanXL(4,i,j) - rBox(1))^2 + (indMeanYL(4,i,j) - rBox(2))^2);
        lCentDistHi(i,j) = sqrt((indMeanXL(5,i,j) - rBox(1))^2 + (indMeanYL(5,i,j) - rBox(2))^2);
        
        % see which line is further from the center at each point
        % remember that Hi should be greater for right and lower for left
        if rCentDistDR(i,j) < rCentDistHi(i,j)
            rLineDR(i,j) = -rLineDR(i,j);
        else
        end
        if rCentDistCoM(i,j) < rCentDistHi(i,j)
            rLineCoM(i,j) = -rLineCoM(i,j);
        else
        end
        if lCentDistDR(i,j) > lCentDistHi(i,j)
            lLineDR(i,j) = -lLineDR(i,j);
        else
        end
        if lCentDistCoM(i,j) > lCentDistHi(i,j)
            lLineCoM(i,j) = -lLineCoM(i,j);
        else
        end

    end
end

diffDR = (rLineDR+lLineDR)/2;
diffCoM = (rLineCoM+lLineCoM)/2;

% Convert data to what FieldTrip likes and run permutation test
% Cell structure matrix
for i = 1:nSub
    % Set up cell structures with fields FieldTrip needs for analysis
    ftDR{1,i}.label = 'reach';
    ftDR{1,i}.fsample = 101;
    ftDR{1,i}.time = 1:101;
    ftDR{1,i}.dimord = 'chan_time';
    ftDR{1,i}.avg = diffDR; % Subject average xPoints (1:100) as a row (each cell column is a subject)
    
    ftCoM{1,i}.label = 'reach';
    ftCoM{1,i}.fsample = 101;
    ftCoM{1,i}.time = 1:101;
    ftCoM{1,i}.dimord = 'chan_time';
    ftCoM{1,i}.avg = diffCoM;
end

% Set up configuration for stats
cfg = [];
cfg.method = 'montecarlo'; % Permutation
cfg.statistic = 'depsamplesT'; % Paired t-test at each timepoint
cfg.channel = 'reach'; % Only channel
cfg.alpha       = 0.05; % Alpha level
cfg.tail        = 0; % two-sided test
cfg.correcttail = 'alpha'; % Correct for 2-tailed test
cfg.design(1,1:2*nSub)  = [ones(1,nSub) 2*ones(1,nSub)]; % Design matrix row 1
cfg.design(2,1:2*nSub)  = [1:nSub 1:nSub]; % Design matrix row 2
cfg.numrandomization = 1000; % Number of permutations
cfg.ivar = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar = 2; % the 2nd row in cfg.design contains the subject number

diffStats = ft_timelockstatistics(cfg,ftDR{:},ftCoM{:});


permSet = [diffDR; diffCoM];

nPerm = 1000;
% for i = 1:nPerm
% 
%     permDR = [];
%     permCoM = [];
% 
%     Shuffle(permSet);
%     permDR = permSet(1:nSub,:);
%     permCoM = permSet(nSub+1:end,:);
% 
%     for j = 1:reSampleLength
% 
%         [H(i,j),P(i,j), CI] = ttest(permDR(:,j), permCoM(:,j));
%     end
% end

meanAttractDR = nanmean(diffDR)/pixPerMm;
meanAttractCoM = nanmean(diffCoM)/pixPerMm;

stdAttractDR = nanstd(diffDR)/pixPerMm;
stdAttractCoM = nanstd(diffCoM)/pixPerMm;

semAttractDR = stdAttractDR/sqrt(nSub);
semAttractCoM = stdAttractCoM/sqrt(nSub);

figure
hold on;
plot(0:100, meanAttractDR,'Color',green/255,'LineWidth',1.5);
plot(0:100, meanAttractCoM,'Color',red/255,'LineWidth',1.5);
plot(0:100, zeros(1,101), 'k');
% Fill in the SEM data in the x dimension
fill([0:100,fliplr(0:100)],[meanAttractDR(1,:)+semAttractDR(1,:),fliplr(meanAttractDR(1,:)-semAttractDR(1,:))],'',...
    'FaceColor',green/255,'FaceAlpha',.25,'EdgeColor',green/255,'EdgeAlpha',0);
fill([0:100,fliplr(0:100)],[meanAttractCoM(1,:)+semAttractCoM(1,:),fliplr(meanAttractCoM(1,:)-semAttractCoM(1,:))],'',...
    'FaceColor',red/255,'FaceAlpha',.25,'EdgeColor',red/255,'EdgeAlpha',0);
%axis equal;
set(gca, 'Units', 'Points');
set(gca,'FontSize',16);
% set(gca,'XTick',-120*pix2mm:40*pix2mm:120*pix2mm);
% set(gca,'XTickLabel',-120:40:120);
set(gca,'YTick',-5:5:10);
set(gca,'YTickLabel',-5:5:10);
xlim([0 100]);
ylim([-5 10]);
xlabel('Normalized Space (%)');
ylabel('Distractor Attraction Score (mm)');
%legend({'Non-Partial Error, Low Coherence', 'Partial Error, Low Coherence'},'Location','NorthOutside');
legend boxoff;

%%
% goodSubs = {'302','304','305','306','308','309','311','313','314','315'};
% 
% % Sub 315 already resampled?
% 
% numSub = length(goodSubs);
% 
% nConds = 6;
% 
% [colors, colorNames] = graphColors(nConds,0);
% 
% for aa = 1:numSub-1
%     
%     blockFiles = dir(strcat('MovementData_',num2str(goodSubs{aa}),'*'));
%     
%     for bb = 1:length(blockFiles);
%         load(blockFiles(bb).name,'AllXMovementPoints','AllYMovementPoints',...
%             'targetLocation','droppedTrials','acc','RT','MT','maxDeviation',...
%             'signedCurvQuart','signedAucQuart','endy');
%         
%         meanEndY(aa) = mean(endy);
%         
%         % Because some trials are not counted, this allows us to keep track
%         % of the target and distractor location for all counted trials
%         overallX = [];
%         overallY = [];
%         overallTargetLoc = [];
%         overallRT = [];
%         overallMT = [];
%         overallCurvature = [];
%         overallSignedCurvQuart = [];
%         overallSignedAucQuart = [];
%         
%         for cc = 1:length(acc)
%             
%             % only count trials that weren't dropped because of missing
%             % samples and were accurate
%             if ~droppedTrials(cc) && acc(cc)
%                 
%                 nSamplesX(cc) = sum(nonzeros(AllXMovementPoints(cc,:)));
%                 nSamplesY(cc) = sum(nonzeros(AllYMovementPoints(cc,:)));
%                 
%                 % reSample the movement to 100 points equally spaced in
%                 % time through EZResample function
%                 %reSampledXData = EZResample_Space5(nonzeros(AllXMovementPoints(x,:)),reSampleLength,1);
%                 %reSampledYData = EZResample_Space5(nonzeros(AllYMovementPoints(x,:)),reSampleLength,1);
%                 if ~isempty(nonzeros(AllXMovementPoints(cc,:)))
%                     [reSampledXData,reSampledYData] = EZResampleSpaceXY(nonzeros(AllXMovementPoints(cc,:)),...
%                         nonzeros(AllYMovementPoints(cc,:)),reSampleLength,1);
%                     
%                     % Store the resampled X and Y positions for this trial,
%                     % along with trial type, target location, and other
%                     % potentially relevant data
%                     overallX = [overallX;reSampledXData];
%                     overallY = [overallY;reSampledYData];
%                     overallTargetLoc = [overallTargetLoc;targetLocation(cc)];
%                     overallRT = [overallRT;RT(cc)];
%                     overallMT = [overallMT;RT(cc)];
%                     overallCurvature = [overallCurvature;maxDeviation(cc)];
%                     overallSignedCurvQuart = [overallSignedCurvQuart;signedCurvQuart(cc)];
%                     overallSignedAucQuart = [overallSignedAucQuart;signedAucQuart(cc)];
%                     
%                 end
%             end
%         end
%         
%         % 1 = error, 2-5 = Q1-Q4, 6 = HiCoh
%         overallSignedCurvQuart = overallSignedCurvQuart+1;
%         overallSignedAucQuart = overallSignedAucQuart+1;
%         
%         overallY = -overallY;
%         
%         figure(aa)
%         hold on;
%         set(gca,'FontSize',24);
%         xlabel('Horizontal Position (cm)');
%         set(gca,'Ytick',0:2*ppd:18*ppd);
%         set(gca,'YtickLabel',0:2:18);
%         ylim([0 18*ppd]);
%         ylabel('Vertical Position (cm)');
%         axis equal;
%         
%         % 0 = error, 1-4 = Q1-4, 5 = HiCoh
%         for dd = 1:length(overallRT)
%             for ee = 1:nConds
%                 if overallSignedCurvQuart(dd) == ee
%                     if overallTargetLoc(dd) == 1
%                         %plot(-overallX(dd,:),-overallY(dd,:),'g-');
%                         newOverallX(dd,:) = -overallX(dd,:);
%                     else
%                         %plot(overallX(dd,:),-overallY(dd,:),'g-');
%                         newOverallX(dd,:) = overallX(dd,:);
%                     end
%                 end
%             end
%         end
%         
%         condColor = {'r','g','b','y','m','k'};
%         
%         % Single Target Mirror
%         if tarMirror
%             
%             for ff = 1:nConds
%                 
%                 subMeanOverallX(aa,ff,:) = mean(newOverallX(overallSignedCurvQuart == ff,:));
%                 subMeanOverallY(aa,ff,:) = mean(overallY(overallSignedCurvQuart == ff,:));
%                 
%                 % Plot target
%                 plot(xTarMarkDist*ppd,yTarMarkDist*ppd,'ks','MarkerSize',100);
%                 % Plot reach
%                 h(ff) = plot(squeeze(subMeanOverallX(aa,ff,:)),squeeze(subMeanOverallY(aa,ff,:)),...
%                     condColor{ff},'LineWidth',2);
%                 
%                 
%                 
%                 %                 plot(mean(newOverallX(overallSignedCurvQuart == 1,:)),...
%                 %                     -mean(overallY(overallSignedCurvQuart == 1,:)),'g-','LineWidth',2);
%                 %                 plot(mean(newOverallX(overallSignedCurvQuart == 2,:)),...
%                 %                     -mean(overallY(overallSignedCurvQuart == 2,:)),'b-','LineWidth',2);
%                 %                 plot(mean(newOverallX(overallSignedCurvQuart == 3,:)),...
%                 %                     -mean(overallY(overallSignedCurvQuart == 3,:)),'k-','LineWidth',2);
%                 %                 plot(mean(newOverallX(overallSignedCurvQuart == 4,:)),...
%                 %                     -mean(overallY(overallSignedCurvQuart == 4,:)),'r-','LineWidth',2);
%                 
%                 
%                 
%             end
%             
%             set(gca,'Xtick',-2*ppd:2*ppd:8*ppd);
%             set(gca,'XtickLabel',-2:2:8);
%             xlim([-2*ppd 8*ppd]);
%             legend(h,{'Error','Q1','Q2','Q3','Q4','HiCoh'},'Location','Northwest');
%             legend BOXOFF;
%         else
%             
%             plot(-xTarMarkDist*ppd,yTarMarkDist*ppd,'ks','MarkerSize',100);
%             plot(xTarMarkDist*ppd,yTarMarkDist*ppd,'ks','MarkerSize',100);
%             % Actual Targets
%             plot(mean(overallX(overallSignedCurvQuart == 1 & overallTargetLoc == 1,:)),...
%                 -mean(overallY(overallSignedCurvQuart == 1 & overallTargetLoc == 1,:)),'g-','LineWidth',2);
%             plot(mean(overallX(overallSignedCurvQuart == 1 & overallTargetLoc == 2,:)),...
%                 -mean(overallY(overallSignedCurvQuart == 1 & overallTargetLoc == 2,:)),'g-','LineWidth',2);
%             plot(mean(overallX(overallSignedCurvQuart == 2 & overallTargetLoc == 1,:)),...
%                 -mean(overallY(overallSignedCurvQuart == 2 & overallTargetLoc == 1,:)),'b-','LineWidth',2);
%             plot(mean(overallX(overallSignedCurvQuart == 2 & overallTargetLoc == 2,:)),...
%                 -mean(overallY(overallSignedCurvQuart == 2 & overallTargetLoc == 2,:)),'b-','LineWidth',2);
%             plot(mean(overallX(overallSignedCurvQuart == 3 & overallTargetLoc == 1,:)),...
%                 -mean(overallY(overallSignedCurvQuart == 3 & overallTargetLoc == 1,:)),'k-','LineWidth',2);
%             plot(mean(overallX(overallSignedCurvQuart == 3 & overallTargetLoc == 2,:)),...
%                 -mean(overallY(overallSignedCurvQuart == 3 & overallTargetLoc == 2,:)),'k-','LineWidth',2);
%             plot(mean(overallX(overallSignedCurvQuart == 4 & overallTargetLoc == 1,:)),...
%                 -mean(overallY(overallSignedCurvQuart == 4 & overallTargetLoc == 1,:)),'r-','LineWidth',2);
%             plot(mean(overallX(overallSignedCurvQuart == 4 & overallTargetLoc == 2,:)),...
%                 -mean(overallY(overallSignedCurvQuart == 4 & overallTargetLoc == 2,:)),'r-','LineWidth',2);
%         end
%         
%         %             figure(aa)
%         %             hold on;
%         %             set(gca,'FontSize',24);
%         %             set(gca,'Xtick',-8*ppd:2*ppd:8*ppd);
%         %             set(gca,'XtickLabel',-8:2:8);
%         %             xlim([-8*ppd 8*ppd]);
%         %             xlabel('Horizontal Position (cm)');
%         %             set(gca,'Ytick',0:2*ppd:18*ppd);
%         %             set(gca,'YtickLabel',0:2:18);
%         %             ylim([0 18*ppd]);
%         %             ylabel('Vertical Position (cm)');
%         %             plot(-5*ppd,15*ppd,'ks','MarkerSize',4*ppd);
%         %             plot(5*ppd,15*ppd,'ks','MarkerSize',4*ppd);
%         %             plot(mean(newOverallX(overallSignedAucQuart == 1,:)),-mean(overallY(overallSignedAucQuart == 1,:)),'g-');
%         %             plot(mean(newOverallX(overallSignedAucQuart == 4,:)),-mean(overallY(overallSignedAucQuart == 4,:)),'r-');
%         
%     end
% end
% 
% cd 
% % Sub 315's movement is already resampled, no need to interpolate
% load('MovementData_315.mat','AllXMovementPoints','AllYMovementPoints',...
%     'targetLocation','droppedTrials','acc','RT','MT','maxDeviation',...
%     'signedCurvQuart','signedAucQuart');
% 
% figure(10)
% hold on;
% set(gca,'FontSize',24);
% set(gca,'Xtick',-8*ppd:2*ppd:8*ppd);
% set(gca,'XtickLabel',-8:2:8);
% xlim([-8*ppd 8*ppd]);
% xlabel('Horizontal Position (cm)');
% set(gca,'Ytick',0:2*ppd:18*ppd);
% set(gca,'YtickLabel',0:2:18);
% ylim([0 18*ppd]);
% ylabel('Vertical Position (cm)');
% plot(-xTarMarkDist*ppd,yTarMarkDist*ppd,'ks','MarkerSize',100);
% plot(xTarMarkDist*ppd,yTarMarkDist*ppd,'ks','MarkerSize',100);
% axis equal;
% 
% for ee = 1:length(acc)
%     if targetLocation(ee) == 1
%         newAllXMovementPoints(ee,1:101) = -AllXMovementPoints(ee,1:101);
%     else
%         newAllXMovementPoints(ee,1:101) = AllXMovementPoints(ee,1:101);
%     end
%     
%     if ~droppedTrials(ee) && acc(ee)
%         if signedCurvQuart(ee) == 1
%             if targetLocation(ee) == 1
%                 %plot(-AllXMovementPoints(ee,1:101),-AllYMovementPoints(ee,1:101),'g-');
%                 %newAllXMovementPoints(ee,1:101) = -AllXMovementPoints(ee,1:101);
%             else
%                 %plot(AllXMovementPoints(ee,1:101),-AllYMovementPoints(ee,1:101),'g-');
%                 %newAllXMovementPoints(ee,1:101) = AllXMovementPoints(ee,1:101);
%             end
%         elseif signedCurvQuart(ee) == 4
%             if targetLocation(ee) == 1
%                 %plot(-AllXMovementPoints(ee,1:101),-AllYMovementPoints(ee,1:101),'r-');
%                 %newAllXMovementPoints(ee,1:101) = -AllXMovementPoints(ee,1:101);
%             else
%                 %plot(AllXMovementPoints(ee,1:101),-AllYMovementPoints(ee,1:101),'r-');
%                 %newAllXMovementPoints(ee,1:101) = AllXMovementPoints(ee,1:101);
%             end
%         end
%     end
% end
% 
% % Single Target Mirror
% if tarMirror
%     plot(mean(newAllXMovementPoints(signedCurvQuart == 1 & ~droppedTrials' & acc',1:101)),...
%         -mean(AllYMovementPoints(signedCurvQuart == 1 & ~droppedTrials' & acc',1:101)),'g-','LineWidth',2);
%     plot(mean(newAllXMovementPoints(signedCurvQuart == 2 & ~droppedTrials' & acc',1:101)),...
%         -mean(AllYMovementPoints(signedCurvQuart == 2 & ~droppedTrials' & acc',1:101)),'b-','LineWidth',2);
%     plot(mean(newAllXMovementPoints(signedCurvQuart == 3 & ~droppedTrials' & acc',1:101)),...
%         -mean(AllYMovementPoints(signedCurvQuart == 3 & ~droppedTrials' & acc',1:101)),'k-','LineWidth',2);
%     plot(mean(newAllXMovementPoints(signedCurvQuart == 4 & ~droppedTrials' & acc',1:101)),...
%         -mean(AllYMovementPoints(signedCurvQuart == 4 & ~droppedTrials' & acc',1:101)),'r-','LineWidth',2);
% else
%     % Actual Targets
%     plot(mean(AllXMovementPoints(signedCurvQuart == 1 & ~droppedTrials' & acc' & targetLocation' == 1,1:101)),...
%         -mean(AllYMovementPoints(signedCurvQuart == 1 & ~droppedTrials' & acc' & targetLocation' == 1,1:101)),'g-','LineWidth',2);
%     plot(mean(AllXMovementPoints(signedCurvQuart == 1 & ~droppedTrials' & acc' & targetLocation' == 2,1:101)),...
%         -mean(AllYMovementPoints(signedCurvQuart == 1 & ~droppedTrials' & acc' & targetLocation' == 2,1:101)),'g-','LineWidth',2);
%     plot(mean(AllXMovementPoints(signedCurvQuart == 2 & ~droppedTrials' & acc' & targetLocation' == 1,1:101)),...
%         -mean(AllYMovementPoints(signedCurvQuart == 2 & ~droppedTrials' & acc' & targetLocation' == 1,1:101)),'b-','LineWidth',2);
%     plot(mean(AllXMovementPoints(signedCurvQuart == 2 & ~droppedTrials' & acc' & targetLocation' == 2,1:101)),...
%         -mean(AllYMovementPoints(signedCurvQuart == 2 & ~droppedTrials' & acc' & targetLocation' == 2,1:101)),'b-','LineWidth',2);
%     plot(mean(AllXMovementPoints(signedCurvQuart == 3 & ~droppedTrials' & acc' & targetLocation' == 1,1:101)),...
%         -mean(AllYMovementPoints(signedCurvQuart == 3 & ~droppedTrials' & acc' & targetLocation' == 1,1:101)),'k-','LineWidth',2);
%     plot(mean(AllXMovementPoints(signedCurvQuart == 3 & ~droppedTrials' & acc' & targetLocation' == 2,1:101)),...
%         -mean(AllYMovementPoints(signedCurvQuart == 3 & ~droppedTrials' & acc' & targetLocation' == 2,1:101)),'k-','LineWidth',2);
%     plot(mean(AllXMovementPoints(signedCurvQuart == 4 & ~droppedTrials' & acc' & targetLocation' == 1,1:101)),...
%         -mean(AllYMovementPoints(signedCurvQuart == 4 & ~droppedTrials' & acc' & targetLocation' == 1,1:101)),'r-','LineWidth',2);
%     plot(mean(AllXMovementPoints(signedCurvQuart == 4 & ~droppedTrials' & acc' & targetLocation' == 2,1:101)),...
%         -mean(AllYMovementPoints(signedCurvQuart == 4 & ~droppedTrials' & acc' & targetLocation' == 2,1:101)),'r-','LineWidth',2);
% end