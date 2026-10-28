function out  = Mixer_IF( in, params )
%  Usage      : out  = Mixer1( in, params  )
%  Function   :
%     - Passband mixing is included in Mixer model .
%  Port
%     1. in     : input signals
%     2. params : Mixer parameters
%     1. out    : output signals
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

   %  High frequency component of mixer will be eliminated by bandwidth of
   %  mixer. So  bandpass filter is not implemented here.
    
    
    
     
    params.bandwidth_en = 0;
    mixer_baseband  = Mixer( in, params );
    
    if ( params.MixingFreq ~= 0)
        params.bandwidth_en = 1; 
        out_passband = baseband2passband( mixer_baseband, params.SampleFreq,  params.MixingFreq);  
        out = ChBandwidth( out_passband, params.FilterCoef, params.bandwidth_en);
    else
        out = ChBandwidth( mixer_baseband, params.FilterCoef, params.bandwidth_en);
    end 
end