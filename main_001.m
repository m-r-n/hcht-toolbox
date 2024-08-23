% ==================================================================
% Re-Implementation of HChT 2024.
% https://github.com/m-r-n/hcht-toolbox/
% contact: mrn at post cz
% ==================================================================
% ToDo:
% - pitch-synchronous frame lenghts
% - 3rd order warping, not a simple circle
% - inverse trf.to implement.
% ==================================================================

% some constants:
frame_to_show = 45 ; % show me the warping of this frame
energy_thresh = 0.01;  % frame energy threshod applied to trigger the pitch tracking.
warping_emphasis = 4; % weighing of the intensity of the warping applied on voiced frames.
negate_the_warping = 0 % swapping positive vs negative alpha. just a test. 

%read the wave
%[x, Fs] = audioread ('xx.wav');

[x, Fs] = audioread ('au.wav');

% if Fs 48kHz, then downsample, as seglen is fixed to 1024.

if Fs > 40000, 
    x = decimate(x(:, 1), 4);
    Fs = Fs/4;
    disp ('signal decimated 4x')
    
end;

if Fs > 20000, 
    x = decimate(x(:, 1), 2);
    Fs = Fs/4;
    disp ('signal decimated 2x')
    beep;
end;

% segmentation
seg_length = 1024;
stepsize = 256;
no_samples = length(x);
no_frames = floor (no_samples / stepsize) - 3; % - 3 needed becausse the stepsize is << seglen.

frame_matrix = zeros(seg_length, no_frames);
specgram_matrix_stft = zeros(512, no_frames);
specgram_matrix_hcht = zeros(512, no_frames);
size(frame_matrix);

for i = 1:no_frames
    x_from = (i-1) * stepsize + 1;
    x_till = x_from + seg_length - 1;
    frame = x(x_from : x_till)';
    frame_matrix(:, i) = frame;
end

% energy of frames

energy_in_time = zeros(1, no_frames);

for i=1:no_frames
    frame = frame_matrix(:, i);
    SE = signalEnergy (frame);
    energy_in_time(1, i) = SE;
end


% rough pitch of frames
%
% AA = frame_matrix(:,125);
% BB = frame_matrix(:,126);

pitch_in_time = zeros(1, no_frames);
pit_sailances = zeros(1, no_frames);
corr_in_time = zeros(126, no_frames);

for i=1:no_frames

    % reading a frame
    signal_frame = frame_matrix(:, i);
    % calculating
    [FP, r_in_Fo_Range, max_of_r] = framePitch (signal_frame, Fs);
    
    % storing
    pitch_in_time(1, i) = FP;
    pit_sailances(1, i) = max_of_r;
    corr_in_time (:, i) = r_in_Fo_Range;

end

% post-processing: resetting Fo "low-energy" candidates
pitch_in_time(pit_sailances < energy_thresh) = 0;


% pitch-rate of frames
[chirprate_over_time, COT] = frameChirprate (pitch_in_time, pit_sailances);
COT = warping_emphasis * COT;


% FFT of frames
ww = hamming (seg_length);

for i=1:no_frames

    % reading a frame
    signal_frame = frame_matrix(:, i);

    % weighting
    ss = ww.*signal_frame;

    % printing a selected frame when warping:
    if i== frame_to_show,
        print_the_warping = 1;
    else
        print_the_warping = 0;
    end

    % warping
    % de_activation of the warping curve:
    % additional lowering of the warping effect, as max warping is
    % +/-100[%]

    % the most important part, the warping:
    ss_warp = warp_the_frame(ss, COT(i), print_the_warping, negate_the_warping);

    % FFT, modulo, etc
    spec_frame = fft(ss);
    log_spec = 20*log(0.0001 + abs(spec_frame (513:end)));
    specgram_matrix_stft(:, i) = log_spec;
       
    % calculating HChT, modulo, etc
    spec_frame = fft(ss_warp);
    log_spec = 20*log(0.0001 + abs(spec_frame (513:end)));
    specgram_matrix_hcht(:, i) = log_spec;
    
end

% ========= eof looops =========

% [1] plotting FRAMES and xCORRS

figure (1); clf;
subplot(211)
%plot(x)
imagesc(frame_matrix)
title('frames')

subplot(212)
%plot(x)
imagesc(corr_in_time)
title('autocorr frames provided by the Fo estimation part');

% [2] plotting time evolutions of parameters

figure(2); clf;
subplot(311)
%plot(x)
plot(energy_in_time, 'r'); hold on;
plot(2* pit_sailances, 'b')
xlabel ('frame index')
ylabel ('relative energy')
title('Estimated energies in time: R:frame energy, B:max(Fo-range energy)')

subplot(312)
%plot(x)
plot(pitch_in_time)
xlabel ('frame index')
ylabel ('xcorr-based pitch over time')
title('Estimated pitch evolution')

subplot(313)
plot(COT,'r'); hold on;
plot(chirprate_over_time,'b')
xlabel ('frame index')
ylabel ('xcorr-based Alpha')
title('Estimated (B) and applied (R)chirp-rate evolution')


% [3] plotting the FFT and HChT grams

figure (3); clf;
subplot(211)
imagesc(specgram_matrix_stft(256:512, :))
title('specgram - FFT')

subplot(212)
imagesc(specgram_matrix_hcht(256:512, :))
title('specgram - HChT')


