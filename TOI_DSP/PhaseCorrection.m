function [POUT] = PhaseCorrection( PIN, params)
%
%  Usage : [POUT] = PhaseCorrection( PIN, params)
%
%  Function   :
%     Carrier phase correction ( linear fitting, minimum phase difference
%     selection )
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
    POUT = PIN; 
    
    if ( params.PCtype == 0 )
        return ;
    end
    
    %% Algorithm  1 : unwrapped phase
    if ( params.PCtype == 1 )
        POUT = unwrap1( PIN, params.CPEtype );
        return ;
    end
    
    %% Algorithm  2: Smoothing
    if ( params.PCtype == 2  )
        PIN1 = unwrap1( PIN, params.CPEtype );
        POUT =  smooth(PIN1,params.STEP*params.smoothing);
%         POUT =  PIN1; 
    end
    
    %% Algorithm  3: Linear fitting 
    if ( params.PCtype == 3  )        
        PIN1 = unwrap1( PIN, params.CPEtype ); 
        idx=1:size(PIN1,2);
        P = polyfit(idx,PIN1(1,1:end),1); 
        POUT = P(1) * idx + P(2);         
%         P = polyfit(idx,PIN(1,1:end),2); 
%         POUT = ( P(1) * idx .^ 2) +  P(2) * idx + P(3); 
    end

end

function POUT = unwrap1( PIN, CPEtype )

        if ( CPEtype == 5  ||  CPEtype == 8 )
            POUT = unwrap(PIN);
        else
            if ( CPEtype == 1 ||  CPEtype == 3  ||  CPEtype == 4   ||  CPEtype == 7)
                POUT = 1/4*unwrap(PIN * 4 );
            else
                POUT = 1/8*unwrap(PIN *8 );
            end
        end
end 