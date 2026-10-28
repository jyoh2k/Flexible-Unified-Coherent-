function [recovered, frameout, sims ] =  RxTop( channelout, txsignal, sims, params) 
    ioffset = 1 ; 
    ratio = params.OSCFreq /  params.RXSampleFreq ;
    margin = 200;
    if ( params.testmode == 1 )
        margin = 200;
    end
    in_size = ceil( ( params.tpr.settling_time   +  params.NFrameSample *2+ margin )* ratio);
    endidx = ioffset+in_size;
    iframe =1;
    max_frame = 1;
    if ( params.testmode == 1 )
        max_frame = params.NFrames ;
    end
    simout.out = zeros(1,2);
    channelout_zp = [channelout, zeros(size(channelout,1), 2000)];
    txsignal.frame_number = 0;
    while ( (endidx < size(channelout_zp,2) && iframe < (max_frame + 1)))% || (ratio == 1 ))
        endidx2 = min(endidx, size(channelout,2));
        channelout1 = [channelout_zp(:,ioffset+1:endidx2)];
        global SC
        if ( SC == 1 )
            if ( params.RXDSP_PTBC == 0 ) 
            [recovered, frame] = RxMain_dp( channelout1, txsignal, sims, params);
            else
            [recovered, frame] = RxMain_stbc( channelout1(1,:), txsignal, sims, params); 
            end
            if (  params.RXDSP_PTBC == 1 &&  frame.PTBC == 0 &&  ...
                   params.testmode ~= 1 )                  
                frameout = frame;recovered=0;
            else  
                [frameout, sims] = FrameAnalysis2( txsignal, frame, params, sims);
%                 stop1( sims, params, frameout, txsignal);
%                 params.dfe.filtertap =frame.dfeout.filtercoef;     
                if ( params.testmode == 1 )
                txsignal.frame_number = frameout.frame_number + 1;
                if ( txsignal.frame_number  > params.NFrames )
                    txsignal.frame_number  = txsignal.frame_number  - params.NFrames;
                end
                end
            end 
            
        else
            [recovered, frame] = RxMain_OFDM( channelout1, txsignal, sims, params);            
            [frameout, sims]   = FrameAnalysis( txsignal, frame, params, sims);
            
        end 
        ioffset = ioffset + round(params.NFrameSample * ratio );
        endidx = ioffset + in_size ;
        iframe = iframe +1;        
        params.eqrep=1;        
    end 
%     SavePostEmpahsis(frameout);
end
