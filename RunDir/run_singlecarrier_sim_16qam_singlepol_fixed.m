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
sims.max_num_sim              = 1;
sims.en_disp_result            = 1; 
sims.dataf.data_file            = [DSP_PATH 'Ptn/prbs31.txt'];
sims.dataf.data_file            = [DSP_PATH 'Ptn/prbs23.txt'];
sims.trainingf.data_file            = [DSP_PATH 'Ptn/prbs23.txt'];
%%
params.Nbitspersymbol = 4;
params.NTXStream         = 1;
params.NRXStream         = 1;
params.tpr.settling_time   = 1600 * 4;
params.totalbits = 524272;
params.en_block_termination   = 4 ;% Add QPSK pilot symbols(Alamouti)
params.stbc.en   = 1 ; 
params.NTrainingSymbol   = 2816;
params.NDataSymbol       = 56320;
params.NSymbol           = params.NTrainingSymbol + params.NDataSymbol;
% params.NSymbol = 12800* 20;
params.fec.en =0;
params.fec.FEC_mode = 6;  
params.fixed_type = 1;

params.pilot.fixed_bit =1 ;
params.TXMatchedfilter.fixed_bit =1;
params.DCCancel.fixed_bit = 1;
params.AGC.fixed_bit      = 1;
params.OFDE.fixed_bit     = 1;
params.tpr.fixed_bit      =  1;
params.rxpostemp.fixed_bit    = 1;
params.searchframe.fixed_bit  = 1;
params.cfr.fixed_bit          = 1;
params.RXMatchedfilter.fixed_bit    = 1;
params.searchfineframe.fixed_bit    = 1;
params.cpr.fixed_bit    = 1;
params.stbc.fixed_bit   =1;

%% TX DSP
params.txpreemp.en  = 0;
params.TXMatchedfilter.en = 1;
params.TXMatchedfilter.alpha = 0.3;
params.TXMatchedfilter.resp_sample = 3;
%% RX DSP 
params.channel_learning = 0;
params.RXMatchedfilter.en = 1;
params.RXMatchedfilter.resp_sample = 4;
params.AGC.en = 1;
params.AGC.avg_out = 0.5 ;   
params.searchframe.en = 1;
params.searchfineframe.en = 1;
params.searchfineframe.type = 3;
params.tpr.cal_init_tpr = 0;
% No delay 
% params.tpr.K1            = -5e-3/2  ;   %  Propotional coefficient of loopfilter
% params.tpr.K2            = -1e-6  * 1 /2 ;   %  Integral coefficient of loopfilter
% Delay
params.tpr.K1            = -0.001 ;   %  Propotional coefficient of loopfilter
params.tpr.K2            =  -5e-08   ;   %  Integral coefficient of loopfilter
params.tpr.L=  2; 
params.dfe.is_training_seq_init =  1;
params.dfe.betaf          =  3.0000e-03 ;
params.dfe.type = 4;
% params.dfe.type = 1;
if ( params.Nbitspersymbol  ==2  )
    params.dfe.type = 2;
end
params.dfe.betab          = 0;
params.dfe.PRL =128;
params.dfe.Nfbe = 0;
params.dfe.Nffe = 41;
params.dfe.update_type =2; 
if ( params.NTXStream == 1)    
    params.dfe.update_type =1; 
end

