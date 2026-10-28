function [sims, params] = DefaultSet( testvector  )  

%  Usage      :[sims, params] = DefaultSet(  )  
%
%  Function   :
%     
%
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

%% Initialization, Setup 


global SW_PATH
global DSP_PATH
run( [ 'Units.m']);

if ( exist('sims') == 0) 
[sims, params]=  Init (    );        
load ([SW_PATH 'RunDir/savedState.mat']);
else
[sims, params]=  Init ( sims, params  );
end

defaultStream = RandStream.getGlobalStream;
defaultStream.State = savedState;
%%
sims.show_constellation = 1;
sims.show_ber  =1;
sims.show_cpr  = 1;
sims.show_tpr  = 1;
sims.show_dfe  = 1;
sims.show_dfe1 = 1;
sims.show_sync = 1;
sims.show_psd  = 0;
sims.show_skew = 1;
sims.mode      = 0;  % 0: No sweep, 1:SNR, 2: TX bandwidth  4:CFO 6:SFO 8: RX Linewidth 9:ETC  , 13:Roll off factor 
sims.X_coor    =  0;%[0.1:0.1:0.9 ];  
sims.Ylabel    = 'EVM '; 
sims.run_mode    = 0;
sims.max_num_sim = 10;

params.AWGSampleFreq =120*GHz;
params.OSCFreq=256*GHz;
params.NTrainingSymbol   = 4096-128-64;
params.NSignalSymbol     = 64;
params.NDataSymbol       = 85760;
params.NFrames           = 10;
params.frame_number      = 1;
sims.dataf.data_file            = [DSP_PATH 'Ptn/prbs23.txt'];

params.signal.en    = 2;  
params.signal.n     = 62;
params.signal.k     = 35;
params.stbc.en   = 0 ;       
params.stbc.L =  0;
params.stbc.tau_frac = 0 ;
params.stbc.K1            = -1e-3 * 50 ;
params.stbc.K2            = -1e-4  * 1  ;
params.stbc.TPEtype   =  1;
params.stbc.rx_in_org = 2;  
params.stbc.Nffe =  17;
params.stbc.PRL    = 128 ;
params.stbc.betaf  = 0.5e-3; 
params.stbc.betab  = 0;
params.stbc.betab2 = 0 ;
params.stbc.is_training_seq_init = 1;
params.RXDSP_PTBC  = 0 ;

