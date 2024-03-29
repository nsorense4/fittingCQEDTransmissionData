function [ params ] = Singlet_T_Param_Guess(lambda, T, locs, widths, proms, pks)
    numFits = length(locs);

    params = zeros(3,numFits);
    %Loaded quality factors:
    Q_t =locs./(widths);
    
    %Resonance contrast:
    RC = proms;
    
    %External coupling quality factor
    Q_ex= 2*Q_t ./(RC);
    
    %Intrinsic quality factors  
    Q_i = Q_ex.* Q_t ./(Q_ex-Q_t);
    
    params(1,:)=locs;
    params(2,:)=Q_ex;
    params(3,:)=Q_i;
    
    %This should be modified to handle the reflection case
    for i= 1:numFits
        Tfit=Singlet_T(params(:,i), lambda, 1);
        plot(lambda,T,lambda,Tfit-(1-pks(i)-proms(i)))
    end
    xlabel('\lambda [nm]')
    ylabel('T')
        
end

