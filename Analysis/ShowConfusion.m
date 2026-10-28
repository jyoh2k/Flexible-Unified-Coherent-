function  [sims] = ShowConfusion( sims, params, frame, txsignal, nstream)

%  Usage      : [sims]= ShowConfusion( sims, params, txsignal, frame)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :


   
 
 
    if (  isempty(sims.confusion_axes)   || ~ ishandle(sims.confusion_axes) )
        [sims.confusion_axes, sims.confusion_text, sims.psdhandle] = PSD();
    end
     
    M = zeros(params.NTXStream, params.NTXStream);
    head = params.NTrainingSymbol ;    
    tail = 0;

    signal    = frame.recovered2(nstream, head+1:end-tail);
    ideal_tx  = txsignal.mapper2(nstream, head+1:end-tail);
    ideal_rx    = slicer( signal, params);
     
     for idx_ideal=1:length(params.mapper_list)
         for idx_rcved =1:length(params.mapper_list)
             M(idx_ideal, idx_rcved) = length (intersect( ...
                                                        find(ideal_rx == params.mapper_list(idx_rcved)),  ...
                                                        find( ideal_tx== params.mapper_list(idx_ideal) )));
             
         end
     end 
     
%     colormap('hot');     
    imagesc(M, 'Parent', sims.confusion_axes);
    colorbar('peer',sims.confusion_axes); 

end

function [decided] = slicer( in, params)
        distance = abs( ( ones(length(params.mapper_list),1) * in - params.mapper_list * ones(1, length(in)) )) .^2;
        [C, I] = min( distance  );
        decided = zeros(size(in));
        decided(1:length(in)) =  params.mapper_list(I);
end

