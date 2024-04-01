function [paramNames, params, resnorms, fitType] = fittingBroadSweeps(xDataIn, ...
                                                yDataIn, ...
                                                options)
%%FitMultiplePeaks Attempts to fit multiple peaks
%
%   Fit Function:
%       FitMultiplePeaks
%
%   ** In development/temp
%
%  Input:
%       xDataIn 
%       yDataIn 
%       options
%           plotFit, default false
%               plot the fit automatically
%           direction, default 1
%               ie is it a peak or a trough (>0 peak, <=0 trough)
%           startPoint = [a0, c, w, x0], default - uses guesses
%           dataWindow = [windowLow, windowHigh]
%               window to apply to data    
%           nPeaks = x
%           
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 30-Jun-2015 18:23:19
%       Added some extra functionality.     

% User settings
    iterations = 20;
    backgroundIterations = 10;
    dataWidthFactor = 1.5;
    livePlot = 0;
    numDoublets = 0;

    paramNames = {};
    params = [];
    resnorms = [];
    fitType = {};

    optionsDefault=struct('plotFit', true,...
                            'direction', 0,...
                            'startPoint',[],...
                            'dataWindow',[], ...
                            'dispBool', true,...
                            'contrastLimit', 0.03,...
                            'maxPeakWidth', 4,...
                            'minPeakWidth', 0.005,...
                            'doubletCheckLimit', 10000,...
                            'checkDoubletBool', false,...
                            'contrastWidthRatioLimit', -1,...
                            'filename','');
    
    if isempty(options)
        options = optionsDefault;
    end    
    if ~ isfield(options, 'direction')
        options.direction = optionsDefault.direction;
    end
    if ~ isfield(options, 'dataWindow')
        options.dataWindow = optionsDefault.dataWindow;
    end  
    if ~ isfield(options, 'plotFit')
        options.plotFit = optionsDefault.plotFit;
    end
    if ~ isfield(options, 'dispBool')
        options.dispBool = optionsDefault.dispBool;
    end
    if ~ isfield(options, 'contrastLimit')
        options.contrastLimit = optionsDefault.contrastLimit;
    end
    if ~ isfield(options, 'maxPeakWidth')
        options.maxPeakWidth = optionsDefault.maxPeakWidth;
    end
    if ~ isfield(options, 'minPeakWidth')
        options.minPeakWidth = optionsDefault.minPeakWidth;
    end
    if ~ isfield(options, 'doubletCheckLimit')
        options.doubletCheckLimit = optionsDefault.doubletCheckLimit;
    end
    if ~ isfield(options, 'checkDoubletBool')
        options.checkDoubletBool = optionsDefault.checkDoubletBool;
    end
    if ~ isfield(options, 'contrastWidthRatioLimit')
        options.contrastWidthRatioLimit = optionsDefault.contrastWidthRatioLimit;
    end
    if ~ isfield(options, 'filename')
        options.filename = optionsDefault.filename;
    end
    
    
    if options.direction > 0
        options.direction = 1;
    else
        options.direction = -1;
    end    
    
% Clean Up Data
    [xDataFiltered, yDataFiltered] = prepareCurveData( xDataIn, yDataIn );

%Force monotonicity (needed for interpolation)
    [xData,I]=sort(xDataFiltered);
    yData=yDataFiltered(I);

%Make sure the matrices are horizontal
    [numColumns,~]=size(yData);
    if(numColumns==1)
        yData=yData';
    end
    
    [numColumns,~]=size(xData);
    if(numColumns==1)
        xData=xData';
    end

%Plot the data to analyse or quit
    if options.plotFit == true
        fig=figure; hold on;
        title(options.filename, 'Interpreter', 'none');
        plot(xData,yData)
        % response = questdlg('Fit dataset?', ...
        %                     '', ...
        %                     'Yes','No','Yes');
        % if strcmpi(response,'No')
        %     disp('Choose a different dataset.')
        %     return
        % end
    end
