%% Initialization, Setup 
global SW_PATH
run( ['Units.m']);

if ( exist('sims') == 0) 
    [sims, params]=  Init (    );        
else
    [sims, params]=  Init ( sims, params  );
end

load ([SW_PATH 'RunDir/savedState.mat']);
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
sims.mode      = 0;  
sims.X_coor    = [0];
sims.Ylabel    = 'EVM '; 
sims.max_num_sim            = 5;
sims.en_disp_result            = 1; 
sims.dataf.data_file            = [DSP_PATH 'Ptn/prbs31.txt'];
sims.dataf.data_file            = [DSP_PATH 'Ptn/prbs23.txt'];
%%
params.Nbitspersymbol = 4;
params.NTXStream         = 2;
params.NRXStream         = 2;
params.tpr.settling_time   = 1600 * 4;
params.totalbits = 524272;
params.en_block_termination   = 2 ;% Add QPSK pilot symbols
params.fec.en =0;
params.fec.FEC_mode = 1;  
%% TX DSP
params.txpreemp.en  = 0;
params.TXMatchedfilter.en =1;
params.TXMatchedfilter.alpha = 0.1;
%% RX DSP
params.RXMatchedfilter.en = 1;
%params.RXMatchedfilter.alpha = 0.4;
params.AGC.en = 1;
params.AGC.avg_out = 0.5;     
params.searchframe.en = 1;
params.searchfineframe.en = 1;
params.tpr.cal_init_tpr = 1;
params.tpr.K1            = -1e-2  ;   %  Propotional coefficient of loopfilter
params.tpr.K2            = -1e-5   ;   %  Integral coefficient of loopfilter
params.tpr.L= 9;
params.dfe.is_training_seq_init =  1;
params.dfe.betaf          =  3.0000e-03 ;
params.dfe.type = 4; 
if ( params.Nbitspersymbol  ==2  )
    params.dfe.type = 2;
end
params.dfe.betab          = 0;
params.dfe.PRL =128;
params.dfe.Nfbe = 0;
params.dfe.Nffe = 15;
params.dfe.update_type =1; 

params.dfe1.en  = 0;
params.cfr.en    = 1;
params.cfr.CFEtype  = 5 ;
params.dfe.skewcomp_en = skewcomp_en;
params.OFDE.freq_resp = ones( 1, 128);
%% Pilot based
params.pilot.en = 1;
params.pilot.Nbitspersymbol =params.Nbitspersymbol;
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
    params.cpr.CPEtype =5;
    if ( params.Nbitspersymbol  ==2  )
        params.cpr.fCPEtype = 1;
    else
        params.cpr.fCPEtype = 4;
    end
    params.cpr.BLK = params.block_size ; 
    params.cpr.PCtype = 2; % 2: Smoothing, 3:Linear fitting
    params.cpr.PCtype2 = 2;
    params.cpr.STEP  = params.cpr.BLK ;   
    params.cpr.fBLK = params.cpr.BLK; 
    params.cpr.fSTEP  = 8;% params.cpr.BLK ;   
    params.cpr.fPCtype = 1; % 2: Smoothing, 3:Linear fitting
    params.cpr.smoothing  = 2 ;  
end 
 
%%
% params.dfe.is_training_seq_init= 1; 
% params.dfe.update_type =1;
params.rxpostemp.en = 0;

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


%% Channel
sims.ROP_cal = 0;
sims.channel.MZmod.launch_power =  5*mW;
sims.channel.CarrierFreqOff   = 0*500*MHz ; 
sims.channel.TimeFreqOff      = 0*10*ppm;
sims.channel.TimePhaseOff     = 0 * -0.5; 
sims.channel.Jitter           = 0.0*ps; 
% sims.channel.AGC.avg_out      = 0.6;
sims.channel.enAWGN           = 1;
sims.channel.TXLineWidth      = 0 * 500 * kHz;
sims.channel.RXLineWidth      = 0 * 500 * kHz;

