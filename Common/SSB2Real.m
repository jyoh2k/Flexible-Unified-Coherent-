function [out] =  SSB2Real( in, en) 
%  Usage      : [out] =  SSB2Real( in, en) 
%  Function   :
% 
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    out = in;
    if ( en == 0)
        return
    end 


    for ich=1:size(in,1)
        out(ich,:)  = 0.5*(in(ich,:) + conj(in(ich,:)));
    end

    out = real(out);
end