% get guesses for start points and plot with analyzed peak locations
    [pks,locs,widths,proms] = findpeaks(1-yData, xData,'MinPeakProminence',options.contrastLimit*max(yData), 'MaxPeakWidth', options.maxPeakWidth, 'MinPeakWidth', options.minPeakWidth);
    % limit assessed width of peaks (helps limit fitting peaks that aren't
    % relevant
    if options.contrastWidthRatioLimit > 0
        relevantFits = proms./widths > options.contrastWidthRatioLimit;
    else
        relevantFits = (((widths < 5) & (proms>0.2*max(yData))) | ((widths < 1) & (proms>options.contrastLimit*max(yData)))) ; %nm
    end

    hold on
    pks = pks(relevantFits);
    locs = locs(relevantFits);
    widths=widths(relevantFits);
    proms = proms(relevantFits);

    pks = 1-pks;

    scatter(locs, pks)
    if options.plotFit == true
        response = questdlg('Choose more points or different points? If so, select peak to zoom in, then click on the peak and then the two points of the FWHM.', ...
                            '', ...
                            'No','Different','Skip','No');
        if strcmpi(response, 'Skip')
            return
        end
        if ~strcmpi(response,'No')
            % Get the screen size
            screenSize = get(0,'ScreenSize');
            % Set the figure position to cover the entire screen
            set(gcf,'Position', screenSize);
            jFrame = get(handle(gcf),'JavaFrame');
            jFrame.setMaximized(true);

            if strcmpi(response, 'Different')
                pks = []; locs = []; widths = []; proms = [];
            end
            response = 'Yes';
            while strcmpi(response,'Yes')
                [point1x,point1y]=ginput(1);
                xlim([point1x - 0.5 point1x + 0.5])  
                [point1x,point1y]=ginput(1);              
                plot(point1x,point1y,'ro')
                locs = [locs; point1x];
                pks = [pks; point1y];
                [point1x,point1y]=ginput(1);
                [point2x,point2y]=ginput(1);
                axis tight;
                widths = [widths; abs(point2x-point1x)];
                proms = [proms; 2*abs(mean([point1y point2y]) - pks(end))];
                response = questdlg('Choose another point?', ...
                                    '', ...
                                    'Yes','No','Yes');
            end
            hold off
        end
    end
    
% sort guesses
    [locs, I] = sort(locs);
    pks = pks(I);
    widths = widths(I);
    proms = proms(I);
    if options.dispBool == true
        disp(['Starting Guess Centers: ', num2str(locs')])
    end
% fit function to each peak 

    fitFun = 'Singlet_T';
    hold on
    params=feval([fitFun,'_Param_Guess'],xData, yData, locs, widths, proms, pks);
    if isempty(params)
        return
    end
    hold off

    close all

% normalize the initial values for better fitting (?)\
    scaleVecs=params;
    params=params./scaleVecs;
    initialParams=params;

% iterate fit of lorentzians 
    numFits = size(params);
    numFits = numFits(2);
    opts = optimset('Display','off');
    
    for i = 1:numFits
% filter the data for each peak
        indexFilter = (xData > locs(i) - dataWidthFactor*widths(i)) & (xData < locs(i) + dataWidthFactor*widths(i)) ;
        xDataPeak = xData(indexFilter);
        yDataPeak = yData(indexFilter);

% quick and dirty normalization
        yDataPeak = yDataPeak./max(yDataPeak);

        if livePlot == 1
            fig=figure; hold on;
            title(options.filename, 'interpreter', 'none');
            plot(xDataPeak, yDataPeak)
        end
        
        fit = yDataPeak;

        param = params(:,i);
        scaleVec = scaleVecs(:,i);
        initialParam = initialParams(:,i);

        for j= 1:iterations
            
            rescaleFun = @(param,W) feval(fitFun,param,xDataPeak,scaleVec);
            [param, resnorm] = lsqcurvefit(rescaleFun,param,xDataPeak,fit,[],[],opts);   
            fit=feval(fitFun,param,xDataPeak,scaleVec);
    
            if(j==backgroundIterations)
                param=initialParam;
                fit=feval(fitFun,param,xDataPeak,scaleVec);
            end
    
%Find the background residual
            background=fit./yDataPeak;
    
            [p,S,mu] = polyfit(xDataPeak,background,5);
            backgroundFit=polyval(p,xDataPeak,S,mu);
    
            errorEst=S.normr;
            if livePlot == 1
                subplot(2,1,1)
                plot(xDataPeak,yDataPeak.*backgroundFit,'b.',xDataPeak,fit,'r-')
                title(['Iteration ',num2str(j),' of ',num2str(iterations)])
                xlabel('\lambda [nm]')
                ylabel('Transmission')
    
                subplot(2,1,2)
                plot(xDataPeak,1./background,'b.',xDataPeak,1./backgroundFit,'r-')
                xlabel('\lambda [nm]')
                ylabel('Background')   
    
                drawnow 
            end

            fit=yDataPeak.*backgroundFit;
            
        end   

        if(livePlot==1)
            close(fig);
        end  

        param = param.*scaleVec;
        paramIndex = i + numDoublets;
        resnorms(paramIndex) = resnorm;
        finalParams(:,paramIndex) = param;
        % disp(param)
        [fit,paramNames]=feval(fitFun,param,xDataPeak);

% if the Q is greater than 15000, try a double fit and plot it for the user to
% choose
        centerWL = param(1);
        Qi = param(3);

        if Qi > options.doubletCheckLimit
% limit the range around each Q, then make a doublet fit
            doubletWidth = centerWL/Qi;
            indexFilter = xData < centerWL + 8*doubletWidth & xData > centerWL - 8*doubletWidth;
            xDataDoublet = xData(indexFilter);
            yDataDoublet = yData(indexFilter);
            [paramDoublet, resnormDoublet] = performDoubletFit(xDataDoublet, yDataDoublet, centerWL, doubletWidth, {});

            if resnormDoublet == -1
                fitType{paramIndex} = 'singlet';
            else
                finalParams(:, paramIndex) = paramDoublet(1:3);
                finalParams(:, paramIndex+1) = paramDoublet(4:6);
                resnorms(paramIndex+1) = resnormDoublet;
                fitType{paramIndex} = 'doublet';
                fitType{paramIndex+1} = 'doublet';
                numDoublets = numDoublets + 1;
            end
        else
            fitType{paramIndex} = 'singlet';
        end
        sizeFinalParams = size(finalParams);
        close all

% plot final fit
        if livePlot == 1      
            fig=figure; hold on;
            title(options.filename, 'interpreter', 'none');
            subplot(2,1,1)
            plot(xDataPeak,yDataPeak.*backgroundFit,'r.',xDataPeak,fit)
            xlabel('\lambda [nm]')
            ylabel('Transmission')
        
            subplot(2,1,2)
            plot(errorEst)
            xlabel('Iterations')
            ylabel('Background Error')
        end
        if options.dispBool == true
            disp('***************************************************************')
            disp('Fit results')
            disp('')
            for k=1:length(paramNames)
                disp([paramNames{k},': ',num2str(param(k))])   
            end
            disp('')
            disp('***************************************************************')
        end

    end

% remove any duplicate fits
    params = finalParams;
    numResonances = length(params(1,:));
    wl = params(1,:);
    width = wl./params(3,:);
    eraseBool = zeros(1,length(wl));
    for k = 1:numResonances
        wlDiff = abs(wl - wl(k));
        if params(2,k) < 0 || params(3,k) < 0
            eraseBool(k) = 1;
            continue
        end
        for l = k+1:numResonances
            if wlDiff(l) < 0.2*max([width(k) width(l)])
                eraseBool(l) = 1;
            end
        end
    end

    for k = 1:numResonances 
        if eraseBool(numResonances - k + 1) == true & numResonances > 1
            params(:,numResonances - k + 1) = [];
            resnorms(numResonances - k + 1) = [];
            type{numResonances - k + 1} = [];
        end
    end

% plot all final fits
    fig=figure; hold on;
    title(options.filename, 'interpreter', 'none');
    plot(xData,yData)
    hold on
    sizeParams = size(params);
    for i = 1:sizeParams(2)
        plot(xData, feval(fitFun,params(:,i),xData))

end                                                    
             
