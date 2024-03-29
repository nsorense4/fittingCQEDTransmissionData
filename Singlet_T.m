function [ T, paramNames ] = Singlet_T(params, Lambda, varagin)
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
    Lambda_o=params(1); %Center wavelength of resonance
    Q_ex=params(2);     %External (coupling) quality factor
    Q_i=params(3);    %Sym mode intrinsic quality factor
    
    %Apply scale factor
    
    %Detuning=(Lambda-Lambda_o)*scaleFactor;
    Detuning=(Lambda-Lambda_o);
    
    %Calculate required Quality factors
    Q=Q_i*Q_ex /(Q_i  +Q_ex);
    
    Pow=-1/(2*Q_ex)./...
        (-1/(2*Q)+1i*(Detuning/Lambda_o));

    %Transmission
    T=abs(-1+Pow).^2;
    
    %Output the parameter names
    S1='Center Wavelength [nm]  ';
    S2='Coupling Quality Factor ';
    S3='Intrinsic Quality Factor';
    
    paramNames=[S1;S2;S3];
    paramNames=cellstr(paramNames);
    
end

