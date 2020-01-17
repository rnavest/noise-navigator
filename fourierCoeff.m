function [ft, f] = fourierCoeff(sig, Fs)
% sig(data,observations)

%% Set parameters
N = size(sig, 1); % number of data points
df = Fs / N; % frequency step

%% Subtract the mean
sig = bsxfun(@minus, sig, mean(sig) );

%% Fourier transform
ft = fft(sig, [], 1); % fft along first dimension
% Note: fft is ordered 0 : N/2-1, -N/2 : -1
% use fftshift to change order to -N/2 : N/2-1
% take the first half of the spectrum (i.e. 0 : N/2-1)
ft = abs(ft(1 : round(N / 2), :) ./ (N / 2) );
% Set the frequency range
f = (0 : round(N / 2) - 1) .* df; % frequency vector [Hz]

end