function out  = OCF(  params )
%  Usage      : out  = OCF( in, params  )
%  Function   :
%     1.  Simple optical comb filter (source ) model with phase noise only. 
%  Port
%     1. params : Optical comb filter parameters
%     2. out    :  output signals
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :


    % zeropad                  = max(0, OCF.min_sample_number_pn - size(AIN,2));
    % AIN_pad = [ AIN, zeros(size(AIN,1), zeropad)];

    optical_sources = exp( 2* pi * 1j * (params.freq' / params.SampleFreq * [0 :1:params.min_sample_number_pn-1]) );
    [out, PhaseNoise]  = AddPhaseNoise_profile( optical_sources, params.SampleFreq, params.psd_f_hz, params.psd_val_dbc_per_hz ) ;

end
