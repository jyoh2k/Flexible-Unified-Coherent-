
run( ['Units.m']); 
[sims, params]=  Init (    );      
dir0 = [   SW_PATH './Results/Figures/Oct03/' ];
dir1 = [   SW_PATH './Results/Figures/Oct03/DualPol/' ];
dir2= [   SW_PATH './Results/Figures/Oct03/DualPolw/' ];
[s,messy] =mkdir([    dir0 ]);
[s,messy] =mkdir([    dir1 ]);
[s,messy] =mkdir([    dir2 ]);
 
%% 
IQGain =1; IQPhase=5;IQSkew=0.75;PhaseNoise=1;PMD=7;ENob=4;CFO=1800;idx =0;skewcomp_en =0;

sims.plot_axes{1}=''; 
sims.plot_axes{3}=''; 

mode      = 87;  
X_coor    = [12 :20 ];   
for sim_case =   [  2 6 9:12 19: 25]
    
    run([SW_PATH './RunDir/run_singlecarrier_sim_16qam_dualpol.m']); 
 
end 
ylim( sims.plothandle{1}.axes1, [1e-5 1e-1]) ;
ylim( sims.plothandle{3}.axes1, [1e-5 1e-1]) ;
xlim( sims.plothandle{1}.axes1,[ROP_dBm(1) ROP_dBm(length(X_coor))+1]);   
xlim( sims.plothandle{3}.axes1,[ROP_dBm(1) ROP_dBm(length(X_coor))+1]);
   
disp_ber( 1.0e-2, dir1, dir2, sims, simout, [   '16QAM_Dual' ] , params, X_coor, draw_new_plot, 1, 2);
 
 
