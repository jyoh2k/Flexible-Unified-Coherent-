function [ out]=  Downsample( in, oversample)

%  Usage      : [ out]=  Downsample( in, oversample)
%
%  Function   :
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    out      = in(:,1:oversample:end); 

end
