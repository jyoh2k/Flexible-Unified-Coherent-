function [ out  ]=  MatchedFilter1( in, params )

%  Usage      : [ out  ]=  MatchedFilter( in, params )
%
%  Function   :
%     1. out :output 
%     2. in : input 
%     3. params : parameters
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
%
%% Matched filter 

    coef = params.time_resp;
    in1 = [zeros(size(in,1),(length(coef)-1)/2) in zeros(size(in,1),(length(coef)-1)/2)];
    in1 = fie_c(in1, params.T.In); 
    
     
    out = in1 ;
    if ( params.en == 0 )        
        return;
    end

    coef = fie_c(coef, params.T.Coef);
    mid = ceil(length(coef)/2);
    for idim=1:size(in1,1)
        for idx=1:size(in1,2)-length(coef)+1
            conv_mul = in1(idim, idx:idx+length(coef)-1) .* coef;
            % Symmetric matched filter 
            conv_mul = [( conv_mul(:, 1:mid-1) + conv_mul(:, end:-1:mid+1)), conv_mul(mid)];
            conv_mul  = fie_c( conv_mul, params.T.Mul) ;
            out(idim,idx)   = sum(conv_mul) ;
        end
    end

    out = fie_c(out, params.T.Out);    
    
    if ( params.fixed_bit == 2 ) 
        coef = fie_c(coef, params.T.Coef);
    end 
end
