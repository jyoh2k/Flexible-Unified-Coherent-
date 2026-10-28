
function NF_dB = noise_dBm2NF(noise_density_dBm, BW, gain_dB)

% Convert noise density in dBm to noise figure using the following
% equation.
%  - noise_figure  = P,,NOUT,, - (-174dBm/Hz + 10 * log10(BW) + Gain)
%   ( https://www.maximintegrated.com/en/app-notes/index.mvp/id/2875, gain method )


%  noise_density_dBm = params.NF_dB + (-174  + 10 * log10(BW) + params.gain_dB);
NF_dB = noise_density_dBm - (-174  + 10 * log10(BW) +  gain_dB);
end