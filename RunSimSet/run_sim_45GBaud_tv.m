
X_coor  =[241 :1:256];
sims.channel.fiber_length     = 0 *km;
run([SW_PATH './RunDir/run_sim_tv.m']);

X_coor  =[289:1: 304];
sims.channel.fiber_length     = -20 *km;
run([SW_PATH './RunDir/run_sim_tv.m']);

