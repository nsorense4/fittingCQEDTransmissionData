function [ ] = DoFitFun( varargin )
%DoFitFun Fits optical resonance data to a function, and a background.
%   At present, DoFitFun can be called as follows:
%   * DoFitFun()
%   * DoFitFun(data) 
%   * DoFitFun(data,fitType)
%
%   In the above 'data' must be organized as output by the laser program, 
%   and 'fitType' must be a valid fit function. Right now the choices are:
%   * Doublet_T
%   * Singlet_T
%
%   Note please add an _T or _R when making a new function to fit.

    %% User settings
    livePlot=1;
    saveFit=1;
    iterations=20;
    backgroundIterations=10;
    
    fitFun1='Doublet_T';
    fitFun2='Singlet_T';
    
    fitFuns=[fitFun1;fitFun2];
    fitFuns=cellstr(fitFuns);
    
   
    
    %%
    % Check inputs
               
    if nargin<1
        %In this case the user selects data from a file
        [fileName,pathName,~] = uigetfile('*.mat');
        fullFileName=fullfile(pathName,fileName);
        load(fullFileName);
    else     
        scanData=varargin{1};
    end
    
    % Write the scan data into local variables for convenience
    % T=scanData.T;
    % R=scanData.R;
    % W=scanData.W;
     
    fig=figure;
    subplot(2,1,1)
    plot(W,T)
    xlabel('\lambda [nm]')
    ylabel('Transmission')

    subplot(2,1,2)
    % plot(W,R)
    xlabel('\lambda [nm]')
    ylabel('Reflection')
    
    if nargin<2    
        %In this case we ask the user what type of fit to do.
        [selectionNum,~] =...
        listdlg('PromptString','Select a fitting function:',...
                'SelectionMode','single',...
                'ListString',fitFuns);
        fitFun=fitFuns{selectionNum};           
    end
    
    close(fig);
    
    % This can either be 'T' for transmission or 'R' for reflection.
    fitDataType=fitFun(end);
    if(strcmpi(fitDataType,'R'))
        iterations=1;
        backgroundIterations=1;
    end
    
    %% Pre-Process data
 
    % Plot the data for the user
    fig=figure;
    switch fitDataType 
        case 'T' 
            plot(W,T);
            xlabel('\lambda [nm]')
            ylabel('Transmission')
        case 'R'
            plot(W,R);
            xlabel('\lambda [nm]')
            ylabel('Reflection')
    end
   
    
    % Find if the user wants to trim the data
    response = questdlg('Trim domain?', ...
        '', ...
        'Yes','No','Yes');
    if strcmpi(response,'Yes')
        
        %Find points to trim at, then trim
        hold on
        [point1x,point1y]=ginput(1);
        plot(point1x,point1y,'k+')
        [point2x,point2y]=ginput(1);
        plot(point2x,point2y,'k+')       
        hold off        
        
        pointIndices=NaN(1,2);
        [~,pointIndices(1)]=min(abs(point1x-W));
        [~,pointIndices(2)]=min(abs(point2x-W));
        pointIndices=sort(pointIndices);

        pointIndices(1)
        pointIndices(2)
        
        T=T(pointIndices(1):pointIndices(2));
        % R=R(pointIndices(1):pointIndices(2));
        W=W(pointIndices(1):pointIndices(2));
        
    end
      
    close(fig)
     
    %Force monotonicity (needed for interpolation)
    [W,I]=sort(W);
    T=T(I);
    % R=R(I);

    %Make sure the matices are horizontal
    [numColumns,~]=size(T);
    if(numColumns==1)
        T=T';
    end
    
    % [numColumns,~]=size(R);
    % if(numColumns==1)
    %     R=R';
    % end
    
    [numColumns,~]=size(W);
    if(numColumns==1)
        W=W';
    end
     
    %In the case of duplicate wavelengths, we'll take the average value
    duplicateLeadingIndex=[1;(find(diff(W))+1)];
    numUniquePoints=length(duplicateLeadingIndex);
    tempW=NaN(1,numUniquePoints);
    tempT=NaN(1,numUniquePoints);
    tempR=NaN(1,numUniquePoints);

    for i=1:(numUniquePoints-1)

        startIndex=duplicateLeadingIndex(i);
        stopIndex=duplicateLeadingIndex(i+1);

        tempW(i)=mean(W(startIndex:stopIndex));
        tempT(i)=mean(T(startIndex:stopIndex));
        % tempR(i)=mean(R(startIndex:stopIndex));

    end

    startIndex=duplicateLeadingIndex(numUniquePoints);

    tempW(numUniquePoints)=mean(W(startIndex:end));
    tempT(numUniquePoints)=mean(T(startIndex:end));
    % tempR(numUniquePoints)=mean(R(startIndex:end));

    W=tempW;
    T=tempT;
    % R=tempR;

    %Do a quick and dirty normalization
    T=T/max(T);
    % R=R/max(R);

    %% 
    % Do Fit

    errorEst=NaN(1,iterations);
    backgroundFit=ones(1,length(W));

    switch fitDataType 
        case 'T'
            signal=T;
        case 'R'
            signal=R;
    end

    fit=signal;

    %Since the parameters vary significantly in magnitude, we scale them by
    %'scaleVec' when doing fits to get better results. They will be rescaled at
    %the end when the fit is finished.

    params=feval([fitFun,'_Param_Guess'],W,signal);

    scaleVec=params;
    params=params./scaleVec;
    initialParams=params;

    opts = optimset('Display','off');

    if(livePlot==1)
        fig=figure;
    end    

    for i=1:iterations

        %Fit the resonance
        rescaleFun = @(params,W) feval(fitFun,params,W,scaleVec);
        params = lsqcurvefit(rescaleFun,params,W,fit,[],[],opts);   
        fit=feval(fitFun,params,W,scaleVec);

        if(i==backgroundIterations)
            params=initialParams;
            fit=feval(fitFun,params,W,scaleVec);
        end

        %Find the background residual
        background=fit./signal;

        [p,S,mu] = polyfit(W,background,5);
        backgroundFit=polyval(p,W,S,mu);

        errorEst(i)=S.normr;

        if(livePlot==1)

            subplot(2,1,1)
            plot(W,signal.*backgroundFit,'b.',W,fit,'r-')
            title(['Iteration ',num2str(i),' of ',num2str(iterations)])
            xlabel('\lambda [nm]')
            ylabel('Transmission')

            subplot(2,1,2)
            plot(W,1./background,'b.',W,1./backgroundFit,'r-')
            xlabel('\lambda [nm]')
            ylabel('Background')   

            drawnow 

        end    

        fit=signal.*backgroundFit;

    end

    if(livePlot==1)
        close(fig);
    end  

    params=params.*scaleVec;

    %%
    % Plot final fit and display the parameters

    [fit,paramNames]=feval(fitFun,params,W);

    fig=figure
    subplot(2,1,1)
    plot(W,signal.*backgroundFit,'r.',W,fit)
    xlabel('\lambda [nm]')
    ylabel('Transmission')

    subplot(2,1,2)
    plot(errorEst)
    xlabel('Iterations')
    ylabel('Background Error')

    disp('***************************************************************')
    disp('Fit results')
    disp('')
    for i=1:length(paramNames)
        disp([paramNames{i},': ',num2str(params(i))])   
    end
    disp('')
    disp('***************************************************************')

    %%
    % Save the fit if selected
  
    if saveFit
        % Find if the user wants to save the fit
        response = questdlg('Save fit?', ...
        '', ...
        'Yes','No','Yes');
        if strcmpi(response,'Yes')
            switch fitDataType 
                case 'T'
                     uisave({'W','T','backgroundFit','params'});
                case 'R'
                     uisave({'W','R','params'});
            end
        end
    end    
    
end
