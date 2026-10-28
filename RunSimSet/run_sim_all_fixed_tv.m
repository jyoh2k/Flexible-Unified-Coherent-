%% 1. TPR K1 optimization
run([SW_PATH './RunDir/run_sim_tv_fixed_init.m']);
params.fixed_type = 0;

 
coloridx =1;
mode = 7 ;
X_coor = - [ 0.0001:0.0002:0.001 0.001:0.001:0.003];
params.stbc.betaf = 0.6e-3;

sims.channel.fiber_length     = -20 *km; 
for testvector_list =[369:7:384];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 


sims.channel.fiber_length     = 0 *km; 
for testvector_list =[353:7:368];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 

%% 2. PTBC betaf  optimization
run([SW_PATH './RunDir/run_sim_tv_fixed_init.m']);
params.tpr.K1=-1e-3;  
params.fixed_type = 0;
coloridx =1;
mode = 26 ;
X_coor = [ 0.0002:0.00025:0.0022];

sims.channel.fiber_length     = -20 *km; 
for testvector_list =[369:5:384];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 


sims.channel.fiber_length     = 0 *km; 
for testvector_list =[353:5:368];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 

%% SearchFineFrame Correlation length

run([SW_PATH './RunDir/run_sim_tv_fixed_init.m']);
params.fixed_type = 0;
params.tpr.K1=-1e-3;  
coloridx =1;
mode = 45 ;
testvector_list = 355;
sims.max_num_sim = 1;
X_coor = [ 64:32:256];

sims.channel.fiber_length     = 0 *km; 
for testvector_list = [       384] %;      [355 356 358 363  384];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 
%% 3,4  Gain, OFDE

run([SW_PATH './RunDir/run_sim_tv_fixed_init.m']);  
% params.tpr.K1=-0.75e-3;  
% params.stbc.betaf = 1.5e-3;  
coloridx =1;
mode = 35 ;
testvector_list=220;

legend_str = 'All floating';  
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']);




params.AGC.fixed_bit = 1;
legend_str = 'AGC fixed';  
coloridx =2;
mode = 35 ;
 
% run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']);


params.OFDE.fixed_bit = 1;
legend_str = 'OFDE fixed';  
coloridx =3;
mode = 35 ;
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']); 
 


params.tpr.fixed_bit = 1;
legend_str = 'TPE fixed';  
coloridx =4;
mode = 35 ;
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']);

dir1 ='../2_Matlab/Results/Figures/Jul18_analysis/Fixed/';
[s,messy] =mkdir([    dir1 ]);
saveas(sims1.plothandle{1}.figure1, [dir1    'BER_tpr_fixed.fig' ], 'fig');   
saveas(sims1.plothandle{2}.figure1, [dir1    'EVM_tpr_fixed.fig' ], 'fig');   
%%
params.searchframe.fixed_bit = 1;
legend_str = 'SearchFrame fixed';  
coloridx =5;
mode = 35 ;

% run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']);

params.cfr.fixed_bit = 1;
legend_str = 'CFR fixed';  
coloridx =6;
mode = 35 ;
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']); 
 

params.RXMatchedfilter.fixed_bit = 1;
legend_str = 'Matchedfilter fixed';  
coloridx =7;
mode = 35 ;
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']); 
 

dir1 ='../2_Matlab/Results/Figures/Jul18_analysis/Fixed/';
saveas(sims1.plothandle{1}.figure1, [dir1    'BER_mf_fixed.fig' ], 'fig');   
saveas(sims1.plothandle{2}.figure1, [dir1    'EVM_mf_fixed.fig' ], 'fig');   


params.searchfineframe.fixed_bit = 1;
legend_str = 'searchfineframe fixed';  
coloridx = 8;
mode = 35 ;
% run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']); 
 

params.cpr.fixed_bit = 1;
legend_str = 'cpr fixed';  
coloridx = 9;
mode = 35 ;
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']);

params.stbc.fixed_bit = 1;
legend_str = 'stbc fixed';  
coloridx = 10;
mode = 35 ;
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']); 

%%


mode = 45 ;
X_coor = [64:1:256];

sims.max_num_sim = 1;
coloridx =1; 
testvector_list=223;
run([SW_PATH './RunDir/run_sim_tv.m']);
  

%% 13 BPS range
run([SW_PATH './RunDir/run_sim_tv_fixed_init.m']);

