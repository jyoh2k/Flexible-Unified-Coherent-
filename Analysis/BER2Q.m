function Q =  BER2Q( BER )

%  Usage      : Q =  BER2Q( BER )
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    t = sqrt( -2 * log ( BER ) );
    q = t - ( ( 2.307 + 0.2706*t)./(1 + t*0.9923 + t.^2 * 0.0448));
    Q=20*log10(q);
end 
