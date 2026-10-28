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
sims.max_num_sim               =10;
sims.en_disp_result            = 1; 
sims.dataf.data_file           = [DSP_PATH 'Ptn/prbs23.txt'];
sims.trainingf.data_file       = [DSP_PATH 'Ptn/prbs23.txt'];
sims.show_dfe               =1;
sims.show_stbc              =1;
sims.show_psd               =1;
%%
params.PTBC              = 0;
params.RXDSP_PTBC        = 1; 
params.Nbitspersymbol    = 4;
params.NTrainingSymbol   = 4096-128 -64;
params.NSignalSymbol     = 64;
params.NDataSymbol       = 85760;
params.pilot.en          = 4;

[sims]  =  SetChannel( sim_case, sims, params);  
sims.mode      = mode;
sims.X_coor    = X_coor;
[params]=  SetParams( sim_case, params );
params.dfe.skewcomp_en = skewcomp_en;
[sims, params]=  ReInit ( sims, params);  
params1 = params;
params1.RXDSP_PTBC =0 ;
[params1]=  SetParams( sim_case, params1 );
[sims, params1]=  ReInit ( sims, params1);  
params2 = params;
params2.RXDSP_PTBC =0 ;
[params1]=  SetParams( sim_case, params2 );
[sims, params1]=  ReInit ( sims, params2);  

if ( sim_case  == 36 )    
    params.dfe.training_seq_size = params.NSymbol;
    params.dfe1.training_seq_size = params.NSymbol;
end
%% Main body 
[channelin, txsignal] = TxTop( sims, params, 0);

%%
simout.out = zeros(1,2);
for simseq=1:length(sims.X_coor)
    [sims, params]     = SweepSim(  sims, params, simseq);
    defaultStream.State = savedState;
    for simnum=1:sims.max_num_sim
        [channelout, sims] = Channel( sims, channelin, sims.channel);  
        [recovered1, frameout1, sims]= RxTop( channelout, txsignal, sims,params1);
        [recovered2, frameout2, sims]= RxTop( channelout, txsignal, sims,params2);
        if ( params.PTBC == 0 ) 
            recovered = recovered1;
            frameout = frameout1;    
        else 
            recovered = recovered2;
            frameout = frameout2;    
        end 
        if (frameout.PTBC ~= params.PTBC )
            disp('Signal field fail');
        end
        simout             = SimAnalysis( sims, simout, frameout, simnum );   
        stop1( sims, params, frameout, txsignal);
        sims.en_disp_result =2;
        if ( sims.mode ~= 51 )
            sims.X_val = sims.channelout.ROP_dBm ;
        end 
        ROP_dBm(1, simseq) = sims.X_val;
        disp_result(simout, frameout, sims, params);  
         
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

if ( params.PTBC   == 1 )
    ptbc_str = 'PTBC';
else
    ptbc_str = 'Dual';
end
simout.title = [ num2str(2^ params.Nbitspersymbol) '-QAM, '   num2str(round(params.BaudFreq *10 /GHz)/10)  'GB, ' ptbc_str ];
simout.color = get_color(sim_case);
if ( sim_case == 9  || sim_case == 33 )
    IQGain = mag2db(sims.channel.iqimb.gainim(1)+1);
    simout.legend = [   'IQ Gain'  num2str(IQGain) ' dB' ];
     simout.title =[simout.title  ', IQGain'];
end  
if ( sim_case == 10 || sim_case == 34 )
    
    IQPhase =  sims.channel.iqimb.phaseim(1);
    simout.legend = [  'IQ Phase'  num2str(IQPhase) ];
     simout.title =[simout.title  ', IQPhase'];
end  
if ( sim_case == 11 || sim_case == 35 || sim_case == 36 )
    IQSkew = sims.channel.iqimb.iqskew(1)/ps;
    simout.legend = [   num2str(IQSkew)  ' ps'];
    simout.title =[simout.title  ', IQSkew'];
end  
if ( sim_case == 12 )
    PhaseNoise = sims.channel.TXLineWidth/MHz;
    simout.legend = [   num2str(PhaseNoise) ' MHz'];
end  
if ( sim_case == 23 )
    PMD = sims.channel.PMD/ps;
    simout.legend = [   num2str(PMD) ' ps' ];
end  
if ( sim_case == 24 )
    ENob =sims.channel.TXDAC.ENob;
    simout.legend = [   'DAC, ENob ' num2str(ENob) ];
end  
if ( sim_case == 25 )
    ENob =sims.channel.RXADC.ENob;
    simout.legend = [   'ADC, ENob ' num2str(ENob) ];
end  
if ( params.dfe.skewcomp_en == 2)
    simout.color = 'ys-';
    simout.legend = [simout.legend ', Widely linear'];
    simout.title =[simout.title  ', Widely linear'];
end 
if ( params.dfe.skewcomp_en == 1)
    simout.legend = [simout.legend ', Real 4x4'];
    simout.color = 'cs-';
    simout.title =[simout.title  ', Real 4x4'];
end 
% if ( params.dfe.skewcomp_en == 0)
%     simout.legend = [simout.legend ', No skew comp'];
%     simout.color = 'ms-';
%     simout.title =[simout.title  ', No skew '];
% end 
sims = DrawSimout( simout, sims, params, draw_new_plot);  

sims.plot_mode = 3 ;
sims = DrawSimout( simout, sims, params, draw_new_plot);  
