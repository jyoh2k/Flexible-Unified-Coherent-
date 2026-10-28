function [txout, txsignal] = TxTop( sims, params, gen_awg) 
    global SC
    if ( SC == 1 )
        dataf1 = DataGen( sims.trainingf, (params.trainingbits+params.signalbits), 0 );
        dataf2 = DataGen( sims.dataf, params.databits, 0 );
        dataf  = [dataf1 dataf2];
    else
        dataf             = DataGen( sims.dataf, params.totalbits, 0 );
    end
    if ( params.testmode == 0 )
        [txout, txsignal] = TxMain( dataf, sims, params);
    else
        txout_ov = [];
        params1 = params;
        params1.PTBC = 1;
        params1.TXMatchedfilter.en = 0; 
        params1.AWGSampleFreq = params.TXSampleFreq;
        for idx=1:floor( params.NFrames / 2)
            params1.PTBC = 1;
            params1.frame_number = idx * 2 - 1;
            [txout1, txsignal1]        = TxMain( dataf, sims, params1);
            params1.PTBC = 0;
            params1.frame_number = idx * 2 ;
            [txout2, txsignal2] = TxMain( dataf, sims, params1);
            txout_ov = [txout_ov txout1 txout2 ];
        end 
        txout_filter_in  = [txout_ov(:, end-16:end) txout_ov txout_ov(:, 1:16)];
        [ txout_filter ]=  MatchedFilter( txout_filter_in, params.TXMatchedfilter );
        txout_filter_out = txout_filter(:,16+(1:size(txout_ov,2)));
        txout_awg = [ txout_filter_out(:, end-4000:end) txout_filter_out]; 
        txout   = Resample( txout_awg, params.TXSampleFreq, params.AWGSampleFreq );         
        if ( params.RXDSP_PTBC == 1)
            txsignal = txsignal1;
        else
            txsignal = txsignal2;
        end
        txsignal.txout = txout;
    end  
   
    %% AWG 
    if ( nargin < 3 || gen_awg ==1)
        
        txsignal.txout_ext = txout;
        txsignal =  GenAWG( txsignal, sims.txdata_file, sims, params) ;
        txout = txsignal.awg_signal;
    end

    txout  = [txout(:,end-15500+1:end) txout txout txout(:,end-2000+1:end)]; 
    txsignal.txout_ext = txout;
end