params.dfe1.en  = 0;
params.cfr.en    =  1;
params.cpr.en    =  1; 
params.cfr.CFEtype  = 5 ;
% params.stbc.PRL =  128 ;
% params.stbc.betaf =  9e-4;%( 1.0000e-02 );
% params.stbc.betab =  2.5e-02 * 2 ;
% params.stbc.PRL =  64 ;
% params.stbc.betaf = 1e-3; 
% params.stbc.betab =  5e-02 ; 
% params.stbc.betab =  0;
% params.stbc.PRL =  32 ;
% params.stbc.betaf = 8e-4;%2e-3; 
% params.stbc.betab = 1 *  0.16 ; 
params.stbc.Nffe =  5; 
params.stbc.betaf = 4.5e-4  ; % (Oversample), 4.5e-4 (Org) 
params.stbc.betab =  0.07; 
params.stbc.PRL =  4;
params.stbc.betab =  0.15; 
params.stbc.L =  0;
params.stbc.tau_frac = 0 ;
params.stbc.K1            = -1e-3 * 50 ; 
params.stbc.K2            = -1e-4  * 1  ;
params.stbc.TPEtype   =  1;
params.stbc.rx_in_org = 6;
params.stbc.BPS_window =16;
params.stbc.BPS_range = 0.4;
params.stbc.BPS_step=4;
if ( params.stbc.rx_in_org  == 1 )
    params.stbc.betaf  = 4.5e-4 ; 
    params.stbc.betab = 0.15 ; 
end
% params.stbc.Nffe = 11;
if ( params.stbc.en == 1 )
    sims.show_dfe1 = 0; 
    sims.show_stbc = 1; 
end

params.stbc.betaf = 2e-3; 
params.stbc.betab = 0.15;  
% params.stbc.PRL =  128 ;
% params.stbc.betaf = 3e-3  ;
% params.stbc.betab = 0 * 4e-2;
params.stbc.PRL =  128 ; 
params.stbc.betaf =   1 * params.stbc.betaf/(params.stbc.PRL /4); 
params.stbc.betab =  1 *  params.stbc.betab/(params.stbc.PRL /4);  
% params.stbc.betaf = 6e-4; % No Delay
params.stbc.betaf = 8e-4; % Delay 27
params.stbc.betab = 0;
% params.stbc.betab = 3e-3;
% params.stbc.PRL =  128 ;
% params.stbc.betaf =  5e-4; % 5e-4 ~ 5e-3
% params.stbc.betab = params.stbc.betab/(128/4); 
params.stbc.betaf = 6e-4;
%% Pilot based
params.pilot.en = 4;
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
if ( params.pilot.en == 1 )
    params.cpr.CPEtype =5;
    if ( params.Nbitspersymbol  ==2  )
        params.cpr.fCPEtype = 1;
    else
        params.cpr.fCPEtype = 4;
    end
    params.cpr.BLK = params.block_size ;  
    params.cpr.PCtype = 2; % 2: Smoothing, 3:Linear fitting
    params.cpr.PCtype2 = 1;
    params.cpr.STEP  = params.cpr.BLK ;   
    params.cpr.fBLK = params.cpr.BLK; 
    params.cpr.fSTEP  = params.cpr.BLK ;   
    params.cpr.fPCtype = 1; % 2: Smoothing, 3:Linear fitting
    params.cpr.smoothing  = 2 ;  
end 

if ( params.pilot.en == 4 )
    params.cpr.CPEtype =6; 
     
    params.cpr.BLK = params.block_size ; 
    params.cpr.PCtype = 1; % 2: Smoothing, 3:Linear fitting
    params.cpr.PCtype2 = 1;
    params.cpr.STEP  = params.block_size * 4   ;   
    params.cpr.fBLK = params.cpr.BLK; 
    params.cpr.fSTEP  = params.cpr.BLK ;   
    params.cpr.fPCtype = 1; % 2: Smoothing, 3:Linear fitting
    params.cpr.smoothing  = 2 ;  
    
end 

params.dfe.is_training_seq_init= 1; 
params.rxpostemp.en = 1;
params.rxpostemp.filename = [SW_PATH  './Ptn/PostEmphasis3.mat'];


