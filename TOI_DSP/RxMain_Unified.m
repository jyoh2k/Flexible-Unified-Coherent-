function [recovered, frame] = RxMain_Unified2(in, txsignal, sims, params)
     
    %%  Training signal 
    if ( params.cfr.CFEtype == 1 )
        params.searchframe.sync_pattern = txsignal.txframe;
    end    
    params.cpr.mapper2 =[  txsignal.mapper3 ];
    params.cpr1.mapper2 =[  txsignal.mapper3 ];
    if ( params.cfr.CFEtype == 1 )        
        params.searchfineframe.sync_pattern = txsignal.mapper3;
    else 
        params.searchfineframe.sync_pattern  =   txsignal.sync_pattern;
    end
    if ( params.RXDSP_PTBC == 1)
        params.dfe.mapper2 = txsignal.mapper2;
    else
        params.dfe.mapper2 = txsignal.mapper3;
    end
%% FrontEnd 

    if ( params.RX_IF_band == 1 )
        [in_dc]    = DCCancel ( params.DCCancel.en, in)   ;
        in_baseband =  passband2baseband (in, params.OSCFreq,   params.RX_IF_Freq );
        FilterCoef    = ChBandwidthInit( params.LPF.NBandwidth, 5, 0); % <-- Very important!, To support CFO of 
        in_baseband_lpf = ChBandwidth( in_baseband, FilterCoef, 1);
        in_rx        = RateConversion( in_baseband_lpf, params.RX_IFSampleFreq, params.RXSampleFreq);
    else
        [in_rx]     = RateConversion( in, params.OSCFreq, params.RXSampleFreq );
    end

    [params, frame.skewest]     = SkewEstimator( in_rx, params );
    [in_skew]     = SkewCompensator( in_rx, params.skew );
    [in_filter] = DCCancel(params.DCCancel,in_skew  );  
    [in_agc, agcgain]    = RxAGC( in_filter, params.AGC);
    [in_emphasis] = RxPostemphasis( in_agc, params.rxpostemp);  
    [in_emphasis, frame.gsop]   = RxIQImbalanceComp( in_emphasis, params.gsop)  ;
    if ( params.gsop.en == 1)
        [in_emphasis, agcgain]    = AGC( in_emphasis, params.AGC);
    end
%%        
    if (  params.RXStructure == 1 )     
        [cd_comp]    = OFDE( in_emphasis, params.OFDE);
        [resampledout, frame.tprout] = RxTPR( cd_comp, txsignal.mapper3, params.tpr ); 
        settle_time = 1024;
        resampledout_eq = resampledout(:,(1+settle_time):end); 
        [resampledout_sync, frame.fscs ]    = SearchFrameStart( resampledout_eq, params.searchframe);
        [cfo_recovered, frame.cfrout]          = RxCFR( resampledout_sync, params.cfr ); 
        [cfo_recovered ]=  MatchedFilter( cfo_recovered, params.RXMatchedfilter );
    end     
    
    if (  params.RXStructure == 3 )   
        [in_agc_sync, frame.fscs ]    = SearchFrameStart( in_emphasis, params.searchframe);
        preamble_idx = (frame.fscs.MaxPos - 1 ) * params.searchframe.RXoversample + 1;
        [cfo_recovered, frame.cfrout]          = RxCFR( in_emphasis, params.cfr, preamble_idx); 
        params.OFDE.freq_resp = params.OFDE.freq_resp .* params.RXMatchedfilter.freq_resp ; 
        [cfo_recovered]    = OFDE( cfo_recovered, params.OFDE);
        [resampledout, frame.tprout] = RxTPR( cfo_recovered, txsignal.mapper3, params.tpr );   
        cfo_recovered = resampledout(:, preamble_idx:end);
    end
    
    [cfo_recovered_sync, frame.fsfs ] = SearchFineFrameStart_Tr( (cfo_recovered), cfo_recovered, params.searchfineframe); 
    offset = (128-32 )*2;    
    cfo_recovered_sync = cfo_recovered_sync(:, offset+1:end);

    [phase_error_recovered_sync, frame.cprout] = RxCPR( cfo_recovered_sync, params.cpr);  
    [resampledout_eq, ffeout, frame.dfeout, ~]   = RxUnifiedEq( phase_error_recovered_sync, params.dfe.mapper2, params.dfe);  

    phase_error_recovered = phase_error_recovered_sync;  
    [phase_error_recovered_sync, frame.cprout1] = RxCPR( ffeout, params.cpr1);   
    
  %%  To BER estimation   
  
    eqout = phase_error_recovered_sync; 
    params.stbcdivdec.en = 0;
    [demapperout, recovered, recovered2, frame.corrected]= FrameDemapper(eqout, txsignal, params);
    frame.PTBC = demapperout(params.trainingbits+1) ; 
    if ( frame.PTBC == 1 && params.RXDSP_PTBC == 0) 
        params.stbcdivdec.en = 1;        
        [demapperout, recovered, recovered2]= FrameDemapper(eqout, txsignal, params);
    end
     
    %% HD FEC    
%     deintrlv_out            = Deinterleaver( demapperout, params.interleaver );
%     [dataf, Llength]                = FECDecoder( deintrlv_out, params.fec); 
    %% SD FEC         
    [llrout]  =  QAMDemapper( recovered(: ,  1:end), params ); 
    [dataf, Llength]                = FECDecoder( llrout( params.trainingbits+1:end), params.fec );  
    %%
    frame.mean = mean(in_agc,2);
    frame.agcgain   = agcgain;
    frame.received  =  in;
    frame.postemphasis  =  in_emphasis;
    frame.in_filter     =  in_filter;
    frame.ADCin  =  in;
    frame.resampledout  =  resampledout;
    frame.equalized =  eqout;
    frame.recovered =  recovered;    
    frame.recovered2 =  recovered2;    
    frame.cfo_recovered_eq =  resampledout_eq;    
    frame.phase_error_recovered_sync =  phase_error_recovered_sync;   
    frame.cfo_recovered_sync =  cfo_recovered;   
    frame.cfo_recovered  =  cfo_recovered ;   
    frame.phase_error_recovered =  phase_error_recovered;  
    frame.fecin = demapperout;    
    frame.PTBC = demapperout(params.trainingbits+1) ;
    frame.dataf  = dataf;
end
