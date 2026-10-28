function aout = fie_phase( ain, T)
%  Usage      : aout = fi_phase( ain, BIT, ROUND)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : miroandi@kaist.ac.kr   
%  Known bugs : Do not support saturation. 
%    Only wrap around is possible. ( which does not require extra coding)       
% range of phase is [-pi pi)
    
    if ( size( T ,1) == 0 )
        ain = double(ain) + 2*pi;
        ain =  mod(ain + pi , 2*pi ) - pi ;
        aout = cast( ain, 'like', T);
        return ;
    end 
end
