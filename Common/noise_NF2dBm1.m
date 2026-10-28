
function noise_power_dBm = noise_NF2dBm1(params)

% Convert noise density in dBm to noise figure using the following
% equation.
%  - noise_figure  = P,,NOUT,, - (-174dBm/Hz + 10 * log10(BW) + Gain)
%   ( https://www.maximintegrated.com/en/app-notes/index.mvp/id/2875, gain method )
%  noise_density_dBm = params.NF_dB + (-174  + 10 * log10(BW) + params.gain_dB);
    
    if ( params.bandwidth_en == 1 )         
        noise_power_dBm = params.NF_dB + (-174  + 10 * log10(params.bandwidth) +  params.gain_dB);        
    else        
        noise_power_dBm = params.NF_dB + (-174  + 10 * log10(params.SampleFreq) +  params.gain_dB);
    end
end