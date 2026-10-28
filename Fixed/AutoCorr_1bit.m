function [P1, R1, Msym, R2] = AutoCorr_1bit( in ,search_idx, CorLen, Interval,params )

%  Usage      : [P1, R1, Msym, R2] = AutoCorr_1bit( in ,search_idx, CorLen, Interval , params )
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com  
%  Known bugs :


        
        k = (1:CorLen)-1;
        InputLength = round( size(in,2)); 
        EndIdx=InputLength-CorLen;
        
        
        in1           = in(:,search_idx :EndIdx+CorLen);
        in2          = (real(in1) < 0);
        in2          = (imag(in1) < 0)* 1j + in2;
        in_prev = in2(:, 1:end-Interval);
        in_cur  = in2(:, Interval+1:end);
       
        mulr =  (xor( imag(in_prev), imag(in_cur))) + (xor( real(in_prev), real(in_cur)));
        muli = not(xor( real(in_prev), imag(in_cur))) + (xor( imag(in_prev), real(in_cur)));
%         tmp = complex( tmpr, tmpi);
        P1_real = zeros(1, EndIdx- Interval) ;
        P1_imag = zeros(1, EndIdx- Interval);
        for isample= 1 :(EndIdx - Interval)
            P1_real(isample) = (sum( sum( mulr(:,isample+k))) );
            P1_imag(isample) = (sum( sum( muli(:,isample+k))) );
end
    
        P1_real = fie_r( P1_real, params.T.Cor);
        P1_imag = fie_r( P1_imag, params.T.Cor);
        P1 = ( P1_real -size(in2,1)*length(k)) + 1j * ( P1_imag -size(in2,1)*length(k)); 
        P1 = fie_c( P1, params.T.P1);
 
        R1 =   1 ;   
        Msym =  (abs( P1 ) .^2)   ;   
        R2 =   (abs( in) .^2 );   
        Msym = fie_r( Msym, params.T.Msym);

        if ( params.fixed_bit == 2 ) 
    end
end
