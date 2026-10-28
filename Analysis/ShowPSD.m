function  [sims] = ShowPSD( sims, params, frame)

%  Usage      : [sims]= ShowPSD( sims, params, frame)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

     if (sims.show_psd ==0 )
         return;
     end

    if (  isempty(sims.psd_axes)   || ~ ishandle(sims.psd_axes) )
        [sims.psd_axes, sims.psd_text, sims.psdhandle] = PSD();
    end

    received = frame.received ;
    GHz      = 1e9;
    Rs       = params.RXSampleFreq/GHz;
    if ( sims.run_mode == 1 )
    end        
    signals  = frame;
    signals.txsignal =  frame.txsignal; 
    signals.received   = frame.received ; 

    set( sims.figure_handle.figure1, 'UserData', signals);
    set( sims.psdhandle.popupmenu1, 'Value', 1);    
    Welch =1;
    draw_psd (sims.psd_axes, received(1,:), Rs, Welch);
    grid(sims.psd_axes,'on');
    %ylim  (sims.psd_axes, [-90 10]); 
    default_color(sims.psd_axes);
 
end

function draw_psd (axes, in, Rs, Welch) 
    if ( Welch == 0 )
            [pxx,w] = periodogram(in);
        freq = fftshift(fft(in));
        pxx = abs(freq);
        w=[-Rs/2:Rs/length(in): Rs/2-Rs/length(in)];
        plot  ( axes, w,mag2db(pxx/max(pxx)), 'y');
    else
    %     Hs=spectrum.periodogram;
        Hs=spectrum.welch; 
        Hpsd = psd(Hs, in(1,:), 'Fs', Rs, 'CenterDC', 1);
        Pw=Hpsd.Data;
        Fw=Hpsd.Frequencies;
        plot(axes, Fw,mag2db(Pw), 'y', 'LineWidth', 2); 
    end
end


