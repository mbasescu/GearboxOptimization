function [ valid ] = gearContactRatio(gearData,i)
%change threshold value in code itself, returns a boolean 
%   Detailed explanation goes here

threshold = 10; 

valid=0;
phi = 20; %deg, pressure angle
pitch=[gearData{2,2}/gearData{2,1}; gearData{4,2}/gearData{4,1}];

    
    r1O = .5*((gearData{2*i,2}+2)/pitch(i));
    r2O = .5*((gearData{2*i+1,2}+2)/pitch(i));
    r1b= .5*((gearData{2*i,1})/pitch(i))*cosd(phi);
    r2b = .5*((gearData{2*i+1,1})/pitch(i))*cosd(phi);

    a = .5*(gearData{2*i,1}+gearData{2*i+1,1}); 
    p = pi / pitch(i); 

    contactRatio =  -( (r1O-r2b)^.5 - (r2O -r1b)^.5 -a*sind(phi))/(p*cosd(phi));

    if contactRatio < threshold
        valid = 1;
    else
        valid = 0; 
    end
valid=1;
end



