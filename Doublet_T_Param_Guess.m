function [ params ] = Doublet_T_Param_Guess(lambda, T, loc, width)
    lambdaFWHMPoints = [loc(1) - width(1)/2, loc(1) + width(1)/2, loc(2) - width(2)/2, loc(2) + width(2)/2];
    
    %Guess input parameters, plot, and ask for user verification 
    
    %Center wavelength:
    Lambda_o=mean(lambdaFWHMPoints);
    Lambda_s =mean(lambdaFWHMPoints(1:2));
    [~,Lambda_s_Index] = min(abs(Lambda_s-lambda));
    Lambda_a=mean(lambdaFWHMPoints(3:4));
    [~,Lambda_a_Index] = min(abs(Lambda_a-lambda));
    
    %Splitting quality factor   
    Q_bs=Lambda_o/(Lambda_a-Lambda_s);
    
    %Loaded quality factors:
    Q_s =Lambda_s/(lambdaFWHMPoints(4)-lambdaFWHMPoints(3));
    Q_a=Lambda_a/(lambdaFWHMPoints(2)-lambdaFWHMPoints(1));
    
    %Resonance contrast:
    RC_s =1-T(Lambda_s_Index );
    RC_a=1-T(Lambda_a_Index);
    
    %External coupling quality factor
    Q_ex_s= 2*Q_s /(RC_s );
    Q_ex_a=2*Q_a/(RC_a);
    Q_ex=(Q_ex_s+Q_ex_a)/2; %(Assume the external coupling is equal)
    
    %Intrinsic quality factors  
    Q_s_i =Q_ex_s* Q_s /(Q_ex_s -Q_s);
    Q_a_i=Q_ex_a*Q_a/(Q_ex_a-Q_a);
    
    params(1)=Lambda_s;
    params(2)=Q_ex_s;
    params(3)=Q_s_i;
    params(4)=Lambda_a;
    params(5)=Q_ex_a;
    params(6)=Q_a_i;
    params(7)=Lambda_o;
    params(8)=Q_bs;

    
    %This should be modified to handle the reflection case
    Tfit=Doublet_T(params, lambda, 1);
    hold off
    plot(lambda,T,lambda,Tfit)
    xlabel('\lambda [nm]')
    %if(strcmpi(measurementType,'T'))
        ylabel('T')
%     elseif(strcmpi(measurementType,'R'))
%         ylabel('R')
%     end
       
    %Ask user to accept the fit
    % response = questdlg('Accept preliminary fit?', ...
    %     '', ...
    %     'Yes','No','Yes');
    % if strcmpi(response,'No')
    %     % close(fig)
    %     DoubletParamGuess(lambda, T);
    % else
        % close(fig)
    % end
        
end

