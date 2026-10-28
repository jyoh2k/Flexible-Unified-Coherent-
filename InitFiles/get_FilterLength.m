function [filter_length]=  get_FilterLength( sims, params )


% Filter length N = 2 floor(2Kπ) + 1
% K = Dλ2 z/ (4πcT2)
% T=1/56GHz ( T/2 equalizer이므로 )
% 
% c = speed of light
% λ = 1550nm
% D=17 ps/nm/km 

    run( ['Units.m']);
    T =1/ params.RXSampleFreq;
    z =  sims.channel.ssmf.fiber_length;
    D = sims.channel.ssmf.CD * ps/nm/km;
    K   =  D * (sims.channel.ssmf.lambda0)^2   * z /( 4* pi * c * T^2);
    filter_length= 2 * floor(2* K * pi ) + 1;
end 