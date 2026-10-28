function [recovered, frame] = RxMain_SC(in, txsignal, sims, params)
    % Fixed for this configuration: RX_IF_band = 0, RXStructure = 1, cfr.CFEtype ~= 1

    %% Training signal
    params.cpr.mapper2 = txsignal.mapper3;
    params.cpr1.mapper2 = txsignal.mapper3;
    params.searchfineframe.sync_pattern = txsignal.sync_pattern;

    %% Front end
    in_rx = RateConversion(in, params.OSCFreq, params.RXSampleFreq);

    [params, frame.skewest] = SkewEstimator(in_rx, params);
    in_skew   = SkewCompensator(in_rx, params.skew);
    in_filter = DCCancel(params.DCCancel, in_skew);

    in_emphasis = in_filter;

    % AGC
    [in_agc, agcgain] = RxAGC(in_emphasis, params.AGC);

    % OFDE
    cd_comp = OFDE(in_agc, params.OFDE);

    [resampledout, frame.tprout] = RxTPR(cd_comp, txsignal.mapper3, params.tpr);

    settle_time    = params.tpr.settling_time;
    resampledout1  = resampledout(:, (1 + settle_time):end);
    resampledout_eq = resampledout1;

    %% RX structure 1: CFR -> matched filter -> fine frame search -> DFE -> CPR
    resampledout_eq = RxPostemphasis(resampledout_eq, params.rxpostemp);
    [resampledout_eq, frame.gsop] = RxIQImbalanceComp(resampledout_eq, params.gsop);
    if (params.gsop.en == 1)
        [resampledout_eq, agcgain] = AGC(resampledout_eq, params.AGC);
    end

    [resampledout_sync, frame.fscs] = SearchFrameStart(resampledout_eq, params.searchframe);
    [cfo_recovered, frame.cfrout]   = RxCFR(resampledout_sync, params.cfr);
    cfo_recovered = MatchedFilter(cfo_recovered, params.RXMatchedfilter);

    [phase_error_recovered_sync, frame.fsfs] = SearchFineFrameStart_Tr(cfo_recovered, cfo_recovered, params.searchfineframe);
    offset = (128 - 32) * 2;
    phase_error_recovered_sync = phase_error_recovered_sync(:, offset + 1:end);
     
    [phase_error_recovered, frame.cprout] = RxCPR(phase_error_recovered_sync, params.cpr);
    phase_error_recovered_sync = phase_error_recovered;
    [resampledout_eq, ~, frame.dfeout, ~] = RxSymEq(phase_error_recovered_sync, txsignal.mapper3, params.dfe);
    phase_error_recovered = resampledout_eq;

    %% BER estimation
    [eqout, ~, frame.dfe1out] = RxSymEq(phase_error_recovered, txsignal.mapper3, params.dfe1);

    % DP QAM demapping
    params.stbcdivdec.en = 0;
    [demapperout, recovered, recovered2, frame.corrected] = FrameDemapper(eqout, txsignal, params);
    frame.PTBC = demapperout(params.trainingbits + 1);

    % PTBC QAM demapping
    if (frame.PTBC == 1)
        params.stbcdivdec.en = 1;
        [demapperout, recovered, recovered2] = FrameDemapper(eqout, txsignal, params);
    end

    %% SD FEC
    llrout = QAMDemapper(recovered(:, 1:end), params);
    [dataf, Llength] = FECDecoder(llrout(params.trainingbits + 1:end), params.fec);

    %% Frame outputs
    frame.mean                       = mean(in_agc, 2);
    frame.agcgain                    = agcgain;
    frame.received                   = in;
    frame.postemphasis               = in_emphasis;
    frame.in_filter                  = in_filter;
    frame.ADCin                      = in;
    frame.resampledout               = resampledout;
    frame.equalized                  = eqout;
    frame.recovered                  = recovered;
    frame.recovered2                 = recovered2;
    frame.cfo_recovered_eq           = resampledout_eq;
    frame.phase_error_recovered_sync = phase_error_recovered_sync;
    frame.cfo_recovered_sync         = cfo_recovered;
    frame.cfo_recovered              = cfo_recovered;
    frame.phase_error_recovered      = phase_error_recovered;
    frame.fecin                      = demapperout;
    frame.PTBC                       = demapperout(params.trainingbits + 1);
    frame.dataf                      = dataf;
end
