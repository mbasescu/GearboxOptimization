function [ke, failed] = stepRatio(firstInstance, gearData, failState)
% stepRatio(storeFirst, gearData) -
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
persistent keLast;
persistent keBeforeLast;
persistent ratioBeforeLast;

% First find information about last time's gear set
lastRatio = gearData(2, 1) / gearData(1, 1);

% If this function is not currently recursing
if firstInstance
    % Optimize over current state first
    gearData = ratios(gearData);
    lastRatio = gearData(2, 1) / gearData(1, 1);
    [keLast, subFailedLast] = stepD2(1, gearData, [0, 0]);
    keBeforeLast = keLast;
    ratioBeforeLast = lastRatio;

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
    change = sign(lastRatio - ratioBeforeLast)*stepSize;
elseif keLast > keBeforeLast % If ke is getting worse, go in the other direction
    change = -sign(lastRatio - ratioBeforeLast)*stepSize;
elseif keLast == keBeforeLast
    % CLEAN UP AND LEAVE
end

% Step the ratio
steppedRatio = lastRatio + change;
steppedGearData = ratios(gearData, steppedRatio);

% Now optimize over this new ratio
[keCurr, steppedFailState] = stepD2(1, steppedGearData, [0, 0]);

% If last time we failed and had a lower kinetic energy, this is the best
% we're going to get
if steppedFailState == 0 && keCurr > keLast && keCurr < keBeforeLast
    finished = 1;
end

% Set the before last values
ratioBeforeLast = lastRatio;
keBeforeLast = keLast;
keLast = keCurr;

% If finished with this step of optimization, pop back up to the first
% instance of this recursive function
if finished
    failed = 0;
    ke = keCurr;
    return;
else 
    % Recurse if we're not done yet
    [ke, failed] = stepRatio(0, steppedGearData, steppedFailState);
end

end