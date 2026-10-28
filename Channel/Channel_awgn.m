function [AOUT, sims] = Channel( sims, AIN, channel )

%  Usage      : [AOUT] = Channel( AIN, channel )
%  Function   :
%     1. Channel with CFO, SFO, STO, linewidth, and jitter
%     2. AIN        : Original signal
%     3. AOUT       : Signal with phase noise
%     4. channel    : Parameter for simsple channel
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :


    AIN_up                   = Resample( AIN,  channel.TXSampleFreq,  channel.SampleFreq);

    esignal_in               = AIN_up;

    mzm_out               = AIN_up;
    fiber_in                 = AIN_up;
    fiber_out                = AIN_up;

    [AIN_up]                 = FiberOpticChannel( AIN_up, channel );
    fiber_out_sfo                = AIN_up;
    pd_out                   = AIN_up;

    esignal_adc              = AIN_up; 
    AIN_dn                   = RateConversion( AIN_up, channel.SampleFreq, channel.RXSampleFreq);

    % AGC for ADC (Simulation) 
    AIN_dn                   = AGC( AIN_dn, channel.AGC);
    [AIN_dn, AWGN]           = AddAWGN( AIN_dn, channel.SNRdB, channel.enAWGN );   
    AOUT                     = AIN_dn;

    %% Analysis

    sims.channelout.DAC_in     = esignal_in;
    sims.channelout.fiber_out  = fiber_out;
    sims.channelout.fiber_in   = fiber_in;
    sims.channelout.pd_out     = pd_out;
    sims.channelout.ADC_out    = esignal_adc;
    sims.channelout.SampleFreq = channel.SampleFreq;
    sims.txpn  = zeros(size(AIN_up));
    sims.rxpn  = zeros(size(AIN_up));
end
