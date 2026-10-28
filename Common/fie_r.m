function aout =fie_r( ain, T) 
%  Usage      : aout =fic( ain, T)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs : Do not support saturation.

%     aout = ain; 
%     if ( size( T ,1) == 0 )
%         aout = cast(real( ain), 'like', T);
%         return ;
%     end 
        
    if ( T.wordl <= 0 )
        aout = real( ain) ;
        return
    end
    if ( T.wordl == 1) 
            aout = sign(real(ain)); 
    else
        ain_wordl = ain * 2^(T.fracl)+ 2^(-25) ;
        aoutr = floor(real(ain_wordl) + 0.5 * T.round) ;
        aoutt = aoutr;
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
            aout = mod(aoutt+wrap_off, 2^(T.wordl))-wrap_off; 
        else
            aout = min(max_val, max(min_val, aoutt)); 
        end
        aout = real(aout / 2^(T.fracl));
    end    
end
