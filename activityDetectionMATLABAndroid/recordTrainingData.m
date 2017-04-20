% This script is used to establish connection with your Android phone
% (after the required MATLAB Mobile App) is installed. After establishing
% connection from MATLAB to your phone, this App will turn on the
% accelerometer and start collecting acceleration data from your phone. 
% Follow instructions displayed during execution of this code to
% successfully record training data.
%
% Copyright 2014 The MathWorks, Inc.

connector on;

mobileSensor = mobiledev();
mobileSensor.SampleRate = 'High';

activity = ['walk          '; ...
            'run           '; ...
            'idle          '; ...
            'climb upstairs'; ...
            'go downstairs '];
activityName = char(cellstr(activity));
windowLength = 5;
uniformSampleRate = 60;

for i = 1:size(activityName, 1)

    display(['Put your phone in pocket, press ENTER, then ', ...
            deblank(activityName(i, :)), ' for at least 20 seconds.']);
    pause;


    mobileSensor.AccelerationSensorEnabled = 1;
    mobileSensor.start;
    mobileSensor.discardlogs;

    display('Press ENTER when you finish recording current activity.')
    pause;

    mobileSensor.stop;
    [a, t] = accellog(mobileSensor);
    plot(t, a);
    
    startTime = input('Use data cursor to select the start point in the plot, key in the x coordinate (time).');
    stopTime = input('Use data cursor to select the stop point in the plot, key in the x coordinate (time).');

    close all;
    indexValidData = find(t > startTime & t < stopTime);
    t = t(indexValidData) - t(indexValidData(1));
    a = a(indexValidData, :);
    
    % Checking tWindow is monotonically increasing
    dt = diff(t);
    deleteIndex = find(dt <= 0);
    while (sum(deleteIndex) > 0)
        t(deleteIndex + 1) = [];
        a(deleteIndex + 1,:) = [];
        dt = diff(t);
        deleteIndex = find(dt <= 0);
    end
    
    plot(t, a);
    xlim([t(1), t(end)]);

    fileName = [deblank(activityName(i, :)), '.mat'];
    save(fileName, 'a', 't');
    
    feature{i} = extractTraisature(fileName, windowLength, ...
                                            uniformSampleRate);
end

featureWalk = feature{1};
featureRun = feature{2};
featureIdle = feature{3};
featureUp = feature{4};
featureDown = feature{5};
save('userTrainingData.mat','featureWalk', 'featureRun', 'featureIdle', ...
     'featureUp', 'featureDown');

display('Congratulations! You finished recording training data.');