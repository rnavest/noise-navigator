clear all
close all
clc

%% Load MRI data
% with profiles in chronological acquisition order
load('data.mat'); % dimensions [ks, profile, channel]

%% Load required parameter values
% required values are repetition time (TR), echo time (TE) and acquisition
% voxel size
load('label.mat');

%% Calculate thermal noise (co)variance
MR_FOV = 720; % [mm]; this is a body scan
[t, noiseVar, noiseCovar, nNoiseSamp] = noiseCoVar_git(data, label, MR_FOV);