% if ( params.PTBC == 0 )
% 
%     params.BaudFreq=14.8*GHz;
%     params.NDataSymbol       = 85760 * 2;
% 
%     params.Nbitspersymbol = 4;
%     params.NTXStream         = 2;
%     params.NRXStream         = 2;
%     params.tpr.settling_time   = 1600 * 1;
%     params.totalbits = 524272;
%     params.en_block_termination   = 1 ;% Add QPSK pilot symbols
%     %% TX DSP
%     params.txpreemp.en  = 0;
%     params.TXMatchedfilter.en =1;
%     params.TXMatchedfilter.alpha = 0.1;
%     %% RX DSP
%     params.RXMatchedfilter.en = 1;
%     %params.RXMatchedfilter.alpha = 0.4;
%     params.AGC.en = 1;
%     params.AGC.avg_out = 0.25 ;
%     params.searchframe.en = 1;
%     params.searchfineframe.en = 1;
%     params.tpr.cal_init_tpr = 1;
%     params.tpr.K1            = -1e-3  ;   %  Propotional coefficient of loopfilter
%     params.tpr.K2            = -1e-5 * 0   ;   %  Integral coefficient of loopfilter
%     params.tpr.L= 9;
%     params.dfe.is_training_seq_init =  0;
%     params.dfe.betaf          =  3.0000e-03 ;
%     params.dfe.type = 4;
%     if ( params.Nbitspersymbol  ==2  )
%         params.dfe.type = 2;
%     end
%     params.dfe.betab          = 0;
%     params.dfe.PRL =128;
%     params.dfe.Nfbe = 0;
%     params.dfe.Nffe = 15;
%     params.dfe.update_type =2;
%     
%     params.dfe1.en  = 0;
%     params.cfr.en    = 1;
%     params.cfr.CFEtype  = 5 ;
%     
%     params.Nbitspersymbol = 4;
%     params.NTXStream         = 2;
%     params.NRXStream         = 2;
%     params.tpr.settling_time   = 1600 * 1;
%     params.totalbits = 524272;
%     params.en_block_termination   = 4 ;% Add QPSK pilot symbols
%     %% TX DSP
%     params.txpreemp.en  = 0;
%     params.TXMatchedfilter.en =1;
%     params.TXMatchedfilter.alpha = 0.1;
%     %% RX DSP
%     params.channel_learning = 0;
%     params.RXMatchedfilter.en = 1;
%     %params.RXMatchedfilter.alpha = 0.4;
%     params.AGC.en = 1;
%     params.AGC.avg_out = 0.25 ;
%     params.searchframe.en = 1;
%     params.searchfineframe.en = 1;
%     params.tpr.cal_init_tpr = 1;
%     params.tpr.K1            = -1e-2  ;   %  Propotional coefficient of loopfilter
%     params.tpr.K2            = -1e-5   ;   %  Integral coefficient of loopfilter
%     params.tpr.L= 9;
%     params.dfe.is_training_seq_init =  0;
%     params.dfe.betaf          =  3.0000e-03 ;
%     params.dfe.type = 4;
%     if ( params.Nbitspersymbol  ==2  )
%         params.dfe.type = 2;
%     end
%     params.dfe.betab          = 0;
%     params.dfe.PRL =128;
%     params.dfe.Nfbe = 0;
%     params.dfe.Nffe = 15;
%     params.dfe.update_type =2;
%     
%     params.dfe1.en  = 0;
%     params.cfr.en    = 1;
%     params.cfr.CFEtype  = 5 ;
% 
%     
%     
%     %% Pilot based
%     params.pilot.en = 1;
%     params.pilot.Nbitspersymbol = 2;
%     if ( params.Nbitspersymbol == 4)
%         params.term_bits  =[1 0 1 0 ];
%     end
%     if ( params.pilot.en == 1 )
%         params.cpr.CPEtype =5;
%         if ( params.Nbitspersymbol  ==2  )
%             params.cpr.fCPEtype = 1;
%         else
%             params.cpr.fCPEtype = 4;
%         end
%         params.cpr.BLK = params.block_size ;
%         params.cpr.PCtype = 2; % 2: Smoothing, 3:Linear fitting
%         params.cpr.PCtype2 = 2;
%         params.cpr.STEP  = params.cpr.BLK ;
%         params.cpr.fBLK = params.cpr.BLK;
%         params.cpr.fSTEP  = params.cpr.BLK ;
%         params.cpr.fPCtype = 1; % 2: Smoothing, 3:Linear fitting
%         params.cpr.smoothing  = 2 ;
%     end
%     %%
%     
%     params.dfe.is_training_seq_init= 1;
%     params.dfe.update_type =1;
%     
%     params.rxpostemp.en = 0;
% else
%     params.NTrainingSymbol   = 4096-128-64;
%     params.NDataSymbol       = 85760;
%     params.NSymbol           = params.NTrainingSymbol + params.NDataSymbol; 
%     params.BaudFreq=30*GHz; 
%     params.Nbitspersymbol = 4;
%     params.NTXStream         = 1;
%     params.NRXStream         = 1;
%     params.tpr.settling_time   = 1600 * 4;
%     params.totalbits = 524272; 
%     params.pilot.en   = 4 ;     
%     params.pilot.Nbitspersymbol = 2;
%     params.stbc.en   = 1 ;
%     params.en_block_termination   = 4 ;% Add QPSK pilot symbols
%     %% TX DSP
%     params.txpreemp.en  = 0;
%     params.TXMatchedfilter.en =1;
%     params.TXMatchedfilter.alpha = 0.3;
% 
%     %% RX DSP 
%     params.channel_learning = 0;
%     params.RXMatchedfilter.en = 1;
%     params.RXMatchedfilter.alpha = 0.3;
%     params.AGC.en = 1;
%     params.AGC.avg_out = 0.5 ;
%     
% %     params.OFDE.freq_resp =zeros(1,32);
%     params.rxpostemp.en = 0;
%     
%     params.searchframe.en = 1;
%     params.searchfineframe.en = 1;
%     params.searchfineframe.type = 3;
%     params.tpr.cal_init_tpr = 0;
%     params.tpr.K1            =  -0.75*1e-3;  %  Propotional coefficient of loopfilter
%     params.tpr.K2            = -1e-3 * 0  ;   %  Integral coefficient of loopfilter
%     params.tpr.L=  5;
%     params.tpr.settling_time   = 128000;    
%     
%     
%     params.cfr.en    = 1;
%     params.cfr.CFEtype  = 5 ;
%     
%     params.cpr.en    = 1;
%     params.cpr.CPEtype = 6;
%     params.cpr.PCtype = 1; 
%     
%     
%     params.dfe.is_training_seq_init =  1;
%     params.dfe.betaf          =  3.0000e-03 ;
%     params.dfe.type = 4; 
%     if ( params.Nbitspersymbol  ==2  )
%         params.dfe.type = 2;
%     end
%     params.dfe.betab          = 0;
%     params.dfe.PRL =128;
%     params.dfe1.en  = 0;
%     
%     
%     %% Pilot based
% 
%     if ( params.Nbitspersymbol == 4)
%         params.term_bits  =[1 0 1 0 ];
%     end
%     if ( params.pilot.en == 1 )
%         params.cpr.CPEtype =5;
%         if ( params.Nbitspersymbol  ==2  )
%             params.cpr.fCPEtype = 1;
%         else
%             params.cpr.fCPEtype = 4;
%         end
%         params.cpr.BLK = params.block_size ;
%         params.cpr.PCtype = 1; % 2: Smoothing, 3:Linear fitting
%         params.cpr.PCtype2 = 1;
%         params.cpr.STEP  = params.cpr.BLK * 2;
%         params.cpr.fBLK = params.cpr.BLK;
%         params.cpr.fSTEP  = params.cpr.BLK ;
%         params.cpr.fPCtype = 1; % 2: Smoothing, 3:Linear fitting
%         params.cpr.smoothing  = 2 ;
%     end
% 
%     if ( params.pilot.en == 4 )
%         params.cpr.CPEtype =6; 
%         params.cpr.BLK = params.block_size ; 
%         params.cpr.PCtype = 1; % 2: Smoothing, 3:Linear fitting
%         params.cpr.PCtype2 = 1;
%         params.cpr.STEP  = params.block_size * 4   ;   
%         params.cpr.fBLK = params.cpr.BLK; 
%         params.cpr.fSTEP  = params.cpr.BLK ;   
%         params.cpr.fPCtype = 1; % 2: Smoothing, 3:Linear fitting
%         params.cpr.smoothing  = 2 ;  
% 
%     end 
    sim_case=1;
