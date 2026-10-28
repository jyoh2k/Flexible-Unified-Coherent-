function [AOUT, cprout] = RxCPR( AIN, params, T )  

%  Usage      :  AOUT = RxCPR( AIN, params, T )   
%
%  Function   :
%     Carrier frequency offset compensation  and phase recovery
%
%  Port  :
%     1. AIN        : Original signal
%     2. params     : CPR parameter
%     3. T          : Reserved for fixed sim.
%     4. AOUT       : Recovered signal
%     5. cprout     : Recovered phase error (For debugging use)
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
        

    
    [d1, d2] = size( AIN);
    PRL         = params.BLK ;     
    zeropad     = ceil(d2/params.OV ) * params.OV  - d2; 
    phase       = zeros(d1, d2 + zeropad  ) ;
    cpe_blk     = zeros(d1, d2 + zeropad  ) ;
    acc_error   = zeros(d1, d2  + zeropad ) ;    
    AOUT = AIN;
    if ( params.en == 0 )
        cprout.phase      = phase(:,1:PRL:d2); 
        cprout.cpe_blk    = cpe_blk (:,1:PRL:d2); 
        cprout.acc_error = acc_error(:,1:PRL:d2);         
        return;
    end
    
    %% Pilot based    
    mapper2   = params.mapper2;
    if ( params.CPEtype ==5 || params.CPEtype ==6 ) 
        AIN = AIN(:, 1:size(mapper2,2)*params.OV); 
        cpe_blk     = zeros(size(AIN) ) ;
         [d1, d2] = size( AIN);
        AOUT = AIN;
    end 
    %% Phase rotataion estimation and recovery
    for ichannel=1:size(AIN,1)
        params.mapper2 = mapper2(ichannel,:);
        cpe_blk(ichannel,:) = CPE( AIN(ichannel, 1:params.OV:end), params);        
        cpe_blk(ichannel,:) = PhaseCorrection( cpe_blk(ichannel,:), params);
    end
     for ichannel=1:size(AIN,1)
        if ( params.PCtype2 == 2 ) 
            params.BLK          = params.fBLK;
            params.CPEtype      = params.fCPEtype;
            params.PCtype       = params.fPCtype;
            params.STEP         = params.fSTEP;

            cpe_blk1 = CPE( AIN(ichannel,1:params.OV:end), params);        
            cpe_blk1 = PhaseCorrection( cpe_blk1, params);
            cpe_blk2 = PhaseCorrection2( cpe_blk1, cpe_blk(ichannel,:), params);
            cpe_blk(ichannel,:) = cpe_blk2;
        end        
        AOUT(ichannel,:) =  CPR( AIN(ichannel,:), cpe_blk(ichannel,:), params);
        
    end
    cprout.phase      = phase(:,1:1:d2); 
    cprout.cpe_blk    = cpe_blk (:,1:1:d2); 
    cprout.acc_error = acc_error(:,1:1:d2); 
    AOUT             = AOUT(:,1:d2);     
    
    if ( params.fixed_bit == 2 )  
    end
end
