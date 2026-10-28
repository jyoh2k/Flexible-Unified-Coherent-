function [tauout,  acc_error] = TPRLoopFilter( tauin, phase_error, acc_error, params)

%  Usage      :  [tauout, tau_error, acc_error] = TPRLoopFilter( tauin, phase_error, acc_error, params, T) 
%
%  Function   :
%    2nd order loop filter for Timign error recovery system
%              
%  Port  :
%     1. tauin      : Accumulated timing error 
%     2. phase_error: Estimated phase error 
%     3. acc_error  : Accumulated error in previous cycle 
%     4. params     : TPR parameter ( K1 : Propotional, K2: Intergral )
%     5.   T        : Reserved for fixed sim.
%     6. tauout     : Accumulated timing error 
%     7. tau_error  : Recovered timing error 
%     8. acc_error  : Accumulated error 
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   

    %% Loop filter
    params.K1 = fie_r( params.K1 , params.T.K1);
    params.K2 = fie_r( params.K2 , params.T.K2);
    error_avg1 = params.K1  * phase_error ;
    error_avg1 = fie_r( error_avg1, params.T.Loop1);
    error_avg2= params.K2 * acc_error ;
    error_avg2 = fie_r( error_avg2, params.T.Loop1);
    tau_error = error_avg1  + error_avg2;
    if ( params.fixed_bit == 2 )   
    end
    tau_error = fie_r( tau_error, params.T.Loop);

    %% update filter or equalizer coefficient
    tauout = tauin +  tau_error  ;
    tauout  = fie_r(tauout , params.T.Tau );

    acc_error = acc_error +  phase_error ;
    acc_error  = fie_r(acc_error , params.T.Acc );
    if ( params.fixed_bit == 2 )  
    end 

end
