function [ gearData ] = ratios(gearData)
%ratios Takes the current gear Ratio, and a table of gear data and outputs
%the correct corresponding Number of teeth, and Pitch Diamaters to make the
%ratios work out properly. 
%   You input Pitch Diamater and Number of teeth for the 2 pinion gears
%   (gear 1 and 3) and the code will find the value of the Pitch Diamater
%   and Number of Teeth of the other 2 gears. Additionally; if the center
%   to center distance is out of the acceptable range (defined in this
%   function) or if any 1 gear has too small of a diamater the code will
%   return a table full of 0s. This will indicate to the driver that what
%   it sent was invalid, and that diffrent initial values should be tried8
ratio1 = gearData(2, 1) / gearData(1, 1);
ratio2 = 7.1 / ratio1;
global pitch1;
global pitch2;

gear2diam=gearData(1,1)*ratio1;
gear2tooth=gear2diam*pitch1;
gear1tooth=gearData(1,1)*pitch1;
gear4diam=gearData(3,1)*ratio2;
gear4tooth=gear4diam*pitch2;
gear3tooth=gearData(3,1)*pitch2;

test=[gearData(1,1), gear1tooth; ...
    gear2diam, gear2tooth; gearData(3,1), gear3tooth; ...
    gear4diam, gear4tooth];

% If total length is too big
if ((test(1,1)/2) + (test(2,1)/2) - (test(3,1)/2) + (test(4,1)/2)) > 10
    test=[-2,-2;-2,-2;-2,-2;-2,-2];
% If total length is too small
elseif ((test(1,1)/2) + (test(2,1)/2) - (test(3,1)/2) + (test(4,1)/2)) < 3 
    test=[-1,-1;-1,-1;-1,-1;-1,-1];
    
%% check for center to center distances
elseif test(1,1)<1.5 || test(2,1)<1.5 || test(3,1)<1.5 || test(4,1)<1.5
    test=[-1,-1;-1,-1;-1,-1;-1,-1];
end

gearData(:,1:2)=test;

end

