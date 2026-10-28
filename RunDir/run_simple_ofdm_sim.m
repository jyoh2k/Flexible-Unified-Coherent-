%% Initialization, Setup 
global SW_PATH
run( ['Units.m']);

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
params.Nsd = 86;
params.NFFT = 128;
% params.Nsd = 170;
% params.NFFT = 256;
% params.Nsd = 340;
% params.NFFT = 512;
% params.Nsd = 680;
% params.NFFT = 1024;
params.TXSampleFreq = params.BaudFreq;
params.RXSampleFreq = params.BaudFreq;
params.AWGSampleFreq = params.TXSampleFreq;
params.OSCFreq  = params.RXSampleFreq;
params.NTXStream = 2;
params.NRXStream = params.NTXStream;
params.NLTF=  1; % 2:Frame synchronization problem
params.NDataSymbol = 1000; 
params.en_bit_alloc = 0;
params.en_power_loading =0;
%% TX DSP
% params.TXMatchedfilter.en = 2;
% params.TXMatchedfilter.alpha = 0.02;
params.TXMatchedfilter.en = 3;
params.TXMatchedfilter.alpha = 1.0;
%% RX DSP
params.searchframe.en = 1;
params.searchfineframe.en = 1;
params.searchframe.th = 0.5;
params.searchfineframe.type = 1;
params.cfr.en = 1;
params.fcfr.en = 1;
params.cpr.en = 1;
params.cpr.bcpr_en=0;
params.tpr.en =  1; 
 
params.tpr.K1 = -2*pi;
params.tpr.K2 = -0.001;

params.AWGSampleFreq = params.BaudFreq;
params.OSCFreq = params.BaudFreq;
%% Channel
sims.channel.CarrierFreqOff   = 1*500*MHz ; 
sims.channel.TimeFreqOff      = 1*10*ppm; 
sims.channel.enAWGN           = 1;
sims.channel.SNRdB                = 27;
sims.channel.TXLineWidth      =  1* 100 * kHz;
sims.channel.RXLineWidth      =  1 * 100 * kHz; 
sims.channel.SampleFreq = params.AWGSampleFreq ;
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
%%
[sims, params]=  ReInit ( sims, params  );  
%% Main body 
dataf     = DataGen( sims.dataf, params.totalbits, 0 );
[txout, txsignal] = TxMain( dataf, sims, params) ;
txout_ext         = [txout(:,end-1001+1:end)  txout txout(:,1:2000)  ]; 
[txout_awg]    = Resample( txout_ext, params.TXSampleFreq, params.AWGSampleFreq);
channelin  = [ txout_awg(:,1:end)]   ;
txsignal.txout_ext = txout_awg;
txsignal.awg_signal = txout_awg;

%%
simout.out = zeros(1,2); 
for simseq=1:length(sims.X_coor)
    [sims, params]     = SweepSim(  sims, params, simseq);
    defaultStream.State = savedState;
    for simnum=1:sims.max_num_sim  
        [channelout, sims.txpn]       = AddPhaseNoise( channelin, 1/sims.channel.SampleFreq, sims.channel.TXLineWidth );
        channelout = CarrierFreqOffset( channelout, sims.channel.CarrierFreqOff_norm, sims.channel.CarrierFreqDrift, sims.channel.PhaseOffset);
        [channelout, sims.rxpn]       = AddPhaseNoise( channelout, 1/sims.channel.SampleFreq, sims.channel.RXLineWidth );
        [channelout]    = SamplingFreqOffset(channelout, sims.channel.TimeFreqOff,  sims.channel.TimePhaseOff);
        [channelout] = AddAWGN( channelout, sims.channel.SNRdB, sims.channel.enAWGN );     
        [recovered, frame] = RxMain( channelout(1:params.NRXStream,:), txsignal, sims, params); 
        [frameout, sims]   = FrameAnalysis( txsignal, frame, params, sims);
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
