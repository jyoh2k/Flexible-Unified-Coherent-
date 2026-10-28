function [AOUT] = CPR( AIN, phase, params)
%  Usage      :  [AOUT] = CPR( AIN, phase, params, T)
%
%  Function   :
%     Carrier phase compensation
%
%  Port
%     1. AIN        : Original signal
%     2. phase      : Phase to be recovered.
%     3. params     : CPR (carrier phase recovery) parameter
%     4. AOUT       : Compensated signal
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   

    phase =  fie_phase(  phase(1:size(AIN,2)), params.T.CompPhase );
    comp_phase = cos(  phase) -1j* sin(phase) ;
    comp_phase =  fie_c(  comp_phase, params.T.CompRom);

    AOUT = AIN  .* (ones(size(AIN,1),1) * comp_phase );
    AOUT =  fie_c(  AOUT, params.T.Out);

    if ( params.fixed_bit == 2 )  
    end
end