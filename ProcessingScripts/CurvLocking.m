% Created 9/26/13 by Jeff Moher
% Purpose of function is to take in a 3D array of data from eeglab which
% specifies the voltage data according to channel number, sample number,
% and trial number. When calling the function, the user specifies the
% voltage change threshold over which a sample is considered to reflect an
% eye movement or eye blink, the relevant channels to be looked at, and the
% relevant number of samples within each trial that should be looked at.
% relevant data and relevant channels within that data, and the number of
% The functions returns a list of bad trials according to this
% threshold


function [newEEG] =  CurvLocking(eegData)
%eegData = EEG;

events = {eegData.event.type};
eventLatencies = {eegData.event.latency};
relCodes = {'S  8';'S 16';'S 32';'S 64'};
relevantEventIndeces = ismember(events,relCodes);
relevantEventList = find(relevantEventIndeces);
relevantLatencies = eventLatencies(relevantEventIndeces);
revisedRelevantLatencies = [];
for trialCounter = 1:length(relevantLatencies)
        currRT = eegData.event(relevantEventList(trialCounter)).RT * 1000;
        if isempty(currRT)
            currRT = 0;
        end
        currTurnAroundRT = eegData.event(relevantEventList(trialCounter)).turnAroundRT * 1000;
        if isempty(currTurnAroundRT)
            currTurnAroundRT = 0;
        end
        %revisedRelevantLatencies(trialCounter) = relevantLatencies{trialCounter} + round(currRT/2);
        revisedRelevantLatencies(trialCounter) = relevantLatencies{trialCounter} + round(currTurnAroundRT/2);
end

for i = 1:5
     relevantLatencies(i)
     revisedRelevantLatencies(i)
end

for i = 1:length(relevantLatencies)
    currentTrialToReplace = relevantEventList(i);
     if i < 5
        eegData.event(currentTrialToReplace).latency
        revisedRelevantLatencies(i)
     end
     eegData.event(currentTrialToReplace).latency = revisedRelevantLatencies(i);
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