
function awg =  txmapping1 ( awg1, TXmapping)
    awg1_conj = complex( imag(awg1), real(awg1));
    awg1_ch = complex( real(awg1), real(awg1));
    switch  TXmapping
        case 1
            awg = [awg1;];
        case 2
            awg = [awg1_conj;];
        case 3
            awg = [awg1_ch; ];
    end
end