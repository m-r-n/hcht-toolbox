function [FP, r_in_Fo_Range, max_of_r] = framePitch (signal_frame, Fs);

% ========================================================================
% time domain signal-frame pitch, ie:
% autocorrelation-based basic Fo estimation

% OUT:
% FP ... frame pitch in Hz,
% r_in_Fo_range = cut of auto/cross-correlation vector 
%                 in the Fo_min ...vFo_max candidate range,
% max_of_r ... max sample amplittude of the whole corr vector

% IN;
% signal_frame .. a single frame, let say 1024 samples long
% Fs ... sampling frequenc fo the frame
% ========================================================================

L= length(signal_frame);

% autocorr of the frame 
[r,lags] = xcorr(signal_frame, signal_frame);

%searching max(r) in_Fo_Range: 

Fo_min = 75; % in Hz    % this range exactly leads to ...
Fo_max = 340; % in Hz   % 500 different samples at Fs =48kHz

lag_min = floor(Fs/Fo_max);
lag_max = floor(Fs/Fo_min);

r_in_Fo_Range = r(lag_min:lag_max);
max_of_r = max(r_in_Fo_Range);

Fo_lag_position = find (r_in_Fo_Range == max_of_r) + lag_min;
FP = Fs / Fo_lag_position;
