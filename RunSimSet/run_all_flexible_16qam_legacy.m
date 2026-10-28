
run( ['Units.m']); 

if ( exist('sims') == 0) 
    [sims, params]=  Init (    );        
else
    [sims, params]=  Init ( sims, params  );
end    

%% 
dir0 = [   SW_PATH './Results/Figures/Sept15_DP_DS_PDM0/' ];
[s,messy] =mkdir([    dir0 ]);
 
skewcomp_en = 0;

sims.plot_axes{1}=''; 
sims.plot_axes{3}=''; 

mode      = 87;  
X_coor    =      [10 :1:20 ];   
for sim_case =    [  2 6 9:12 19: 25]
    
    run([SW_PATH './RunDir/run_flexible_sim_DP_DS_PDM0.m']); 
 
end 
ylim( sims.plothandle{1}.axes1, [1e-5 1e-1]) ;
ylim( sims.plothandle{3}.axes1, [1e-5 1e-1]) ;
xlim( sims.plothandle{1}.axes1,[ROP_dBm(1) ROP_dBm(length(X_coor))+1]);   
xlim( sims.plothandle{3}.axes1,[ROP_dBm(1) ROP_dBm(length(X_coor))+1]);
   
dir1 = [   dir0 ptbc_str 'w/'  ];
dir2= [  dir0 ptbc_str '/'];

[s,messy] =mkdir([    dir1 ]);
[s,messy] =mkdir([    dir2 ]);
disp_ber( 1.0e-2, dir1, dir2, sims, simout, [   '16QAM' ptbc_str ] , params, X_coor, draw_new_plot, 2, 2);
 
 save('DSP_DP_DS_PDM0_params.mat' ,'params1');
%% 
dir0 = [   SW_PATH './Results/Figures/Sept15_DP_DS_MRC0/' ];
[s,messy] =mkdir([    dir0 ]);
 
skewcomp_en = 0;

sims.plot_axes{1}=''; 
sims.plot_axes{3}=''; 

mode      = 87;  
X_coor    =      [10 :1:20 ] - 3;   
for sim_case =    [  2 6 9:12 19: 25]
    
    run([SW_PATH './RunDir/run_flexible_sim_DP_DS_MRC0.m']); 
 
end 
ylim( sims.plothandle{1}.axes1, [1e-5 1e-1]) ;
ylim( sims.plothandle{3}.axes1, [1e-5 1e-1]) ;
xlim( sims.plothandle{1}.axes1,[ROP_dBm(1) ROP_dBm(length(X_coor))+1]);   
xlim( sims.plothandle{3}.axes1,[ROP_dBm(1) ROP_dBm(length(X_coor))+1]);
   
dir1 = [   dir0 ptbc_str 'w/'  ];
dir2= [  dir0 ptbc_str '/'];

[s,messy] =mkdir([    dir1 ]);
[s,messy] =mkdir([    dir2 ]);
disp_ber( 1.0e-2, dir1, dir2, sims, simout, [   '16QAM' ptbc_str ] , params, X_coor, draw_new_plot, 2, 2);
 
save('DSP_DP_DS_MRC0_params.mat' ,'params1');
%% 
dir0 = [   SW_PATH './Results/Figures/Sept15_SP_SS_PTBC/' ];
[s,messy] =mkdir([    dir0 ]);
 
skewcomp_en = 0;

sims.plot_axes{1}=''; 
sims.plot_axes{3}=''; 

mode      = 87;  
X_coor    =      [10 :1:20 ];   
for sim_case =    [  2 6 9:12 19: 25]
    
    run([SW_PATH './RunDir/run_flexible_sim_SP_SS_PTBC.m']); 
 
end 
ylim( sims.plothandle{1}.axes1, [1e-5 1e-1]) ;
ylim( sims.plothandle{3}.axes1, [1e-5 1e-1]) ;
xlim( sims.plothandle{1}.axes1,[ROP_dBm(1) ROP_dBm(length(X_coor))+1]);   
xlim( sims.plothandle{3}.axes1,[ROP_dBm(1) ROP_dBm(length(X_coor))+1]);
   
dir1 = [   dir0 ptbc_str 'w/'  ];
dir2= [  dir0 ptbc_str '/'];

[s,messy] =mkdir([    dir1 ]);
[s,messy] =mkdir([    dir2 ]);
disp_ber( 1.0e-2, dir1, dir2, sims, simout, [   '16QAM' ptbc_str ] , params, X_coor, draw_new_plot, 2, 2);
 
params1 = params;
save('DSP_SP_SS_PTBC_params.mat' ,'params1');
