function [recovered, frame] =  RxMain_dp( in, txsignal, sims, params) 
     
    %%  Training signal 
    if ( params.cfr.CFEtype == 1 )
        params.searchframe.sync_pattern = txsignal.txframe;
    end    
    params.cpr.mapper2 =[  txsignal.mapper3 ];
    if ( params.cfr.CFEtype == 1 )        
        params.searchfineframe.sync_pattern = txsignal.mapper3;
    else
%         params.searchfineframe.sync_pattern = txsignal.txframe(:, 1:size(params.sync_pattern,2));
        params.searchfineframe.sync_pattern  =   txsignal.sync_pattern;
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
 
    [in_filter] = DCCancel(params.DCCancel,in_skew  )  ; 
    
    
    in_emphasis = in_filter; 
    
    % AGC 
    [in_agc, agcgain]    = RxAGC( in_emphasis, params.AGC);
       
    % OFDE 
    [cd_comp]    = OFDE( in_agc, params.OFDE);

    [resampledout, frame.tprout] = RxTPR( cd_comp, txsignal.mapper3, params.tpr );  

    
    settle_time = 1024;
    resampledout1 = resampledout(:,(1+settle_time):end);

    resampledout_eq   = resampledout1 ;  
    
    if (  params.RXStructure == 0 ) % Blind Equalizer

        resampledout_eq = RxPostemphasis( resampledout_eq, params.rxpostemp); 
        [resampledout_eq, frame.gsop]   = RxIQImbalanceComp( resampledout_eq, params.gsop)  ;
        if ( params.gsop.en == 1)
            [resampledout_eq, agcgain]    = AGC( resampledout_eq, params.AGC);
        end
         [resampledout_eq, frame.dfeout]   = RxSymEq( resampledout_eq, txsignal.mapper3, params.dfe)  ;  
     
        [resampledout_sync, frame.fscs ]    = SearchFrameStart( resampledout_eq, params.searchframe);
        [cfo_recovered, frame.cfrout]          = RxCFR( resampledout_sync, params.cfr, sims.T ); 
        [cfo_recovered ]=  MatchedFilter1( cfo_recovered, params.RXMatchedfilter );

        [cfo_recovered_sync, frame.fsfs ] = SearchFineFrameStart_Tr( (cfo_recovered),cfo_recovered, params.searchfineframe ); 
        [phase_error_recovered, frame.cprout] = RxCPR( cfo_recovered_sync, params.cpr);   
        [phase_error_recovered_sync] = phase_error_recovered;
    end
    
    if (  params.RXStructure == 1 )        
        [resampledout_eq] = RxPostemphasis( resampledout_eq, params.rxpostemp);  
        [resampledout_eq, frame.gsop]   = RxIQImbalanceComp( resampledout_eq, params.gsop)  ;
        if ( params.gsop.en == 1)
            [resampledout_eq, agcgain]    = AGC( resampledout_eq, params.AGC);
        end
        [resampledout_sync, frame.fscs ]    = SearchFrameStart( resampledout_eq, params.searchframe);
        [cfo_recovered, frame.cfrout]          = RxCFR( resampledout_sync, params.cfr ); 
        [cfo_recovered ]=  MatchedFilter( cfo_recovered, params.RXMatchedfilter );
        [phase_error_recovered_sync, frame.fsfs ] = SearchFineFrameStart_Tr( (cfo_recovered), cfo_recovered, params.searchfineframe); 
         offset = (128-32 )*2;    
        phase_error_recovered_sync = phase_error_recovered_sync(:, offset+1:end);
        [resampledout_eq,~, frame.dfeout, ~]   = RxSymEq( phase_error_recovered_sync, txsignal.mapper3, params.dfe);  
 
        [phase_error_recovered, frame.cprout] = RxCPR( resampledout_eq, params.cpr);  
        [phase_error_recovered_sync] = phase_error_recovered;
    end 
    
      
    if (  params.RXStructure == 2 )        
        [resampledout_eq] = RxPostemphasis( resampledout_eq, params.rxpostemp);  
        [resampledout_eq, frame.gsop]   = RxIQImbalanceComp( resampledout_eq, params.gsop)  ;
        if ( params.gsop.en == 1)
            [resampledout_eq, agcgain]    = AGC( resampledout_eq, params.AGC);
        end
        [resampledout_sync, frame.fscs ]    = SearchFrameStart( resampledout_eq, params.searchframe );  
        [cfo_recovered, frame.cfrout]          = RxCFR( resampledout_sync, params.cfr);       
        [resampledout_sync, frame.fsfs ] = SearchFineFrameStart_Tr( cfo_recovered, resampledout_sync, params.searchfineframe); 
        [resampledout_sync ]=  MatchedFilter( resampledout_sync, params.RXMatchedfilter );
        [resampledout_eq, ~, frame.dfeout, ~]   = RxSymEq( resampledout_sync, txsignal.mapper3, params.dfe)  ;   

        params.cfr.en =0;params.cfr.exp_phasediff =  frame.cfrout.cfe(2);
%         params.cfr.exp_phasediff  =   1800e6/params.BaudFreq *pi;
%         params.cpr.en =0;
        [cfo_recovered, frame.cfrout1]          = RxCFR( resampledout_eq, params.cfr );     
        [phase_error_recovered, frame.cprout] = RxCPR( cfo_recovered, params.cpr);  
        [phase_error_recovered_sync] = phase_error_recovered;
    end 
     

  %%  To BER estimation    
  
    % Symbol equalization   
    [eqout, ~,frame.dfe1out] = RxSymEq( phase_error_recovered_sync, txsignal.mapper3, params.dfe1)  ;

    
    %  DP QAMDemapping  
    params.stbcdivdec.en = 0;
    [demapperout, recovered, recovered2, frame.corrected]= FrameDemapper(eqout, txsignal, params);
    frame.PTBC = demapperout(params.trainingbits+1) ;
    %  PTBC QAMDemapping  
    if ( frame.PTBC == 1 ) 
        params.stbcdivdec.en = 1;        
        [demapperout, recovered, recovered2]= FrameDemapper(eqout, txsignal, params);
    end
     
    %% HD FEC    
%     deintrlv_out            = Deinterleaver( demapperout, params.interleaver );
%     [dataf, Llength]                = FECDecoder( deintrlv_out, params.fec); 
    %% SD FEC   
      
    [llrout]  =  QAMDemapper( recovered(: ,  1:end), params ); 
    [dataf, Llength]                = FECDecoder( llrout( params.trainingbits+1:end), params.fec ); 
%     dataf = ~ dataf;
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
