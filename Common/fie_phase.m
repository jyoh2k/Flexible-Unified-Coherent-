function aout = fie_phase( ain, T)
%  Usage      : aout = fi_phase( ain, BIT, ROUND)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : miroandi@kaist.ac.kr   
%  Known bugs : 
%    Do not support saturation. 
%    Only wrap around is possible. ( which does not require extra coding)       
% range of phase is [-pi pi)
    
    if ( size( T ,1) == 0 )
        ain = double(ain) + 2*pi;
        ain =  mod(ain + pi , 2*pi ) - pi ;
        aout = cast( ain, 'like', T);
        return ;
    end 
    if ( T.wordl <= 0 )
        aout = mod(ain + pi , 2*pi ) - pi ;
    else
        if ( (T.wordl - T.fracl) < 3 )
            Rate =(2^(T.fracl+3))/2/pi ;
            aout = floor( (mod(ain+pi, 2* pi)-pi) * Rate  + 2^(-25) + 0.5 * T.round) ;
            wrap_off = 2 ^(T.wordl-1);
            aout = mod(aout+wrap_off, 2^(T.wordl))-wrap_off;
        else
            Rate =(2^T.wordl)/2/pi ;
            aout = floor( (mod(ain+pi, 2* pi)-pi) * Rate  + 2^(-25) + 0.5 * T.round) ;
        end
        
        aout = aout /Rate;        
        aout =  mod(aout + pi , 2*pi ) - pi ;
    end    
end
