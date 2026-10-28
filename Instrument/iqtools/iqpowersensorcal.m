function result = iqpowersensorcal(varargin)
% Generate amplitude correction based on power sensor measurement
% Arguments are given as attrtibute/value pairs. Possible arguments:
%  - offset: frequency offset in Hz that is added to all tones before
%         taking a measurement (use offset when tones are upconverted)
%         if offset is negative, tone frequencies are subtracted
%  - tone: vector of tones at which measurement is performed.
%  - fs: samplerate to be used
%  - update: if set to 0, will not write the ampCorr file. (default = 1)
%  - plot: if set to 0, will not plot the result (default = 1)
%  - recalibrate: If set to 1, the list of frequencies is taken from
%          the existing amplitude correction file (iqampCorrFilename()). The
%          measurement is added to the existing correction in this case.
%  - msgbox: msgbox handle (will be reused)
%% parse optional arguments
result = [];
tone = [];
fs = 0;
correction = 0;
offset = 0;
update = 1;
doPlot = 1;
recalibrate = 0;
hMsgBox = [];
handles = [];
chMap = [1 0; 1 0];
i = 1;
while (i <= nargin)
    if (ischar(varargin{i}))
        switch lower(varargin{i})
            case 'offset'; offset = varargin{i+1};
            case 'tone'; tone = varargin{i+1};
            case 'fs'; fs = varargin{i+1};
            case 'samplerate'; fs = varargin{i+1};
            case 'correction'; correction = varargin{i+1};
            case 'update'; update = varargin{i+1};
            case 'plot'; doPlot = varargin{i+1};
            case 'recalibrate'; recalibrate = varargin{i+1};
            case 'msgbox'; hMsgBox = varargin{i+1};
            case 'handles'; handles = varargin{i+1};
            case 'chmap'; chMap = varargin{i+1};
            otherwise error(['unexpected argument: ' varargin{i}]);
        end
    else
        error('string argument expected');
    end
    i = i+2;
end

% make sure tone vector is the correct shape (one column)
if (size(tone,2) > 1)
    tone = tone';
end
% if a list of frequencies is specified, use them as a starting point for a
% new correction. Otherwise use existing correction is used as a starting
% point. The measurement is added to the existing correction in this case.
[ampCorr, perChannelCorr] = iqcorrection([]);
if (~isempty(ampCorr) && (recalibrate || isempty(tone)))
    if (~isequal(ampCorr(:,1), tone))
        errordlg('Frequency points must be identical for re-calibration. Please perform initial calibration first.');
        return;
    end
    oldCorr = ampCorr(:,2);
else
    oldCorr = zeros(length(tone),1);
end
origTone = tone;
%
if (~isempty(hMsgBox))
    close(hMsgBox);
end

%% establish a connection to power sensor
options.Resize = 'on';
options.WindowStyle = 'normal';
if (~isempty(handles) && isfield(handles, 'visaAddrPowerSensor'))
    visaAddr = handles.visaAddrPowerSensor;
else
    visaAddr = 'TCPIP0::K-L2062XA-xxxxx::inst0::INSTR';
end
if (~isempty(handles) && isfield(handles, 'powerSensorAverages'))
    powerSensorAverages = handles.powerSensorAverages;
else
    powerSensorAverages = 'AUTO';
end

defaultanswer = {visaAddr, powerSensorAverages};
res = inputdlg({'VISA address', 'Number of Averages'}, 'Power Sensor Configuration', 1, defaultanswer, options);
if (isempty(res))
    return;
end
handles.visaAddrPowerSensor = res{1};
handles.powerSensorAverages = res{2};
guidata(handles.iqtool, handles);

visaAddrPowerSensor = res{1};
powerSensorAverages = res{2};
f = iqopen(visaAddrPowerSensor);
if (isempty(f))
    return;
end
hmsgbox = msgbox('Initializing Power Sensor, please wait...', 'Please wait...', 'replace');
xfprintf(f, '*RST');
query(f, '*OPC?');
xfprintf(f, 'CAL:AUTO 0');
%xfprintf(f, 'CAL:ALL');
query(f, '*OPC?');
xfprintf(f, 'TRIG:SOUR IMM');
xfprintf(f, 'SENS:DET:FUNC AVER');
xfprintf(f, sprintf('AVER:COUNT %s', powerSensorAverages));
xfprintf(f, 'INIT:CONT OFF');
xfprintf(f, 'SENS:MRATE NORM');
xfprintf(f, 'UNIT:POW DBM');


compareToSA = 0;
if (compareToSA)
    [~, sa] = loadArbConfig();
    fSa = iqopen(sa.visaAddr);
    listSa = nan(length(tone), 1);
end