%% Channel
sims.ROP_cal = 3;
sims.channel.MZmod.launch_power =  5*mW;
sims.channel.CarrierFreqOff   = 0*500*MHz ; 
sims.channel.TimeFreqOff      =  0 *10*ppm;
sims.channel.TimePhaseOff     = 0 * -0.5; 
sims.channel.Jitter           = 0.0*ps; 
% sims.channel.AGC.avg_out      = 0.6;
sims.channel.enAWGN           = 1;
sims.channel.TXLineWidth      = 0 * 500 * kHz;
sims.channel.RXLineWidth      = 0  * 500 * kHz;

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
sims.channel.RXADC.gain  = 1/4;
if ( params.Nbitspersymbol == 2 && params.NTXStream == 1)
params.OSCFreq  = 68*GHz;
sims.channel.RXADC.bandwidth  = 33.5*GHz;
else
params.OSCFreq  = 34*GHz;
sims.channel.RXADC.bandwidth  = 20 *GHz;
sims.channel.RXADC.bandwidth_en  = 0;
end
sims.channel.RXADC.ENob  = 4;
sims.channel.RXADC.T.wordl = 0;
sims.channel.RXADC.T.fracl = 7;

sims.channel.fiber_length     = 0 *km;
sims.channel.ssmf.power_split2 = 0.5;
sims.channel.PMD = 0 * 2*ps;
sims.channel.iqimb.gainim = zeros(2,1) * (db2mag(1) - 1); % 1 dB
sims.channel.iqimb.phaseim = zeros(2,1) * 2.5; %  2.5degree
sims.channel.iqimb.iqskew =zeros(2,1) *  0.75*ps;
%% Baud rate increase due to FEC 
params.BaudFreq = 100*GHz / (params.Nbitspersymbol)/params.NTXStream;
% params.fec.FEC_mode = 6;
switch  params.fec.FEC_mode
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

 sims.channel.SNRdB = 15.2424;
sims.channel.TXDAC.nonoise =1; 
sims.channel.RXADC.nonoise =1; 
    params.rxpostemp.en = 0;
    %%
params.dfe.skewcomp_en =0;
params.dfe1.skewcomp_en =0;
%%
if ( sim_case  == 1);
    params.TXMatchedfilter.en = 0;
    params.RXMatchedfilter.en = 0;
    sims.channel.RFDriver.nonoise = 1;
    sims.channel.PD.nonoise = 1;
    sims.channel.RFAmp.nonoise =1; 
    params.tpr.en=0;
    params.cfr.en= 0;
    params.cpr.en= 0;
    params.rxpostemp.en = 0;
end
%%
if ( sim_case  == 2) 
    sims.channel.RFDriver.nonoise = 1;
    sims.channel.PD.nonoise = 1;
    sims.channel.RFAmp.nonoise =1; 
    sims.channel.enAWGN           = 0;
    params.rxpostemp.en = 0;
end

%%
if ( sim_case  == 6)      
    sims.channel.PD.NF_dB = 0;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 15.31 + 0.5  ;
    sims.channel.RFDriver.nonoise = 1;
    sims.channel.PD.nonoise = 1;
    sims.channel.RFAmp.nonoise =1; 
    sims.channel.TXDAC.nonoise =1; 
    sims.channel.RXADC.nonoise =1;  
    params.rxpostemp.en = 0;
end
%%
if ( sim_case  == 7)            
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 15.34 + 0.5  ; 
end
%%
if ( sim_case  == 8)            
    sims.channel.PD.NF_dB = 0;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 15.34 + 0.5  ; 
    sims.channel.SNRdB = 18.5  ; 
end
%%

if ( sim_case  == 9)             % IQ gain   
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 18  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(IQGain) - 1); % 1 dB
end
 
if ( sim_case  == 10)            % IQ phase imbalance 
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 15.34 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * IQPhase; %  5 degre
end
 
 
if ( sim_case  == 11)            % IQ skew
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 15.34 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  IQSkew *ps;
end
 
 
 
if ( sim_case  == 12 )            %  Phase noise
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 17.34 + 2   ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = PhaseNoise *   MHz;
    sims.channel.RXLineWidth      = PhaseNoise *   MHz;
end
  
%%

if ( sim_case  == 14 )            %  CFO
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 16 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 0.2 *   MHz;
    sims.channel.RXLineWidth      = 0.2 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz; 
