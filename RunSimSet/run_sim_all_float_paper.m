run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']); 
sims.max_num_sim =20;
coloridx =1;
testvector_list =[223];
mode = 7 ;
X_coor = -[ 0.0001:0.0002:0.001  0.001: 0.001:0.005 ];

sims.channel.fiber_length     = 0 *km; 
for testvector_list =[225 :7:240];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 


sims.channel.fiber_length     = -20 *km; 
for testvector_list =[273:7: 288];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 
%% STBC update rate optimization
run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']);
params.tpr.K1= -1*1e-3;
sims.max_num_sim = 20;
params.BaudFreq=30*GHz;
coloridx =1;
testvector_list =[223];
mode = 26 ;
X_coor = [ 0.0001 0.0005 0.001 :0.001 :0.007];

sims.channel.fiber_length     = 0 *km; 
for testvector_list =[225 :7:240];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 


sims.channel.fiber_length     = -20 *km; 
for testvector_list =[273:7: 288];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 


%% Nffe opt.
run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']); 

coloridx =1;
testvector_list =[223];
mode = 31 ;
X_coor = [ 5:4:25];

sims.channel.fiber_length     = 0 *km; 
for testvector_list =[225 :7:240];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 


sims.channel.fiber_length     = -20 *km; 
for testvector_list =[273:7: 288];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 

%% Autocorrelation interval 
run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']); 

params.stbc.rx_in_org = 0; % Without Fine phase recovery
coloridx =1;
testvector_list =[223];
mode = 35 ;
X_coor = [241 :4:256]; 


coloridx =1;
for cpr_interaval =[ 1 2 3 4 5]
    params.cpr.interval  =cpr_interaval;
    legend_str = ['cpr interaval   ' num2str(params.cpr.interval)   ];
    run([SW_PATH './RunDir/run_sim_30GBaud_tv.m']); 
    coloridx = coloridx +1;
end 
%% Autocorrelation window 

run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']); 

coloridx =1;
testvector_list =[223];
mode = 35 ;
X_coor = [257:7:272];
params.stbc.rx_in_org = 0; % Without Fine phase recovery

coloridx =1;
for cpr_window =[ 1 2 3 4 5]
    params.cpr.window  =cpr_window;
    legend_str = ['cpr window   ' num2str(params.cpr.window)   ];
    run([SW_PATH './RunDir/run_sim_30GBaud_tv.m']); 
    coloridx = coloridx +1;
end 
%% Autocorrelation interval 
run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']); 

coloridx =1;
testvector_list =[223];
mode = 35 ;
X_coor = [241 :4:256]; 


coloridx =1;
for cpr_interaval = [ 1 2 3 4 5]
    params.cpr.interval  =cpr_interaval;
    legend_str = ['cpr interaval   ' num2str(params.cpr.interval)   ];
    run([SW_PATH './RunDir/run_sim_30GBaud_tv.m']); 
    coloridx = coloridx +1;
end 
%% Autocorrelation window 
run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']); 

coloridx =1;
testvector_list =[223];
mode = 35 ;
X_coor = [257:7:272];

coloridx =1;
for cpr_window = [ 1 2 3 4 5]
    params.cpr.window  =cpr_window;
    legend_str = ['cpr window   ' num2str(params.cpr.window)   ];
    run([SW_PATH './RunDir/run_sim_30GBaud_tv.m']); 
    coloridx = coloridx +1;
end 
%% 13 BPS range

run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']); 
testvector_list=220;
 
params.stbc.BPS_step  = 32;
mode = 35 ;


coloridx =1;
for BPS_range =[  0.8 0.4 0.2 0.1 0.05  ]
    params.stbc.BPS_range =BPS_range;
    legend_str = ['BPS range ' num2str(params.stbc.BPS_range)  'pi/2'];
    run([SW_PATH './RunDir/run_sim_30GBaud_tv.m']); 
    coloridx = coloridx +1;
end 
  

%% 13 BPS range histogram

run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']); 
testvector_list=220;
 
params.stbc.BPS_step  = 64;
mode = 35 ;


coloridx =1;
for BPS_range =[  1  ]
    params.stbc.BPS_range =BPS_range;
    legend_str = ['BPS range ' num2str(params.stbc.BPS_range)  'pi/2'];
    X_coor  =  [240];
    sims.channel.fiber_length     = 0 *km;
%     run([SW_PATH './RunDir/run_sim_tv.m']);
%     run([SW_PATH './RunDir/run_sim_30GBaud_tv.m']); 
    X_coor  =  [288];
    sims.channel.fiber_length     = -20 *km;
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 
  
%% 13 BPS step

run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']);
 
params.stbc.BPS_range =0.2;
mode = 35 ;

