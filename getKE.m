function [ kE ] = getKE(gearData)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

currentRatio = gearData(2,1) / gearData(1,1);
rho = .284; %lb/in^3

kE3 = .5*(440/currentRatio)^2*(.5*rho*gearData(3,3)*3.14*(gearData(3,1)/2)^4);
kE1 = .5*(440)^2*(.5*rho*gearData(1,3)*3.14*(gearData(1,1)/2)^4); 

kE2 = .5*(440/currentRatio)^2*(.0085*(gearData(2,1)/2)^4)*gearData(2,3);
kE4 = .5*(440/7.1)^2*         (.0085*(gearData(4,1)/2)^4)*gearData(4,3);


kE=[kE1;kE2;kE3;kE4];

end

