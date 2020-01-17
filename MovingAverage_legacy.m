function [tMA, ma] = MovingAverage_legacy(sig, t, tFilt, type)
%Calculate the moving average filtered signal from the input
%   input: sig [samples, channels]
%        : time vector "t" [s]
%        : filter window length "tFilt" [s]
%        : type: 'same' length or 'valid' without zero padding at the edges
%   output: time vector corresponding to filtered signal "tMA"
%         : filtered signal "ma"

%% Check input
% make sure that "sig" is a Nx1 vector if it contains only a single
% observation
if isvector(sig)
    sig = sig(:);
end
% maks sure that "sig" and "t" are equal length
if (size(sig, 1) ~= length(t) )
    error('Inputs "sig" and "t" should have the same number of samples in dimension 1');
end

%% Get parameters
[N, M] = size(sig); % input dimensions
dt = abs(t(2) - t(1) ); % time step [s]
% Demean the input signal
u = mean(sig);
sig = bsxfun(@minus, sig, u);
% Set filter parameters
span = round(tFilt / dt); % length of filter in points
win = hamming(span); % hamming filter kernel
win = win ./ sum(win); % normalized filter kernel
% Apply filter per observation
if strcmp(type, 'valid')
    len = N - span + 1;
    ma = zeros(len, M);
    for m = 1 : M
        ma(:, m) = conv(sig(:, m), win, 'valid');
    end
    tMA = t(round(0.5 * span) : round(0.5 * span) + len - 1); % time vector [s]
elseif strcmp(type, 'same')
    ma = zeros(N, M);
    for m = 1 : M
        ma(:, m) = conv(sig(:, m), win, 'same');
    end
    tMA = t;
else
    error('type should be "valid" or "same"')
end
% Add the mean to the ouput signal
ma = bsxfun(@plus, ma, u);

end