end

if ( sim_case  == 15 )            %  CFO
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 16 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 0.2 *   MHz;
    sims.channel.RXLineWidth      = 0.2 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz; 
end

if ( sim_case  == 16 )            %  CFO
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 16 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 0.2 *   MHz;
    sims.channel.RXLineWidth      = 0.2 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz; 
end

if ( sim_case  == 17 )            %  CFO
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 0; 
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 16 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 0.2 *   MHz;
    sims.channel.RXLineWidth      = 0.2 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz; 
end
%%

if ( sim_case  == 18 )            %  CFO
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 16 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 0.2 *   MHz;
    sims.channel.RXLineWidth      = 0.2 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz; 
end

%%
if ( sim_case  == 19 )            %  CFO
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 14 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 0.2 *   MHz;
    sims.channel.RXLineWidth      = 0.2 *   MHz;
    sims.channel.CarrierFreqOff   =  CFO *MHz ; 
end
%%
if ( sim_case  == 20 )            %  SFO 
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 16 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 0.2 *   MHz;
    sims.channel.RXLineWidth      = 0.2 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz; 
    sims.channel.TimeFreqOff      =  20*ppm;
end
  

if ( sim_case  == 21 )            %  Jitter 
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 16 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 0.2 *   MHz;
    sims.channel.RXLineWidth      = 0.2 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz; 
    sims.channel.TimeFreqOff      =  20*ppm;    
    sims.channel.Jitter           = 0.65*ps; 
end
  

if ( sim_case  == 22)            %  Fiber length 20km
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 16 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 0.2 *   MHz;
    sims.channel.RXLineWidth      = 0.2 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz; 
    sims.channel.TimeFreqOff      =  20*ppm;
    sims.channel.fiber_length     = 20 *km;
    sims.channel.Jitter           = 0.65*ps;  
%     sims.channel.MZmod.launch_power =  7*mW;
end


if ( sim_case  == 23 )            %  PMD
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 16 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 0.2 *   MHz;
    sims.channel.RXLineWidth      = 0.2 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz; 
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
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 16 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 0.2 *   MHz;
    sims.channel.RXLineWidth      = 0.2 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz; 
    sims.channel.TimeFreqOff      =  20*ppm;
    sims.channel.fiber_length     = 20 *km;
%     sims.channel.MZmod.launch_power =  7*mW;
    sims.channel.Jitter           = 0.65*ps; 
    sims.channel.PMD = 2 *ps;
    sims.channel.TXDAC.nonoise =0; 
    sims.channel.TXDAC.T.wordl =6; 
    sims.channel.TXDAC.ENob    =ENob; 
end
if ( sim_case  == 25 )            %  PMD
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 19 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 0.2 *   MHz;
    sims.channel.RXLineWidth      = 0.2 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz; 
    sims.channel.TimeFreqOff      =  20*ppm;
    sims.channel.fiber_length     = 20 *km;
%     sims.channel.MZmod.launch_power =  7*mW;
    sims.channel.Jitter           = 0.65*ps; 
    sims.channel.PMD = 2 * ps;
    sims.channel.TXDAC.nonoise =0; 
    sims.channel.TXDAC.T.wordl =6; 
    sims.channel.RXADC.nonoise =0; 
    sims.channel.RXADC.T.wordl =6; 
    sims.channel.RXADC.ENob    =ENob; 
end

if ( sim_case  == 26 )            %  All impairment, no AWGN      
    sims.channel.enAWGN           = 0;
    sims.channel.RFDriver.nonoise = 1;
    sims.channel.PD.nonoise = 1;
    sims.channel.RFAmp.nonoise =1;
    sims.channel.TXDAC.nonoise =1; 
    sims.channel.RXADC.nonoise =1;     
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 19 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 0.2 *   MHz;
    sims.channel.RXLineWidth      = 0.2 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz; 
    sims.channel.TimeFreqOff      =  20*ppm;
    sims.channel.fiber_length     = 20 *km; 
