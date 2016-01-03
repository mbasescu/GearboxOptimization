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
myFiles = {'main.m', 'findStress.m', 'calcStress.m', 'gearWidthCalculator.m'};
poolobj = gcp;
addAttachedFiles(poolobj, myFiles);

% Define constant values
rho = 0.284; % lb/in^3 (density of gears)
totRatio = 7.1; % Input to output gear ratio
pressureAngle = 20; % Degrees

stepSize = 0.1; % Determines accuracy/speed of optimization

% Set up gear variables
currentRatio = 2; % Ratio of first gear set

% Table of current gear properties
% Column headers: 'Pitch Diameter', '# of Teeth', 'Face Width', 'KE'
gearData = [4,19,1,1;6,52,1,1;1.8,19,2,1;6,52,2,1];
gearData(:, 4) = getKE(gearData, currentRatio); % TODO: modify getKE to return proper formatting

% Counters
% storeFirst = 0; % Tells the innermost loop whether or not to store data before stepping its parameter

% Data structures to store each optimization trial
global trialStruct;
trialStruct = struct('gearData', [], 'keTot', 0, 'success', 0); % success = 1 corresponds to success
global trialArray;
trialArray = []; % Stores each attempt of parameter combinations
