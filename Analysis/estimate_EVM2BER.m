function BER = estimate_EVM2BER( EVM_dB, params)

  EVM_rms = db2mag(EVM_dB);
  M = 2^params.Nbitspersymbol;
  BER  = 2* (1- 1/sqrt(M)) /log2(M) * erfc(sqrt(3/2/(M-1) ./ (EVM_rms.^2)) );

end 