[params]=  SetParams( sim_case, params);
    
    global FIXED_ARCHITECTURE;
    if ( FIXED_ARCHITECTURE == 1)
        params.TXMatchedfilter.resp_sample =3;
        params.RXMatchedfilter.en = 1;
        params.fixed_type = 1;
        params.OFDE.freq_resp =zeros(1,32); 
        params.searchfineframe.cor_length = 192;
        params.tpr.K1=-0.5e-3;
        params.stbc.rx_in_org = 6;
        params.stbc.betaf = 0.6e-3;
        params.stbc.rx_in_org =6;
        params.stbc.Nffe = 5;
        params.stbc.BPS_range =0.4;
        params.stbc.BPS_step  = 4;
        params.stbc.BPS_window = 16 ;
    end
    
    if ( params.stbc.en == 1 )
        sims.show_dfe1 = 0;
        sims.show_stbc = 1;
    end
% end


ps  = 1e-12;
skew_ps(1) =   0 * 1j * ps;
skew_ps(2) =   0   * ps + 1j * (  0  * ps); 
txskew_ps(1) =   0 * 1j * ps;
txskew_ps(2) =   0   * ps + 1j * (  0  * ps); 
params.skew.skew_ps  = skew_ps;
params.txskew.skew_ps  = txskew_ps;

sims.signal_fail_cnt = 0; 
sims.hamming_corr_cnt= 0; 
sims.Totframe        = 0; 
if ( testvector == 1) % Unified version    
    params.dfe.skewcomp_en = 0;
    %% Unified DSP parameters :Coarse CPR parameter 
    params.cpr.PCtype =2;
    params.cpr.PCtype2 =1;
    params.cpr.CPEtype = 5; % Cross correlation
    params.cpr.STEP =64;
    % params.cpr.CPEtype = 6; % Auto correation, constant interval
    params.cpr.CPEtype = 8; %Auto correlation with fixed reference  
    params.cpr.STEP = 128;% params.cpr.BLK * params.cpr.period;
    %% Unified DSP parameters :Equalizer
    params.dfe.type =1;
    % params.dfe.betaf =1e-3;
    % params.dfe.update_rate_training =7;
    params.dfe.cost_function =1;
    %% Unified DSP parameters :Fine CPR parameter 
    params.cpr1.BLK = 32;
    params.cpr1.PCtype =0;
    params.cpr1.PCtype2 =1;
    if ( params.RXDSP_PTBC == 0 )
        % Dual Pol
        params.cpr1.CPEtype = 4; 
        params.cpr1.BPS_step = 8;
        params.cpr1.BPS_range = 1/2;
        params.cpr1.STEP = 32;
    else
        % PTBC 
        params.cpr1.CPEtype = 7; 
        params.cpr1.BPS_step = 8;
        params.cpr1.BPS_range = 0.5;
        params.cpr1.STEP = 32;
    end 

end 
[sims, params]=  ReInit ( sims, params  ); 
    
end
