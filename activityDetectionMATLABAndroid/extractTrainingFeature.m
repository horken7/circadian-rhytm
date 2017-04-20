function featureTraining = extractTrainingFeature(fileName,...
                                                  windowLength,...
                                                  uniformSampleRate)
% The function extracts training data from file specified by 'filename'.
% The raw data in the file should two variables, a and t.
%
% t is a column vector representing relative time of when the accelerometer 
% reading is taken.
%
% a is a n-by-3 matrix, n is the length of t, each row of it stores
% acceleration in x y and z direction.
%
% The raw data is sampled around 200 Hz, but it is not uniformly sampled.
% This function uses a sliding window technique to scan the raw data and
% extract features from windows of windowLength. The first window starts at
% t(1), it moves to the right by 1 data sample per step until the window
% doesn't have enough data samples to fill the windowLength. Along its
% moving, the function calls extracFeatures to extract the features in each
% windown and stores in the output variable featureTraining.
%
% Copyright 2014 The MathWorks, Inc.

    rawData = load(fileName); % load recorded data
    
    %resampling
    tStart = rawData.t(1);
    tStop = rawData.t(end);
    newTime = tStart:1/uniformSampleRate:tStop;
    newData = interp1(rawData.t, rawData.a, newTime);

    %find out the starting index of last possilbe window in training data
    frameIndex = find(newTime > (newTime(end) - windowLength...
                      - 2 / uniformSampleRate));
    lastFrame = frameIndex(1);
    
    featureTraining = [];
    %using a sliding window to extract features of recorded data
    for i = 1:lastFrame
        startIndex = i; % window start index
        t0 = newTime(startIndex);
        stopIndex = find(newTime > t0 + windowLength);
        stopIndex = stopIndex(1) - 1; % window stop index
        featureTraining(end+1,:) = extractFeatures(...
                                   newData(startIndex:stopIndex,:,:),...
                                   newTime(startIndex:stopIndex),...
                                   uniformSampleRate);
    end

end