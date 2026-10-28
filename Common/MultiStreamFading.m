function  [AOUT] = MultiStreamFading( AIN, params )

%  Usage      : [AOUT] = MultiStreamFading(  AIN, params )
%  Function   :
%     Multifading channel model for multi steam
%
%  Port :
%     1. AIN          : Original signal
%     2. params    : Parameter for Multifading channel model
%     3. AOUT       : Signal with phase noise
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
% Tx x Rx  
% [ 1  2 ]     [    TX1 ]
%               x |
% [ 3  4 ]     [     TX2 ]


    if ( params.en == 0) 
        AOUT =   AIN ;
        return;
    end
    
    params_org = params;
    nstream = size(AIN,1);
    ATMP = zeros(nstream^2,size(AIN,2));

    for rxidx=1:nstream 
        for txidx=1:nstream 
             idx = (rxidx-1)*nstream+txidx ;
             params.filtercoef = params_org.filtercoef(:, :, idx);
             params.sample_delay = params_org.sample_delay(:, :, idx);
            ATMP(txidx,:)= MultiFading( AIN(txidx, :), params); 
        end
         AOUT(rxidx,:) = sum(ATMP(1:nstream ,:), 1);
    end
     
end

 
