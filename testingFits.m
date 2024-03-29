clear; clc; close all;

% settings
useBackground = true;

addpath('C:\Users\nicho\Documents\gitProjects\lab-analysis-software\barclay-lab\data\transmissionData\DNV_B14_QG3\postCleaning')


backgroundData = load('backgroundSweep_100mA_1040nm_P1.mat').scanData;
% transData = load('6.36um-1_telecom_10mW_sweep_full_P1.mat');
transData = load('4.40um-0_1040nm_100mA_sweep_semi_full.mat').scanData;
% plot(transData.W, transData.T/backgroundData.T)

% remove nans
if useBackground == true
    [backgroundData.W, backgroundData.T] = removeNan(backgroundData.W, backgroundData.T);
end

[transData.W, transData.T] = removeNan(transData.W, transData.T);

interpBackgroundData.T = interp1(backgroundData.W, backgroundData.T, transData.W);

normData = {};
normData.W = transData.W;
if useBackground == true
    normData.T = transData.T./interpBackgroundData.T;
else
    normData.T = transData.T./max(transData.T);
end
[normData.W, normData.T] = removeNan(normData.W, normData.T);
normData.T = medfilt1(normData.T,10);

fs=20e3;
% normData.T = lowpass(normData.T, 500,fs);
% plot(normData.W, normData.T)
% ylim([0.7, 1])

% [pks,locs,widths,proms] = findpeaks(1-normData.T, normData.W,'MinPeakProminence',0.03);

[paramNames, params, resnorm] = fittingBroadSweeps(normData.W, normData.T, struct('direction', 0));

% fittingBroadSweeps(normData.W, normData.T, {})