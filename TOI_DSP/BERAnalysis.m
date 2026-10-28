function  [sims, frame] = BERAnalysis( sims, params, frame, txsignal)

%  Usage      : frame = BERAnalysis( sims, params, frame) 
%  Function   : BER analysis
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    if ( params.testmode == 1 )
        [mapper_list ,mapper_list1, upper_right_data ]=  QAMMapperList (  params) ;
        frame.mapper_tx2 = txsignal.mapper2 ;
        frame.upper_right_data = upper_right_data;
        frame.BER = 0;
        frame.EVM               =0;
        frame.Nbiterr = 0;        
        frame.txsignal = txsignal;
        return;
    end

    %% Uncoded BER 
    tail = 0;
    head = params.signalbits + params.trainingbits + 1;
    Tx_uncoded = txsignal.fecout(:,head:end-tail) ;          % Tx FEC output    
    Rx_uncoded = frame.fecin(:,head:end-tail);               % Rx FEC input

    
    [frame.BER, frame.Nbiterr, frame.Ntotal, Ndiff] = calculate_BER_mode( params.blind_mode, Tx_uncoded, Rx_uncoded, params.NTrainingSymbol );
 
    %% Coded BER
    if ( params.fec.en == 1)
        tail = params.Nbitspersymbol * 125;
        head =  1;
        Tx_coded = txsignal.dataf(head:end-tail) ;           
        Rx_coded = frame.dataf(head:end-2-tail);             
        [frame.codedBER, frame.codedNbiterr, frame.codedNtotal, Ndiff] = calculate_BER( Tx_coded, Rx_coded );
    else
        frame.codedBER =frame.BER;
        frame.codedNbiterr =  frame.Nbiterr ;
        frame.codedNtotal = frame.Ntotal;
    end
    %% EVM
    
   [txout_if, txsignal1] =TxMain(frame.fecin, sims, params);
    head = params.NTrainingSymbol ;     
    tail = 0;
    signal    = frame.recovered(:, head+1:end-tail);
    ideal_tx  = txsignal.mapper(:, head+1:end-tail);
    ideal_rx  = txsignal1.mapper(:, head+1:end-tail);
    [EVM_dB, error_const_idx, cmp_length] = calculate_EVM(params, signal, ideal_tx , ideal_rx );
    error_const_idx = error_const_idx + head;
    frame.error_const_idx{1} = error_const_idx;
    frame.EVM = EVM_dB;
    frame.EVM_ch = EVM_dB;
    
    if ( size(frame.recovered2,1) ~= 1)
        frame.error_const_idx   =[];
        for ich=1: min(size(frame.recovered2,1),size(txsignal.mapper2,1))
                signal    = frame.recovered2(ich, head+1:end-tail);
                ideal_tx  = txsignal.mapper2(ich, head+1:end-tail);
                ideal_rx  = txsignal1.mapper2(ich, head+1:end-tail);

                [EVM_dB, error_const_idx, cmp_length] = calculate_EVM(params, signal, ideal_tx, ideal_rx );
                frame.EVM_ch(ich) = EVM_dB;
                 frame.error_const_idx{ich} =  error_const_idx ;
        end
        frame.EVM = mean(frame.EVM_ch);
       
    end
    %%
    upper_right_data = complex( max(real(params.mapper_list)),  max(imag(params.mapper_list))); 
    [mapper_list ,mapper_list1, upper_right_data ]=  QAMMapperList (  params) ;
    frame.mapper_tx2 = txsignal.mapper2 ;
    frame.upper_right_data = upper_right_data;

%%
%     frame.txout    = txsignal.txout_ext;
    frame.txsignal    = txsignal;
    frame.txoutclk = params.TXSampleFreq;
    if (sims.show_ber == 0 )
        return ;
    end

    if (  isempty(sims.ber_axes)   || ~ ishandle(sims.ber_axes) )
        [sims.ber_axes, sims.ber_text]=BERFigure();
    end
    nbin = sims.BERanalysis.nbin   ; 
    head = 1;%params.NTrainingSymbol ;
    tail     = cmp_length;%(params.NTrainingSymbol + cmp_length );
    bin_size = floor ( cmp_length/ nbin);
    xb=[head:bin_size: tail] ;
    idx = 1;
    for ii= xb  
        nb(idx) =  length(intersect( find( error_const_idx < ( ii + bin_size)), find(error_const_idx > ( ii - 1))));
        idx = idx +1 ;
    end
 
    
    bar(sims.ber_axes, xb, nb, 1, 'y');
    %set(sims.ber_text, 'String', 'Error distribution');
    if ( version('-release') ~= '2014a' )
        xticklabels(sims.ber_axes,round(xb/500)*500);
    end
    xlim  (sims.ber_axes, [1  xb(1)+cmp_length]);% cmp_length ]);  
    default_color(sims.ber_axes);
    
end


 function [ BER, Nbiterr, Ntotal, Ndiff] = calculate_BER_mode( blind_mode, TX_ptn, RX_ptn, ptn_length )
     if ( blind_mode == 1)
         RX_ptn1=reshape(RX_ptn,2,size(RX_ptn,2)/2);
         [BER, Nbiterr, Ntotal, Ndiff] = PRBS_sync_func_refsave(RX_ptn1,ptn_length);
     else
         [BER, Nbiterr, Ntotal, Ndiff] = calculate_BER( TX_ptn, RX_ptn ); 
     end
 end
