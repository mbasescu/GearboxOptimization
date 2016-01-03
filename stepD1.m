function [ke] = stepD1(firstInstance, gearData, failState)
% stepD1(storeFirst, gearData) -
%
% This function takes two inputs:

% % USE FOR HIGHER LEVEL FUNCTIONS - 'storeFirst' determines whether to step this parameter immediately or to
% % store the trial before stepping.  It is a boolean value: 1 means yes, 0
% % means no.

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

% If this function is not currently recursing
if firstInstance
    % PSEUDOCODE, FIX WITH REAL ARGS AND FUNCS
    failState = findStress(arg1, arg2);
    gearData(:, 4) = getKE(arg1, arg2);
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

% STEP PARAMETER
% GET INFO ABOUT NEW DATA SET INCLUDING KE AND FAILURE
% CHECK IF DONE ITERATING, SET FINISHED IF SO

% If finished with this step of optimization, pop back up to the first
% instance of this recursive function
if finished
    ke = sum(steppedGearData(:, 4));
    % Store before returning because we won't 
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