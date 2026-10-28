function [AOUT, PhaseNoise]  = AddPhaseNoise_profile( AIN, SampleFreq, PSD_f, PSD_dBc_Hz ) 

%  Usage      : [AOUT, PhaseNoise] = AddPhaseNoise_profile( AIN, SampleFreq, PSD_f, PSD_dBc_H );    
%  Function   :
%     1. Generate phase noise and apply it into original signal.       
%     2. AIN        : Original signal
%     3. SampleFreq : Sample frequency of signal
%     4. PSD_f      : Frequency 
%     5. PSD_dBc_Hz : Power spectral density value
%     6. AOUT       : Signal with phase noise
%     7. PhaseNoise : Generated phase noise
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :


if ( PSD_f(2) == 0 )
    AOUT =AIN;
    PhaseNoise = zeros(1,size(AIN,2));
    return;
end

    fs_Hz = SampleFreq ;
    N = size(AIN,2);
    N = ceil(N/2) * 2;
    % 1) Defining the frequency vector
    freq_v_Hz = [0:N/2]/N*fs_Hz;
    delta_f   = fs_Hz/N;
    slope    = [PSD_dBc_Hz(2:end) - PSD_dBc_Hz(1:end-1) ]./...
                (log10(PSD_f(2:end)) - log10(PSD_f(1:end-1)));
 

    % interpolating the phase noise psd values
    psd_ssb_dB = -Inf*ones(1,N/2+1); % from [0:N/2]
    for ii=1:length(PSD_f)-1
       [tt1 fl_idx ] = (min(abs(PSD_f(ii) - freq_v_Hz)));
       [tt2 fr_idx ] = (min(abs(PSD_f(ii+1) - freq_v_Hz)));	
       fvec = [freq_v_Hz(fl_idx):delta_f:freq_v_Hz(fr_idx)];
       psdvec = slope(ii)*log10(fvec+eps) + PSD_dBc_Hz(ii) - slope(ii)*log10(PSD_f(ii)+eps);
       psd_ssb_dB(fl_idx:fr_idx) = psdvec;
    end

    % forming the full vector from [-N/2:-1 0:N/2-1 ]/N*fs_Hz
    psd_dB                  = -Inf*ones(1,N);
    psd_dB([-N/2:-1]+N/2+1) = psd_ssb_dB([N/2+1:-1:2]);
    psd_dB([0:N/2-1]+N/2+1) = psd_ssb_dB(1:N/2);
    
    
   psd_linear = 10.^(psd_dB/20);

    psd_linear([0]+N/2+1) = 0; % 2020-06-11 Rha, To remove DC phase noise

   % defining frequency vector
   phase_noise_freq       = 1/sqrt(2)*(randn(1,N) + 1i*randn(1,N));
   % Normalization of resolution to unity
   phase_noise_freq_scale = N*sqrt(delta_f)*phase_noise_freq;
%    phase_noise_freq_scale =   phase_noise_freq * delta_f ;
   phase_noise_freq_psd   = phase_noise_freq_scale .*psd_linear;
   
   % converting to time domain
   PhaseNoise      = sqrt(2)* real(ifft(fftshift(phase_noise_freq_psd))); 
   PhaseNoise      = PhaseNoise(1,1:size(AIN,2));
   AOUT =  AIN .* ( ones(size(AIN,1), 1) * exp(1i*PhaseNoise));
end
 
