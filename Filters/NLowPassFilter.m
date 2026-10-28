
function out= NLowPassFilter( in, filter, en)

%  Usage      : out= NLowPassFilter( in, sim, en)
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
            inr = interp1(1:d2+1, [ real(in(jj,1:d2)) 0],1:1/2:d2+1/2);
            ini = interp1(1:d2+1, [ imag(in(jj,1:d2)) 0],1:1/2:d2+1/2);
            filteroutr = filtfilt( filter.b, filter.a, inr );
            filterouti = filtfilt( filter.b, filter.a, ini );
            out(jj,:) = complex( filteroutr(2:2:2*d2), filterouti(2:2:2*d2));   
%             filteroutr = filtfilt( filter.b, filter.a, real(in(jj,1:d2)) );
%             filterouti = filtfilt( filter.b, filter.a, imag(in(jj,1:d2)) );
%             out(jj,:) = complex( filteroutr, filterouti);           
        end   
    end
end
