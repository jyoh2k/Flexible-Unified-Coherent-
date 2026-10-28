
function   OFD( in , Rs, Welch)

%  Usage      : OFD( in , Rs)
%  Function   :
%     Spectrum analyzer ( Center DC)
% Port 
%     in        : signal
%     Rs       : Sampling frequency
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    if ( nargin < 3)
        Welch = 0;
    end 
    figure;hold

    if (Welch == 1)
        Hs=spectrum.welch;

       if ( size(in,2) == 1 )
           in  = reshape(in(:,1), 1, length(in(:)));
       end
        Hpsd = psd(Hs, in(1,:), 'Fs', Rs, 'CenterDC', 1);
        Pw=Hpsd.Data;
        Fw=Hpsd.Frequencies;
        plot(axes, Fw,mag2db(Pw), 'g', 'LineWidth', 2);
 
%         PW1=fftshift(Pw);
%         plot(axes, Fw,mag2db(Pw/PW1(1)), 'g',  'LineWidth', 2); 
    else
        if ( version('-release') == '2014a' )
            Hs=spectrum.periodogram;
            % Hs=spectrum.welch;
            psd(Hs,in(1,:), 'Fs',Rs, 'CenterDC', 1)
        else

    %         [pxx,w] = periodogram(in);
            freq = fftshift(fft(in));
            pxx = abs(freq);
            w=[-Rs/2:Rs/length(freq): Rs/2-Rs/length(freq)];
            plot(w,mag2db(pxx/max(pxx)));
            grid on;
        end
    end 
end 
