function out_bw  = AWG( in, params )
%  Usage      : out  = AWG( in, params  )
%  Function   :
%     - Only insertion loss and bandwidth are modelled.
%  Port
%     1. in     : input signals
%     2. params : AWG parameters
%     1. out    : output signals
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    out    = in * db2mag(- params.loss_dB) ;
    out_bw = ChBandwidth( out, params.FilterCoef, params.bandwidth_en);
    
end
