% This is the main MATLAB script that needs to be run to execute the demo.
% This script will load already saved training data to train the machine
% learning algorithm. It then loads the new acceleration data, extracts
% features and then detects the activities performed while the acceleration
% data was being recorded. At the end, it plots the raw acceleration data
% along with the detected activites in a MATLAB figure. 
%
% You can run this script, by executing the command 
% >> activityDetection
% at the MATLAB Command line. To accurately detect new accelerometer data
% that you might have collected, you will need to train the machine
% learning algorithm with training data generated for you.
%
% Copyright 2014 The MathWorks, Inc.

%%
%Step 0: Initialize parameters

% Detection window length
windowLength = 5;
% Number of windows between consecutive detections
detectionInterval = 1;
% Data from phone may not be uniformly sampled, therefore it will be
% resampled at this rate.
uniformSampleRate = 60; % Hz. 


%%
%Step 1: Extract features from observation data (If features are extracted 
% and saved in a file, just load the file.)
% fileWalk = 'walk1.mat'; % Change the file name to point to your file
% featureWalk = extractTrainingFeature(fileWalk,windowLength,uniformSampleRate);
% 
% fileRun = 'run1.mat'; % Change the file name to point to your file
% featureRun = extractTrainingFeature(fileRun,windowLength,uniformSampleRate);
% 
% fileIdle = 'idle1.mat'; % Change the file name to point to your file
% featureIdle = extractTrainingFeature(fileIdle,windowLength,uniformSampleRate);
% 
% fileUp = 'upstairs1.mat'; % Change the file name to point to your file
% featureUp = extractTrainingFeature(fileUp,windowLength,uniformSampleRate);
% 
% fileDown = 'downstairs1.mat'; % Change the file name to point to your file
% featureDown = extractTrainingFeature(fileDown,windowLength,uniformSampleRate);

% Load the extracted features from the training data above. Commnent the
% line below if you are extracting 
load('trainingData.mat');


%%
%Step 2: Normalize training data

data = [featureWalk; featureRun; featureIdle; featureUp; featureDown];

for i = 1:size(data,2)
    range(1,i) = max(data(:,i))-min(data(:,i)); %#ok<*SAGROW>
    dMin(1,i) = min(data(:,i));
    data(:,i) = (data(:,i)- dMin(i)) / range(i);
end

%%
%Step 2: Activity indexing
indexIdle =  0;
indexWalk =  2;
indexDown = -1;
indexRun  =  3;
indexUp   =  1;

Idle = indexIdle * zeros(length(featureIdle),1);
Walk = indexWalk * ones(length(featureWalk),1);
Down = indexDown * ones(length(featureDown),1);
Run  = indexRun  * ones(length(featureRun),1);
Up   = indexUp   * ones(length(featureUp),1);


%%
%Step 3: Training the machine learning algorithm

X = data;
Y = [Walk;Run;Idle;Up;Down];
mdl = fitcknn(X,Y);
knnK = 30; %num of nearest neighbors using in KNN classifier
mdl.NumNeighbors = knnK;%specify num of nearest neighbors


%%
%Step 4: load recorded data and uniformly resample it
load('newData.mat');

% Resampling the raw data to obtain uniformly sampled acceleration data
newTime = 0:1/60:(t(end)-t(1));
x = a(:,1);
y = a(:,2);
z = a(:,3);
x = interp1(t,x,newTime);
y = interp1(t,y,newTime);
z = interp1(t,z,newTime);
a = [x;y;z]';
t = newTime;


%%
%Step 5: Activity Detection
i = 1;
lastFrame = find(t>(t(end)-windowLength-0.005), 1);
% Set default starting activity to idling
lastDetectedActivity = 0;

frameIndex = [];
result = [];
score = [];

% Parse through the data in 5 second windows and detect activity for each 5
% second window
while (i < lastFrame)
    startIndex = i;
    frameIndex(end+1,:) = startIndex;
    t0 = t(startIndex);
    nextFrameIndex = find(t > t0 + detectionInterval);
    nextFrameIndex = nextFrameIndex(1) - 1;
    stopIndex = find(t > t0 + windowLength);
    stopIndex = stopIndex(1) - 1;
    currentFeature = extractFeatures(a(startIndex:stopIndex, :, :),...
                     t(startIndex:stopIndex), uniformSampleRate);
    currentFeature = (currentFeature - dMin) ./ range;
    [tempResult,tempScore] = predict(mdl, currentFeature);
    % Scores reported by KNN classifier is ranging from 0 to 1. Higher score
    % means greater confidence of detection.
    if max(tempScore) < 0.95 || tempResult ~= lastDetectedActivity 
        % Set result to transition
        result(end+1, :) = -10; 
    else
        result(end+1, :) = tempResult;
    end
    lastDetectedActivity = tempResult;
    score(end+1, :) = tempScore;
    i = nextFrameIndex + 1;
end


%%
%Step 6: Generate a plot of raw data and the results
figure;
plot(t,a);
% Raw acceleration data is bounded by +-20, leaving space in bottom of the 
% graph for activity detection markers.
ylim([-30 20]);
hold all;

resWalk =(result == 2);
resRun  =(result == 3);
resIdle =(result == 0);
resDown =(result ==-1);
resUp   =(result == 1);
resUnknown =(result == -10);

% Plot activity detection markers below the raw acceleration data
hWalk = plot(t(frameIndex(resWalk))+windowLength, 0*result(resWalk)-25, 'kx');
hRun  = plot(t(frameIndex(resRun))+windowLength, 0*result(resRun)-25, 'r*');
hIdle = plot(t(frameIndex(resIdle))+windowLength, 0*result(resIdle)-25, 'bo');
hDown = plot(t(frameIndex(resDown))+windowLength, 0*result(resDown)-25, 'cv');
hUp   = plot(t(frameIndex(resUp))+windowLength, 0*result(resUp)-25, 'm^');
hTransition = plot(t(frameIndex(resUnknown))+windowLength, 0*result(resUnknown)-25, 'k.');

% Increase y-axis limit to include the detected marker
ylim([-30 20]);

title('Raw acceleration data and detection result');
% Add legend to the graph
legend([hWalk, hRun, hIdle, hDown, hUp, hTransition], ...
    'Walking','Running','Idling','Walking Downstairs','Walking Upstairs',...
    'Transition'); 
