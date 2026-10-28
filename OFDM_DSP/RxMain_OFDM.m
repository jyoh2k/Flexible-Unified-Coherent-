function [eq_out, frame] =  RxMain_OFDM( in, txsignal, sims, params)

%  Usage      : [recovered, frame] =  RxMain_OFDM( in, txsignal, sims, params)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    if ( params.RX_IF_band == 1 )
        
        [in_dc]    = DCCancel ( params.DCCancel.en, in)   ;
        in_postemphais = OFDE( in_dc, params.OFDE) ;
        in_baseband =  passband2baseband (in_postemphais, params.RX_IFSampleFreq,   params.RX_IF_Freq );
        FilterCoef    = ChBandwidthInit( params.LPF.NBandwidth, 5, 0); % <-- Very important!, To support CFO of 
        in_baseband_lpf = ChBandwidth( in_baseband, FilterCoef, 1);
        in_baseband        = RateConversion( in_baseband_lpf, params.RX_IFSampleFreq, params.RXSampleFreq);
        
    else
        
        [in_rx]     = RateConversion( in, params.OSCFreq, params.RXSampleFreq );
        [in_skew]   = SkewCompensator( in_rx, params.rxskew );
        [in_baseband] = DCCancel(params.DCCancel,in_skew);
        
    end

    
    [in_agc, agcgain]             = AGC( in_baseband, params.AGC);

    [in_sync, frame.fscs ]        = SearchFrameStart_OFDM( in_agc, params.searchframe);

    [cfo_recovered, frame.cfrout] = RxCFR( in_sync, params.cfr);

    
    [cfo_sync, frame.fsfs ] = SearchFineFrameStart_Tr( (cfo_recovered), cfo_recovered, params.searchfineframe);
  
                                           
   [fcfo_sync, frame.fcfrout] = RxCFR( cfo_sync, params.fcfr);

    [fft_out    ]                 = FFTnRemoveGI( fcfo_sync, params.fft);

    [data_out, H, frame.ce]       = ChannelEst ( fft_out,  params.ce);

    [eq2_out, pilot, eq_out2, frame] = ChannelComp ( data_out,  H, params, frame);

    eq_out = SingleStreamOut( eq2_out,  params);

    demapperout                    = OFDMDemapper( eq_out, params);

   %%
   
    frame.agcgain   = agcgain;
    frame.received  =  in_baseband;  
    frame.ADCin  =  in;
    frame.resampledout  =  cfo_sync;
    frame.equalized =  eq_out;
    frame.recovered =  eq_out;
    frame.recovered2 =  eq2_out;
    frame.cfo_recovered_eq =  cfo_sync;
    frame.phase_error_recovered_sync =  eq_out;
    frame.cfo_recovered_sync =  cfo_recovered;
    frame.cfo_recovered  =  cfo_recovered ;
    frame.phase_error_recovered =  eq_out;
    frame.fecin = demapperout;

end 