coloridx =1;
for BPS_step =[   2 4:4:16 ]
    params.stbc.BPS_step =BPS_step;    
    legend_str = ['BPS step ' num2str(params.stbc.BPS_step)  ];
    run([SW_PATH './RunSimSet/run_sim_30GBaud_tv.m']); 
    coloridx = coloridx +1;
end 
  

params.stbc.rx_in_org =5; 
legend_str = ['BPS off '  ];
run([SW_PATH './RunSimSet/run_sim_30GBaud_tv.m']);  
 
% 13 BPS window

run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']);  

params.stbc.BPS_range =0.2;
params.stbc.BPS_step  = 4;
mode = 35 ;


coloridx =1;
for BPS_window =128 % [   8 16  32 64 ]
    params.stbc.BPS_window =BPS_window;    
    legend_str = ['BPS window ' num2str(params.stbc.BPS_window)  ];
    run([SW_PATH './RunDir/run_sim_30GBaud_tv.m']); 
    coloridx = coloridx +1;
end   
  

%% Final 

run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']);
testvector_list=220;
sims.max_num_sim = 20;
coloridx = 1;
mode = 35 ;
legend_str = '30 GBaud 20km';

params.cpr.interval =1;
run([SW_PATH './RunSimSet/run_sim_30GBaud_tv.m']); 
 


%%

run([SW_PATH './RunPaper/run_sim_paper_float_45GBaud_init.m']);
testvector_list=220;
sims.max_num_sim = 20; 
coloridx = 2;
mode = 35 ;
legend_str = '45 GBaud 20km';
params.cpr.interval =1;
run([SW_PATH './RunSimSet/run_sim_45GBaud_tv.m']); 

%

run([SW_PATH './RunPaper/run_sim_paper_float_60GBaud_init.m']);
testvector_list=220;
params.cpr.interval =1;
sims.max_num_sim = 20; 
coloridx = 3;
mode = 35 ;
legend_str = '60 GBaud 20km';
run([SW_PATH './RunSimSet/run_sim_60GBaud_tv.m']); 
%%
% 
% run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']);
% testvector_list=220;
% sims.max_num_sim = 18;
% coloridx = 1;
% mode = 35 ;
% params.stbc.BPS_step =32;
% 
% for BPS_range = [ 0.05 0.1 0.2 0.4 0.8] 
%     params.stbc.BPS_range =BPS_range;
%     legend_str = ['BPS range ' num2str(BPS_range)];
%     run([SW_PATH './RunDir/run_sim_30GBaud_tv.m']); 
%     coloridx = coloridx +1;
% end 


params.stbc.rx_in_org = 0;
legend_str = ['BPS off ' ];
run([SW_PATH './RunDir/run_sim_30GBaud_tv.m']); 


%% Conventional betab optimization


run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']);
testvector_list=220;
sims.max_num_sim = 18;
coloridx = 1;
mode = 27 ;
legend_str = '30 GBaud 20km';
params.stbc.rx_in_org = 0; %New
params.cpr.en = 0;  
params.stbc.PRL = 32;  
params.stbc.betaf = 0.002;  
params.stbc.betab = 0.03;  

mode =  27;
X_coor =  [0.015:0.005:0.04 ];

sims.channel.fiber_length     = 0 *km; 
for testvector_list =[225 :1:240];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 


sims.channel.fiber_length     = -20 *km; 
for testvector_list =[273:7: 288];    
    legend_str =['tv :', num2str(testvector_list)];
%     run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 
 
%%

run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']);
testvector_list=220;
sims.max_num_sim = 18;
coloridx = 1;
mode = 27 ;
legend_str = '30 GBaud 20km';
params.stbc.rx_in_org = 0; %New
params.cpr.en = 0;  
params.stbc.PRL = 64;  
params.stbc.betaf = 0.002;  
params.stbc.betab = 0.03;  

mode =  27;
X_coor =  [0.01:0.005:0.05 ];

sims.channel.fiber_length     = 0 *km; 
for testvector_list =[225 :5:240];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 


sims.channel.fiber_length     = -20 *km; 
for testvector_list =[273:5: 288];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 
 
%


run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']);
testvector_list=220;
sims.max_num_sim = 18;
coloridx = 1;
mode = 27 ;
legend_str = '30 GBaud 20km';
params.stbc.rx_in_org = 0; %New
params.cpr.en = 0;  
params.stbc.PRL = 128;  
params.stbc.betaf = 0.002;  
params.stbc.betab = 0.03;  

mode =  27;
X_coor =  [0.01:0.005:0.05 ];

sims.channel.fiber_length     = 0 *km; 
for testvector_list =[225 :5:240];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 


sims.channel.fiber_length     = -20 *km; 
for testvector_list =[273:5: 288];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 
 
