function [passed] = checkConstraints(gearData)
% This function determines whether or not the gearset passed in is within
% valid constraints for each of its parameters

passed = 1;
gearData = ratios(gearData);

% If gear 1 is out of bounds
if gearData(1, 1) < 1.5 || gearData(1, 1) > 10
    passed = 0;
% If gear 2 is out of bounds
elseif gearData(3, 1) < 1.5 || gearData(3, 1) > 10
    passed = 0;
% If total length is too big
elseif ((gearData(1,1)/2) + (gearData(2,1)/2) - (gearData(3,1)/2) + (gearData(4,1)/2)) > 10
    passed = 0;
% If total length is too small
elseif ((gearData(1,1)/2) + (gearData(2,1)/2) - (gearData(3,1)/2) + (gearData(4,1)/2)) < 3 
    passed = 0;
% Check for center to center distances
elseif gearData(1,1)<1.5 || gearData(2,1)<1.5 || gearData(3,1)<1.5 || gearData(4,1)<1.5
    passed = 0;
end



end