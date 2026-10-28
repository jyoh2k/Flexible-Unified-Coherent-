function [frameout, simout]=  FrameAnalysis( txsignal, frame, params, sims)

%  Usage      : [frameout]=  FrameAnalysis( txsignal, frame, params, sims)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    frameout     = frame;
    [sims, frameout] = TPRAnalysis( sims, params, frameout);
    [sims, frameout] = CPRAnalysis( sims, params, frameout);
    [sims, frameout] = DFEAnalysis( sims, params, frameout);
    [sims, frameout] = DFE1Analysis( sims, params, frameout);
    [sims, frameout] = SyncAnalysis( sims, params, frameout);    
    [sims, frameout] = BERAnalysis( sims, params, frameout, txsignal);
    [sims] = ShowConstellation( sims, params, frameout);
    [sims] = ShowPSD( sims, params, frameout);
    simout = sims;
end
