function txsignal =  GenAWG( txsignal, filename, sims, params) 
     
   if ( params.AWGResampleMethod ~= 0 ) 
       
%        txsignal.txout = [txsignal.txout txsignal.txout(:, end-params.awg_pad+1:end)];
       if ( size(txsignal.txout,1) == 2 )
           txsignal.txout =  txmapping( txsignal.txout(1,:), txsignal.txout(2,:), params.TXmapping);
       else
           txsignal.txout =  txmapping1( txsignal.txout(1,:), params.TXmapping);
       end 
       
       [txsignal.txout]     = SkewCompensator( txsignal.txout, params.txskew );

       txsignal.awg_signal=  KeySight_AWG_Write1( txsignal, params );  
       
   else 
       
       txsignal.awg_signal = txsignal.txout_ext;  
       global SW_PATH
       dlmwrite([SW_PATH  filesep   'Results' filesep  'PPG_XI.txt' ], real(txsignal.txframe(1,:))> 0);
       dlmwrite([SW_PATH  filesep   'Results' filesep  'PPG_XQ.txt' ], imag(txsignal.txframe(1,:))> 0);
       if ( size(txsignal.txframe,1) > 1 )
           dlmwrite([SW_PATH  filesep   'Results' filesep  'PPG_YI.txt' ], real(txsignal.txframe(2,:))> 0);
           dlmwrite([SW_PATH  filesep   'Results' filesep  'PPG_YQ.txt' ], imag(txsignal.txframe(2,:))> 0);
       end 
       
   end 

    sims_saved = sims;
    params_saved = params;
    save(filename, 'txsignal',  'params_saved');
%     save([ filename 'Env'] , 'txsignal', 'sims_saved', 'params_saved');

end





