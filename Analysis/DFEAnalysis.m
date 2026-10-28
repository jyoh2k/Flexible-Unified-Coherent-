function  [sim, frame] = DFEAnalysis( sim, params, frame)

%  Usage      : [sfo]= DFEAnalysis( sim, params, tpr)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

     
    if (sim.show_dfe )
        dfeout = frame.dfeout;

        idx_axes = [1:size(dfeout.filtercoef,1)];
        idx_axes = [1:params.NTXStream*params.NRXStream];
        if ( params.dfe.update_type == 3 ) % SISO
            idx_axes = [0:params.NTXStream-1] * ( params.NTXStream +1)+1;
        end
        
        for iaxes=idx_axes(1:min(4,end))
            if (  isempty(sim.dfe_axes{iaxes})   || ~ ishandle(sim.dfe_axes{iaxes}))
                [sim.dfe_axes{iaxes}, sim.dfe_text(iaxes), sim.dfe_axes1(iaxes)]=TPRFigure();
                str = get_string( iaxes, params.NTXStream );
                set(sim.dfe_text(iaxes), 'String', ['First Symbol Equalizer ', str] );
            end

            %% Estimated accumulated timing error 
            filtercoef =  dfeout.filtercoef ; 
            filtercoeft=  dfeout.filtercoeft ; 
            
            err = dfeout.ffe_error(iaxes,:) ;
            if ( size(dfeout.error,1) >= iaxes )
                err = dfeout.error(iaxes,:) ;
            end
            SubDFEAnalysis(  sim.dfe_axes{iaxes}, sim.dfe_axes1(iaxes), filtercoef(iaxes,:) , filtercoeft(iaxes,:, :), err, params.dfe );
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

function  SubDFEAnalysis( dfe_axes, dfe_axes1, filtercoef ,filtercoef1, err, params)
    hold(dfe_axes, 'off');
    p = stem  (dfe_axes,...
        1:length( filtercoef), imag(filtercoef), 'y' );
    hold(dfe_axes, 'on');
    p = stem  (dfe_axes,...
        1:length(filtercoef), real(filtercoef), 'r' );
    title (dfe_axes,'Filter coefficients');  
    default_color(dfe_axes);
    
    %% Estimated timing error 
    %p =   plot  (  dfe_axes1, ...
    %         1:length(err), real(err), 'r', ...
    %         1:length(err), imag(err), 'g');
    
%     p =   plot  (  dfe_axes1, ...
%              1:length(err), abs(err), 'g');
%     title(dfe_axes1,'Estimated mean error');
%     xlim(dfe_axes1, [1 length(err)]);
%     default_color(dfe_axes1);
    
    %% Filter convergence
    color_str = { 'c'  'r'  'y'  'g' 'm' 'b'   'c' 'y' 'r' 'g' 'b' 'y' 'm' 'g' 'c'};
    off = size(filtercoef1, 2); off = floor(off /2+0.5);
    off = params.Nffe - params.Npostcursor;
    off =   params.Npostcursor+1;
    idx_list=[-1:1];
    if ( off < 5)
        idx_list =0;
    end
    for idx=off+idx_list
        filtercoef =  (squeeze(filtercoef1(1,idx,:)));
         p =   plot  (  dfe_axes1, ...
                 params.PRL*(1:length(filtercoef)), real(filtercoef), color_str{idx-off -idx_list(1)+2});  
        hold(dfe_axes1, 'on');  
%          p =   plot  (  dfe_axes1, ...
%                  1:length(filtercoef), imag(filtercoef), [color_str{idx} '--']);         
    end
    if ( params.Nfbe == 1 )
        filtercoef =  (squeeze(filtercoef1(1,params.Nffe+1,:)));
     p =   plot  (  dfe_axes1, ...
                 params.PRL*(1:length(filtercoef)), real(filtercoef), color_str{idx-off+3});      
    end
    title(dfe_axes1,'Filter convergence');
    xlim(dfe_axes1, [1 length(filtercoef)*params.PRL ]);
    default_color(dfe_axes1);
    hold(dfe_axes1, 'off');
end