params.tpr.K1=-0.5e-3;
params.OFDE.freq_resp =zeros(1,32);
params.searchfineframe.cor_length = 192;
params.stbc.betaf = 0.6e-3;
params.stbc.rx_in_org =6;
params.stbc.Nffe = 5;
sims.en_disp_result =2;
sims.max_num_sim = 10;
testvector_list=220;

params.AGC.fixed_bit = 1;
params.OFDE.fixed_bit = 1;
params.tpr.fixed_bit = 1;
params.searchframe.fixed_bit = 1;
params.cfr.fixed_bit          = 1;
params.RXMatchedfilter.fixed_bit    = 1;
params.searchfineframe.fixed_bit    = 1;
params.cpr.fixed_bit    = 1;
params.stbc.fixed_bit   = 1;
params.stbc.BPS_step  = 32;
mode = 35 ;


coloridx =1; 
params.stbc.BPS_range =0.8;
legend_str = ['BPS range ' num2str(params.stbc.BPS_range), 'pi/2'];
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']);


coloridx = coloridx +1;
params.stbc.BPS_range =0.4;
legend_str = ['BPS range ' num2str(params.stbc.BPS_range), 'pi/2'];
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']); 

coloridx = coloridx +1;
params.stbc.BPS_range =0.2;
legend_str = ['BPS range ' num2str(params.stbc.BPS_range), 'pi/2'];
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']);
 

coloridx = coloridx +1;
params.stbc.BPS_range =0.1;
legend_str = ['BPS range ' num2str(params.stbc.BPS_range), 'pi/2'];
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']);


coloridx = coloridx +1;
params.stbc.BPS_range =0.05;
legend_str = ['BPS range ' num2str(params.stbc.BPS_range), 'pi/2'];
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']); 

%% 13 BPS step
run([SW_PATH './RunDir/run_sim_tv_fixed_init.m']);

% params.tpr.K1=-0.5e-3;
% params.OFDE.freq_resp =zeros(1,32);
% params.searchfineframe.cor_length = 192;
% params.stbc.betaf = 0.6e-3;
% params.stbc.rx_in_org =6;
% params.stbc.Nffe = 5;
% sims.en_disp_result =2;
% sims.max_num_sim = 10;
% testvector_list=220;

params.AGC.fixed_bit = 1;
params.OFDE.fixed_bit = 1;
params.tpr.fixed_bit = 1;
params.searchframe.fixed_bit = 1;
params.cfr.fixed_bit          = 1;
params.RXMatchedfilter.fixed_bit    = 1;
params.searchfineframe.fixed_bit    = 1;
params.cpr.fixed_bit    = 1;
params.stbc.fixed_bit   = 1;

params.stbc.BPS_range =0.2;
mode = 35 ;

params.stbc.BPS_step  = 32;
coloridx =1;
legend_str = ['BPS step ' num2str(params.stbc.BPS_step)];
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']); 

params.stbc.BPS_step  = 16;
coloridx =coloridx +1;
legend_str = ['BPS step ' num2str(params.stbc.BPS_step)];
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']); 

params.stbc.BPS_step  = 8;
coloridx =coloridx +1;
legend_str = ['BPS step ' num2str(params.stbc.BPS_step)];
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']); 

params.stbc.BPS_step  = 4;
coloridx =coloridx +1;
legend_str = ['BPS step ' num2str(params.stbc.BPS_step)];
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']); 


params.stbc.BPS_step  = 2;
coloridx =coloridx +1;
legend_str = ['BPS step ' num2str(params.stbc.BPS_step)];
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']);
 

params.stbc.rx_in_org =5;
coloridx =6;
legend_str = ['BPS off '  ];
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']);
 
%% 13 BPS window
run([SW_PATH './RunDir/run_sim_tv_fixed_init.m']);

% params.tpr.K1=-0.5e-3;
% params.OFDE.freq_resp =zeros(1,32);
% params.searchfineframe.cor_length = 192;
% params.stbc.betaf = 0.6e-3;
% params.stbc.rx_in_org =6;
% params.stbc.Nffe = 5;
% sims.en_disp_result =2;
% sims.max_num_sim = 10;
% testvector_list=220;

params.AGC.fixed_bit = 1;
params.OFDE.fixed_bit = 1;
params.tpr.fixed_bit = 1;
params.searchframe.fixed_bit = 1;
params.cfr.fixed_bit          = 1;
params.RXMatchedfilter.fixed_bit    = 1;
params.searchfineframe.fixed_bit    = 1;
params.cpr.fixed_bit    = 1;
params.stbc.fixed_bit   = 1;