if ( params.Nbitspersymbol == 2 && params.NTXStream == 1)
params.AWGSampleFreq = 72 *GHz;
sims.channel.TXDAC.bandwidth  = 35.5*GHz;
else 
params.AWGSampleFreq = 36 *GHz;
sims.channel.TXDAC.bandwidth  = 17*GHz;
end
sims.channel.TXDAC.bandwidth_en = 0;
sims.channel.TXDAC.ENob  = 4;
sims.channel.TXDAC.T.wordl = 0;
sims.channel.TXDAC.T.fracl = 4;
sims.channel.RFDriver.gain_dB =  2;
sims.channel.RFDriver.bandwidth_en =  0;
sims.channel.MZmod.bandwidth_en = 0;
if ( params.Nbitspersymbol == 2 && params.NTXStream == 1)
sims.channel.MZmod.bandwidth  = 35*GHz;
else
sims.channel.MZmod.bandwidth  = 20*GHz;
end
sims.channel.PD.bandwidth_en  = 0;
sims.channel.PD.bandwidth  = 42*GHz;
%sims.channel.PD.noise_power_dBm =  -30;
sims.channel.RXADC.bandwidth_en  = 0;
if ( params.Nbitspersymbol == 2 && params.NTXStream == 1)
params.OSCFreq  = 68*GHz;
sims.channel.RXADC.bandwidth  = 33.5*GHz;
else
params.OSCFreq  = 28*GHz;
sims.channel.RXADC.bandwidth  = 13.5*GHz;
sims.channel.RXADC.bandwidth_en  = 0;
end
sims.channel.RXADC.ENob  = 4;
sims.channel.RXADC.T.wordl = 0;
sims.channel.RXADC.T.fracl = 4;

sims.channel.fiber_length     = 0 *km;
sims.channel.ssmf.power_split2 = 0.35;
sims.channel.PMD = 0 * 2*ps;
sims.channel.iqimb.gainim = zeros(2,1) * (db2mag(1) - 1); % 1 dB
sims.channel.iqimb.phaseim = zeros(2,1) * 2.5; %  2.5degree
sims.channel.iqimb.iqskew =zeros(2,1) *  0.75*ps;
%% Baud rate increase due to FEC 
params.BaudFreq = 100*GHz / (params.Nbitspersymbol)/params.NTXStream;
% params.fec.FEC_mode = 0;
switch  params.fec.FEC_mode
    case 0
        params.BaudFreq = params.BaudFreq  * 1432/1288; 
    case 1
        params.BaudFreq = params.BaudFreq  * 1432/1288; 
    case 4
        params.BaudFreq = params.BaudFreq  * 544/514; 
    case 5
        params.BaudFreq = params.BaudFreq  * 528/514; 
    case 6
        params.BaudFreq = params.BaudFreq  * 1.15;
    otherwise
        params.BaudFreq = params.BaudFreq;
end
if ( params.pilot.en ~= 0 )
    params.BaudFreq = params.BaudFreq * params.pilot.rate;
end
params.TXSampleFreq = params.BaudFreq * 2; 
params.RXSampleFreq = params.BaudFreq * 2; 
params.OSCFreq  = params.RXSampleFreq ;
params.AWGSampleFreq  = params.TXSampleFreq ;

sims.channel.SNRdB = 17.2424;
sims.channel.SNRdB = 15;
sims.channel.TXDAC.nonoise =1; 
sims.channel.RXADC.nonoise =1; 
%%
if ( sim_case  == 1);
    params.TXMatchedfilter.en = 0;
    params.RXMatchedfilter.en = 0;
%     params.TXMatchedfilter.alpha = 0.5;
%     params.RXMatchedfilter.alpha = 0.5;
    sims.channel.RFDriver.nonoise = 1;
    sims.channel.PD.nonoise = 1;
    sims.channel.RFAmp.nonoise =1;
    sims.channel.TXDAC.nonoise =1; 
    sims.channel.RXADC.nonoise =1; 
    params.tpr.en=0;
    params.cfr.en= 0;
    params.cpr.en= 0;
