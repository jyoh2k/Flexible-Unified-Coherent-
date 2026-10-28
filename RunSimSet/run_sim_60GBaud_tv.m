
X_coor  =[257:1:272];
sims.channel.fiber_length     = 0 *km;
run([SW_PATH './RunDir/run_sim_tv.m']);

X_coor  =[305 :1:320];
sims.channel.fiber_length     = -20 *km;
run([SW_PATH './RunDir/run_sim_tv.m']);

