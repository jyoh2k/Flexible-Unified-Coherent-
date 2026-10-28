function [POUT] = PhaseCorrection2( PIN, Ref, params)
%
%  Usage : [POUT] = PhaseCorrection2( PIN, params, T)
%
%  Function   :
%     Carrier phase correction ( One CPE only, Guide+ CPE, Coarse + Fine)
%
%  Port
%     1. PIN        : Phase 
%     2. params     : CPR (carrier phase recovery) parameter
%     3. T          : Reserved for future use
%     4. POUT       : Correctd phase
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   

 
    phase_cycslip = zeros(1, size(PIN,2)+1);
     if ( params.PCtype2 == 2 )
        for idx=1:size(PIN,2)
            if ( params.CPEtype == 1 || params.CPEtype == 4  || params.CPEtype == 6) 
                phase_diff = PIN(idx) + [ pi pi/2 0 -pi/2 ]';
            else
                phase_diff = PIN(idx) + pi/4 *[ 5:-1:-3]';
            end
            
            phase_distance =  mod(( phase_diff - Ref(idx))+pi, 2*pi) - pi;
            [C, I] = min(abs(phase_distance));
            phase_cycslip(idx+1) =  phase_diff(I);
        end
    end
    POUT = phase_cycslip(1, 2:end); 
end
