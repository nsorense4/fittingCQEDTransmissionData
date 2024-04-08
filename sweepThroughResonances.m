close all; clc; clear;
fig = figure;
hold on


sampleIndex = 0:23; % index zero corresponds to the small samples on the side. 
sampleSize = [3.6 3.9 4.2 4.4 4.7 5 5.15 5.3 5.45 5.6 5.75 5.9 6.05 6.21 6.36];

numDevices = length(sampleIndex);
numSizes = length(sampleSize);
numUniqueDevices = numDevices*numSizes;

analysisDir = 'C:\Users\nicho\Documents\gitProjects\lab-analysis-software\barclay-lab\fittingCQEDTransmissionData\fittedDatasets\';

%%
% plot diameter vs center wavelength of resonances

xlabel('diameter, d [um]')
ylabel('center wavelength, \lambda [nm]')

xlim([3, 7])
% ylim([1535, 1570])

% Get a list of all files in the directory
files = dir(fullfile(analysisDir, '*.mat'));

% Loop through each file
for i = 1:numel(files)
    % Get the file name
    filename = files(i).name;
    
    % Load the .mat file
    data = load(fullfile(analysisDir, filename));
    params = data.deviceSweepData.resonances.params;
    fitType = data.deviceSweepData.resonances.fitType;
    sizeParams = size(params);

    numResonances = sizeParams(2);

    Qi = params(3,:);
    wlCenter = params(1,:);
    filter = Qi < 2e5 & Qi >1000;
    Qi = Qi(filter);
    numResonances = length(Qi);
    wlCenternm = wlCenter(filter);
    fitType = fitType(filter);
    diameterum =  data.deviceSweepData.diameter .* ones(numResonances, 1)';
    opacity = 1;
    sz = Qi/1000;

    for  k = 1:numResonances
        try
            if strcmp(fitType{k}, "singlet")
                color= 'red';
            else
                color= 'blue';
            end
        catch
            color= 'green';
        end
        s = scatter(diameterum(k), wlCenternm(k), sz(k), 'filled', 'MarkerEdgeColor', color, ...
                'MarkerFaceColor', color);
    end
end

%%
% plot center wavelength vs Qi

xlabel('center wavelength, \lambda [nm]')
ylabel('intrinsic quality factor, Q_i')

% xlim([3, 7])
% ylim([1535, 1570])

% Get a list of all files in the directory
files = dir(fullfile(analysisDir, '*.mat'));

% Loop through each file
for i = 1:numel(files)
    % Get the file name
    filename = files(i).name;
    
    % Load the .mat file
    data = load(fullfile(analysisDir, filename));
    params = data.deviceSweepData.resonances.params;
    fitType = data.deviceSweepData.resonances.fitType;
    sizeParams = size(params);

    numResonances = sizeParams(2);

    Qi = params(3,:);
    wlCenter = params(1,:);
    filter = Qi < 2e5 & Qi >1000;
    Qi = Qi(filter);
    numResonances = length(Qi);
    wlCenternm = wlCenter(filter);
    fitType = fitType(filter);
    diameterum =  data.deviceSweepData.diameter .* ones(numResonances, 1)';
    opacity = 1;
    sz = Qi/1000;

    for  k = 1:numResonances
        try
            if strcmp(fitType{k}, "singlet")
                color= 'red';
            else
                color= 'blue';
            end
        catch
            color= 'green';
        end
        s = scatter(wlCenternm(k), Qi(k), 'filled', 'MarkerEdgeColor', color, ...
                'MarkerFaceColor', color);
    end
end

%%
% export a table of all resonces

% Get a list of all files in the directory
files = dir(fullfile(analysisDir, '*.mat'));

% create table to write into
dataTable = table();
dataRow = 1;

% Loop through each file
for i = 1:numel(files)

    % Get the file name
    filename = files(i).name;
    
    % Load the .mat file
    data = load(fullfile(analysisDir, filename));
    data = data.deviceSweepData;
    params = data.resonances.params;
    resnorm = data.resonances.resnorm;
    sizeParams = size(params);
    numResonances = sizeParams(2);
    
    for j = 1:numResonances
            dataTable.diameterum(dataRow) = data.diameter;
            dataTable.index(dataRow) = data.index;
            dataTable.type(dataRow) = {data.type};
            dataTable.laser(dataRow) = {data.laser};
            dataTable.sweepType(dataRow) = {data.sweepType};
            dataTable.intrinsicQualityFactor(dataRow) = params(3,j);
            dataTable.couplingQualityFactor(dataRow) = params(2,j);
            dataTable.centerWavelengthnm(dataRow) = params(1,j);
        
        try
            dataTable.resnormFit(dataRow) = resnorm(j);
        catch
            dataTable.resnormFit(dataRow) = -1;
        end

        dataRow = dataRow + 1;
    end
end

writetable(dataTable,[analysisDir, '20240401_B14ResonanceData.csv'])  
%%
idx = dataTable.intrinsicQualityFactor > 5e4;
dataTable