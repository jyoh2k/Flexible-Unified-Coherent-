function [out_bw, PhaseNoise]  = Mixer( in, params )
%  Usage      : [out, phase_noise]  = Mixer( in, params  )
%  Function   :
%     - Only insertion loss.phase noise, noise figure and bandwidth are
%       modelled.
%     - Mixer function is not implemented.
%  Port
%     1. in     : input signals
%     2. params : Mixer parameters
%     1. out    :  output signals
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    [in_phase_noise, PhaseNoise]  = AddPhaseNoise_profile( in, params.SampleFreq, params.psd_f_hz, params.psd_val_dbc_per_hz ) ;

    mW = 1e-3;
    if ( params.nonoise == 1)
        out =in * db2mag(- params.loss_dB) ;
    else
        if ( params.bandwidth_en ==  1)
            BW                = params.bandwidth ;
        else
            BW                = params.SampleFreq ;
        end
        noise_density_dBm = params.NF_dB + (-174 + 10 * log10(BW) - params.loss_dB);
        noise_density     = 10^(noise_density_dBm/10) * mW;
        noise             = sqrt( noise_density/2 )*(randn(size(in_phase_noise)) + 1j*randn(size(in_phase_noise)));
        out               = in_phase_noise * db2mag(- params.loss_dB) + noise;
    end
    
    out_bw = ChBandwidth( out, params.FilterCoef, params.bandwidth_en);
    
end
