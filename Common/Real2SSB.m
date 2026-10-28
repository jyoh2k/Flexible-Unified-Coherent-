function [out] =  Real2SSB( in, en) 
%  Usage      : [out] =  Real2SSB( in, en) 
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
        out(ich,:)  = hilbert(   in(ich,:)  );
    end

end
