function  [sims, frame] = WaveformAnalysis( sims, params, frame)

%  Usage      :  [sim] = WaveformAnalysis( sim, params, frame)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
    d2=min(size(frame.equalized_dfe,2),size(frame.txsignal.trainingseq,2));
    equalized_dfe = frame.equalized_dfe(1, params.NTrainingSymbol+1:d2);
    transmitted   = frame.txsignal.trainingseq(1,params.NTrainingSymbol+1:d2); 

    for ilist=1:length(params.dfe.mapper_list)
        pam0 = find( transmitted  == params.dfe.mapper_list(ilist));   
        frame.mean(ilist) = mean(equalized_dfe(pam0) ) ;
       frame.var(ilist) =  var(equalized_dfe(pam0) ) ;
    end
end