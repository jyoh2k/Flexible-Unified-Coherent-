function [out] = TxGain( in, params )

%  Usage      : [out] = TxGain(in, params )
%  Function   :
%     1. Gain control to meet optimum DAC gain.
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    if ( params.en == 0 )
        out = in ;
        gain_ratio = 1;
        return
    end

    in = fie_c( in, params.T.In);    
    gain_ratio = fie_r( params.gain, params.T.Gain);
    out = in .* ( gain_ratio * ones(1, size(in,2)));
    out = fie_c( out, params.T.Out);    
    
end
