function awg_signal=  KeySight_AWG_Write1( txsignal, params)

    %% Keysight AWG M8194 : Number of samples shoulbe the multiples of 128.
    tx_data = txsignal.txout;
    if ( params.AWGResampleMethod  ==1 )
        tx_data = [txsignal.txout tx_data(:, end-127:end)]; 
%         tx_data = [txsignal.txout ]; 
        params.AWGResampleMethod = 1;   
        endidx =  ceil(size(txsignal.txout,2)/128)*128 ;
        Y = tx_data(1,1:endidx);  XDelta = 1/params.AWGSampleFreq;
        if ( size(tx_data, 1) == 2)
             Y1 = tx_data(2,1:endidx);   
        end 
    else
        tx_data = [txsignal.txout zeros(size(tx_data,1), 128)];      
        endidx =  ceil(size(txsignal.txout,2)/128)*128 ;
        Y = tx_data(:,1:endidx);  XDelta = 1/params.TXSampleFreq;
        if ( size(tx_data, 1) == 2)
             Y1 = tx_data(2,1:endidx);   
        end
    end
    global SW_PATH 
    mat_file = [SW_PATH 'tmp.mat'];
    save(mat_file, 'Y', 'XDelta');
     if ( size(tx_data, 1) == 2)
        mat_file1 = [SW_PATH 'tmp1.mat'];
        save(mat_file1, 'Y1', 'XDelta');
     end
    
    %% Keysight AWG M8194 : Ch1(X Pol, real),    
    AWGFreq = params.AWGSampleFreq; 
    
     if ( params.AWGResampleMethod  ==1 )
         resampleFactor = 1;
         sampleRate = [];
     else
        resampleFactor = AWGFreq/params.TXSampleFreq;
        sampleRate = AWGFreq;
        params.AWGResampleMethod = params.AWGResampleMethod -1;  
     end
     
    MethodList = { 'resample' 'interpolate' 'fft' 'linear'  'arbitrary' };
    %params.AWGcorrection = 1;
    
    [iqdata, fs, marker, rpt, chMap] = iqloadfile( ...
    'fileType', 'MATLAB (.mat)', 'filename', mat_file, ...
    'sampleRate', sampleRate, 'csvDataColumn', '1', 'csvMarkerMap', '[0 0 0 0]', ...
    'binaryMarkerMap', [1 2 3 4], 'resampleMethod', MethodList{params.AWGResampleMethod}, 'resampleFactor', resampleFactor, ...
    'matlabVarNames', { 'Y' 'XDelta' '' }, 'frequencyShift', [], 'scaleMinMax', [-1 1 1], ...
    'correction', params.AWGcorrection, 'chMap', [1 0; 0 1; 0 0; 0 0], 'windowmethod', [], 'windowfactor', 0);

     if ( size(tx_data, 1) == 2)
        [iqdata1, fs1, marker1, rpt1, chMap1] = iqloadfile( ...
        'fileType', 'MATLAB (.mat)', 'filename', mat_file1 , ...
        'sampleRate', sampleRate, 'csvDataColumn', '1', 'csvMarkerMap', '[0 0 0 0]', ...
        'binaryMarkerMap', [1 2 3 4], 'resampleMethod', MethodList{params.AWGResampleMethod}, 'resampleFactor', resampleFactor, ...
        'matlabVarNames', { 'Y1' 'XDelta' '' }, 'frequencyShift', [], 'scaleMinMax', [-1 1 1], ...
        'correction', params.AWGcorrection, 'chMap', [0 0; 0 0; 1 0; 0 1], 'windowmethod', [], 'windowfactor', 0);

     end

    global SW_DEBUG_ONLY
    if ( SW_DEBUG_ONLY == 0 )
        if (~isempty(iqdata))
            iqdownload(repmat(iqdata, rpt, 1), fs, ...
                'chMap', chMap, 'segmentNumber', 1, 'marker', repmat(marker, rpt, 1));
        end 
         if ( size(tx_data, 1) == 2)
            if (~isempty(iqdata1))
                iqdownload(repmat(iqdata1, rpt1, 1), fs1, ...
                    'chMap', chMap1, 'segmentNumber', 1, 'marker', repmat(marker1, rpt1, 1));
            end 
         end
    end

    awg_signal = iqdata;
    if ( size(tx_data, 1) == 2)
            awg_signal =[ reshape(iqdata, 1, length(iqdata)); reshape(iqdata1, 1, length(iqdata));];
    else
        awg_signal = reshape(iqdata, 1, length(iqdata));
    end
    if (length(awg_signal) > (524288 * 4) )
         f = warndlg('Size should not be larger than 524288');
    end
end

 
