function [out, gain] = RXAGC( in, params )

%  Usage      : [out, gain] = RXAGC(in, params )
%  Function   :
%     1. Gain control to meet optimum ADC gain.
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    if ( params.en == 0 )
        out = in ;
        gain = 1;
        return
    end
    in = fie_c( in, params.T.In);    
    avg_in = mean(abs(in).^2, 2);
    gain2 = params.avg_out ./avg_in  ;
    gain = sqrt(gain2);
    gain = fie_r( gain, params.T.Gain);
    out = in .* ( gain * ones(1, size(in,2)));
    out = fie_c( out, params.T.Out);    
    
     %%
    if ( params.fixed_bit == 2 ) 
    end 
end
