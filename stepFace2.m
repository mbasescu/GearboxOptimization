function [ke, failed] = stepFace2(firstInstance, gearData, failState)
% stepFace2(firstInstance, gearData, failState) -
%
% This function takes three inputs:
%
% - 'firstInstance' is a boolean (0 or 1) describing whether or not this
% function is being called from a higher level function, or whether it is
% recursing
% - 'gearData' is a matrix containing a set of gear data and corresponding
% kinetic energies for each gear in the set.  Refer to 'main.m' for
% detailed description of format
% - 'failState' is a 1x2 row vector describing if the first or second set
% of gears in the current gearData fails due to stress.  If calling this
% function from a higher level function (i.e. not recursing), pass in
% anything for this vector, but make sure to set firstInstance to 1
%
% Once finished recursing, this function returns 'ke', the minimum value of kinetic energy it has
% achieved before leaving this level of recursion (popping back up to the
% next highest parameter).  However, if a choice could not be made for this
% parameter that prevents failure, the second return value will be set to 1

% Setup/initialization
finished = 0;
failed = 0;

% Declare globals
global trialStruct;
global trialArray;
global currentRatio;
global stepSize;
persistent faceLast;
persistent faceBeforeLast;
persistent keLast;
persistent keBeforeLast;
persistent keHist;
persistent countFace2;

if isempty(countFace2)
    countFace2 = 0;
else
    countFace2 = countFace2 + 1
end

faceLast = gearData(3, 3);
    
% If this function is not currently recursing
if firstInstance
    keHist = [];
    
    % First optimize over the current state
    gearData = ratios(gearData, currentRatio);
    [keLast, subFailedLast] = stepFace1(1, gearData, [0, 0]);
    keHist = [keHist, keLast];
    
    % Save best diameters and face1
    gearDataTemp = [trialStruct.gearData];
    gearData(1, 1) = gearDataTemp(1, 1);
    gearData(3, 1) = gearDataTemp(3, 1);
    gearData(1, 3) = gearDataTemp(1, 3);
    gearData(2, 3) = gearDataTemp(2, 3);
    
    keBeforeLast = keLast;
    faceBeforeLast = faceLast;
    % Set the initial failure state
    if subFailedLast
        failState = 1;
    else
        failState = 0;
    end
end 

% Decide which way and how much to step
if firstInstance % First time through, just go bigger
    change = stepSize;
elseif keLast < keBeforeLast || keLast == keBeforeLast % Keep going in the same direction if ke is decreasing
    change = sign(faceLast - faceBeforeLast)*stepSize;
elseif keLast > keBeforeLast % If ke is getting worse, go in the other direction
    change = -sign(faceLast - faceBeforeLast)*stepSize;
end

% Step the face size
steppedFace = faceLast + change;
steppedGearData = gearData;
steppedGearData(3, 3) = steppedFace;
steppedGearData(4, 3) = steppedFace;

% Now optimize over this new face size
[keCurr, steppedFailState] = stepFace1(1, steppedGearData, [0, 0]);

% If the lowest kinetic energy has not been updated for at least 7 iterations, kick out
minIndices = find(keHist == min(keHist));
minIndex = minIndices(1);
if minIndex <= length(keHist) - 5
    finished = 1;
end

% Set the before last values
faceBeforeLast = faceLast;
keBeforeLast = keLast;
keLast = keCurr;
keHist = [keHist, keLast];

% If finished with this step of optimization, pop back up to the first
% instance of this recursive function
if finished
    failed = 0;
    ke = min(keHist);
    return;
else
    % Recurse if we're not done yet
    [ke, failed] = stepFace2(0, steppedGearData, steppedFailState);
end
end