params.stbc.BPS_range =0.4;
params.stbc.BPS_step  = 4;
mode = 35 ;

coloridx =1;
params.stbc.BPS_window =8 ;
legend_str = ['BPS window ' num2str(params.stbc.BPS_window *2  )];
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']); 

coloridx =coloridx +1;
params.stbc.BPS_window =16 ;
legend_str = ['BPS window ' num2str(params.stbc.BPS_window *2)];
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']); 

coloridx =coloridx +1;
params.stbc.BPS_window =32 ; 
legend_str = ['BPS window ' num2str(params.stbc.BPS_window *2)];
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']); 

coloridx =coloridx +1;
params.stbc.BPS_window = 64 ; 
legend_str = ['BPS window ' num2str(params.stbc.BPS_window *2)];
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']); 

coloridx =coloridx +1;
params.stbc.BPS_window =4 ;
legend_str = ['BPS window ' num2str(params.stbc.BPS_window *2)];
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']); 

%% 14 BPS window
run([SW_PATH './RunDir/run_sim_tv_fixed_init.m']);

% params.tpr.K1=-0.5e-3;
% params.OFDE.freq_resp =zeros(1,32);
% params.searchfineframe.cor_length = 128;
% params.stbc.betaf = 0.6e-3;
% params.stbc.rx_in_org =6;
% params.stbc.Nffe = 5;
sims.en_disp_result =2;
sims.max_num_sim = 10;
testvector_list=220;

params.AGC.fixed_bit = 1;
params.OFDE.fixed_bit = 1;
params.tpr.fixed_bit = 1;
params.searchframe.fixed_bit = 1;
params.cfr.fixed_bit          = 1;
params.RXMatchedfilter.fixed_bit    = 1;
params.searchfineframe.fixed_bit    = 1;
params.cpr.fixed_bit    = 1;
params.stbc.fixed_bit   = 1;

params.stbc.BPS_range =0.2;
params.stbc.BPS_step  = 4;
params.stbc.BPS_window =16 ;
mode = 35 ;

coloridx =1;
legend_str = ['BPS fixed ' ];
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']);  
coloridx =coloridx +1;

params.stbc.BPS_range =0.8;
params.stbc.BPS_step  = 32;
params.stbc.BPS_window =8 ;
legend_str = ['BPS fixed ' ];
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']); 

coloridx =coloridx +1;

params.stbc.BPS_range =0.4;
params.stbc.BPS_step  = 4;
params.stbc.BPS_window = 16 ;
legend_str = ['BPS fixed ' ];
run([SW_PATH './RunDir/run_sim_30GBaud_fixed_tv.m']); 

%% Testvector generation:20km

run([SW_PATH './RunDir/run_sim_tv_fixed_init.m']);

% params.tpr.K1=-0.5e-3;
% params.OFDE.freq_resp =zeros(1,32);
% params.searchfineframe.cor_length = 192;
% params.stbc.betaf = 0.6e-3;
% params.stbc.rx_in_org =6;
% params.stbc.Nffe = 5;
% params.tpr.K2 = 3e-8 ;
sims.en_disp_result =2;
sims.max_num_sim = 1;
testvector_list=220;
mode = 35 ;

params.AGC.fixed_bit = 1;
params.OFDE.fixed_bit = 1;
params.tpr.fixed_bit = 1;
params.searchframe.fixed_bit = 1;
params.cfr.fixed_bit          = 1;
params.RXMatchedfilter.fixed_bit    = 1;
params.searchfineframe.fixed_bit    = 1;
params.cpr.fixed_bit    = 1;
params.stbc.fixed_bit   = 1;
sims.write_tv  =1;
coloridx=1;
% params.stbc.BPS_range =0.4;
% params.stbc.BPS_step  = 4;
% params.stbc.BPS_window = 16 ;
% params.tpr.settling_time = 247040;
X_coor  =[384];
sims.channel.fiber_length     = -20 *km;
run([SW_PATH './RunDir/run_sim_tv.m']);


params.tpr.settling_time = 247040;
run([SW_PATH './RunDir/run_sim_tv.m']);



params.tpr.settling_time = 366080;
run([SW_PATH './RunDir/run_sim_tv.m']);


%params.tpr.settling_time = 485120;
%run([SW_PATH './RunDir/run_sim_tv.m']);
%% Testvector generation:0 km, 1frame

run([SW_PATH './RunDir/run_sim_tv_fixed_init.m']);