end
%%
if ( sim_case  == 2) 
%     params.TXMatchedfilter.en = 0;
%     params.RXMatchedfilter.en = 0;
    sims.channel.RFDriver.nonoise = 1;
    sims.channel.PD.nonoise = 1;
    sims.channel.RFAmp.nonoise =1; 
    sims.channel.TXDAC.nonoise =1; 
    sims.channel.RXADC.nonoise =1;  
    sims.channel.SNRdB = 16;
end

%%

if ( sim_case  == 3)    
    sims.channel.PD.NF_dB = 0;
    sims.channel.TXDAC.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.SNRdB = 14.75 + 0.5 ;
    sims.channel.RFDriver.nonoise = 1;
    sims.channel.PD.nonoise = 1;
    sims.channel.RFAmp.nonoise =1; 
    sims.channel.TXDAC.nonoise =1; 
    sims.channel.RXADC.nonoise =1; 
end 
if ( sim_case  == 4)    
    sims.channel.PD.NF_dB = 0;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 7.84 * GHz;
    sims.channel.SNRdB = 14.85 + 0.5  ;
    sims.channel.RFDriver.nonoise = 1;
    sims.channel.PD.nonoise = 1;
    sims.channel.RFAmp.nonoise =1; 
    sims.channel.TXDAC.nonoise =1; 
    sims.channel.RXADC.nonoise =1; 
end 
if ( sim_case  == 5)        
    sims.channel.PD.NF_dB = 0;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 7.84 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.SNRdB = 14.93 + 0.5  ;
    sims.channel.RFDriver.nonoise = 1;
    sims.channel.PD.nonoise = 1;
    sims.channel.RFAmp.nonoise =1; 
    sims.channel.TXDAC.nonoise =1; 
    sims.channel.RXADC.nonoise =1;  
end
if ( sim_case  == 6)      
    sims.channel.PD.NF_dB = 0;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 7.84 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 2 * 1.1 * 9.1* GHz;
    sims.channel.SNRdB = 16.2  ;
    sims.channel.RFDriver.nonoise = 1;
    sims.channel.PD.nonoise = 1;
    sims.channel.RFAmp.nonoise =1; 
    sims.channel.TXDAC.nonoise =1; 
    sims.channel.RXADC.nonoise =1;  
end
%%
if ( sim_case  == 7)            
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 7.84 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 2 * 1.1 * 9.1* GHz;
    sims.channel.SNRdB = 16.2  ;
end
%%
if ( sim_case  == 8)            
    sims.channel.PD.NF_dB = 0;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 7.84 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 2 * 1.1 * 9.1* GHz;
    sims.channel.SNRdB = 15.34 + 0.5  ; 
    sims.channel.SNRdB = 16.2  ;
end
%%

if ( sim_case  == 9)             % IQ gain   
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 7.84 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 2 * 1.1 * 9.1* GHz;
    sims.channel.SNRdB = 16.7  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(IQGain) - 1); % 1 dB
end
 
if ( sim_case  == 10)            % IQ phase imbalance 
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 7.84 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 2 * 1.1 * 9.1* GHz;
    sims.channel.SNRdB = 15.34 + 0.5  ; 
    sims.channel.SNRdB = 17   ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * IQPhase; %  5 degre
end
 
 
if ( sim_case  == 11)            % IQ skew
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 7.84 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 2 * 1.1 * 9.1* GHz;
    sims.channel.SNRdB = 15.34 + 0.5  ; 
    sims.channel.SNRdB = 17  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) * IQSkew *ps;
end
 
 
 
if ( sim_case  == 12 )            %  Phase noise
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 7.84 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 2 * 1.1 * 9.1* GHz;
    sims.channel.SNRdB = 15.61  ; 
    sims.channel.SNRdB = 17.6  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = PhaseNoise *   MHz;
    sims.channel.RXLineWidth      = PhaseNoise *   MHz;
end
 
