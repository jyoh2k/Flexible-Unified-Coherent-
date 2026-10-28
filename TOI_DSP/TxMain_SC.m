function [txout_if, txsignal] =  TxMain_SC( dataf, sims, params) 


    fecin = dataf(params.trainingbits+params.signalbits+1:end);
    trainingin = dataf(1:params.trainingbits);
    signalin = dataf(params.trainingbits+(1:params.signalbits));
    signalin(1) = params.PTBC; 
    signalin(2:10) = dec2bin(params.frame_number, 9) - '0';
   
    [fecout, Llength] = FECEncoder( fecin, sims, params.fec );
    fecout            = Interleaver( fecout, params.interleaver );
    mapper    = QAMMapper ( fecout,  params.mapper);
    mapper2   = MultiStreamOut ( mapper,  params);
    mapper2   = AddPilotSymbol( mapper2,  params.pilot ); 


    %% Training symbol, Signal symbol
    [signalout] = SigEncoder( signalin, params.signal );
    signalout = signalout(:, 1:124);
    tmapper    = QAMMapper ( trainingin,  params.tmapper);
    smapper    = QAMMapper ( signalout,  params.smapper);
    mapper1   = AddPilotSymbol( [tmapper, smapper],  params.pilot );
    if (params.PTBC == 1)
        params.stbc.en = 1;
        mapper2  = [mapper1 mapper2];
        mapper3   = STBCEnc( mapper2,  params.stbc );
    else
        params.stbc.en = 1;
        mapper1   = STBCEnc( mapper1,  params.stbc );
        mapper2  = [mapper1 mapper2];
        mapper3 = mapper2;
    end

    mapper4 = [conj(params.sync_pattern(:,1:96))  mapper3];
    txframe   = AddTrainingSymbol ( mapper4,  params );
    txframe   = TxLUTPredistortion2( txframe, params.lutpredistortion);

    txout_ov  = TxUpsample( txframe, 2, 0 );
    txout_ov_pre = TxPreemphasis( txout_ov, params.txpreemp);
    params.OFDE.SampleFreq = params.TXSampleFreq;
    
    global FIXED_ARCHITECTURE 
    if  ( FIXED_ARCHITECTURE == 1 )
        [ txout_pre  ]=  MatchedFilter1( txout_ov_pre, params.TXMatchedfilter ); 
        txout_pre  = txout_pre(:, 1:size(txout_ov_pre,2));
    else
        [ txout_pre  ]=  MatchedFilter( txout_ov_pre, params.TXMatchedfilter ); 
    end
    [txout_pre]    = Resample( txout_pre, params.BaudFreq * 2, params.TXSampleFreq);
    txout_pre = TxPredistortion(txout_pre, params.txnlapdp);
    if ( params.TX_IF_band == 1 )
        txout_awg = [txout_pre txout_pre(:, end-params.awg_pad+1:end)];
        txout_base   =  txout_awg;
        txout_resample   = Resample( txout_base, params.TXSampleFreq, params.TX_IFSampleFreq  );
        txout_if   =  baseband2passband (txout_resample, params.TX_IFSampleFreq,   params.TX_IF_Freq );
    else
        txout_awg = [txout_pre txout_pre(:, end-params.awg_pad+1:end)];
        txout_resample   = Resample( txout_awg, params.TXSampleFreq, params.AWGSampleFreq );
        txout_if = txout_resample;
    end

     
    txout_if = TxGain(txout_if, params.txgain); 

    %%
    txsignal.dataf = fecin;
    txsignal.fecout = [ dataf(1:(params.trainingbits+params.signalbits)) fecout];
    txsignal.mapperin = fecout;
    txsignal.mapper2 = mapper2;
    txsignal.mapper3 = mapper3; 
    txsignal.mapper  = [tmapper smapper mapper ];
    txsignal.txframe  = txframe ;
    txsignal.txframe  = txframe ;
    txsignal.txout  = txout_if ;
    txsignal.txout_ov  = txout_ov ;
    txsignal.txout_pre  = txout_pre ;
    txsignal.txout_if  = txout_if ;
    txsignal.sync_pattern =   txframe(:,1:500); 
    txsignal.trainingseq =  mapper; 
    %%       trainingin fecout
    if ( sims.write_tv ==  1 ) 
        save_data ('', fecout,  'TxMain/fecout'); 
        save_data ('', trainingin,  'TxMain/trainingin'); 
        save_data1('',  mapper,    'TxMain/mapperout', params.mapper.T.mapper); 
        save_data1('',  mapper2,    'TxMain/pilotout', params.pilot.T.mapper); 
        save_data1('',  mapper3,    'TxMain/stbcencout', params.pilot.T.mapper); 
        save_data1('',  params.sync_pattern,    'TxMain/frameheader', params.pilot.T.mapper); 
        save_data1('',  txframe,    'TxMain/frameheaderout', params.pilot.T.mapper); 
        save_data1('',  txout_ov,    'TxMain/upsampleout', params.pilot.T.mapper); 
        save_data1('', params.TXMatchedfilter.time_resp,    'TxMain/mf_coef', params.TXMatchedfilter.T.Coef); 
        save_data1('', txout_pre,    'TxMain/matchedfilterout', params.TXMatchedfilter.T.Out); 
        save_data1('', txout_pre,    'FPGA/TxOut', params.TXMatchedfilter.T.Out); 
    end 
end
