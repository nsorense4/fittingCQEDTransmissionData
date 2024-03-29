close all; clc;
fig = figure;
hold on


sampleIndex = 0:23; % index zero corresponds to the small samples on the side. 
sampleSize = [3.6 3.9 4.2 4.4 4.7 5 5.15 5.3 5.45 5.6 5.75 5.9 6.05 6.21 6.36];

numDevices = length(sampleIndex);
numSizes = length(sampleSize);
numUniqueDevices = numDevices*numSizes;

xlabel('diameter, d [um]')
ylabel('center wavelength, \lambda [nm]')

xlim([3, 7])
% ylim([1535, 1570])
maxQi = 1e5;

for i = 1:numUniqueDevices 
    numFiles = length(deviceData(i).resonances);
    for j = 1:numFiles
% load each resonance file fit
        resonance = deviceData(i).resonances{j};
        if isempty(resonance)
            continue 
        end
% read the Qi, center wavelength, and device size of each fit
        Qi = resonance.params(3,:);
        wlCenter = resonance.params(1,:);
        fitType = resonance.fitType;
        filter = Qi < 2e5 & Qi >1000;
        Qi = Qi(filter);
        wlCenternm = wlCenter(filter);
        fitType = fitType(filter);
        diameterum =  deviceData(i).diameter .* ones(length(wlCenternm), 1)';
        opacity = 1;
        sz = Qi/1000;
        % s.AlphaData = ones(length(sz),1)*100;
        % s.MarkerFaceAlpha = 'flat';
        % s.MarkerEdgeAlpha = 'flat';
        % error = resonance.resnorm;
        % filter = Qi < 2e10 & Qi > 1000;
        % error = error(filter).*wlCenternm(filter)./Qi(filter);
        % e = errorbar(diameterum(filter), wlCenternm(filter), error,"LineStyle","none");
        % e.LineWidth = 1;
        % e.Color = 'red';
        % e.AlphaData = opacity;
        % e.MarkerFaceAlpha = 'flat';
        % e.MarkerEdgeAlpha = 'flat';
        for k = 1:length(fitType)
            if strcmp(fitType{k}, "singlet")
                color= 'red';
            else
                color= 'blue';
            end
            s = scatter(diameterum(k), wlCenternm(k), sz(k), 'filled', 'MarkerEdgeColor', color, ...
                    'MarkerFaceColor', color);
        end
    end

end
