function awg =  txmapping ( awg1, awg2, TXmapping)
    awg1_conj = complex( imag(awg1), real(awg1));
    awg2_conj = complex( imag(awg2), real(awg2));
    awg1_ch = complex( real(awg1), real(awg1));
    switch  TXmapping
        case 1
            awg = [awg1;awg2];
        case 2
            awg = [awg2_conj;awg1_conj];
        case 3
            awg = [awg1; awg2_conj];
        case 4
            awg = [awg1_conj;awg2];
        case 5
            awg = [awg1; awg1*0];
        case 6
            awg = [awg1_conj; awg1*0];
        case 7
            awg = [awg1*0; awg1];
        case 8
            awg = [awg1*0; awg1_conj];
        case 9
            awg = [awg1_ch; awg1_ch];
        case 10
            awg = [awg1; awg1];
        case 11
            awg = [awg1_conj; awg1];
        case 12
            awg = [awg1_conj; awg1_conj];
        case 13
            awg = [awg1; awg1_conj];
        otherwise
            awg = [awg1;awg2];
    end
end