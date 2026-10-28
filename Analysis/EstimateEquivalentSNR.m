function [SNR_dB] =  EstimateEquivalentSNR ( sims,params, PD_in )

%  Usage      : [SNR_dB] =  EstimateEquivalentSNR ( sims,params, PD_in )
%
%  Function   : Estimate equvalent SNR of receiver
%                -Laser Linewidth
%                -Electronic jitter
%                -Shot noise
%                -Electircal amplifier noise
%                -Optical pre-amplifier 
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
%          Not verified yet!! 
%          This is an example for the specific system.
%          To apply this example, you should be careful.

elec_charge = 1.602e-19;
h =6.6e-34;  % Plank constant, J.s

bandwidth(1) = get_bandwidth( sims.channel.RXADC );
bandwidth(2) = get_bandwidth( sims.channel.PD );
bandwidth(3) = get_bandwidth( sims.channel.RFAmp );
bandwidth(4) = params.RXSampleFreq;
ElecBandwidth = min(bandwidth);% Electrical bandwidth of receiver

signal_power = mean(mean(abs(PD_in) .^ 2));
LO_power = mean(mean(abs(PD_in) .^ 2)); % LO power 
% EIN  = ; %Equalivalent input power 


SNR_LO = ElecBandwidth/sims.channel.RXLineWidth/4 ;
%SNR_jitter = 1/8/pi^2/phase_noise_variance
SNR_shot = 2* sims.channel.PD.responsivity * signal_power /elec_charge/ElecBandwidth;
% SNR_amp_noise = 4 * ( sims.channel.PD.responsivity ^ 2 ) * signal_power * LO_power /EIN^2/ElecBandwidth;
%Releative intensity noise
% SNR_RIN =   4 * signal_power /RIN/LO_power /CMMR /ElecBandwidth ;
%SNR_EDFA =   2 * signal_power /h /sims.channel.ssmf.lambda0/db2mag(sims.channel.rxedfa.NF_db) /ElecBandwidth ;

%% Summation
% SNR_sum = i(SNR_LO ^-1 + SNR_shot ^-1 + SNR_amp_noise ^-1 + SNR_EDFA ^-1)^-1;
SNR_sum = (   SNR_shot ^-1 + SNR_amp_noise ^-1)^-1;
SNR_dB = mag2db(SNR_sum);
end


function bw = get_bandwidth(params)
   if (params.bandwidth_en == 1 )
      bw = (params.bandwidth);
   else
      bw = (params.SampleFreq);
   end   
end
