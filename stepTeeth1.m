function [ke, failed] = stepPitch1(firstInstance, gearData, failState)
% stepPitch1(firstInstance, gearData, failState) -
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
global pitch1;
persistent keLast;
persistent keBeforeLast;
persistent pitchLast;
persistent pitchBeforeLast;

% If this function is not currently recursing
if firstInstance
    % Optimize over current state first
    gearData = ratios(gearData);
    pitchLast = pitch1;
    [keLast, subFailedLast] = stepRatio(1, gearData, [0, 0]);
    keBeforeLast = keLast;
    pitchBeforeLast = pitchLast;

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
    change = sign(pitchLast - pitchBeforeLast)*stepSize;
elseif keLast > keBeforeLast % If ke is getting worse, go in the other direction
    change = -sign(pitchLast - pitchBeforeLast)*stepSize;
elseif keLast == keBeforeLast
    change = sign(pitchLast - pitchBeforeLast)*stepSize;
end

change = 10*change;

% Step the pitch
pitch1 = pitchLast + change;
steppedGearData = ratios(gearData);

% Now optimize over this new ratio
[keCurr, steppedFailState] = stepRatio(1, steppedGearData, [0, 0]);

% If last time we failed and had a lower kinetic energy, this is the best
% we're going to get
if steppedFailState == 0 && keCurr > keLast && keCurr < keBeforeLast
    finished = 1;
end

% Set the before last values
pitchBeforeLast = pitchLast;
keBeforeLast = keLast;
pitchLast = pitch1;
keLast = keCurr;

% If finished with this step of optimization, pop back up to the first
% instance of this recursive function
if finished
    failed = 0;
    ke = keCurr;
    return;
else 
    % Recurse if we're not done yet
    [ke, failed] = stepTeeth1(0, steppedGearData, steppedFailState);
end

end