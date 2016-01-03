function [ minFaceWidth ] = calcStress(  pitch, gear1Teeth, gear2Teeth, currentRatio)
%findStress Summary of this function goes here
%   Erez wrote it. ask him when you can't figure it out. 
%% Input Variables (mess around with this later)
%http://www.azom.com/article.aspx?ArticleID=6733
Brinel9310 = 241;
Yield9310 = 65300; %psi
%http://www.azom.com/article.aspx?ArticleID=6770
Brinel4150 = 197;
Yield4150 = 55100; %psi


%% FIXED INPUTS
RPM = 3800/.9/currentRatio; 
torque = 14.5*12*3.8*currentRatio; %lbin
phi = 20; %deg, pressure angle

%% 


%%
%sym W; % facewidth 

gear1 = struct;
gear2 = struct;
gear1.yield = Yield9310;
gear2.yield = Yield4150;
gear1.hardness = Brinel9310;
gear2.hardness = Brinel4150;
gear1.youngs = 28500*10^3; %9310
gear2.youngs = 28500*10^3;
gear1.teeth = gear1Teeth;
gear2.teeth = gear2Teeth ;
minFaceWidth = gearWidthCalculator(torque,RPM,phi,pitch,gear1,gear2);


%% Computed Bending Stress;


% 
% %% Contact Stress 
% 
% %allowable stress
% Zn = 1; %lifetime factor 
% Ch = % hardness ratio (for pitting resistance) 
% max_allowable_contact = (Sc/Sf)*(Zn*Ch/(Kt*Kr));
% 
% contact_stress = Cp*sqrt(Ft*Ko*Kv*Ks*(Km/(dp*W))*(Cf/I));
% 
% 



end

