function [ke, failed] = stepRatio(firstInstance, gearData, failState)
% stepRatio(firstInstance, gearData, failState) -
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
% next highest parameter).

% Setup/initialization
finished = 0;
failed = 0;

% Declare globals
global trialStruct;
global trialArray;
global stepSize;
global currentRatio;
persistent keLast;
persistent keBeforeLast;
persistent ratioBeforeLast;
persistent keHist; % History of kinetic energies
persistent counter;
if isempty(counter)
    counter = 0;
end

counter = counter + 1

% First find information about last time's gear set
ratioLast = gearData(2, 1) / gearData(1, 1);

% If this function is not currently recursing
if firstInstance
    % Optimize over current state first
    gearData = ratios(gearData, currentRatio);
    ratioLast = gearData(2, 1) / gearData(1, 1);
    [keLast, subFailedLast] = stepD2(1, gearData, [0, 0]);
    keHist = [keHist, keLast];
    
    % Save best diameters
    gearDataTemp = [trialStruct.gearData];
    gearData(1, 1) = gearDataTemp(1, 1);
    gearData(3, 1) = gearDataTemp(3, 1);
    
    keBeforeLast = keLast;
    ratioBeforeLast = ratioLast;

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
elseif keLast < keBeforeLast % Keep going in the same direction if ke is decreasing
    change = sign(ratioLast - ratioBeforeLast)*stepSize;
elseif keLast > keBeforeLast % If ke is getting worse, go in the other direction
    change = -sign(ratioLast - ratioBeforeLast)*stepSize;
elseif keLast == keBeforeLast
    % CLEAN UP AND LEAVE
end

% Step the ratio
steppedRatio = ratioLast + abs(change);
currentRatio = steppedRatio;
steppedGearData = ratios(gearData, steppedRatio);

% Now optimize over this new ratio
[keCurr, steppedFailState] = stepD2(1, steppedGearData, [0, 0]);

% If the lowest kinetic energy has not been updated for at least 7 iterations, kick out
minIndices = find(keHist == min(keHist));
minIndex = minIndices(end);
if minIndex <= length(keHist) - 7
    finished = 1;
end

% Set the before last values
ratioBeforeLast = ratioLast;
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
    [ke, failed] = stepRatio(0, steppedGearData, steppedFailState);
end

end