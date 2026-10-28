function [ out  ]=  FIR( in, coef, params )

%  Usage      : [ out  ]=  FIR( in, params )
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

    in = fie_c(in, params.T.In);
    out = in ;
    if ( params.en == 0 )        
        return;
    end

    coef = fie_c(coef, params.T.Coef);
    
    for idim=1:size(in,1)
        for idx=1:size(in,2)-length(coef)+1
            conv_mul = in(idim, idx:idx+length(coef)-1) .* coef;
            conv_mul  = fie_c( conv_mul, params.T.Mul) ;
            out(idim,idx)   = sum(conv_mul) ;
        end
    end

    out = fie_c(out, params.T.Out);
    
    


end
