% global SW_PATH
run( ['Units.m']);

if ( exist('sims') == 0) 
    [sims, params]=  Init (    );    
else
    [sims, params]=  Init ( sims, params  );
end

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
load ( [SW_PATH 'InitFiles/30G_Parameter_Jul18_float.mat']);
params = params1;
%%
params.RXMatchedfilter.en = 1; 


% params.DCCancel.fixed_bit = 1;
% params.AGC.fixed_bit      = 1;
% params.OFDE.fixed_bit     = 1;
% params.tpr.fixed_bit      =  1;
% params.rxpostemp.fixed_bit    = 1;
% params.searchframe.fixed_bit  = 1;
% params.cfr.fixed_bit          = 1;
% params.RXMatchedfilter.fixed_bit    = 1;
% params.searchfineframe.fixed_bit    = 1;
% params.cpr.fixed_bit    = 1;
% params.stbc.fixed_bit   = 1;

sims.channel.fiber_length     = 20 *km;
sims1 = sims;

sims1.plot_axes{1} ='';
sims1.plot_axes{2} ='';
sims1.plot_axes{3} ='';
sims1.plothandle{1}.axes1='';
sims1.plothandle{2}.axes1='';
sims1.plothandle{3}.axes1='';
%%
% testvector_list =[223];
% mode = 26 ;
% X_coor = [ 0.001:0.002:0.01];

params.NTrainingSymbol =2816;
params.NDataSymbol = 56320;
