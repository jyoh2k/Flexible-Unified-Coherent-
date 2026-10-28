
function out= NLowPassFilter1( in,filter, en)

%  Usage      : out= NLowPassFilter1( in,filter, en)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    [d1, d2] = size(in);
    out= zeros(d1, d2);    
    if ( en == 0 )
        out = in ;
    else
        for jj=1:d1
            inr =  [ real(in(jj,1:d2)) ];
            ini =  [ imag(in(jj,1:d2)) ];
            filteroutr = filtfilt( filter.b, filter.a, inr );
            filterouti = filtfilt( filter.b, filter.a, ini );
             out(jj,:) = complex( filteroutr, filterouti);   
        end   
    end
end
