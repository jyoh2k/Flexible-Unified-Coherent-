
function [channelout] =  rxmapping ( channelout, RXmapping)
    channelout1 = channelout(1,:);
    channelout2 = channelout(2,:);
    channelout1_conj = complex( imag(channelout(1,:)),  real(channelout(1,:)));
    channelout2_conj = complex( imag(channelout(2,:)),  real(channelout(2,:)));
    switch  RXmapping
        case 1
            channelout = [channelout1; channelout2];
        case 2
            channelout = [channelout2; channelout1];
        case 3
            channelout = [channelout1; channelout2 * 0];
        case 4
            channelout = [channelout1_conj; channelout2 * 0];
        case 5
            channelout = [channelout2; channelout2 * 0];
        case 6
            channelout = [channelout2_conj; channelout2 * 0];
        case 7
            channelout = [channelout1_conj; channelout2_conj];
        otherwise
            channelout = [channelout1; channelout2];
    end
end
