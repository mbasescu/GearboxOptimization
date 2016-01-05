%{
2016 JHU Gearbox Analysis
Goal: Minimize rotational kinetic energy
Authors: Matthew Bailey, Max Basescu
1/2/2016

Units are American Standard
%}

% Start fresh
clc; clear all; close all;

% Clear all static variables manually (not sure if necessary)
% INSERT CODE HERE

% Set up parallel pool (faster?)
%myFiles = {'main.m', 'findStress.m', 'calcStress.m', 'gearWidthCalculator.m'};
%poolobj = gcp;
%addAttachedFiles(poolobj, myFiles);

% Define constant values
rho = 0.284; % lb/in^3 (density of gears)
totRatio = 7.1; % Input to output gear ratio
pressureAngle = 20; % Degrees

% Globals 
global stepSize; % Determines accuracy/speed of optimization
stepSize = 0.1;
global pitch1;
pitch1 = 10;
global pitch2;
pitch2 = 10;

% Set up gear variables
currentRatio = 2; % Ratio of first gear set

% Table of initial gear properties
% Column headers: 'Pitch Diameter', '# of Teeth', 'Face Width', 'KE'
gearData = [4,19,1,1;6,52,1,1;2.8,19,2,1;6,52,2,1];
gearData(:, 4) = getKE(gearData);

% Counters
% storeFirst = 0; % Tells the innermost loop whether or not to store data before stepping its parameter

% Data structures to store each optimization trial
global trialStruct;
trialStruct = struct('gearData', [], 'keTot', 0, 'success', 0); % success = 1 corresponds to success
global trialArray;
trialArray = []; % Stores each attempt of parameter combinations

% Perform optimization
[minKE, failed] = stepD2(1, gearData, [0, 0])

successfulTrials = [];
failedTrials = [];

hold on;
% Identify succesful trials and unsuccessful trials, plot success in red
% and failure in black
for i = 1:length(trialArray)
    if trialArray(i).success && checkConstraints([trialArray(i).gearData])
        plot(i, trialArray(i).keTot, 'ro');
    else 
        plot(i, trialArray(i).keTot, 'ko');
    end
end
hold off;