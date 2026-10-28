
run( ['Units.m']); 

if ( exist('sims') == 0) 
    [sims, params]=  Init (    );        
else
    [sims, params]=  Init ( sims, params  );
end    
dir0 = [   SW_PATH './Results/Figures/Sept02/' ];
[s,messy] =mkdir([    dir0 ]);
 
%% 
%IQGain =1; IQPhase=5;IQSkew=0.75;PhaseNoise=1;PMD=7;ENob=4;CFO=1800;idx =0;skewcomp_en =0;
skewcomp_en = 0;

sims.plot_axes{1}=''; 
sims.plot_axes{3}=''; 

mode      = 87;  
X_coor    =  [10 :1:20] -3 ;   
for sim_case =   [ 2 6 9:12 19: 25]
    
    run([SW_PATH './RunDir/run_flexible_sim_16qam_scenario2.m']); 
 
end 
ylim( sims.plothandle{1}.axes1, [1e-5 1e-1]) ;
ylim( sims.plothandle{3}.axes1, [1e-5 1e-1]) ;
xlim( sims.plothandle{1}.axes1,[ROP_dBm(1) ROP_dBm(length(X_coor))+1]);   
xlim( sims.plothandle{3}.axes1,[ROP_dBm(1) ROP_dBm(length(X_coor))+1]);
   
 
