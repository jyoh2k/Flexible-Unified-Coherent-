function  [sim, frame] = SkewAnalysis( sim, params, frame)

%  Usage      : [sim, frame]= SkewAnalysis( sim, params, frame)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
if (sim.show_skew == 0 ) 
    return;
end



if (  isempty(sim.psd_axes)   || ~ ishandle(sim.psd_axes) )
    [sims.psd_axes, sims.psd_text, sims.psdhandle] = PSD();
    set(sim.psd_text, 'String', 'Skew Analysis');
end

    set(sim.psd_text, 'String', 'Skew Analysis(ps)');
%% Skew 

    hold(sim.psd_axes, 'off'); 
    ps=1e-12;    
    x_coor = 1/(params.BaudFreq)/size(frame.skewest,2)*[1:size(frame.skewest,2)]/ps;
    linestr='';             
    for idim=1:size(frame.skewest,1)
        plot(sim.psd_axes, x_coor, real(frame.skewest(idim,:)), ['rs-' linestr],'LineWidth', 2);
        hold(sim.psd_axes, 'on');
        plot(sim.psd_axes, x_coor, imag(frame.skewest(idim,:)), ['bs-' linestr],'LineWidth', 2);
        linestr='-';        
    end
   
    xlim  (sim.psd_axes, [x_coor(1) x_coor(end)]); 
    default_color(sim.psd_axes);
 
 
end