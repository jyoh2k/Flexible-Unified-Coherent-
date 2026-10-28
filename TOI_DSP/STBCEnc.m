function [out]=  STBCEnc( in,  params )

%  Usage      : [out]=  STBCEnc( in,  params )
%  Function   :
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    if ( params.en == 0 )
        out = in ;
        return
    end

    if ( size(in,1) ~= 1 | mod(size(in,2),2) ~= 0) 
        error(' STBC accepts only one stream ( one stream -> two streams) and  # of input should be even.');
    end

   out = zeros(2, size( in,2));
   out(1,1:2:end) = in(1:2:end);
   out(1,2:2:end) = -conj(in(2:2:end));
   out(2,1:2:end) = in(2:2:end);
   out(2,2:2:end) = conj(in(1:2:end)); 

    %output 
    % in(1)  -conj(in(2))  ... in(n)  -conj(in(n+1))  ...
    % in(2)   conj(in(1)) ...  in(n+1)   conj(in(n)) ...
   
   % Normalization  factor  ; params.norm
   %out = out / params.norm;
end 
