clear all
close all
clc

%% Load MRI data
% with profiles in chronological acquisition order
for c = 1:8
    load(sprintf('data_ch%d.mat', c) ); % dimensions [ks, profile, 1]
    data(:, :, c) = data_ch; % dimensions [ks, profile, channel]
    clear data_ch
end

%% Load required parameter values
% required values are repetition time (TR), echo time (TE) and acquisition
% voxel size
load('label.mat');

%% Calculate thermal noise (co)variance
MR_FOV = 720; % [mm]; this is a body scan
[t, noiseVar, noiseCovar, nNoiseSamp] = noiseCoVar_git(data, label, MR_FOV);

%% Normalize noise variance
% divide by median per channel
noiseVar = bsxfun(@rdivide, noiseVar, median(noiseVar) );
% remove mean per channel
noiseVar = bsxfun(@minus, noiseVar, mean(noiseVar) );

%% Calculate principal components
[~, ~, V] = svd(noiseVar, 0);
pc_full = noiseVar * V;
clear V

%% Select the principal component within the breathing frequency range
% Calculate frequency spectrum
[ft, f] = fourierCoeff(pc_full, 1 / (t(2) - t(1) ) );
% relative respiratory power (between 0.05 and 0.8 Hz) within full frequency
pow_rel = sum(ft(f > 0.05 & f < 0.8, :) .^ 2) ./ sum(ft .^2 );
clear ft f
% select principal component
pc = pc_full(:, pow_rel == max(pow_rel) );
clear pc_full pow_rel

%% Apply Kalman filter
[kal, omega, der, covMat] = Kalman_IEEE_legacy(pc, t, nNoiseSamp);

%% Apply moving average filter
tFilt = 1.2; % filter window length [s]
type = 'same'; %'same' length or 'valid' without zero padding at the edges
[tMA, ma] = MovingAverage_legacy(pc, t, tFilt, type);

%% Show results
figure('Color', 'w');
plot(t, pc .* 100, 'b', t, kal .* 100, 'g', tMA, ma .* 100, 'r',...
    'LineWidth', 2);
set(gca, 'Xlim', [0, t(end)], 'FontSize', 15);
xlabel('Time [s]');
ylabel('Modulation [%]');
legend('raw', 'Kalman', 'moving average', 'NumColumns', 3);
title('Noise navigator')
