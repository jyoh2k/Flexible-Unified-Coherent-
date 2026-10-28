
function   SubShowWaveform( equalized_dfe, transmitted, one_panel, const_axes, const_text, consthandle, hist_axes, params, frame )
    if ( one_panel == 0 && ~isempty(consthandle.figure1) && ishandle(consthandle.figure1))
        set( consthandle.figure1, 'UserData', frame);
    end 
    
    hold(const_axes, 'off');
    hold(hist_axes, 'off');
    set( consthandle.popupmenu1, 'Value', 1);      
    color_str = {'y' 'r' 'g' 'b' 'y' 'm' 'g' 'c' 'y' 'r' 'g' 'b' 'y' 'm' 'g' 'c'};
    head=1000;
    equalized_dfe = equalized_dfe(1:end-200);
    max_nb0 =0 ;
    for ilist=1:length(params.dfe.mapper_list)
        pam0 = find( transmitted  == params.dfe.mapper_list(ilist));
        idx = find(pam0 < length( equalized_dfe)) ;
        pam0 = pam0(idx);
        plot( const_axes, pam0, equalized_dfe(pam0), [ color_str{ilist} '*']);
        eq_dc = filter( ones(1, 1024)/1024, 1,  equalized_dfe(pam0)-params.dfe.mapper_list(ilist));
        [nb0, xb0] = hist(equalized_dfe(pam0(head:end)), 80);
        plot( hist_axes, nb0, xb0,  [ color_str{ilist} '-']);
        if ( size(equalized_dfe(pam0),2) ~= 0 )
            hold(const_axes, 'on');
            hold(hist_axes, 'on');
        end 
        plot( const_axes, pam0, eq_dc(1,1:length(pam0))+params.dfe.mapper_list(ilist),  'w-');
        max_nb0 = max(max_nb0,max(nb0)); 
    end
    hold(const_axes, 'off');
    hold(hist_axes, 'off');
    xlim  (const_axes, [1 size(equalized_dfe,2) ]) ;
    equalized_dfe = equalized_dfe(1000:end);
    ylim( const_axes, [min(equalized_dfe)-0.1 max(equalized_dfe)+0.1]); 
    ylim( hist_axes, [min(equalized_dfe)-0.1 max(equalized_dfe)+0.1]);
    xlim  (hist_axes, [max(max_nb0)*-0.1   max(max_nb0) *1.2 ]) ;
    default_color(hist_axes);
    default_color(const_axes);
end

