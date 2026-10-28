function AOUT = TxPreemphasisH( AIN, params )    

%  Usage      : AOUT = TxPreemphasisH( AIN, params )    
%  Function   : Preemphasis in frequency domain
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :


    
    AOUT =AIN;
    if ( params.en == 0 )
      return;    
    end

    if ( mod(size(AIN,2), length(params.H)) ~= 0)
       error('The number of sample should be the integer multiples of preemphasis coef');
    end 

    Nsymbol = ceil(size(AIN,2) /length(params.H));
    H = zeros(length(params.H),1);
    H(:,1) = params.H;
    H_ext = ones(Nsymbol, 1) *  H;
    H_ext = reshape( H_ext,  1, size(AIN,2));
    for ii=1:size(AIN,1)
        AOUT(ii,:) = AIN(ii,:) .* H_ext ;
    end
    
 
end
