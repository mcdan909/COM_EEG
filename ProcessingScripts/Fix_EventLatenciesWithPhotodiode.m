% Created 9/26/13 by Jeff Moher
% Function takes in a 3D array of data from eeglab which
% specifies the voltage data according to channel number, sample number,
% and trial number. When calling the function, the user specifies the
% channel number of the photodiode.  The function then calculates stimulus
% onset according to the photodiode rather than the trigger, and updates
% the EEG data to align the epochs with stimulus onset according to the
% more precise photodiode data.  This function also notes which trials are
% the first trial in a block for later removal from analysis.  This is
% because the first trial of each block was not always presented smoothly
% due to a computer/code problem.


function [newEEG,relevantEventList] =  Fix_EventLatenciesWithPhotodiode(eegData, photoChannelNumber)

% Threshold over which this represents a stimulus event
photoThreshold = 10000;
% Get photodiode data
relevantData = eegData.data(photoChannelNumber,:)';
% Get all event codes
events = {eegData.event.type};
% Get all event latencies
eventLatencies = {eegData.event.latency};
% Get important codes (i.e., first block trial, event types)
relCodes = {'S  2';'S  8';'S 16';'S 32';'S 64'};
% Make a relevant event logical
relevantEventIndeces = ismember(events,relCodes);
% Find block start indicies (S  2)
startIndeces = ismember(events,relCodes(1));
% Make block start in relevent events equal zero
relevantEventIndeces(startIndeces) = 0;
% Move the start index to remove the first trial
firstTrialIndeces = (find(startIndeces == 1) + 1);
% Create a logical of relevant events
relevantEventList = find(relevantEventIndeces);
% Create a logical of relevant event latencies
relevantLatencies = eventLatencies(relevantEventIndeces);

% around the trigger, time in which to look for photodiode activity
buffer = 300;
revisedRelevantLatencies = [];

% For each trial, step through and find the stimulus onset to the data
% according to the photodiode
for trialCounter = 1:length(relevantLatencies)
    photoData = relevantData(relevantLatencies{trialCounter} - buffer:relevantLatencies{trialCounter} + buffer);
    diffPhoto = abs(diff(photoData));
    photoSignals = find(diffPhoto > photoThreshold);
    if ~isempty(photoSignals)
        % Assign the new onset according to where the photosignal occurred.  
        %Subtract 300 because we were looking at 300 samples before and after the trigger        
        photoSignalOffset = photoSignals(1) - 300;
        revisedRelevantLatencies(trialCounter) = relevantLatencies{trialCounter} + photoSignalOffset;
    else
        revisedRelevantLatencies(trialCounter) = relevantLatencies{trialCounter};
        'PhotoFail';
    end
end

% Show in the command window the correction for a handful of trials
for i = 1:5
    relevantLatencies(i)
  revisedRelevantLatencies(i)
end

%update the struct to reflect corrected data
for i = 1:length(relevantLatencies)
    currentTrialToReplace = relevantEventList(i);
    eegData.event(currentTrialToReplace).latency = revisedRelevantLatencies(i);
end

% Mark in the struct the start of each block
eegData.event(1).startBlock = 0;
for i = 1:length(eegData.event)
    if any(firstTrialIndeces == i)
        eegData.event(i).startBlock = 1;
    else
        eegData.event(i).startBlock = 0;
    end
end

newEEG = eegData;



%% IF you want to plot out individual trial to check how well this function
%% works, uncomment the code below
% for trialCounter = 1:5
%     figure;
%     plot(relevantData(relevantLatencies{trialCounter} - 10:relevantLatencies{trialCounter} + 10));
%     relevantLatencies(trialCounter)
%     revisedRelevantLatencies(trialCounter)
% end