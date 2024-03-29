close all;
fs = 10000;             % sampling rate in nm/s
f0 = 1000;                % notch frequency
fn = fs/2;              % Nyquist frequency
freqRatio = f0/fn;      % ratio of notch freq. to Nyquist freq.
notchWidth = 1;       % width of the notch

% Compute zeros
notchZeros = [exp( sqrt(-1)*pi*freqRatio ), exp( -sqrt(-1)*pi*freqRatio )];

% Compute poles
notchPoles = (1-notchWidth) * notchZeros;

% figure;
% zplane(notchZeros.', notchPoles.');

b = poly( notchZeros ); %  Get moving average filter coefficients
a = poly( notchPoles ); %  Get autoregressive filter coefficients

figure;
freqz(b,a,32000,fs)



% filter signal 

T = normData.T;
W = normData.W;
fig = figure;
hold on
plot(W,T)
ylim([-1,1])
% plot(W,cos(f0*W))
TFiltered = filter(b,a,T);
% highpass(T,f0,fs)
plot(W,TFiltered)