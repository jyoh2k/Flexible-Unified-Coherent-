% global SW_PATH
run( ['Units.m']);

if ( exist('sims') == 0) 
    [sims, params]=  Init (    );    
else
    [sims, params]=  Init ( sims, params  );
end

sims.plot_axes{1} ='';
sims.plot_axes{2} ='';
sims.plot_axes{3} ='';
sims.plothandle{1}.axes1='';
sims.plothandle{2}.axes1='';
sims.plothandle{3}.axes1='';
sims.show_constellation = 0;
sims.show_ber  =1;
sims.show_cpr  = 1;
sims.show_tpr  = 1;
sims.show_dfe  = 1;
sims.show_dfe1 = 0;
sims.show_sync = 1;
sims.show_psd  = 0;

load ([SW_PATH 'RunDir/savedState.mat']);
defaultStream = RandStream.getGlobalStream;
defaultStream.State = savedState;
        
[sims, params] = DefaultSet( 6  )  ;
% load ( [SW_PATH 'InitFiles/30G_Parameter_June20_floating_wmatched.mat']);
load ( [SW_PATH 'InitFiles/30G_Parameter_Jul18_fixed.mat']);
params = params1;
%%
sims.max_num_sim = 20; 
sims1 = sims;
%%

% params.fixed_type = 1; 
% params.tpr.K1=-0.75e-3;  
% params.tpr.L= 2;  
% params.stbc.betaf = 1e-3;
% params.searchfineframe.search_range = 64;
% params.searchfineframe.cor_length = 128; 
% params.dfe.delta = 1; 
% 
%  
run([SW_PATH './RunDir/run_init.m']);