if ( sim_case  == 13 )            %  CFO
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 7.84 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 2 * 1.1 * 9.1* GHz;
    sims.channel.SNRdB = 16.0 + 0.5  ; 
    sims.channel.SNRdB = 18  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      =  0 * 1 *   MHz;
    sims.channel.RXLineWidth      =  0 *1 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz ; 
end
 
%%

if ( sim_case  == 14 )            %  CFO
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 0;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 7.84 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 2 * 1.1 * 9.1* GHz;
    sims.channel.SNRdB = 16 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 1 *   MHz;
    sims.channel.RXLineWidth      = 1 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz ; 
end

if ( sim_case  == 15 )            %  CFO
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 0; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth =  1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth =   1.1 * 7.84 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 2 * 1.1 * 9.1* GHz;
    sims.channel.SNRdB = 16 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 1 *   MHz;
    sims.channel.RXLineWidth      = 1 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz ; 
end

if ( sim_case  == 16 )            %  CFO
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 0; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 7.84 * GHz;
    sims.channel.MZmod.bandwidth =    1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 2 * 1.1 * 9.1* GHz;
    sims.channel.SNRdB = 16 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 1 *   MHz;
    sims.channel.RXLineWidth      = 1 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz ; 
end

if ( sim_case  == 17 )            %  CFO
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 0; 
    sims.channel.TXDAC.bandwidth =  1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 7.84 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 2 * 1.1 * 9.1* GHz;
    sims.channel.SNRdB = 16 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 1 *   MHz;
    sims.channel.RXLineWidth      = 1 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz ; 
end
%%

if ( sim_case  == 18 )            %  CFO
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 11.5 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 1.1 * 9.1* GHz;
    sims.channel.SNRdB = 16 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 1 *   MHz;
    sims.channel.RXLineWidth      = 1 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz ; 
end

%%
if ( sim_case  == 19 )            %  CFO
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 11.5 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 1.1 * 11 * GHz;
    sims.channel.SNRdB = 17.6  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 1 *   MHz;
    sims.channel.RXLineWidth      = 1 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz ; 
end
%%
if ( sim_case  == 20 )            %  SFO 
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 11.5 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 1.1 * 11 * GHz;
    sims.channel.SNRdB = 17.6  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 1 *   MHz;
    sims.channel.RXLineWidth      = 1 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz ; 
    sims.channel.TimeFreqOff      =  20*ppm;
end
  

if ( sim_case  == 21 )            %  Jitter 
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 11.5 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 1.1 * 11 * GHz;
    sims.channel.SNRdB = 17.6  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 1 *   MHz;
    sims.channel.RXLineWidth      = 1 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz ; 
    sims.channel.TimeFreqOff      =  20*ppm;    
    sims.channel.Jitter           = 0.65*ps; 
end
  

if ( sim_case  == 22)            %  Fiber length 20km
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 11.5 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 1.1 * 11 * GHz;
    sims.channel.SNRdB = 17.6  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 1 *   MHz;
    sims.channel.RXLineWidth      = 1 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz ; 
    sims.channel.TimeFreqOff      =  20*ppm;
    sims.channel.fiber_length     = 20 *km;
    sims.channel.Jitter           = 0.65*ps; 
    sims.channel.RFDriver.nonoise = 1;
    sims.channel.PD.nonoise = 1;
    sims.channel.RFAmp.nonoise =1;
    sims.channel.TXDAC.nonoise =1; 
    sims.channel.RXADC.nonoise =1; 
%     sims.channel.MZmod.launch_power =  7*mW;
end


if ( sim_case  == 23 )            %  PMD
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 11.5 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 1.1 * 11 * GHz;
    sims.channel.SNRdB = 17.6  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 1 *   MHz;
    sims.channel.RXLineWidth      = 1 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz ; 
    sims.channel.TimeFreqOff      =  20*ppm;
    sims.channel.fiber_length     = 20 *km;
