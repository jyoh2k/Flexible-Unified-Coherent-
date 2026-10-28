function [h]=  get_CD_filter ( sims, params, filter_length  )

    run( ['Units.m']);
    T =1/ params.RXSampleFreq;
    z =  sims.channel.ssmf.fiber_length;
    D = sims.channel.ssmf.CD * ps/nm/km;
    K   =  D * (sims.channel.ssmf.lambda0)^2   * z /( 4* pi * c * T^2);
    
    n = floor((filter_length)/2);
    
    h  = sqrt( 1j /4/K/pi ) * exp(-1j  /4/K * [-n:n] .* [-n:n]);
end
