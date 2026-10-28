function  [sim] = ShowWaveform( sim, params, frame)

%  Usage      : [sim]= ShowWaveform( sim, params, frame)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

 if (sim.show_constellation ==0 )
     return;
 end


 
for iaxes=1:size(frame.equalized,1)
    if ( sim.one_panel == 1 )
        sim.const_axes{iaxes} =sim.const_axes{1};
        sim.const_text(iaxes) =sim.const_text(1); 
        sim.consthandle(iaxes) = sim.consthandle(1);
        sim.hist_axes(iaxes) = sim.hist_axes(1);
    end
    if (  isempty(sim.const_axes{iaxes})   || ~ ishandle(sim.const_axes{iaxes}) )        
        [sim.const_axes{iaxes}, sim.const_text(iaxes), sim.hist_axes(iaxes), sim.consthandle(iaxes)] = Waveform();
        set(sim.const_text(iaxes), 'String', ['Waveform', num2str(iaxes)] );
    end

    frame.iaxes = iaxes;
    frame.Nbitspersymbol = params.Nbitspersymbol ;     
    frame.RXoversample = params.RXoversample ;     

    equalized_dfe = frame.equalized_dfe(1, :);
    transmitted   = frame.txsignal.trainingseq(1,:); 
    SubShowWaveform( equalized_dfe, transmitted, sim.one_panel, sim.const_axes{iaxes}, sim.const_text(iaxes), sim.consthandle(iaxes), sim.hist_axes(iaxes), params, frame );
end
end

% function   SubShowWaveform( equalized_dfe, transmitted, one_panel, const_axes, const_text, consthandle, hist_axes, params, frame )
%     if ( one_panel == 0 && ~isempty(consthandle.figure1) && ishandle(consthandle.figure1))
%         set( consthandle.figure1, 'UserData', frame);
%     end 
%     set( consthandle.popupmenu1, 'Value', 1);
%     pam0 = find( transmitted  == params.mapper_list(1));
%     pam1 = find( transmitted  == params.mapper_list(2));
%     pam2 = find( transmitted  == params.mapper_list(3));
%     pam3 = find( transmitted  == params.mapper_list(4));
%     idx = find(pam0 < length( equalized_dfe)) ;
%     pam0 = pam0(idx);
%     idx = find(pam1 < length( equalized_dfe)) ;
%     pam1 = pam1(idx);
%     idx = find(pam2 < length( equalized_dfe)) ;
%     pam2 = pam2(idx);
%     idx = find(pam3 < length( equalized_dfe)) ;
%     pam3 = pam3(idx);
%     plot( const_axes, ...
%             pam0, equalized_dfe(pam0), 'y*', ...
%             pam1, equalized_dfe(pam1), 'r*', ...
%             pam2, equalized_dfe(pam2), 'g*', ...
%             pam3, equalized_dfe(pam3), 'b*'  ...
%             );
%     xlim  (const_axes, [1 size(equalized_dfe,2) ]) 
%     head=1000;
%     [nb0, xb0] = hist(equalized_dfe(pam0(head:end)), 80);
%     [nb1, xb1] = hist(equalized_dfe(pam1(head:end)), 80);
%     [nb2, xb2] = hist(equalized_dfe(pam2(head:end)), 80);
%     [nb3, xb3] = hist(equalized_dfe(pam3(head:end)), 80);
%     default_color(const_axes);
%      plot( hist_axes, ...
%             nb0, xb0, 'y-', ...
%             nb1, xb1, 'r-', ...
%             nb2, xb2, 'g-', ...
%             nb3, xb3, 'b-'  ...
%             );
%        
%     ylim( const_axes, [min(equalized_dfe)-0.1 max(equalized_dfe)+0.1]); 
%     ylim( hist_axes, [min(equalized_dfe)-0.1 max(equalized_dfe)+0.1]);
%     xlim  (hist_axes, [0  max([nb0 nb1 nb2 nb3]) *1.2 ]) ;
%     default_color(hist_axes);
% end
