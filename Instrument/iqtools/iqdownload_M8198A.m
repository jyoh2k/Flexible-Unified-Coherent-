function result = iqdownload_M8198A(arbConfig, fs, data, marker1, marker2, segmNum, keepOpen, channelMapping, sequence, run)
% Download a waveform to the M8198A
% It is NOT intended that this function be called directly, only via iqdownload
%
% B.Krueger, Th.Dippon, Keysight Technologies 2019
%
% Disclaimer of Warranties: THIS SOFTWARE HAS NOT COMPLETED KEYSIGHT'S FULL
% QUALITY ASSURANCE PROGRAM AND MAY HAVE ERRORS OR DEFECTS. KEYSIGHT MAKES 
% NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND WITH RESPECT TO THE SOFTWARE,
% AND SPECIFICALLY DISCLAIMS THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
% FITNESS FOR A PARTICULAR PURPOSE.
% THIS SOFTWARE MAY ONLY BE USED IN CONJUNCTION WITH KEYSIGHT INSTRUMENTS. 

    result = [];
    if (~isempty(sequence))
        errordlg('Sorry, M8198A does not have a sequencer yet');
        return;
    end

    % open the VISA connection
    f = iqopen(arbConfig);
    if (isempty(f))
        return;
    end
    result = f;
    
    % stop waveform generation
    if (run >= 0)
        if (xfprintf(f, sprintf(':ABORt')) ~= 0)
            % if ABORT does not work, let's not try anything else...
            % we will probably get many other errors
            return;
        end
    end
    
    % perform instrument reset if it is selected in the configuration
    if (isfield(arbConfig,'do_rst') && arbConfig.do_rst)
        xfprintf(f, '*RST');
    end
    
    % set frequency
    if (fs ~= 0)
        xfprintf(f, sprintf(':FREQuency:RASTer %.15g;', fs));
    end
    
    % direct mode waveform download
    for col = 1:size(channelMapping, 2) / 2
        for ch = find(channelMapping(:, 2*col-1))'
            gen_arb_M8198A(arbConfig, f, ch, real(data(:,col)), marker1, segmNum, run);
        end
        for ch = find(channelMapping(:, 2*col))'
            gen_arb_M8198A(arbConfig, f, ch, imag(data(:,col)), marker2, segmNum, run);
        end
    end
    
    if (run == 1 && sum(sum(channelMapping)) ~= 0)
        fprintf(f, ':INIT:IMMediate');
    end
    if (~exist('keepOpen', 'var') || keepOpen == 0)
        fclose(f);
    end
    end



function gen_arb_M8198A(arbConfig, f, chan, data, marker, segm_num, run)
% download an arbitrary waveform signal to a given channel and segment
    if (isempty(chan) || ~chan)
        return;
    end
    segm_len = length(data);
    if (segm_len > 0)
        % scale to DAC values - data is assumed to be -1 ... +1
        data = int8(round(127 * data));
        offset = 0;
        % Download the arbitrary waveform. 
        cmd = sprintf(':TRACe%d:DATA %d,%d', chan, segm_num, offset);
        cmd = [cmd sprintf(',%d', data) '\n'];
        xfprintf(f, cmd);
        xquery(f, '*opc?');
    end
    % turn on output
    xfprintf(f, sprintf(':OUTPut%d ON', chan));
end



function x = fixlength(x, len)
% make a vector with <len> elements by duplicating or cutting <x> as
% necessary
x = reshape(x, 1, numel(x));
x = repmat(x, 1, ceil(len / length(x)));
x = x(1:len);
end



function xbinblockwrite(f, data, format, cmd)
% set debugScpi=1 in MATLAB workspace to log SCPI commands
    if (evalin('base', 'exist(''debugScpi'', ''var'')'))
        fprintf('cmd = %s %s, %d elements\n', cmd, format, length(data));
    end
    binblockwrite(f, data, format, cmd);
    fprintf(f, '');
end


function retVal = xquery(f, s)
% send a query to the instrument object f
    retVal = query(f, s);
% set debugScpi=1 in MATLAB workspace to log SCPI commands
    if (evalin('base', 'exist(''debugScpi'', ''var'')'))
        if (length(retVal) > 60)
            rstr = sprintf('%s... (total %d chars)', retVal(1:60), length(retVal));
        else
            rstr = retVal;
        end
        fprintf('qry = %s -> %s\n', s, strtrim(rstr));
    end
end


function retVal = xfprintf(f, s, ignoreError)
% Send the string s to the instrument object f
% and check the error status
% if ignoreError is set, the result of :syst:err is ignored
% returns 0 for success, -1 for errors

    retVal = 0;
% set debugScpi=1 in MATLAB workspace to log SCPI commands
    if (evalin('base', 'exist(''debugScpi'', ''var'')'))
        fprintf('cmd = %s\n', s);
    end
    fprintf(f, s);
    result = query(f, ':syst:err?');
    if (isempty(result))
        fclose(f);
        errordlg({'The M8198A firmware did not respond to a :SYST:ERRor query.' ...
            'Please check that the firmware is running and responding to commands.'}, 'Error');
        retVal = -1;
        return;
    end
    if (~exist('ignoreError', 'var') || ignoreError == 0)
        while (~strncmp(result, '0,No error', 10) && ~strncmp(result, '0,"No error"', 12))
            errordlg({'M8198A firmware returns an error on command:' s 'Error Message:' result});
            result = query(f, ':syst:err?');
            retVal = -1;
        end
    end
end
