function awg_signal=  KeySight_AWG_Write( txsignal, params)

    %% Keysight AWG M8194 : Number of samples shoulbe the multiples of 128.
    awg_signal = txsignal.txout;
    npadding =  ceil(size(awg_signal,2)/128)*128 -size(awg_signal,2);
    padding = awg_signal(:,end-npadding+1:end);
    awg_signal = [awg_signal  padding ];

    %% Keysight AWG M8194 : Ch1(X Pol, real), Ch2(X Pol, imag)
    fs = params.AWGSampleFreq; 
    correction =0;
    channelMapping = zeros(4,2);channelMapping(1,1)=1;channelMapping(2,2)=1;
    segmentNum =1;

    if (correction)
        [awg_signal(1,:), chMap] = ...
        iqcorrection(awg_signal(1,:), fs, 'chMap', channelMapping);
    end

    %% Keysight AWG M8194 : Ch3(Y Pol, real), Ch4(Y Pol, imag)
    channelMapping = zeros(4,2);channelMapping(3,1)=1;channelMapping(4,2)=1;
    if (correction)
        [awg_signal(2,:), chMap] = ...
        iqcorrection(awg_signal(2,:), fs, 'chMap', channelMapping);
    end

    global SW_DEBUG_ONLY
    if ( SW_DEBUG_ONLY == 0 )
        if (~isempty(awg_signal))            
           channelMapping = zeros(4,2);channelMapping(1,1)=1; 
            iqdownload(real(awg_signal(1,:)) , fs, ...
                   'channelMapping', channelMapping,  ...
                   'segmentNumber', segmentNum  );
           channelMapping = zeros(4,2);channelMapping(2,1)=1; 
            iqdownload(imag(awg_signal(1,:)) , fs, ...
                   'channelMapping', channelMapping,  ...
                   'segmentNumber', segmentNum  );
           channelMapping = zeros(4,2);channelMapping(3,1)=1; 
            iqdownload(real(awg_signal(2,:)) , fs, ...
                   'channelMapping', channelMapping,  ...
                   'segmentNumber', segmentNum  );
           channelMapping = zeros(4,2);channelMapping(4,1)=1; 
            iqdownload(imag(awg_signal(2,:)) , fs, ...
                   'channelMapping', channelMapping,  ...
                   'segmentNumber', segmentNum  );
        end 
    end
end
 
