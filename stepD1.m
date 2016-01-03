function [ke] = stepD1(firstInstance, gearData, failState)
% stepD1(storeFirst, gearData) -
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

% Declare globals
global trialStruct;
global trialArray;
global stepSize;

% If this function is not currently recursing
if firstInstance
    % Grab information about the gear set
    failState = findStress(gearData);
    gearData(:, 4) = getKE(gearData);
end 

% Store stuff
trialStruct.gearData = gearData;
trialStruct.keTot = sum(gearData(:, 4));

% Set success parameter based on failure of each gear set
if failState(1) == 0 && failState(2) == -8
    trialStruct.success = 1;
else 
    trialStruct.success = 0;
end

% Stick into array
trialArray = [trialArray trialStruct];

% Decide which way and how much to step
if firstInstance % First time through, just go bigger
    change = stepSize;
elseif failState(1) ~= 0 % If failed, go bigger
    change = stepSize;
else % Go smaller in all other cases
    change = -stepSize;
end

% Step the parameter
steppedGearData = gearData;
steppedGearData(1, 1) = gearData(1, 1) + change;
steppedGearData = ratios(steppedGearData);

% Grab updated information
if steppedGearData(1, 1) == 0 % If ratios could not be performed
    steppedFailState = [-1, -1];
    steppedGearData(:, 4) = 9999999;
else
    steppedFailState = findStress(steppedGearData);
    steppedGearData(:, 4) = getKE(steppedGearData);
end

% Check if done iterating, and set finished if so
if failState(1) ~= 0 && steppedFailState(1) == 0
    finished = 1;
end

% If finished with this step of optimization, pop back up to the first
% instance of this recursive function
if finished
    ke = sum(steppedGearData(:, 4));
    % Store before returning
    trialStruct.gearData = steppedGearData;
    trialStruct.keTot = ke;
    trialStruct.success = 1;
    trialArray = [trialArray trialStruct];
    return;
else 
    % Recurse if we're not done yet
    ke = stepD1(0, steppedGearData, steppedFailState);
end

end