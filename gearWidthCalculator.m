function [ faceWidth ] = gearWidthCalculator(torque, RPM,phi, pitch, gear1, gear2 )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
W= sym('W');

gear1teeth=gear1.teeth;
gear2teeth=gear2.teeth;

%check for gear 1 
Sf= 1.3; % safety factor 
Yn =1; %inifinite life design, 
Kt = 1; %temperature factor
Kr = 1; % reliability factor
%maxAllowableBending1 = (gear1.yield/Sf)*(Yn /(Kt*Kr)); %brought down to
%parfor loop
%maxAllowableBending2 = (gear2.yield/Sf)*(Yn /(Kt*Kr));

% First do bending, first gear
dp1 =  gear1teeth/pitch;
F = (torque/(dp1/2));
Ko =1; %Overload Factor 
%Velocity Factor 
Qv =7; % quality factor for baja type gears 
B =.25*(12-Qv)^(2/3);
A = 50 + 56*(1-B);
V = pi* dp1 * RPM/12 ; % same for both gears  
Kv= ((A + sqrt(V))/A)^B;

% size factor

Ks1 = 1; % dont have enough info to use anything else 
%load distribution factor 
Cpf1 = (W/(10*dp1)) - .25 ; % DOUBLE CHECK THIS ONE 
Cma1 = .125; % approx, could write as function of W
Cpm1 = 1.05;
Ce1 = 1; 
Cmc1 =1;
Km1 = 1 + Cmc1*(Cpf1*Cpm1 + Cma1*Ce1);
    %display(Km1);
%Rim thickness factor 
Kb1 = 1; % if we keep rim thickness bigger than tooth thickness
Ktot1 = Ko * Kv * Ks1 * Km1 * Kb1;
%eqn1 = maxAllowableBending1 == Ktot1*(F*pitch)/(W * Y1);
%W1 = double(solve(eqn1,W));
    %display(W1)
%%

dp2 = gear2teeth/pitch;
Ks2 = 1; % dont have enough info to use anything else 
%load distribution factor 
Cpf2 = (sym('W')/(10*dp2)) - .25 ; % DOUBLE CHECK THIS ONE 
Cma2 = .125; % approx, could write as function of W
Cpm2 = 1.05;
Ce2 = 1; 
Cmc2 =1;
Km2 = 1 + Cmc2*(Cpf2*Cpm2 + Cma2*Ce2);
    %display(Km2);
%Rim thickness factor 
Kb2 = 1; % if we keep rim thickness bigger than tooth thickness
Ktot2 = Ko * Kv * Ks2 * Km2 * Kb2;

%eqn2 = maxAllowableBending2 == Ktot2*(F*pitch)/(W * Y2);
%W2 = double(solve(eqn2,W));
    %display(W2)

%% Allowable Bending Stress (Conservative), can be adjusted

Sc1 = (349*gear1.hardness) + 34300; % for grade 2 
    %display(Sc1);
Sc2 = (349*gear2.hardness) + 34300;
Zn = 1; %lifetime factor
Ch = 1.005; % function of brinel ratios
maxAllowableContact1 = (Sc1/Sf)*(Zn*Ch)/(Kt*Kr);
maxAllowableContact2 = (Sc2/Sf)*(Zn*Ch)/(Kt*Kr);

%% 
Cf1 =1; %dont have a good figure
Cf2 =1;
mg = gear2teeth/gear1teeth;
I =(mg/(mg+1))*cosd(phi)*sind(phi)/2;
Cp =sqrt(1/(pi*( ( (1-.3^2)/gear1.youngs )+ ( (1-.3^2)/gear2.youngs ) )) );
%    display(Cp);

looped=zeros(1,4);
for i=1:4
    if i==5
        Y1 = lewisFactor(gear1teeth);
        maxAllowableBending1 = (gear1.yield/Sf)*(Yn /(Kt*Kr));
        eqn1 = maxAllowableBending1 == Ktot1*(F*pitch)/(W * Y1);
        temp=(solve(eqn1,W));
        if isempty(temp)==0
            looped(i) = temp;
        end
    elseif i==5
        Y2 = lewisFactor(gear2teeth);
        maxAllowableBending2 = (gear2.yield/Sf)*(Yn /(Kt*Kr));
        eqn2 = maxAllowableBending2 == Ktot2*(F*pitch)/(W * Y2);
        temp=(solve(eqn2,W));
        if isempty(temp)==0
            looped(i) = temp;
        end
    elseif i==3
        eqn3 = Cp*sqrt(F*Ko*Kv*Ks1*Km1*Cf1/(dp1*W*I)) == maxAllowableContact1;
        temp=(solve(eqn3,W));
        if isempty(temp)==0
            looped(i) = temp;
        end
    elseif i==5
        eqn4 = Cp*sqrt(F*Ko*Kv*Ks2*Km2*Cf2/(dp2*W*I)) == maxAllowableContact2;
        temp=(solve(eqn4,W));
        if isempty(temp)==0
            looped(i) = temp;
        end
      
    end
end
    faceWidth = max([looped(1);looped(2);looped(3);looped(4)]);


end

