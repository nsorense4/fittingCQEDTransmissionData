function [paramDoublet, resnorm] = performDoubletFit(xData, yData, loc, width, options)

    optionsDefault=struct('widthScale', 0.2,...
                    'contrastLimit', 0.001,...
                    'iterations',20,...
                    'backgroundIterations',10, ...
                    'livePlot', 0,...
                    'checkFitTypeBool', false,...
                    'dispBool', false,...
                    'promCutoff', 0.7);

    if isempty(options)
        options = optionsDefault;
    end    
    if ~ isfield(options, 'widthScale')
        options.widthScale = optionsDefault.widthScale;
    end
    if ~ isfield(options, 'contrastLimit')
        options.contrastLimit = optionsDefault.contrastLimit;
    end
    if ~ isfield(options, 'iterations')
        options.iterations = optionsDefault.iterations;
    end
    if ~ isfield(options, 'backgroundIterations')
        options.backgroundIterations = optionsDefault.backgroundIterations;
    end
    if ~ isfield(options, 'livePlot')
        options.livePlot = optionsDefault.livePlot;
    end
    if ~ isfield(options, 'checkFitTypeBool')
        options.checkFitTypeBool = optionsDefault.checkFitTypeBool;
    end
    if ~ isfield(options, 'dispBool')
        options.dispBool = optionsDefault.dispBool;
    end
    if ~ isfield(options, 'promCutoff')
        options.promCutoff = optionsDefault.promCutoff;
    end

% choose only the largest 2 peaks
        [pks,locs,widths,proms] = findpeaks(1-yData, xData,'MinPeakProminence',options.contrastLimit*max(yData), 'MinPeakWidth', width*options.widthScale);
        pks = 1 - pks;
        [~, I] = sort(pks);
        if length(I) < 2
            paramDoublet = -1;
            resnorm = -1;
            return
        end
        I = I(1:2);
        locs = locs(I);
        pks = pks(I);
        widths = widths(I);
        proms = proms(I);
% if the peaks are very different, and  there is probably no doublet
        condition = (abs(pks(1)-pks(2))/max(proms) <= options.promCutoff) & (true);
        if condition
            if options.checkFitTypeBool
                fig = figure;
                plot(xData, yData);
                response = questdlg('We think this is a doublet. Is it?', ...
                                    '', ...
                                    'Yes','No','Yes');
    
                if strcmpi(response,'No')
                    paramDoublet = -1;
                    resnorm = -1;
                    return
                end
                hold on
                scatter(locs, pks)
                hold off
                response = questdlg('Are these good points?', ...
                                    '', ...
                                    'Yes','No','No');
                if strcmp(response, 'No')
                    disp('bad auto doublet fit')
                    paramDoublet = -1;
                    resnorm = -1;
                    return
                end
            end

% sort guesses
            [locs, I] = sort(locs);
            widths = widths(I);
            widths = ones(1, length(widths))*width/3;
            if options.dispBool == true
                disp(['Starting Guess Centers: ', num2str(locs')])
            end

% fit function to each peak 
            
            yData = yData./max(yData);

            fitFun = 'Doublet_T';
            hold on
            params=feval([fitFun,'_Param_Guess'],xData, yData, locs, widths);
            hold off
        
            close all

% normalize the initial values for better fitting (?)\
            scaleVecs=params;
            params=params./scaleVecs;
            initialParams=params;

% iterate fit of lorentzians 
            opts = optimset('Display','off');
                          
            if options.livePlot == 1
                fig=figure;
                plot(xData, yData)
            end
            
            fit = yData;
    
            for j= 1:options.iterations
                
                rescaleFun = @(params,W) feval(fitFun,params,xData,scaleVecs);
                [params, resnorm] = lsqcurvefit(rescaleFun,params,xData,fit,[],[],opts);   
                fit=feval(fitFun,params,xData,scaleVecs);
        
                if(j==options.backgroundIterations)
                    params=initialParams;
                    fit=feval(fitFun,params,xData,scaleVecs);
                end

%Find the background residual
                background=fit./yData;
        
                [p,S,mu] = polyfit(xData,background,5);
                backgroundFit=polyval(p,xData,S,mu);
        
                errorEst=S.normr;
                if options.livePlot == 1
                    subplot(2,1,1)
                    plot(xData,yData.*backgroundFit,'b.',xData,fit,'r-')
                    title(['Iteration ',num2str(j),' of ',num2str(options.iterations)])
                    xlabel('\lambda [nm]')
                    ylabel('Transmission')
        
                    subplot(2,1,2)
                    plot(xData,1./background,'b.',xData,1./backgroundFit,'r-')
                    xlabel('\lambda [nm]')
                    ylabel('Background')   
        
                    drawnow 
                end
    
                fit=yData.*backgroundFit;
                
            end   
    
            if(options.livePlot==1)
                close(fig);
            end  

            params = params.*scaleVecs;
            paramDoublet=params;
        % params(:,i) = param;
        % % disp(param)
            [fit,paramNames]=feval(fitFun,params,xData);
            if options.livePlot == 1      
                fig=figure;
                subplot(2,1,1)
                plot(xData,yData.*backgroundFit,'r.',xData,fit)
                xlabel('\lambda [nm]')
                ylabel('Transmission')
            
                subplot(2,1,2)
                plot(xData, backgroundFit)
                xlabel('Iterations')
                ylabel('Background Fit')
            end
            if options.dispBool == true
                disp('***************************************************************')
                disp('Fit results')
                disp('')
                for k=1:length(paramNames)
                    disp([paramNames{k},': ',num2str(params(k))])   
                end
                disp('')
                disp('***************************************************************')
            end

         
        else
            if options.checkFitTypeBool
                fig = figure;
                plot(xData, yData);
                response = questdlg('We think this is a singlet. Is it?', ...
                                    '', ...
                                    'Yes','No','Yes');
            end
            paramDoublet = -1;
            resnorm = -1;

        end
        

