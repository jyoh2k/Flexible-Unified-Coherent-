function  [sims] = ShowMIMO( sims, params, frame)

%  Usage      : [sims]= ShowMIMO( sims, params, frame)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

 
 
    if (  isempty(sims.mimo_axes)   || ~ ishandle(sims.mimo_axes) )
        [sims.mimo_axes, sims.psd_text, sims.psdhandle] = PSD();
    end
    
    if ( params.NRXStream > 1 )
        filter_coef = abs(frame.dfeout.filtercoef(:, params.dfe.Npostcursor+1));
        
%         colormap('hot');
        M = reshape(filter_coef(1:params.NTXStream*params.NRXStream), params.NTXStream, params.NRXStream);        
        imagesc(M, 'Parent', sims.mimo_axes);
        colorbar('peer',sims.mimo_axes);
    end

end