% params.tpr.K1=-0.5e-3;
% params.OFDE.freq_resp =zeros(1,32);
% params.searchfineframe.cor_length = 192;
% params.stbc.betaf = 0.6e-3;
% params.stbc.rx_in_org =6;
% params.stbc.Nffe = 5;
% params.tpr.K2 = 3e-8 ;
sims.en_disp_result =2;
sims.max_num_sim = 1;
testvector_list=385;
mode = 35 ;

params.AGC.fixed_bit = 1;
params.OFDE.fixed_bit = 1;
params.tpr.fixed_bit = 1;
params.searchframe.fixed_bit = 1;
params.cfr.fixed_bit          = 1;
params.RXMatchedfilter.fixed_bit    = 1;
params.searchfineframe.fixed_bit    = 1;
params.cpr.fixed_bit    = 1;
params.stbc.fixed_bit   = 1;
sims.write_tv  =0;
coloridx=1;
% params.stbc.BPS_range =0.4;
% params.stbc.BPS_step  = 4;
% params.stbc.BPS_window = 16 ;
% params.tpr.settling_time = 247040;
X_coor  =[353];
sims.channel.fiber_length     =  0 *km;
run([SW_PATH './RunDir/run_sim_tv.m']);



% params.tpr.settling_time = 247040;
% run([SW_PATH './RunDir/run_sim_tv.m']);



% params.tpr.settling_time = 366080;
% run([SW_PATH './RunDir/run_sim_tv.m']);
%% AGC

%% Testvector generation:0 km, 1frame

run([SW_PATH './RunDir/run_sim_tv_fixed_init.m']);

% params.tpr.K1=-0.5e-3;
% params.OFDE.freq_resp =zeros(1,32);
% params.searchfineframe.cor_length = 192;
% params.stbc.betaf = 0.6e-3;
% params.stbc.rx_in_org =6;
% params.stbc.Nffe = 5;
% params.tpr.K2 = 3e-8 ;
sims.en_disp_result =2;
sims.max_num_sim = 1;
testvector_list=353;
mode = 3 ;

params.AGC.fixed_bit = 1;
params.OFDE.fixed_bit = 1;
params.tpr.fixed_bit = 1;
params.searchframe.fixed_bit = 1;
params.cfr.fixed_bit          = 1;
params.RXMatchedfilter.fixed_bit    = 1;
params.searchfineframe.fixed_bit    = 1;
params.cpr.fixed_bit    = 1;
params.stbc.fixed_bit   = 1;
sims.write_tv  = 0;
coloridx=1;
% params.stbc.BPS_range =0.4;
% params.stbc.BPS_step  = 4;
% params.stbc.BPS_window = 16 ;
% params.tpr.settling_time = 247040;
X_coor  =[0.4091:(0.5-0.4091)/20:0.5];
sims.channel.fiber_length     =  0 *km;
run([SW_PATH './RunDir/run_sim_tv.m']);


%% Testvector generation:0 km, 1frame

run([SW_PATH './RunDir/run_sim_tv_fixed_init.m']);
 
sims.en_disp_result =2;
sims.max_num_sim = 1;
testvector_list=220;
mode = 35 ;

params.AGC.fixed_bit = 1;
params.OFDE.fixed_bit = 1;
params.tpr.fixed_bit = 1;
params.searchframe.fixed_bit = 1;
params.cfr.fixed_bit          = 1;
params.RXMatchedfilter.fixed_bit    = 1;
params.searchfineframe.fixed_bit    = 1;
params.cpr.fixed_bit    = 1;
params.stbc.fixed_bit   = 1;
sims.write_tv  =1;
coloridx=1;
% params.stbc.BPS_range =0.4;
% params.stbc.BPS_step  = 4;
% params.stbc.BPS_window = 16 ;
% params.tpr.settling_time = 247040;
X_coor  =[368];
sims.channel.fiber_length     =  0 *km;
params.tpr.settling_time = 111360;  % params.NFrameSample - 25*128*2 - 128*10
run([SW_PATH './RunDir/run_sim_tv.m']);



 %% Testvector generation:0 km, 1frame

run([SW_PATH './RunDir/run_sim_tv_fixed_init.m']);

% params.tpr.K1=-0.5e-3;
% params.OFDE.freq_resp =zeros(1,32);
% params.searchfineframe.cor_length = 192;
% params.stbc.betaf = 0.6e-3;
% params.stbc.rx_in_org =6;
% params.stbc.Nffe = 5;
% params.tpr.K2 = 3e-8 ;
sims.en_disp_result =2;
sims.max_num_sim = 1;
testvector_list=220;
mode = 35 ;

