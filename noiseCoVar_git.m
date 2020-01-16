function [t, noiseVar, noiseCovar, nNoiseSamp] = noiseCoVar_git(data, label, MR_FOV)
%Calculate the noise navigator from MR data
%   input: MRI data "data" [kx, prof, chan], where the profiles are in
%           chronological order
%          label containing the values of the TR, TE and acquisition voxel
%           size
%        : MR_FOV indicating the extent of the MR signal in readout [mm]
%           recommended values for body = 720 mm / head-and-neck = 400 mm
%   output: time vector "t"
%         : individual coil variances "noiseVar"
%         : full array covariances "noiseCovar"

%% Sort MRI data
[nKx, nProf, nChan] = size(data); % size of MRI data [kx, prof, chan]
    
%% Calculate noise only part
% the data is zero centered and it is assumed there is no MR signal
% 0.5 * MR_FOV away from isocenter
noise_samp = floor(0.5 * (nKx - (MR_FOV / label.AcqVoxelSize(1) ) ) );
if noise_samp > 0
    indNoise = [1:noise_samp, (nKx - noise_samp + 1):nKx];
else
    error('Not enough samples available to calculate the thermal noise variance\nset MR_FOV smaller than current value: %d', MR_FOV);
end
nNoiseSamp = length(indNoise);
clear noise_samp

%% Apply 1D Fourier transform and select noise only region
% Convert to hybrid space
ft = fftshift(ifft(ifftshift(data, 1), [], 1), 1); % [x, prof, chan]
clear chron_data

% Select noise only part
ft = ft(indNoise, :, :); % [x, prof, chan]
clear indNoise

%% Calculate noise (co)variance
% thermal noise variance
noiseVar = squeeze(var(ft, 1, 1) ); % [prof, chan]
% if there is only a single receive channel noiseVar is [1, prof]
if (nChan == 1)
    % make sure noiseVar is [prof, 1] for consistent output
    noiseVar = noiseVar(:);
end
% thermal noise covariance
noiseCovar = zeros(nProf, nChan, nChan); % [prof, chan, chan]
for p = 1:nProf
    % the correlated noise is in the real part, whereas the uncorrelated
    % noise is in the imaginary part; only the real part is of interest
    noiseCovar(p, :, :) = real(cov(squeeze(ft(:, p, :) ), 1) );
end
clear ft

%% Create time vector
t = label.TE + (0:(nProf - 1) ) .* label.TR; % [s]

end