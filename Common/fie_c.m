function aout =fie_c( ain, T) 
%  Usage      : aout =fic( ain, T)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs : Do not support saturation.
    if ( size( T ,1) == 0 )
        aout = cast( ain, 'like', T);
        return ;
    end 
    
    if ( T.wordl <= 0 )
        aout = ain ;
        return 
    end        
    if ( T.wordl == 1) 
            aout = complex( sign(real(ain)),  sign(imag(ain))); 
    else
%         ain_wordl = ain * 2^(T.fracl)  ;
        ain_wordl = ain * 2^(T.fracl) + 2^(-25)*(1+1j) ;
        aoutr = floor(real(ain_wordl)  + 0.5 * T.round) ;
        aouti = floor(imag(ain_wordl) + 0.5 * T.round) ;
        if ( T.signed == 1)
            max_val = 2 ^(T.wordl-1)-1;
            min_val = -max_val-1;
            wrap_off = 2 ^(T.wordl-1);
        else
            max_val = 2 ^(T.wordl )-1;
            min_val = 0;
            wrap_off = 0;
        end
        if ( T.sat == 0 ) % Wrap around 
            aout_r = mod(aoutr+wrap_off, 2^(T.wordl))-wrap_off; 
            aout_i = mod(aouti+wrap_off, 2^(T.wordl))-wrap_off; 
        else
            aout_r = min(max_val, max(min_val, aoutr)); 
            aout_i = min(max_val, max(min_val, aouti)); 
        end

        aout  = complex( aout_r, aout_i);
        aout  = aout / 2^(T.fracl);
    end  
end