params.AGC.fixed_bit = 2;
params.OFDE.fixed_bit = 2;
params.tpr.fixed_bit = 2;
params.searchframe.fixed_bit = 2;
params.cfr.fixed_bit          = 2;
params.RXMatchedfilter.fixed_bit    = 2;
params.searchfineframe.fixed_bit    = 2;
params.cpr.fixed_bit    =2;
params.stbc.fixed_bit   = 2;
sims.write_tv  =0;
coloridx=1; 
X_coor  =[1];
params.tpr.settling_time = 0;
params.OSCFreq= params.RXSampleFreq;
sims.channel.fiber_length     =  0 *km;
% params.tpr.settling_time =  params.NFrameSample *1;  
run([SW_PATH './RunDir/run_sim_tv.m']);


 %% Final 
run([SW_PATH './RunDir/run_sim_tv_fixed_init.m']);
legend_str =['Final'];coloridx =8;
sims.en_disp_result =2;
sims.max_num_sim = 20;
testvector_list=220;
mode = 35 ;

params.AGC.fixed_bit = 1;
params.OFDE.fixed_bit = 1;
params.tpr.fixed_bit = 1;
params.searchframe.fixed_bit = 1;
params.cfr.fixed_bit          = 1;
params.RXMatchedfilter.fixed_bit    = 1;
params.searchfineframe.fixed_bit    = 1;
params.cpr.fixed_bit    =1;
params.stbc.fixed_bit   = 1;
sims.write_tv  =0;
run([SW_PATH './RunSimSet/run_sim_30GBaud_fixed_tv.m']);


%% Final :channel learning
run([SW_PATH './RunDir/run_sim_tv_fixed_init.m']);
legend_str =['Final'];coloridx =8;
sims.en_disp_result =2;
sims.max_num_sim = 20;
sims.channel_learning = 0;
testvector_list=220;
mode = 35 ;

params.AGC.fixed_bit = 1;
params.OFDE.fixed_bit = 1;
params.tpr.fixed_bit = 1;
params.searchframe.fixed_bit = 1;
params.cfr.fixed_bit          = 1;
params.RXMatchedfilter.fixed_bit    = 1;
params.searchfineframe.fixed_bit    = 1;
params.cpr.fixed_bit    =1;
params.stbc.fixed_bit   = 1;
sims.write_tv  =0;


params.stbc.betaf = 0.0006;
run([SW_PATH './RunSimSet/run_sim_30GBaud_fixed_tv.m']);

%% Final :channel learning 0.0006
run([SW_PATH './RunDir/run_sim_tv_fixed_init.m']);
legend_str =['Final'];coloridx =8;
sims.en_disp_result =2;
sims.max_num_sim = 20;
sims.channel_learning =1;
testvector_list=220;
mode = 35 ;

params.AGC.fixed_bit = 1;
params.OFDE.fixed_bit = 1;
params.tpr.fixed_bit = 1;
params.searchframe.fixed_bit = 1;
params.cfr.fixed_bit          = 1;
params.RXMatchedfilter.fixed_bit    = 1;
params.searchfineframe.fixed_bit    = 1;
params.cpr.fixed_bit    =1;
params.stbc.fixed_bit   = 1;
sims.write_tv  =0;


params.stbc.betaf = 0.0008; 

run([SW_PATH './RunSimSet/run_sim_30GBaud_fixed_tv.m']);


%% Final  floating, no channel learning, no delay, FIXED_ARCHITECTURE = 0;

run([SW_PATH './RunDir/run_sim_tv_fixed_init.m']);
legend_str =['Final'];coloridx =6;
sims.en_disp_result =2;
sims.max_num_sim = 20;
testvector_list=220;
sims.channel_learning =0;
mode = 35 ;

params.fixed_type = 0;
params.AGC.fixed_bit = 0;
params.OFDE.fixed_bit = 0;
params.tpr.fixed_bit = 0;
params.searchframe.fixed_bit = 0;
params.cfr.fixed_bit          = 0;
params.RXMatchedfilter.fixed_bit    = 0;
params.searchfineframe.fixed_bit    = 0;
params.cpr.fixed_bit    =0;
params.stbc.fixed_bit   = 0;
sims.write_tv  =0;
run([SW_PATH './RunSimSet/run_sim_30GBaud_fixed_tv.m']);
