function out = get_CSPR(in)
    carrier = mean(in);
    carrier_pwr = abs(carrier) .^2;
    signal = in - carrier ;
    signal_pwr =  mean(abs(signal) .^2);
    out = mag2db(sqrt(carrier_pwr/signal_pwr));
end