%     sims.channel.MZmod.launch_power =  7*mW;
    sims.channel.Jitter           = 0.65*ps; 
    sims.channel.PMD = 2 * ps;
    sims.channel.TXDAC.nonoise =0; 
    sims.channel.TXDAC.T.wordl =6; 
    sims.channel.RXADC.nonoise =0; 
    sims.channel.RXADC.T.wordl =6; 
end

if ( sim_case  == 27 )            %  PMD
    sims.channel.PD.NF_dB = 6;
    sims.channel.TXDAC.bandwidth_en = 1;
    sims.channel.RXADC.bandwidth_en = 1; 
    sims.channel.MZmod.bandwidth_en = 1; 
    sims.channel.PD.bandwidth_en = 1; 
    sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
    sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
    sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
    sims.channel.PD.bandwidth = 0.8 * params.BaudFreq;
    sims.channel.SNRdB = 19 + 0.5  ; 
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(1) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * 5; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  0.75*ps;
    sims.channel.TXLineWidth      = 0.2 *   MHz;
    sims.channel.RXLineWidth      = 0.2 *   MHz;
    sims.channel.CarrierFreqOff   =  1800*MHz; 
    sims.channel.TimeFreqOff      =  20*ppm;
    sims.channel.fiber_length     = 20 *km;
%     sims.channel.MZmod.launch_power =  7*mW;
    sims.channel.Jitter           = 0.65*ps; 
    sims.channel.PMD = 7 * ps;
%     sims.channel.PMD = PMD * ps;
    sims.channel.TXDAC.nonoise =0; 
    sims.channel.TXDAC.T.wordl =6; 
    sims.channel.RXADC.nonoise =0; 
    sims.channel.RXADC.T.wordl =6; 
%     sims.channel.ssmf.power_split2 = 0;
end
%%

if ( sim_case  == 30) 
    sims.channel.RFDriver.nonoise = 1;
    sims.channel.PD.nonoise = 1;
    sims.channel.RFAmp.nonoise =1; 
    sims.channel.TXDAC.nonoise =1; 
    sims.channel.RXADC.nonoise =1; 
    sims.channel.MZmod.launch_power =  5 *mW;
    sims.channel.fiber_length     = 0 *km;
end
%%
if ( sim_case  == 31) 
    sims.channel.RFDriver.nonoise = 1;
    sims.channel.PD.nonoise = 1;
    sims.channel.RFAmp.nonoise =1; 
    sims.channel.TXDAC.nonoise =1; 
    sims.channel.RXADC.nonoise =1; 
    sims.channel.MZmod.launch_power =  5*mW;
    sims.channel.fiber_length     = 20 *km;
end
%%
if ( sim_case  == 32) 
    sims.channel.RFDriver.nonoise = 1;
    sims.channel.PD.nonoise = 1;
    sims.channel.RFAmp.nonoise =1; 
    sims.channel.TXDAC.nonoise =1; 
    sims.channel.RXADC.nonoise =1; 
    sims.channel.MZmod.launch_power =  5*mW;
    sims.channel.fiber_length     = 80 *km;
end
%%
if ( sim_case  == 33  ||  sim_case == 34  ||  sim_case == 35) 
    sims.channel.RFDriver.nonoise = 1;
    sims.channel.PD.nonoise = 1;
    sims.channel.RFAmp.nonoise =1; 
    params.rxpostemp.en = 0;
    sims.channel.iqimb.gainim = ones(2,1) * (db2mag(IQGain) - 1); % 1 dB
    sims.channel.iqimb.phaseim = ones(2,1) * IQPhase; %  5 degre
    sims.channel.iqimb.iqskew =ones(2,1) *  IQSkew *ps;
end
%% Baud Rate fixed (flow1)
sims.channel.TXDAC.bandwidth = 0.75 * params.BaudFreq  ;
sims.channel.RXADC.bandwidth = 0.75 * params.BaudFreq ;
sims.channel.MZmod.bandwidth =  0.8 * params.BaudFreq;
sims.channel.PD.bandwidth = 0.8 * params.BaudFreq; 