%     sims.channel.MZmod.launch_power =  7*mW;
    sims.channel.Jitter           = 0.65*ps; 
    sims.channel.PMD = PMD *ps;
end

if ( sim_case  == 24 )            %  DAC
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 11.5 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 1.1 * 11 * GHz;
    sims.channel.SNRdB = 18.4 ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 1 *   MHz;
    sims.channel.RXLineWidth      = 1 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz ; 
    sims.channel.TimeFreqOff      =  20*ppm;
    sims.channel.fiber_length     = 20 *km;
%     sims.channel.MZmod.launch_power =  7*mW;
    sims.channel.Jitter           = 0.65*ps; 
    sims.channel.PMD = 7 *ps;
    sims.channel.TXDAC.nonoise =0; 
    sims.channel.TXDAC.T.wordl =6; 
    sims.channel.TXDAC.ENob = ENob;
end
if ( sim_case  == 25 )            %  ADC
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 11.5 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 1.1 * 11 * GHz;
    sims.channel.SNRdB = 19 ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 1 *   MHz;
    sims.channel.RXLineWidth      = 1 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz ; 
    sims.channel.TimeFreqOff      =  20*ppm;
    sims.channel.fiber_length     = 20 *km;
%     sims.channel.MZmod.launch_power =  7*mW;
    sims.channel.Jitter           = 0.65*ps; 
    sims.channel.PMD = 7 *ps;
    sims.channel.TXDAC.nonoise =0; 
    sims.channel.TXDAC.T.wordl =6; 
    sims.channel.RXADC.nonoise =0; 
    sims.channel.RXADC.T.wordl =6; 
    sims.channel.RXADC.ENob = ENob;
end

if ( sim_case  == 26 )            %  All impairment, no AWGN      
    sims.channel.enAWGN           = 0;
    sims.channel.RFDriver.nonoise = 1;
    sims.channel.PD.nonoise = 1;
    sims.channel.RFAmp.nonoise =1;
    sims.channel.TXDAC.nonoise =1; 
    sims.channel.RXADC.nonoise =1; 
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 11.5 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 1.1 * 11 * GHz;
    sims.channel.SNRdB = 25  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 1 *   MHz;
    sims.channel.RXLineWidth      = 1 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz ; 
    sims.channel.TimeFreqOff      =  20*ppm;
    sims.channel.fiber_length     = 20 *km; 
    sims.channel.Jitter           = 0.65*ps; 
    sims.channel.PMD = 7 *ps;
    sims.channel.TXDAC.nonoise =0; 
    sims.channel.TXDAC.T.wordl =6; 
    sims.channel.RXADC.nonoise =0; 
    sims.channel.RXADC.T.wordl =6; 
    params.cpr.fBLK = 16;
    params.cpr.fSTEP = 16;
    params.dfe.betaf = 0.006;
end
if ( sim_case  == 27 )            %  PMD
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 11.5 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 1.1 * 11 * GHz;
    sims.channel.SNRdB = 25  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 1 *   MHz;
    sims.channel.RXLineWidth      = 1 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz ; 
    sims.channel.TimeFreqOff      =  20*ppm;
    sims.channel.fiber_length     = 20 *km;
%     sims.channel.MZmod.launch_power =  7*mW;
    sims.channel.Jitter           = 0.65*ps; 
    sims.channel.PMD = 7 *ps;
    sims.channel.TXDAC.nonoise =0; 
    sims.channel.TXDAC.T.wordl =6; 
    sims.channel.RXADC.nonoise =0; 
    sims.channel.RXADC.T.wordl =6; 
    params.cpr.fBLK = 16;
    params.cpr.fSTEP = 16;
    params.dfe.betaf = 0.006;
end
%%

if ( sim_case  == 30) 
    sims.channel.RFDriver.nonoise = 1;
%     sims.channel.PD.nonoise = 1;
    sims.channel.RFAmp.nonoise =1; 
    sims.channel.TXDAC.nonoise =1; 
    sims.channel.RXADC.nonoise =1; 
    sims.channel.MZmod.launch_power =  5 *mW;
    sims.channel.fiber_length     = 0 *km;
