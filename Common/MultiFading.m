function [AOUT] = MultiFading( AIN, params )

%  Usage      : [AOUT] = MultiFading(  AIN, params )
%  Function   :
%     Multifading channel model
%
%  Port :
%     1. AIN          : Original signal
%     2. params    : Parameter for Multifading channel model
%     3. AOUT       : Signal with phase noise
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    filtercoef =   params.filtercoef  ;
    sample_delay = params.sample_delay  ;
    offset =  (params.filtertap -1)/2; 

    if ( params.en == 0)
%         AOUT = params.gains(1) * AIN ;
        AOUT =   AIN ;
        return;
    end
    AOUT = zeros(size(AIN));
    for idx=1:size(filtercoef,1)
        for ich=1:size(AIN,1)
            A = circshift( conv( filtercoef(idx,:), AIN(ich,:)), [0 sample_delay(idx) ]);
            AOUT(ich,:) = AOUT(ich,:) +  A(offset+(1:size(AIN,2)));
        end
    end

end 