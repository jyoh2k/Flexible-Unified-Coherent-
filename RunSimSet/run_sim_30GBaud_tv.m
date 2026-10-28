
X_coor  =  [225 :1:240];
sims.channel.fiber_length     = 0 *km;
run([SW_PATH './RunDir/run_sim_tv.m']);

X_coor  =[273:1: 288]; 
sims.channel.fiber_length     = -20 *km;
run([SW_PATH './RunDir/run_sim_tv.m']);

