function [recovered, frame] =  RxMain_stbc( in, txsignal, sims, params) 
     
    %%  Training signal 
    if ( params.cfr.CFEtype == 1 )
        params.searchframe.sync_pattern = txsignal.txframe;
    end    
    params.cpr.mapper2 =[  txsignal.mapper3 ];
    if ( params.cfr.CFEtype == 1 )        
        params.searchfineframe.sync_pattern = txsignal.mapper2;
    else
        params.searchfineframe.sync_pattern  =   txsignal.sync_pattern(:,:);
    end
%% FrontEnd 

  if ( params.RX_IF_band == 1 )
        in_baseband =  passband2baseband (in, params.OSCFreq,   params.RX_IF_Freq );
        FilterCoef    = ChBandwidthInit( params.LPF.NBandwidth, 5, 0); % <-- Very important!, To support CFO of 
        in_baseband_lpf = ChBandwidth( in_baseband, FilterCoef, 1);
        in_rx        = RateConversion( in_baseband_lpf, params.RX_IFSampleFreq, params.RXSampleFreq);
    else
        [in_rx]     = RateConversion( in, params.OSCFreq, params.RXSampleFreq );
  end
 
    [in_rx]     = SkewCompensator( in_rx, params.skew );
   
    [in_filter] = DCCancel(params.DCCancel, in_rx  )  ; 
    
    in_emphasis = in_filter;
    
    % AGC 
    [in_agc, agcgain]    = RxAGC( in_emphasis, params.AGC);
%     params.OFDE.en =1;
    % OFDE 
     [cd_comp]    = OFDE( in_agc, params.OFDE);

%%  Main DSP 
%     Timing error recovery

    [resampledout, frame.tprout] = RxTPR( complex(cd_comp), txsignal.mapper2, params.tpr );  
    
%% Skip settling time 
    global SKIP_SETTLE_TIME
    if ( SKIP_SETTLE_TIME == 1 ) 
        settle_time = params.tpr.settling_time;
        resampledout1 = resampledout(:,(1+settle_time):end);
        resampledout_eq   = resampledout1 ; 
    else     
        resampledout_eq   = resampledout ;  
    end 
%%     
    [resampledout_sync, frame.fscs ]    = SearchFrameStart( resampledout_eq, params.searchframe);
    [cfo_recovered, frame.cfrout]          = RxCFR( resampledout_sync, params.cfr ); 
     cfo_recovered = RxPostemphasis( cfo_recovered, params.rxpostemp); 
     
      [cfo_recovered, frame.fsfs ] = SearchFineFrameStart_Tr( (cfo_recovered), cfo_recovered, params.searchfineframe); 
      
    global FIXED_ARCHITECTURE
    if  ( FIXED_ARCHITECTURE == 1 )
        [cfo_recovered ]=  MatchedFilter1( cfo_recovered, params.RXMatchedfilter ); 
    else
        [cfo_recovered ]=  MatchedFilter( cfo_recovered, params.RXMatchedfilter ); 
    end
    
%     [phase_error_recovered_sync, frame.fsfs ] = SearchFineFrameStart_Tr( (cfo_recovered), cfo_recovered, params.searchfineframe); 
    [phase_error_recovered_sync  ] =  (cfo_recovered);
    offset = (128-32 )*2;    
    phase_error_recovered_sync = phase_error_recovered_sync(:, offset+1:end);
%     [resampledout_eq, ~, frame.dfeout]   = RxSymEq( phase_error_recovered_sync, txsignal.mapper3(1:params.dfe.NStream,:), params.dfe )  ; 
     
     if ( params.stbc.en == 1 )
            resampledout_eq1 = resampledout_eq; 
            [phase_error_recovered, frame.cprout] = RxCPR( phase_error_recovered_sync, params.cpr);  
            [resampledout_eq, frame.stbcout]  = STBCDec(phase_error_recovered, txsignal, params.stbc); 
            
            eqout = resampledout_eq;
     else 
    % Phase error recovery     
        params.cpr.stbc = 1;
        [phase_error_recovered, frame.cprout] = RxCPR( resampledout_eq, params.cpr );  
        phase_error_recovered_sync = phase_error_recovered;

      %%  To BER estimation    
        % Symbol equalization   
%         [eqout, ~, frame.dfe1out] = RxSymEq( phase_error_recovered_sync, txsignal.mapper3, params.dfe1 )  ;
     end 
     
    % QAMDemapping  
    params.stbcdivdec.en = 0;
    [demapperout, recovered, recovered2, frame.corrected]= FrameDemapper(eqout, txsignal, params);
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
    %%
    
    if ( sims.write_tv ==  1 ) 
        
        global SW_PATH;
        NumFrame = 2; 
        margin = 128*2;
        FrameStart  =  settle_time +  (frame.fscs.start_of_frame - 1 )*2+1+ frame.fsfs.start_of_frame -  768  + margin;
        FrameEnd    =  FrameStart+params.NFrameSample*NumFrame; 
        FrameIdx = 1;
        PrevFrame = params.NFrameSample - 25*128*2;
        while ( FrameEnd < size( in_emphasis,2) || (NumFrame == 0 && FrameIdx > 1)) 
            if ( NumFrame == 0 )
                channelout = in_emphasis(:, FrameStart-PrevFrame+1:end);
            else
                channelout = in_emphasis(:, FrameStart-PrevFrame+1:FrameStart+params.NFrameSample*NumFrame);
            end
            if ( FrameIdx ==1 )                
                channelout1 = channelout;
            end
            save([SW_PATH 'FixedData' num2str(FrameIdx) '.mat'],'channelout');        
            FrameIdx = FrameIdx + 1;
            settle_time = settle_time + params.NFrameSample ;
            FrameStart  =  settle_time +  (frame.fscs.start_of_frame - 1 )*2+1+ frame.fsfs.start_of_frame -  768  + margin;
            FrameEnd    =  FrameStart+params.NFrameSample*NumFrame; 
        end 
        
        
        save_data1('',  recovered1(:, params.NTrainingSymbol+1:end),    ['FPGA/RxEq' ], params.stbc.T.EQ); 
        cfo_recovered = cfo_recovered(:, 1:params.RXoversample:end);
        cfo_recovered = cfo_recovered(:, 1:params.NTrainingSymbol+params.NDataSymbol);
        save_data1('',  cfo_recovered,    ['FPGA/CFO' ], params.RXMatchedfilter.T.Out);   
        save_data1('',  channelout1,    ['FPGA/RxIn' ], params.AGC.T.In);   
%         save_data1('',  in,    ['FPGA/RxIn' ], params.AGC.T.In);   
    end 
    
end
