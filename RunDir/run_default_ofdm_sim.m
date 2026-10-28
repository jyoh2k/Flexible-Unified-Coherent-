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
sims.show_ce  = 1;
sims.show_tpr  = 1;
sims.show_sync = 1;
sims.show_psd  = 0;
sims.mode      = 0;  
sims.X_coor    = [0];
sims.Ylabel    = 'EVM '; 
sims.max_num_sim              = 1;
sims.en_disp_result            = 1; 
sims.dataf.data_file            = [DSP_PATH 'Ptn/prbs15.txt'];
%%
params.BaudFreq = 30*GHz;
params.RX = 30*GHz;
params.Nbpsc = 4 ;
% params.Nsd = 700;
% params.NFFT = 1024;
params.Nsd = 76;
params.NFFT = 128;
params.TXSampleFreq = params.BaudFreq;
params.RXSampleFreq = params.BaudFreq;
params.AWGSampleFreq = params.TXSampleFreq;
params.OSCFreq  = params.RXSampleFreq;
params.NTXStream = 1;
params.NRXStream = params.NTXStream;
params.NLTF=  2; % 2:Frame synchronization problem
params.NDataSymbol = 1000; 
%% RX DSP
params.searchframe.en = 1;
params.searchfineframe.en = 1;
params.searchframe.th = 0.5;
params.searchfineframe.type = 1;
params.cfr.en = 1;
params.fcfr.en = 0;
params.cpr.en = 1;
params.tpr.en =  1; 
% 128
params.tpr.K1 = -1;
params.tpr.K2 = -0.001;
 

% params.tpr.K1 = -4;
% params.tpr.K2 = -0.001;
%% IF 
params.TX_IF_band = 0;
params.RX_IF_band = 0;
%% Channel
sims.channel.CarrierFreqOff   = 0*500*MHz ; 
sims.channel.TimeFreqOff      = 0*10*ppm;
% sims.channel.TimePhaseOff     = 1 * -0.5; 
% sims.channel.Jitter           = 0.25*ps; 
sims.channel.enAWGN           = 1;
sims.channel.SNRdB = 25;
sims.channel.TXLineWidth      =  0 * 100 * kHz;
sims.channel.RXLineWidth      =  0 * 100 * kHz;
sims.channel.TXDAC.gain        = 3 ;

sims.channel.TXDAC.bandwidth_en = 0;
% sims.channel.TXDAC.ENob  = 4;
% sims.channel.TXDAC.T.wordl = 0;
% sims.channel.TXDAC.T.fracl = 4;
sims.channel.RFDriver.gain_dB =  1;
sims.channel.RFDriver.bandwidth_en =  0;
sims.channel.MZmod.bandwidth_en = 0;
sims.channel.MZmod.bandwidth  = 20*GHz;
sims.channel.PD.bandwidth_en  = 0;
sims.channel.PD.bandwidth  = 42*GHz;
%sims.channel.PD.noise_power_dBm =  -30;
sims.channel.RXADC.bandwidth_en  = 0;


sims.channel.RFDriver.nonoise = 1;
sims.channel.PD.nonoise = 1;
sims.channel.RFAmp.nonoise =1;
sims.channel.TXDAC.nonoise =1;
sims.channel.RXADC.nonoise =1;
sims.channel.AGC.avg_out=0.125;
%%
sims.mode      = 0;
sims.X_coor    = 0;
% sims.mode      = 8;
% sims.X_coor      = [  -1e-4 -5e-4  -1e-3 -5e-3 -1e-2 -5e-2    ];%[-1:-1:-10];
% % sims.X_coor      = -5e-3 ;
% params.tpr.K1 = -2;
% params.tpr.K2 = -1e-3;
% sims.mode      = 6;
% sims.X_coor      = [    -5  :-1:-20]; 
% params.tpr.K2 = 0;
% sims.channel.TimeFreqOff   = 0*ppm;
%% Bit allocation, Power loading
% params.Nbpsc_sc = params.Nbpsc * ones(params.NTXStream, params.Nsd);
% params.power_sc = 1 * ones(params.NTXStream, size(params.SubcarrierIndex,2)) ;
%%
[sims, params]=  ReInit ( sims, params  );  
%% Main body 
[channelin, txsignal] = TxTop( sims, params, 0);
%%
simout.out = zeros(1,2);
for simseq=1:length(sims.X_coor)
    [sims, params]     = SweepSim(  sims, params, simseq);
    defaultStream.State = savedState;
    for simnum=1:sims.max_num_sim 
        [channelout, sims] = Channel( sims, channelin, sims.channel);
        [recovered, frameout, sims] = RxTop( channelout, txsignal, sims, params);  
        simout             = SimAnalysis( sims, simout, frameout, simnum );   
        sims.en_disp_result =2;
        disp_result(simout, frameout, sims, params);  
    end
    sims.en_disp_result =1;
    simout.out(simseq, 1) = mean(simout.BER);
    simout.out(simseq, 2) = mean(simout.EVM);
    disp_result(simout, frameout, sims, params);    
    pause(1);
end

%% Draw  s1imulation results
draw_new_plot = 0 ;
sims.plot_mode = 1 ;
simout.legend = ['K1 ' num2str(params.tpr.K1)];
simout.title = [ 'BER  '];
simout.color = 'ys-';

sims = DrawSimout( simout, sims, params, draw_new_plot);  

%sims.plot_mode = 2 ;
%sims = DrawSimout( simout, sims, params, draw_new_plot);  
%%
% ParameterSet( 'pushbutton1_Callback',  'Parameter', sims, params);
