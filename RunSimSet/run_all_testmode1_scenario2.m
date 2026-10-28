
run( ['Units.m']); 

if ( exist('sims') == 0) 
    [sims, params]=  Init (    );        
else
    [sims, params]=  Init ( sims, params  );
end    
dir0 = [   SW_PATH './Results/Figures/Sept02/' ];
[s,messy] =mkdir([    dir0 ]);
 
%% 
skewcomp_en = 0;

sims.plot_axes{1}=''; 
sims.plot_axes{3}=''; 
mode      = 87;  
X_coor    =     [0 :1:6 ];   
for sim_case =  [2 25] %[ 2 6 9:12 19: 25 ]
     disp2(sims.logfile,['Sim case ' num2str(sim_case)]);
    run([SW_PATH './RunDir/run_testmode1_scenario2.m']); 
 
end 
% ylim( sims.plothandle{1}.axes1, [1e-5 1e-1]) ;
% ylim( sims.plothandle{3}.axes1, [1e-5 1e-1]) ;
% xlim( sims.plothandle{1}.axes1,[ROP_dBm(1) ROP_dBm(length(X_coor))+1]);   
% xlim( sims.plothandle{3}.axes1,[ROP_dBm(1) ROP_dBm(length(X_coor))+1]);
   
 
 
 
