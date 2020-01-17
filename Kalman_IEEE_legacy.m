function [kal, omega, der, covMat] = Kalman_IEEE_legacy(sig, t, nNoiseSamp)
% [kal, omega, der] = KalmanFilter_freq(sig, t, param)
% model: x = A * sin(W * t)
%% Set parameters
Ts = t(2) - t(1); % time step [s]
A = 0.1; % amplitude
W = 2 * pi * 0.23; % signal frequency [rad/s]
PHIs = (pi / 2) ^ 4; % uncertainty in frequency measurement (2 breath/min = pi/15 rad/s)
order = 3; % number of parameters
I = eye(order); % identity matrix
H = [1, 0, 0]; % linearized measurement matrix
R = 5e-2 * sqrt(760 / nNoiseSamp); % noise in measurement (reliabiltiy of a single observation)

%% Initial filter state estimates
x(1, 1) = 0; % initial observation Xh
x(2, 1) = 0; % initial derivative XDh
x(3, 1) = W; % initial frequency [rad/s]

%% Initial error covariance matrix
P = zeros(order); % covariance matrix
P(1, 1) = (A / 4) ^ 2; % observation (4*std = A)
P(2, 2) = (A * W / 4) ^ 2; % derivative (4*std = A*W)
P(3, 3) = (pi / 20) ^2; % frequency (4*std = 0.1 Hz = pi/5 rad/s)

%% Initial fundamental matrix
PHI = [1, Ts, 0;
    -x(3) * x(3) * Ts, 1, -2 * x(3) * x(1) * Ts;
    0, 0, 1];

%% Initial process noise matrix
Q = [0, 0, 0;
    0, 4 / 3 * x(3) * x(3) * x(1) * x(1) * Ts * Ts * Ts * PHIs, -x(3) * x(1) * Ts * Ts * PHIs;
    0, -x(3) * x(1) * Ts * Ts * PHIs, Ts * PHIs];

%% Initial a priori error covariance matrix
Pb = PHI * P * PHI' + Q;

%% Apply filter
kal = zeros(size(sig) );
omega = kal + 0.23;
der = kal;
covMat = zeros(length(sig), 3, 3);
covMat(1, :, :) = Pb;

for n = 1 : (length(t) - 1)
    
    %% Correction
    K = Pb * H' / (H * Pb * H' + R); % Kalman gain
    x = x + K * (sig(n) - x(1) ); % estimated measurement
    % a posteriori error covariance
    P = (I - K * H) * Pb; % estimated error covariance
    
    %% Prediction
    % update PHI
    PHI(2, 1) = -x(3) * x(3) * Ts;
    PHI(2, 3) = -2 * x(3) * x(1) * Ts;
    % update Q
    Q(2, 2) = 4 / 3 * x(3) * x(3) * x(1) * x(1) * Ts * Ts * Ts * PHIs;
    Q(2, 3) = -x(3) * x(1) * Ts * Ts * PHIs;
    Q(3, 2) = Q(2, 3);
    % a priori error covariance
    Pb = PHI * P * PHI' + Q; % predicted error covariance
    % Project states one sampling interval ahead using Euler integration
    xDD = -x(3) * x(3) * x(1); % predicted second derivative
    x(2) = x(2) + Ts * xDD; % predicted first derivative
    x(1) = x(1) + Ts * x(2); % predicted measurement
    
    %% Export parameters
    kal(n + 1) = x(1); % filtered signal
    der(n + 1) = x(2); % estimated derivative of filtered signal
    omega(n + 1) = x(3) / (2 * pi); % estimated frequency [Hz]
    covMat(n + 1, :, :) = Pb;
end

end