function [params]=  SetParams( sim_case, params )
%  Usage      : [params]=  SetParams(sim_case, params)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
    

if (params.PTBC == 0 ) 
    params.NTXStream         = 2;
else 
    params.NTXStream         = 1;
end 
if (params.RXDSP_PTBC == 0 ) 
    params.NRXStream         = 2;
else 
    params.NRXStream         = 1;
end 
params.tpr.settling_time   = 1600 * 4;
params.totalbits = 524272;
params.en_block_termination   = 4 ;% Add QPSK pilot symbols
params.NSymbol           = params.NTrainingSymbol + params.NDataSymbol;
params.NSymbol           = params.NSymbol + params.NSignalSymbol;

params.fec.en       = 0;
params.fec.FEC_mode = 1;  
params.signal.en    = 2;  
params.signal.n     = 62;
params.signal.k     = 35;
params.fixed_type   = 0;  
%% TX DSP
params.txpreemp.en  = 0;
params.TXMatchedfilter.en =1;
params.TXMatchedfilter.alpha = 0.3;
params.TXMatchedfilter.resp_sample = 4;
%% RX DSP
params.RXStructure = 1;
params.channel_learning = 0;
params.RXMatchedfilter.en = 1;
params.AGC.en = 1;
params.AGC.avg_out = 0.5;     

params.OFDE.freq_resp = ones( 1, 128);

params.searchframe.en = 1;
params.searchfineframe.en = 1;

params.tpr.cal_init_tpr = 1;
params.tpr.K1            = -5e-3;   %  Propotional coefficient of loopfilter
params.tpr.K2            = -1e-6;   %  Integral coefficient of loopfilter
params.tpr.L             = 9;

params.dfe.is_training_seq_init =  1;
params.dfe.betaf          =  4.0000e-04 ;
params.dfe.update_rate_training = 10;
params.dfe.type           = 4; 
if ( params.Nbitspersymbol  ==2  )
    params.dfe.type = 2;
end
params.dfe.betab          = 0;
params.dfe.PRL = 128;
params.dfe.Nfbe = 0;
params.dfe.Nffe = 17;
params.dfe.update_type =1; 

params.dfe1.en  = 0;
params.cfr.en    = 1;
params.cfr.CFEtype  = 5 ;

params.stbc.PRL =   128;
params.stbc.block_size = 32;
params.stbc.Nffe =  17;
params.stbc.betaf = 2 * 5e-4 ; 
params.stbc.betab =  0;
params.stbc.en_block_termination =  4;
params.stbc.is_training_seq_init =  1;
params.stbc.filtertap_update =  1;
params.stbc.h_init_en =  1;
params.stbc.update_type =  1;
params.stbc.BPS_window =  8;
params.stbc.BPS_step =  8*3;
params.stbc.BPS_range =  0.4*3;
params.stbc.TPEtype   =  1;
params.stbc.TPEtype   =  1;
params.stbc.rx_in_org = 2;

if (params.RXDSP_PTBC == 1 ) 
    params.searchfineframe.type = 3;
else 
    params.searchfineframe.type = 1;
    %params.searchfineframe.type = 0;
end 
%% Pilot based
params.pilot.Nbitspersymbol = 2; % QPSK
if ( params.Nbitspersymbol == 4)
    params.term_bits  =[1 0 1 0 ];
end
if ( params.Nbitspersymbol == 5)
    params.term_bits  =[1 0 1 0 1 ];
end
if ( params.Nbitspersymbol == 6)
    params.term_bits  =[1 0 1 0  1 1];
end


if ( params.pilot.en ~= 0 )
    params.cpr.CPEtype = 5;
    if ( params.Nbitspersymbol  ==2  )
        params.cpr.fCPEtype = 1;  % 4-th Viterbi 
    else
        params.cpr.fCPEtype = 4;  % BPS 
    end
    params.cpr.BLK = params.block_size ; 
    params.cpr.PCtype = 2; % 2: Smoothing, 3:Linear fitting
    params.cpr.PCtype2 = 2;
    params.cpr.STEP  = params.cpr.BLK * 2;   
    params.cpr.fBLK = params.cpr.BLK; 
    params.cpr.fSTEP  = params.cpr.BLK * 2;   
    params.cpr.fPCtype = 1; % 2: Smoothing, 3:Linear fitting
    params.cpr.smoothing  = 2 ;  
    params.cpr.BPS_range =1;
    params.cpr1 = params.cpr;
end 
 
if ( params.pilot.en == 4 && params.RXDSP_PTBC == 1)
%     if (params.RXDSP_PTBC == 1 ) 
        params.cpr.CPEtype = 6;
%     else
%         params.cpr.CPEtype = 8;
%     end  
    params.cpr.BLK = params.block_size ;
    params.cpr.PCtype = 1; % 2: Smoothing, 3:Linear fitting
    params.cpr.PCtype2 = 1;
    params.cpr.STEP  = params.block_size * 2   ;
    params.cpr.fBLK = params.cpr.BLK;
    params.cpr.fSTEP  = params.cpr.BLK ;
    params.cpr.fPCtype = 1; % 2: Smoothing, 3:Linear fitting
    params.cpr.smoothing  = 2 ;

end

%%
% params.dfe.is_training_seq_init= 1; 
% params.dfe.update_type =1;
params.rxpostemp.en = 0;

if ( sim_case  == 1);
    params.TXMatchedfilter.en = 0;
    params.RXMatchedfilter.en = 0;
end 
if ( sim_case  == 33 || sim_case  == 34 || sim_case  == 35 ) 
    if ( params.dfe.skewcomp_en == 0 ) 
        params.RXStructure = 0;
        params.dfe1.en  = 1;   
        params.dfe.is_training_seq_init = 1;   
        params.cpr.PCtype = 1; 
    end
    if ( params.dfe.skewcomp_en == 1)    
        params.RXStructure = 0;
        params.dfe1.en  = 1;   
        params.dfe.is_training_seq_init = 1;  
        params.cpr.PCtype = 1;    
        params.dfe.type = 9;
        params.dfe.betaf = 5e-3;
    end
    if ( params.dfe.skewcomp_en == 2) 
        params.RXStructure = 2;
%         params.dfe1.en  = 1;   
%         params.dfe.is_training_seq_init = 1;   
%         params.cpr.PCtype = 1; 
    end
end
if ( sim_case  == 36 || sim_case  == 37  )   
    params.RXStructure = 2;
    params.dfe1.en  = 1;   
    params.dfe.is_training_seq_init = 1;  
    params.dfe.skewcomp_en  = 2;
    params.dfe1.skewcomp_en  = 2;
    params.dfe1.type  = 10;
    params.dfe1.is_training_seq_init = 1;  
    params.cpr.PCtype = 1;     
    params.dfe.Nffe = 32;
    params.dfe1.Nffe = 32;
end


%% Baud rate increase due to FEC 
GHz = 1e9;
params.BaudFreq = 32.78*GHz;

params.TXSampleFreq = params.BaudFreq * 2; 
params.RXSampleFreq = params.BaudFreq * 2; 
params.OSCFreq  = params.RXSampleFreq ;
params.AWGSampleFreq  = params.TXSampleFreq ;
end
