function [chirprate_over_time, chirprate_over_time_LP] = frameChirprate (pitch_over_time, energy_over_time);

% ========================================================================
% chirprate estimation from precalculated, 
% time domain signal-frame pitch, ie:
% autocorrelation-based basic Fo estimation, 
% with some post-filtration
% IN:
% pit_sailances .. energy-like feature from max of xCorrs
% pitch_in_time .. real pitch in Hz.

% OUT:
% chirprate_over_time ... basic estimation
% COT ... processed estimation.
% ========================================================================

no_frames = length(pitch_over_time);

chirprate_over_time = zeros(1, no_frames);

chirprate_over_time(1:end-1) = pitch_over_time (2:end)- pitch_over_time (1:end-1) ;
% or an inverse derivation:
%chirprate_over_time(1:end-1) = pitch_over_time (1:end-1) - pitch_over_time (2:end) ;

% post-processing, by removing changes bigger than 50Hz:
chirprate_over_time(chirprate_over_time > 20) = 0;
chirprate_over_time(chirprate_over_time < -20) = 0;

chirprate_over_time_LP = lowpass(chirprate_over_time, 0.1);

figure (12); clf;
plot(chirprate_over_time,'r'); hold on
plot(chirprate_over_time_LP, 'b')




