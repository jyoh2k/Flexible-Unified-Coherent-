function [Pr]=  Friis (  Pi, carrier_frequency, distance, alpha )

    c = 2.99e8;  % Speed of light 
    lambda  = c /carrier_frequency ;  
    Pr = Pi * ( lambda/4/pi/distance) ^2 * exp( -alpha * distance);

end