% determine the crest factor of the overall signal
[sig, ~, ~, ~, chMap] = iqtone('samplerate', fs, 'tone', tone, ...
    'correction', correction, 'channelMapping', chMap, 'normalize', 0, 'nowarning', 1);
rms = norm(sig) / sqrt(length(sig));
peak = max(abs(sig));
crest = peak / rms;

% now run the power measurement for each tone
list = nan(length(tone), 1);
useWaitbar = 0;
if (useWaitbar)
    try close(hmsgbox); catch; end
    h = waitbar(0, 'Please wait...', 'Name', 'Please wait...', 'CreateCancelBtn', 'setappdata(gcbf,''cancel'',1)');
    setappdata(h, 'cancel', 0);
end
try
for i = 1:length(tone)
    % download each tone individually
    if (useWaitbar)
        waitbar(i/length(tone), h, sprintf('Measuring tone %d of %d', i, length(tone)));
        if (~isempty(h) && getappdata(h, 'cancel'))
            break;
        end
    else
        msgbox(sprintf('Measuring tone %d of %d', i, length(tone)), 'Please wait...', 'replace');
    end
    [sig, ~, ~, ~, chMap] = iqtone('samplerate', fs, 'tone', tone(i), ...
        'correction', correction, 'channelMapping', chMap, 'normalize', 0, 'nowarning', 1);
    % scale the signal by number of tones and crest factor
    sig = sig / sqrt(length(tone)) / crest;
    iqdownload(sig, fs, 'chMap', chMap);
    % update the progress bar and break the loop if user has pressed
    xfprintf(f, sprintf(':SENS:FREQ:CW %.15g', tone(i)));
    pause(0.2);
    res = query(f, 'READ?');
    meas = sscanf(res, '%g');
    if (meas < -100 || meas > 40)
        break;
    end
    list(i) = meas;
    
    if (compareToSA)
        mag_s = query(fSa, 'CALC:MARK1:Y?');
        mag = sscanf(mag_s, '%g');
        listSa(i) = mag;
        figure(5); plot(tone/1e9, [list listSa], '.-');
        xlabel('GHz');
        ylabel('dBm');
        grid on;
        legend({'power sensor', 'spectrum analyzer'});
    end

end
catch
end
if (useWaitbar)
    try delete(h); catch; end
end
fclose(f);


%% calculate the new correction factors
% some sanity check
if (length(list) ~= length(tone) || ~isempty(find(isnan(list), 1)))
    errordlg('Measurement aborted or unexpected power sensor result. Please check Fc parameter.');
    return;
end
% check, if absolute magnitude shift is used (be graceful if cal file does
% not exist)
acs = [];
try
    acs = load(iqampCorrFilename());
catch
end
if (isfield(acs, 'absMagnitude'))
    meas = list - acs.absMagnitude;
else
    % calculate deviation from average
    meas = list - sum(list)/length(list);
end
% subtract from previous correction
newCorr = oldCorr - meas;
% check, if absolute magnitude can be achieved
if (isfield(acs, 'absMagnitude'))
    if (max(newCorr) > 0)
        minVal = -1*max(newCorr) + acs.absMagnitude;
        minVal = floor(minVal * 10) / 10;
        volt = 0;
        try
            f = iqopen();
            volt = str2double(query(f, ':VOLT?'));
            volt = volt / 10^(-1*max(newCorr)/20);
            volt = ceil(volt * 10) / 10;
            fclose(f);
        catch
        end
        warndlg(sprintf(['Output amplitude is not sufficient to achieve %g dBm.\n' ...
            'Please increase AWG amplitude to %.1f V\nor reduce desired ' ...
            'output power to %.1f dBm'], acs.absMagnitude, volt, minVal));
    end
end
% use the orginal tone vector in the file
tone = origTone;
acs.ampCorr = [tone newCorr];
% ...and save it to ampCorr.mat
if (update)
    save(iqampCorrFilename(), '-struct', 'acs');
end

%% plot results
doPlot = 1;
if (doPlot)
    figure(10);
    set(10,'Name','Flatness Correction');
    hold off;  plot(tone, meas, 'r.-');
    hold on; plot(tone, -1 * oldCorr, 'b.-');
    plot(tone, -1 * newCorr, 'k.-'); hold off;
    legend('measurement', 'old correction', 'new correction');
    xlabel('frequency (Hz)');
    ylabel('dB');
    pause(3);
end
result = list;
end



function xfprintf(f, s)
% Send the string s to the instrument object f
% and check the error status

    if (evalin('base', 'exist(''debugCal'', ''var'')'))
        fprintf('cmd = %s\n', s);
    end
    fprintf(f, s);
    res = query(f, ':syst:err?');
    if (isempty(res))
        fclose(f);
        error(':syst:err query failed');
    end
    if (~strncmp(res, '+', 1))
        errordlg(sprintf('Error sending command: %s\n\n%s', s, res));
    end
end

