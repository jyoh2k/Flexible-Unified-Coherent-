function out =  SPMPreComp( in, params) 

%  Usage      : out =  SPMPreComp( in, params) 
%  Function   :
%   Phase rotation due to the nonlinear effect 
%   theta = span * gamma * Leff * P
%   (ofdmsig * txgain )^2 * laser.launch * 10^(TXEDFA.gain /10)
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    out = in;
    if ( params.en ==1 )  
        out = in;
        
        for np=1:size(in,1)          
            nltheta       = params.gain .* sum(abs( in(:,:)) .^2, 1 );
            out(np,:)   = in(np,:) .* exp (- 1i* nltheta);
        end 
    end   
end 

