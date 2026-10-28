function  [sim, frame] = STBCAnalysis( sim, params, frame)

%  Usage      : [sfo]= STBCAnalysis( sim, params, frame)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

     
    if (sim.show_stbc )
        dfeout = frame.stbcout;

        idx_axes = [1:size(dfeout.h,1)];
        for iaxes=idx_axes
            if (  isempty(sim.dfe1_axes{iaxes})   || ~ ishandle(sim.dfe1_axes{iaxes}))
                [sim.dfe1_axes{iaxes}, sim.dfe1_text(iaxes), sim.dfe1_axes1(iaxes)]=TPRFigure();
                str = get_string( iaxes, params.NTXStream );
                set(sim.dfe1_text(iaxes), 'String', ['Final Symbol Equalizer ', str] );
            end

            %% Estimated accumulated timing error 
            filtercoeft =  dfeout.h (iaxes,:, :);
            filtercoef = dfeout.h (iaxes,:, end);
            err = dfeout.error(1,:) ;
            err = (dfeout.p(1,:));
            %err = real(exp(1j* dfeout.p(1,:)));
            SubSTBCAnalysis( sim.dfe1_axes{iaxes}, sim.dfe1_axes1(iaxes), filtercoef ,filtercoeft, err, params.stbc); 
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


function  SubSTBCAnalysis( dfe_axes, dfe_axes1, filtercoef ,filtercoef1, p_ang, params)
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
%           p =   plot  (  dfe_axes1, ...
%                   1:length(filtercoef), imag(filtercoef), [color_str{idx} '--']);         
    end 
%         filtercoef =  (squeeze(filtercoef1(1,params.Nffe+1,:)));
    p =   plot  (  dfe_axes1, ...
                params.PRL*(1:length(p_ang)), real(p_ang), color_str{1});      
 
    title(dfe_axes1,'Filter convergence');
    xlim(dfe_axes1, [1 length(filtercoef)*params.PRL ]);
    default_color(dfe_axes1);
    hold(dfe_axes1, 'off');
end
