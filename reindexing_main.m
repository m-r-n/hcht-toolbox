% here run "rec_waves_01" to record S1 and S2
disp ('--------------------------')
% loading example waves, also present on https://github.com/m-r-n > wavesurfing.
load "waves_s1_s2"

%cut part of s1:

ss1= s1(1000:1710);
ss2 =s2(30:740);

figure 100; clf
subplot(211); plot(ss1)
title("whistle")
subplot(212); plot(ss2)
title("vowel")

% --- spectrum of a frame --- 
spZ1=log (abs(fft(ss1))(1:355));
%spZ2=log (abs(fft(ss2))(1:355));

figure 101
clf
subplot(211)
plot(spZ1)
hold on
%plot(spZ2,'r')
grid
title ( 'Spectrum (b) and reind (r) of input frames')

% --- reindexing LUT preparaion ---

noHarmonics = 5;  % number of harmonix used
minF0 = 10
maxF0 = 399

Fs = 11050
Nfft = 1024
freqPerBin = Fs/Nfft

pitchAxis= minF0:maxF0;
pitchAxis = pitchAxis/freqPerBin;
pitAxis1 = pitchAxis;
pitAxis2 = 2*pitAxis1;
pitAxis3 = 3*pitAxis1;
pitAxis4 = 4*pitAxis1;
pitAxis5 = 5*pitAxis1;

figure 102; clf; 
hold on
plot(pitAxis1, 'r')
plot(pitAxis2, 'b')
plot(pitAxis3, 'c')
plot(pitAxis4, 'k')
plot(pitAxis5, 'r')

reindSpec1 = spZ1(ceil(pitAxis1));
reindSpec2 = spZ1(ceil(pitAxis2));
reindSpec3 = spZ1(ceil(pitAxis3));
reindSpec4 = spZ1(ceil(pitAxis4));
reindSpec5 = spZ1(ceil(pitAxis5));

figure 101
subplot(212)
hold on
plot(reindSpec1,'r')
plot(reindSpec2,'b')
plot(reindSpec3,'c')
plot(reindSpec4,'k')
plot(reindSpec5,'r')

sumReind = reindSpec1 + reindSpec2 + reindSpec3 + reindSpec4 + reindSpec5;
figure 101
subplot(211)
plot(sumReind, 'r')


