function [ke, failed] = stepD2(firstInstance, gearData, failState)
% stepD2(storeFirst, gearData) -
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

% If this function is not currently recursing
if firstInstance
    % Optimize over current state first
    gearDataTemp = ratios(gearData, 1);
    [keLast, subFailedLast] = stepD1(1, gearDataTemp, [0, 0]);

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
elseif failState > 0 % If failed from stress or too small for ratios, go bigger
    change = stepSize;
else % Go smaller in all other cases
    change = -stepSize;
end

% Step the parameter
steppedGearData = gearData;
steppedGearData(3, 1) = gearData(3, 1) + change;
steppedGearDataTemp = ratios(steppedGearData, 1);

% Grab updated information
% First check we're within certain bounds
if steppedGearData(3,1) < 1.5
    steppedFailState = 2;
elseif steppedGearData(3,1) > 8
    steppedFailState = -1;
elseif steppedGearDataTemp(1, 1) > 0
    % Iterate lower parameters
    [keCurr, steppedFailState] = stepD1(1, steppedGearDataTemp, [0, 0]);
else 
end


% Check if done iterating, and set finished if so
if failState > 0 && steppedFailState == 0
    finished = 1;
end

% If finished with this step of optimization, pop back up to the first
% instance of this recursive function
if finished
    failed = 0;
    ke = keCurr;
    return;
else 
    % Recurse if we're not done yet
    [ke, failed] = stepD2(0, steppedGearData, steppedFailState);
end