%%
sims.channel.TXDAC.bandwidth = 0.9  * params.BaudFreq  ;
sims.channel.RXADC.bandwidth = 0.9  * params.BaudFreq ;
sims.channel.MZmod.bandwidth =  0.95 * params.BaudFreq;
sims.channel.PD.bandwidth = 0.95 * params.BaudFreq; 
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

%% Main body 
[channelin, txsignal] = TxTop( sims, params);
%%
    if ( params.channel_learning == 1 )
        sims1= sims;
        sims1.channel.enAWGN           = 0;
        sims1.channel.PMD = 0 *ps;
        sims1.channel.ssmf.power_split2 = 0;
        sims1.channel.rx_power_split = [ 1 0 ; 0 1;];
        params1 = params;
        params1.rxpostemp.en = 0;
        params1.stbc.en = 0;
        params1.dfe.type = 1;
        [channelout, sims1] = Channel( sims1, channelin, sims1.channel);
        [recovered, frameout, sims1] = RxTop( channelout, txsignal, sims, params);
        simout             = SimAnalysis( sims1, simout, frameout, simnum );   
        sims1.en_disp_result =2;
        if ( sims.mode == 87 )
            sims.X_val = sims.channelout.ROP_dBm ;
        end         
        ROP_dBm(1, simseq) = sims.X_val;
        disp_result(simout, frameout, sims1, params1);  
        PostEmphasis = frame.dfeout.filtercoef(1,:);
        save([SW_PATH  './Ptn/PostEmphasis3.mat'], 'PostEmphasis');
    end 
%%
simout.out = zeros(1,2);
ROP=zeros(1,2);
for simseq=1:length(sims.X_coor)
    [sims, params]     = SweepSim(  sims, params, simseq);
    defaultStream.State = savedState;
    for simnum=1:sims.max_num_sim
        %load([SW_PATH './Results/Test.mat']);params.OSCFreq = 100*GHz;
        [channelout, sims] = Channel( sims, channelin, sims.channel);
%         channelout = 1/4 * channelin(1:params.NRXStream,:);
        [recovered, frameout, sims] = RxTop(channelout, txsignal, sims, params);
        simout             = SimAnalysis( sims, simout, frameout, simnum );   
        stop1( sims, params, frameout, txsignal);
        sims.en_disp_result =2;
        if ( sims.mode == 87 )
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
%     phase(1:2,simseq) = mean(frameout.stbcout.tpr_error,2);
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
simout.title = [ num2str(2^ params.Nbitspersymbol) '-QAM, '   num2str(round(params.BaudFreq *10 /GHz)/10)  'GBaud, Alamouti' ];
if ( idx == 0 )
    simout.color = get_color(sim_case);
else 
    simout.color = get_color(idx);
end 
if ( sim_case == 9 ||  sim_case == 33 )
    simout.legend = [   num2str(IQGain) ' dB' ];
    simout.title = [simout.title ', Gain imbalance'];
end  
if ( sim_case == 10 ||  sim_case == 34 )
    simout.legend = [   num2str(IQPhase) ];
    simout.title = [simout.title ', Phase imbalance'];
end  
if ( sim_case == 11 ||  sim_case == 35 )
    simout.legend = [   num2str(IQSkew)  ' ps'];
    simout.title = [simout.title ', IQ Skew'];
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
% if ( params.stbc.rx_in_org  == 1)
%     legend1 = ' Original';
%     simout.color = 'ws-';
% else
%     legend1 = ' Single Pol.(w.o. BW)';
%     simout.color = 'ws-';
% end 
% 
% simout.color = 'cs-';
sims = DrawSimout( simout, sims, params, draw_new_plot);  

sims.plot_mode = 3 ;
% simout.color = 'bs-';
sims = DrawSimout( simout, sims, params, draw_new_plot);  
