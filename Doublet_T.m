function [ T, paramNames ] = Doublet_T(params, Lambda, varagin)
%Doublet Summary of this function goes here
%   Detailed explanation goes here

    %Find if scale factor included
    if nargin == 3
        scaleVec=varagin;
    else
        scaleVec=ones(1,length(params));
    end 
    
    %scaleFactor
    
    params=params.*scaleVec;
    
    %Organize the fitting parameters
    Lambda_o=params(7); %Center wavelength of resonance
    Q_ex=params(2);     %External (coupling) quality factor
    Q_s_i=params(3);    %Sym mode intrinsic quality factor
    Q_a_i=params(6);    %Antisym mode intrinsic quality factor
    Q_bs=params(8);     %Backscattering quality factor
 
    %Apply scale factor
    
    %Detuning=(Lambda-Lambda_o)*scaleFactor;
    Detuning=(Lambda-Lambda_o);
    
    %Calculate required Quality factors
    Q_s =Q_s_i*Q_ex /(Q_s_i  +Q_ex);
    Q_a=Q_a_i*Q_ex/(Q_a_i+Q_ex);

    %Clockwise mode
    Pow_s=-1/(2*Q_ex)./...
        (-1/(2*Q_s)+1i*(Detuning/Lambda_o+1/(2*Q_bs)));

    %Counterclockwise
    Pow_a=-1/(2*Q_ex)./...
        (-1/(2*Q_a)+1i*(Detuning/Lambda_o-1/(2*Q_bs)));

    %Transmission
    T=abs(-1+Pow_s+Pow_a).^2;
    
    %Output the parameter names
    S1='Center Wavelength 1  [nm]                  ';
    S2='Coupling Quality Factor                    ';
    S3='Mode 1 (s) Intrinsic Quality Factor        ';
    S4='Center Wavelength 2  [nm]                  ';
    S5='Coupling Quality Factor                    ';
    S6='Mode 2 (a) Intrinsic Quality Factor        ';
    S7='Center Wavelength [nm]                     ';
    S8='Backscattering Qualit Factor               ';
    
    paramNames=[S1;S2;S3;S4;S5;S6;S7;S8];
    paramNames=cellstr(paramNames);
    
end