end
%%
if ( sim_case  == 31) 
    sims.channel.RFDriver.nonoise = 1;
%     sims.channel.PD.nonoise = 1;
    sims.channel.RFAmp.nonoise =1; 
    sims.channel.TXDAC.nonoise =1; 
    sims.channel.RXADC.nonoise =1; 
    sims.channel.MZmod.launch_power =  5*mW;
    sims.channel.fiber_length     = 20 *km;
end
%%
if ( sim_case  == 32) 
    sims.channel.RFDriver.nonoise = 1;
%     sims.channel.PD.nonoise = 1;
    sims.channel.RFAmp.nonoise =1; 
    sims.channel.TXDAC.nonoise =1; 
    sims.channel.RXADC.nonoise =1; 
    sims.channel.MZmod.launch_power =  8*mW;
    sims.channel.fiber_length     = 80 *km;
end
%%
if ( sim_case  == 33 || sim_case  == 34 || sim_case  == 35 ) 
    sims.channel.RFDriver.nonoise = 1;
    sims.channel.PD.nonoise = 1;
    sims.channel.RFAmp.nonoise =1; 
    params.rxpostemp.en = 0;
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(IQGain) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * IQPhase; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  IQSkew *ps;
end
if ( sim_case  == 36 )            %  IQ Skew 
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 1.1 * 7.55 * GHz;
    sims.channel.RXADC.bandwidth = 1.1 * 11.5 * GHz;
    sims.channel.MZmod.bandwidth = 1.1 * 7.975* GHz;
    sims.channel.PD.bandwidth = 1.1 * 11 * GHz;
    sims.channel.SNRdB = 19 ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  IQSkew *ps;
    sims.channel.txiqimb.iqskew =ones(2,1) * TXIQSkew *ps;
    sims.channel.TXLineWidth      =     1 *   MHz;
    sims.channel.RXLineWidth      =     1 *   MHz;
    sims.channel.CarrierFreqOff   =   1800*MHz ; 
    sims.channel.TimeFreqOff      =  20*ppm;
    sims.channel.fiber_length     = 20 *km;
    sims.channel.Jitter           = 0.65*ps; 
    sims.channel.PMD = 7 *ps;
    sims.channel.TXDAC.nonoise =0; 
    sims.channel.TXDAC.T.wordl =6; 
    sims.channel.RXADC.nonoise =0; 
    sims.channel.RXADC.T.wordl =6; 
end

%% Baud Rate fixed (flow1)
sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
%%
sims.mode      = mode;
sims.X_coor    = X_coor;
channel.RFAmp.gain_dB=0;
if ( sims.mode == 51 )
    sims.channel.PD.nonoise = 1;
    sims.channel.enAWGN  =1;
else 
    sims.channel.PD.nonoise = 0;
    sims.channel.enAWGN  =0;
end
%%
[sims, params]=  ReInit ( sims, params  );  

if ( sim_case  == 36 )    
    params.dfe.training_seq_size = params.NSymbol;
    params.dfe1.training_seq_size = params.NSymbol;
end
%% Main body 
[channelin, txsignal] = TxTop( sims, params);

% dataf     = DataGen( sims.dataf, params.totalbits, 0 );
% [txout, txsignal] = TxMain( dataf, sims, params) ;
% txout_ext         = [txout(:,end-params.tpr.settling_time*2+1:end) txout txout(:,1:2000)  ]; 
% if ( params.NTXStream   == 1 )
%     txout_ext1 =txout_ext;
%     txout_ext = [txout_ext1(:,3:end); txout_ext(:,1:end-2) ;];
% end
% [txout_awg]    = Resample( txout_ext, params.TXSampleFreq, params.AWGSampleFreq);
% channelin  = [ txout_awg(:,1:end)]   ;
% txsignal.txout_ext = txout_awg;
% txsignal.awg_signal = txout_awg;

