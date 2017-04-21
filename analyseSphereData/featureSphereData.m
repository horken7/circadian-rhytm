%% Load Sphere data
clear all; clc
addpath /Users/horken7/Documents/UoB/MDM3/circadian-rhytm/activityDetectionMATLABAndroid

t_load = load('t.mat');
t = t_load.struct';
a_load = load('a.mat');
a = a_load.struct';

save('data.mat', 'a', 't')

windowLength = 5;
uniformSampleRate = 60;

extractTrainingFeature('data.mat',windowLength,uniformSampleRate)

