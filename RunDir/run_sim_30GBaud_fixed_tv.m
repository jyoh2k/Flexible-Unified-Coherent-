

X_coor  =[369:1:384];
sims.channel.fiber_length     = -20 *km;
run([SW_PATH './RunDir/run_sim_tv.m']);


X_coor  =[353:1:368];
sims.channel.fiber_length     = 0 *km; 
run([SW_PATH './RunDir/run_sim_tv.m']);

