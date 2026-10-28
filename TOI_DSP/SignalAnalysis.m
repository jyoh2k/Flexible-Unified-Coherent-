function  [sims, frame] = SignalAnalysis( sims, params, frame, txsignal)

%  Usage      : frame = SignalAnalysis( sims, params, frame) 
%  Function   : Signal field analysis
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
   
    head = params.trainingbits + 1;
    tail = params.signalbits + params.trainingbits;
    Rx_uncoded = frame.fecin(:,head:tail);
    frame.frame_number = sum(Rx_uncoded(2:10) .* 2.^(8:-1:0));
    frame.PTBC = Rx_uncoded(1); 
    frame.signal_fail1= frame.frame_number ~= txsignal.frame_number;
    frame.signal_fail2= mod(frame.frame_number, 2) ~= frame.PTBC ;
    frame.signal_fail = 0;
    if( frame.signal_fail1 || frame.signal_fail2 )
        frame.signal_fail = 1;
    end
    if ( txsignal.frame_number ~= 0 )
         sims.Totframe = sims.Totframe + 1;
         sims.hamming_corr_cnt = sims.hamming_corr_cnt + frame.corrected;
         sims.signal_fail_cnt = sims.signal_fail_cnt + frame.signal_fail;
         if ( frame.signal_fail )
             [sims.Totframe sims.signal_fail_cnt];
         end 
         txsignal.frame_number
         sims.FrameNumber = [sims.FrameNumber; txsignal.frame_number];
    end  
    
end


