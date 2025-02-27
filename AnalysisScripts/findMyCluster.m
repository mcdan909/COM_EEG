% fucntion to find consecutive instances where X consecutive values pass Y
% thresholds

function [mainClusterSize, summedClusterValue, clusterStart,clusterEnd] = findMyCluster(thresholdValues,numberValues,flag)

lengthValues = length(thresholdValues);
currRunSize = 0;
mainClusterSize = 0;
currStartPoint = 0;
currEndPoint = 0;
lastValue = -1;
currClusterType = 0;
clusterStart = 0;
clusterEnd = 0;
for clusterIndex = 1:lengthValues
    if thresholdValues(clusterIndex) ~= lastValue        
        currEndPoint = clusterIndex;
        currRunSize = currEndPoint - currStartPoint;
        if currRunSize > mainClusterSize && currClusterType == 1
            mainClusterSize = currRunSize;
            clusterStart = currStartPoint;
            clusterEnd = currEndPoint - 1;
        end        
        currStartPoint = clusterIndex;
        lastValue = thresholdValues(clusterIndex);
        currClusterType = thresholdValues(clusterIndex);
    end
end
if clusterStart ~= clusterEnd  
    summedClusterValue = sum(numberValues(clusterStart:clusterEnd));
else
    summedClusterValue = 0;
end


