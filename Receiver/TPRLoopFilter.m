function [tauout,  acc_error] = TPRLoopFilter( tauin, phase_error, acc_error, params, T)

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
    tau_error = params.K1  * phase_error + params.K2 * acc_error;

    %% update filter or equalizer coefficient
    tauout = tauin +  tau_error  ;
    
    acc_error = acc_error +  phase_error ;

end
