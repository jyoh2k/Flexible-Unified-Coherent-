
run( ['Units.m']); 
[sims, params]=  Init (    );      
dir0 = [   SW_PATH './Results/Figures/Mar05/' ];
dir1 = [   SW_PATH './Results/Figures/Mar05/SinglePol/' ];
dir2= [   SW_PATH './Results/Figures/Mar05/SinglePolw/' ];
[s,messy] =mkdir([    dir0 ]);
[s,messy] =mkdir([    dir1 ]);
[s,messy] =mkdir([    dir2 ]);
%%
IQGain =1; IQPhase=5;IQSkew=0.75;PhaseNoise=0.2;PMD=2;ENob=4;CFO=1800;idx =0;skewcomp_en =0; 
sims.plot_axes{1}=''; 
sims.plot_axes{3}=''; 

mode      = 87;  
X_coor    = [10:2:20];   
% mode      = 26;  
% X_coor    = [    6e-4:1e-4: 10e-4      ];   
% mode      = 27;  
% X_coor    = [   1e-4  5e-4   1e-3    5e-3   1e-2    5e-2 1e-1       ];   
% mode      = 7;  
% X_coor    = [      5e-4 : 5e-4  :4e-3         ] * -1;   
% X_coor    = [   1e-4  5e-4   1e-3    5e-3   1e-2    5e-2         ] * -1;   
% mode      = 8;  
% X_coor    = [  0  1e-8  5e-8   1e-7    5e-7   1e-6    5e-6         ] * -1;   
% X_coor    = [ 0 1e-6 1e-5:1e-5:9e-5  1e-4:1e-4:9e-4  1e-3:1e-3 :1e-2 1.5e-2:0.5e-2:10e-2      ];   
% X_coor = [ 3e-2:1e-3:4e-2];
for sim_case = [  2 6 9:12 19: 25]    
%     run([SW_PATH './RunDir/run_singlecarrier_sim_16qam_singlepol.m']);  
    run([SW_PATH './RunDir/run_singlecarrier_sim_16qam_singlepol_fixed.m']);  
end 
ylim( sims.plothandle{1}.axes1, [5e-4 1e-1]) ;
ylim( sims.plothandle{3}.axes1, [5e-4 1e-1]) ;
xlim( sims.plothandle{1}.axes1,[ROP_dBm(1) ROP_dBm(length(X_coor))+1]);   
xlim( sims.plothandle{3}.axes1,[ROP_dBm(1) ROP_dBm(length(X_coor))+1]);
   
disp_ber( 1.0e-2, dir1, dir2, sims, simout, [   '16QAM_Single' ] , params, X_coor, draw_new_plot, 2, 2);

 
%%

% run([SW_PATH './RunDir/run_sim_tv_fixed_init.m']);
% params.fixed_type = 0;


% run([SW_PATH './RunDir/run_sim_tv.m']);
