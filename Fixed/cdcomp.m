
function freq_cdcomp = cdcomp( AFreq, freq_resp, params)
   AFreq = fie_c(complex(AFreq),params.T.FIN);
    freq_resp = complex(freq_resp);
    freq_cdcomp = AFreq  .* freq_resp;    
    freq_cdcomp =  fie_c(freq_cdcomp,params.T.FOUT);
end 