%%

run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']);
testvector_list=220;
sims.max_num_sim = 18;
coloridx = 1;
mode = 27 ;
legend_str = '30 GBaud 20km';
params.stbc.rx_in_org = 0; %New
params.cpr.en = 0;  
params.stbc.PRL = 16;  
params.stbc.betaf = 0.002;  
params.stbc.betab = 0.03;  

mode =  27;
X_coor =  [0.01:0.01:0.05 ];
X_coor =  [0.06:0.01:0.1 ];

sims.channel.fiber_length     = 0 *km; 
for testvector_list =[225 :5:240];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 


sims.channel.fiber_length     = -20 *km; 
for testvector_list =[273:5: 288];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 
 
 
%%

run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']);
testvector_list=220;
sims.max_num_sim = 18;
coloridx = 1;
mode = 27 ;
legend_str = '30 GBaud 20km';
params.stbc.rx_in_org = 0; %New
params.cpr.en = 0;  
params.stbc.PRL = 4;  
params.stbc.betaf = 0.002;  
params.stbc.betab = 0.03;  

mode =  27; 
X_coor =  [0.02:0.02:0.20 ];

sims.channel.fiber_length     = 0 *km; 
for testvector_list =[225 :5:240];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 


sims.channel.fiber_length     = -20 *km; 
for testvector_list =[273:5: 288];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 
 

%%

run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']);
testvector_list=220;
sims.max_num_sim = 20;
coloridx = 1;
mode = 27 ;
legend_str = '30 GBaud 20km';
params.stbc.rx_in_org = 0; %New
params.cpr.en = 0;  
params.stbc.PRL = 4;  
params.stbc.betaf = 0.002;  
params.stbc.betab = 0.1;  

mode =  26; 
X_coor =  [0.001:0.001:0.01 ];

sims.channel.fiber_length     = 0 *km; 
for testvector_list =[225 :5:240];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 


sims.channel.fiber_length     = -20 *km; 
for testvector_list =[273:5: 288];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 
 


run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']);
testvector_list=220;
sims.max_num_sim = 20;
coloridx = 1;
mode = 27 ;
legend_str = '30 GBaud 20km';
params.stbc.rx_in_org = 0; %New
params.cpr.en = 0;  
params.stbc.PRL = 16;  
params.stbc.betaf = 0.002;  
params.stbc.betab = 0.05;  

mode =  26; 
X_coor =  [0.001:0.001:0.01 ]*1/2;

sims.channel.fiber_length     = 0 *km; 
for testvector_list =[225 :5:240];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 


sims.channel.fiber_length     = -20 *km; 
for testvector_list =[273:5: 288];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 
 
 

run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']);
testvector_list=220;
sims.max_num_sim = 20;
coloridx = 1;
mode = 27 ;
legend_str = '30 GBaud 20km';
params.stbc.rx_in_org = 0; %New
params.cpr.en = 0;  
params.stbc.PRL = 32;  
params.stbc.betaf = 0.002;  
params.stbc.betab = 0.025;  

mode =  26; 
X_coor =  [0.001:0.0005:0.005 ];

sims.channel.fiber_length     = 0 *km; 
for testvector_list =[225 :5:240];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 


sims.channel.fiber_length     = -20 *km; 
for testvector_list =[273:5: 288];    
    legend_str =['tv :', num2str(testvector_list)];
    run([SW_PATH './RunDir/run_sim_tv.m']);
    coloridx = coloridx +1;
end 
 
%% Final conventional


run([SW_PATH './RunPaper/run_sim_paper_float_30GBaud_init.m']);
testvector_list=220;
sims.max_num_sim = 20;
coloridx = 2;
mode = 35 ;
legend_str = 'PRL 4'; 
params.stbc.rx_in_org = 0; %New
params.cpr.en = 0;  
params.stbc.PRL = 4;  
params.stbc.betaf = 0.002;  
params.stbc.betab = 0.1;  


run([SW_PATH './RunDir/run_sim_30GBaud_tv.m']); 


coloridx = 3;
legend_str = 'PRL 16'; 
params.stbc.rx_in_org = 0; %New
params.cpr.en = 0;  
params.stbc.PRL = 16;  
params.stbc.betaf = 0.002;  
params.stbc.betab = 0.05;  

run([SW_PATH './RunDir/run_sim_30GBaud_tv.m']); 


coloridx = 4;
legend_str = 'PRL 32'; 
params.stbc.rx_in_org = 0; %New
params.cpr.en = 0;  
params.stbc.PRL = 32;  
params.stbc.betaf = 0.002;  
params.stbc.betab = 0.03;  

run([SW_PATH './RunDir/run_sim_30GBaud_tv.m']); 