%%
simout.out = zeros(1,2);
for simseq=1:length(sims.X_coor)
    [sims, params]     = SweepSim(  sims, params, simseq);
    defaultStream.State = savedState;
    for simnum=1:sims.max_num_sim
        [channelout, sims] = Channel( sims, channelin, sims.channel);  
        [recovered, frameout, sims] = RxTop( channelout, txsignal, sims, params);
        simout             = SimAnalysis( sims, simout, frameout, simnum );   
        stop1( sims, params, frameout, txsignal);
        sims.en_disp_result =2;
        if ( sims.mode ~= 51 )
            sims.X_val = sims.channelout.ROP_dBm ;
        end 
        ROP_dBm(1, simseq) = sims.X_val;
        disp_result(simout, frameout, sims, params);  
        %        save( [SW_PATH 'Results/Sim/Fiber' num2str(sims.X_coor(simseq)/km) 'km.mat'], 'channelout');
    end
    sims.en_disp_result =1;
    simout.out(simseq, 1) = mean(simout.BER);
    simout.out(simseq, 2) = mean(simout.EVM);
    simout.out(simseq, 3) = mean(simout.BER);
    disp_result(simout, frameout, sims, params);    
    pause(1);
end

%%
if ( sims.mode == 87 )
    sims.X_coor = ROP_dBm(1,1:length(sims.X_coor));
end
%% Draw  simulation results
draw_new_plot = 0 ;
sims.plot_mode = 1 ;
testcase = [ ', Sim case  ' num2str(sim_case)];
simout.legend = [   num2str(2^ params.Nbitspersymbol) '-QAM, ' ...
                   num2str(params.NTXStream)  ' TX,'...
                  'Baud Rate '  num2str(round(params.BaudFreq *10 /GHz)/10) testcase ];
simout.legend = get_legend(sim_case);
simout.color = 'ms-';
simout.title = [ 'BER   ' testcase ];
simout.title = [ num2str(2^ params.Nbitspersymbol) '-QAM, '   num2str(round(params.BaudFreq *10 /GHz)/10)  'GB, Dual' ];
if ( idx == 0 )
    simout.color = get_color(sim_case);
else 
    simout.color = get_color(idx);
end 
if ( sim_case == 9  || sim_case == 33 )
    simout.legend = [   num2str(IQGain) ' dB' ];
     simout.title =[simout.title  ', IQGain'];
end  
if ( sim_case == 10 || sim_case == 34 )
    simout.legend = [   num2str(IQPhase) ];
     simout.title =[simout.title  ', IQPhase'];
end  
if ( sim_case == 11 || sim_case == 35 || sim_case == 36 )
    simout.legend = [   num2str(IQSkew)  ' ps'];
     simout.title =[simout.title  ', IQSkew'];
end  
if ( sim_case == 12 )
    simout.legend = [   num2str(PhaseNoise) ' MHz'];
end  
if ( sim_case == 23 )
    simout.legend = [   num2str(PMD) ' ps' ];
end  
if ( sim_case == 24 )
    simout.legend = [   num2str(ENob) ];
end  
if ( sim_case == 25 )
    simout.legend = [   num2str(ENob) ];
end  
if ( params.dfe.skewcomp_en == 2)
%     simout.color = 'ys-';
%     simout.legend = [simout.legend ', Widely linear'];
    simout.title =[simout.title  ', Widely linear'];
end 
if ( params.dfe.skewcomp_en == 1)
%     simout.legend = [simout.legend ', Real 4x4'];
%     simout.color = 'cs-';
    simout.title =[simout.title  ', Real 4x4'];
end 
if ( params.dfe.skewcomp_en == 0)
%     simout.legend = [simout.legend ', No skew comp'];
%     simout.color = 'ms-';
    simout.title =[simout.title  ', No skew '];
end 
sims = DrawSimout( simout, sims, params, draw_new_plot);  

sims.plot_mode = 3 ;
sims = DrawSimout( simout, sims, params, draw_new_plot);  
