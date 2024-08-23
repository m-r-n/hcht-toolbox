function [ss_warp, warping_curve] = warp_the_frame(ss, chirprate_to_apply, print_or_not, negate_the_warping)

% ========================================================================
% time-domain frame warping based on the estimated chirprate evolution over time, 
% negative chirprate means, we are delaying the beginning of the frame,
% i.e. slowing down the frame at the beginning, and speeding up at the end of the frame.
% check the orinting feature to see the effect.

% IN:
% ss .. original signal frame in time domain, predefined fro 1024 samples!
% chirprate_to_apply .. <+/-100% > in percentage, not more, otherwise
% ... the time domain sample indices will saturate!!


% OUT:
% ss_warp .. warped frame, eventually warping curve
% warping_curve .. self explanatory.
% negate_the_warping .. apply a negtated (-) alpha instead of the given one.
% ========================================================================

lin_curve = linspace(1, 1024, 1024);

% deriving the stretching curve based on the shirprate
% we are using a semicircle based differential curve
const = pi /1024;

angle_curve = const*lin_curve;                  % 0 .. pi/1024
diff_curve = sin(angle_curve);                  % sin of prev.
diff_curve = diff_curve * 3 * chirprate_to_apply;% stretched prev.

% semicircel added to a linspace and converted to indices
if negate_the_warping
    warping_curve = round(lin_curve + diff_curve);   
else
    warping_curve = round(lin_curve - diff_curve);
end


% taking care of the limits, ie 1st and 1024th sampl indices.
warping_curve(warping_curve < 1) = 1;
warping_curve(warping_curve > 1024) = 1024;     % we cannot leave the original frame


% warping the ss input
ss_warp =ss(warping_curve);

% plotting if necessary

if print_or_not
    figure(4); clf;
    subplot(211)
    plot(lin_curve, 'b'); hold on;
    plot(warping_curve, 'r');
    grid on;
    title ('warping curve <-100%, +100%> max!')
    xlabel('original frame index')
    ylabel('new frame index')

    subplot(212)
    plot(ss, 'b'); hold on;
    plot(ss_warp, 'r')
    grid on
    title(['warped frame, chirprate = ', num2str(chirprate_to_apply)])
    xlabel('samples')
    ylabel('sample amplittude')
end

