function [phase_error  ] = TPE( AIN, decided, params )

%  Usage      :  AOUT = TPE( AIN, params )   
%
%  Function   :
%     1. Timing phase error estimation
%     2. AIN        : Original signal
%     3. decided    : Decided value of AIN
%     3. params     : TPR parameter
%     4. T          : Reserved for fixed sim.
%     5. phase_error: Estimated phase error
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :


    
    type = params.TPEtype;
    OV   = params.OV;
    PRL  = (floor(size(AIN,2)/OV)-1)*OV;
        
    iPRL =1:OV:PRL;
    idx = iPRL + OV/2;
    e = zeros(1, PRL);
    
    if ( type == 1 ) % Gardner 
        AIN1 = real(AIN);
        e = AIN1(idx) .*  ( AIN1(idx-OV/2) - AIN1(idx+OV/2));
        e = fie_c( e, params.T.TED);
    end
    if ( type == 2 )   % Early-late 
        deltaT = 0.5;
        AIN = real(AIN);
        e = ( (resample_inter(AIN(idx-1), AIN(idx), 1-deltaT) ).^2 ...
               - (resample_inter(AIN(idx), AIN(idx+1), deltaT) ).^2 ); 
    end   
    if ( type == 4 )   %  Mueller-Muller e_n=(y ^_(n-1)*y_n)-(y_(n-1)*y ^_n)
        e(iPRL)=  decided((iPRL-1)/OV+1) .* AIN(iPRL+OV) ...
                - AIN(iPRL) .* decided((iPRL-1)/OV+2);
    end
    if ( type == 5 )  %  Digital Filter and Square timing recovery
        x = 1:length(AIN); 
        x1 = 1:1/2:length(AIN);
        AIN_inter = interp1(x, AIN, x1);
        length_AIN = length(AIN_inter);
        OV = 2 * params.OV;
        x_freq =  (sum( abs(AIN_inter([1:length_AIN])) .^2 .* ...
                   exp( 1j*2*pi/OV*[0:1:(length_AIN-1)]) )); 
        e      = atan2(imag(x_freq), real(x_freq));
    end
    if ( type == 6 )  %  Digital Filter and Square timing recovery
        x = 1:length(AIN);  
        length_AIN = length(AIN);
        OV =  params.OV;
        x_freq =  (sum( abs(AIN([1:length_AIN])) .^2 .* ...
                   exp( 1j*2*pi/OV*[0:1:(length_AIN-1)]) )); 
        e      = atan2(imag(x_freq), real(x_freq));
    end
    phase_error = sum(real(e)) + sum(imag(e));
    phase_error = fie_r( phase_error, params.T.TEDSum);
    
    if ( params.fixed_bit == 2 )  
    end 

end

function out= resample_inter( in1, in2, deltaT )
    out = in1 * deltaT + in2 *(1-deltaT);
end


%% Algorithm
% 1 :Gardner: F. Gardner, "A BPSK/QPSK Timing-Error Detector for Sampled Receivers," in IEEE Transactions on Communications, vol. 34, no. 5, pp. 423-429, May 1986.
% 5: Digital filter and square timing recovery, M. Oerder and H. Meyr, ��Digital filter and square timing recovery,�� IEEE Trans. Commun. 36(5), 605?612
% (1988).
