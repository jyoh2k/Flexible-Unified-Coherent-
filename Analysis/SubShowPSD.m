
function SubShowPSD(chidx, frame, params, txsignal, axes, signal_str)

    Welch =0 ;
    if ( strcmp(signal_str ,  'Received') )
        in = frame.received(chidx, :);
        Rs = params.OSCFreq;
    end
    if ( strcmp(signal_str ,  'Received Welch') )
        in = frame.received(chidx, :);
        Rs = params.OSCFreq;
        Welch =1;
    end
    if ( strcmp(signal_str ,  'Eq Welch') )
        in = frame.equalized(chidx, :);
        Rs = params.RXSampleFreq;
        Welch =1;
    end

    if ( strcmp(signal_str ,  'TX after matched') )
        in = real(txsignal.txout_filter(chidx, :));
        Rs = params.TXSampleFreq;
    end
    if ( strcmp(signal_str ,  'TX after preemp') )
        in = real(txsignal.txout_ov_pre(chidx, :));
        Rs = params.TXSampleFreq;
    end
    if ( strcmp(signal_str ,  'Transmitted') )
        if ( size(txsignal.awg_signal,1) > size(txsignal.awg_signal,2))
            in = (txsignal.awg_signal(:, chidx));  
        else
            in = (txsignal.awg_signal(chidx, :));  
        end
        Rs = params.AWGSampleFreq;
    end

    if ( strcmp(signal_str ,  'Transmitted Welch') )
        if ( size(txsignal.awg_signal,1) > size(txsignal.awg_signal,2))
            in = (txsignal.awg_signal(:, chidx));  
        else
            in = (txsignal.awg_signal(chidx, :));  
        end
        Rs = params.AWGSampleFreq;
        Welch =1;
    end
    
    if ( strcmp(signal_str ,  'TX DSP out') )
        in = txsignal.txout(chidx, :);
        Rs = params.TXSampleFreq;
    end
    
    if ( strcmp(signal_str ,  'TX DSP out Welch') )
        in = txsignal.txout(chidx, :);
        Rs = params.TXSampleFreq;
        Welch =1;
    end
    if ( strcmp(signal_str ,  'ADC In') )
        in = frame.ADCin(chidx, :); 
        Rs = params.OSCFreq;
    end
    if ( strcmp(signal_str ,  'ADC In Welch') )
        in = frame.ADCin(chidx, :); 
        Rs = params.OSCFreq;
        Welch =1;
    end
    if ( strcmp(signal_str ,  'DAC Out') )
        in = frame.channel.DACout(chidx, :); 
        Rs = frame.channel.SampleFreq;
    end
    if ( strcmp(signal_str ,  'AWG Out') )
        in = frame.txsignal.awg_signal(chidx, :);  
        Rs = frame.params.AWGSampleFreq;
    end
    if ( strcmp(signal_str ,  'Wireless RF Out') )
        in = frame.channel.TXRFout(chidx, :);
        Rs = frame.channel.SampleFreq;
    end
    if ( strcmp(signal_str ,  'LNA Out') )
        in = frame.channel.rx_lna_out(chidx, :);
        Rs = frame.channel.SampleFreq;
    end
    if ( strcmp(signal_str ,  'Mixer Out') )
        in = frame.channel.rx_mixer_out(chidx, :);
        Rs = frame.channel.SampleFreq;
    end
    if ( strcmp(signal_str ,  'PostEmphais') )
        in = frame.postemphasis(chidx, :); 
        Rs = params.OSCFreq;
    end
    if ( strcmp(signal_str ,  'PostEmphais Welch') )
        in = frame.postemphasis(chidx, :); 
        Rs =params.OSCFreq;
        Welch =1;
    end

    if ( strcmp(signal_str ,  'Fiber Out') )
        in = frame.channel.fiber_out(chidx, :);
        Rs = frame.channel.SampleFreq;
    end
    if ( strcmp(signal_str ,  'Fiber In') )
        in = frame.channel.fiber_in(chidx, :); 
        Rs = frame.channel.SampleFreq;
    end
    if ( strcmp(signal_str ,  'ADC Out') )
        in = frame.channel.ADC_out(chidx, :); 
        Rs = frame.channel.SampleFreq;
    end
    if ( strcmp(signal_str ,  'PD Out') )
        in = frame.channel.pd_out(chidx, :); 
        Rs = frame.channel.SampleFreq;
    end 
    GHz =1e9;
    pwr_in = sqrt(mean(abs(in).^2)); 
    draw_psd ( axes, in, Rs, Welch);
    % ylim  (axes, [-150 15]); 
    xlabel(axes,'Freq. (GHz)', 'Color','white');
    grid(axes, 'on');
    default_color(axes);
end


function draw_psd (axes, in, Rs, Welch)
% if ( version('-release') == '2019a' )
if ( Welch == 0 )
        [pxx,w] = periodogram(in);
    freq = fftshift(fft(in));
    pxx = abs(freq);
    w=[-Rs/2:Rs/length(in): Rs/2-Rs/length(in)];
    plot  ( axes, w,mag2db(pxx/max(pxx)), 'y');
else
%     Hs=spectrum.periodogram;
    Hs=spectrum.welch;
%     psd(Hs,in(1,:), 'Fs',Rs, 'CenterDC', 1)
   if ( size(in,2) == 1 )
       in  = reshape(in(:,1), 1, length(in(:)));
   end
    Hpsd = psd(Hs, in(1,:), 'Fs', Rs, 'CenterDC', 1);
    Pw=Hpsd.Data;
    Fw=Hpsd.Frequencies;
    plot(axes, Fw,mag2db(Pw), 'y', 'LineWidth', 2);
    global SW_PATH;
    save( [SW_PATH '/Pw.mat'], 'Pw');
end


end 
