function [ fails ] = findStress(gearData)
%findStress Summary of this function goes here
%   Erez wrote it. ask him when you can't figure it out. 

fails = [0 0];
%% For pair 1
pitch1=gearData(1,2)/gearData(1,1);

gear1Teeth=gearData(1,2);
gear2Teeth=gearData(2,2);

face1=calcStress(pitch1, gear1Teeth, gear2Teeth, 1);

if face1>gearData(1,3)
    fails(1)=face1-gearData(1,3);
else
    fails(1)=0;
end

%% For pair 2

pitch2=gearData(3,2)/gearData(3,1);
gear3Teeth=gearData(3,2);
gear4Teeth=gearData(4,2);
    
face2=calcStress(pitch2, gear3Teeth, gear4Teeth, gearData(2,1)/gearData(1,1));
    
if face2>gearData(3,3)
    fails(2)=face2-gearData(3,3);
else
    fails(2)=-8;
end
end

