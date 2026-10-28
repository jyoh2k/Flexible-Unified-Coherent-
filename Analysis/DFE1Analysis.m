function  [sim, frame] = DFE1Analysis( sim, params, frame)

%  Usage      : [sfo]= DFEAnalysis( sim, params, tpr)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

     
    if (sim.show_dfe1 )
        dfeout = frame.dfe1out;

        idx_axes = [1:size(dfeout.filtercoef,1)];
        idx_axes = [1:params.NTXStream*params.NRXStream];
        if ( params.dfe1.update_type == 3 )
            idx_axes = [0:params.NTXStream-1] * ( params.NTXStream +1)+1;
        end
        for iaxes=idx_axes(1:min(4,end))
            if (  isempty(sim.dfe1_axes{iaxes})   || ~ ishandle(sim.dfe1_axes{iaxes}))
                [sim.dfe1_axes{iaxes}, sim.dfe1_text(iaxes), sim.dfe1_axes1(iaxes)]=TPRFigure();
                str = get_string( iaxes, params.NTXStream );
                set(sim.dfe1_text(iaxes), 'String', ['Final Symbol Equalizer ', str] );
            end

            %% Estimated accumulated timing error 
            filtercoef =  dfeout.filtercoef (iaxes,end:-1:1);
            err = dfeout.ffe_error(iaxes,:) ;
            SubDFEAnalysis( sim.dfe1_axes{iaxes}, sim.dfe1_axes1(iaxes), filtercoef , err);
        end
    end
end

function str = get_string( iaxes, NStream )
%  sidx = (is - 1 )* NStream + os ; % equation index 
%  For example, input stream : 3 , output stream:2  
%  sidx = 3: is = 2, os = 1 
    i_num = floor( (iaxes-1) /NStream )+1;
    o_num = mod( iaxes-1, NStream)+1;
    str = [num2str(i_num) , '->', num2str(o_num)];
end 

function  SubDFEAnalysis( dfe_axes, dfe_axes1, filtercoef , err);
    hold(dfe_axes, 'off');
    p = stem  (dfe_axes,...
        1:length( filtercoef), imag(filtercoef), 'y' );
    hold(dfe_axes, 'on');
    p = stem  (dfe_axes,...
        1:length(filtercoef), real(filtercoef), 'r' );
    title (dfe_axes,'Filter coefficients');  
    default_color(dfe_axes);
    
    %% Estimated timing error 
    p =   plot  (  dfe_axes1, ...
             1:length(err), real(err), 'r', ...
             1:length(err), imag(err), 'g');
    title(dfe_axes1,'Estimated mean error');
    xlim(dfe_axes1, [1 length(err)]);
    default_color(dfe_axes1);
end
