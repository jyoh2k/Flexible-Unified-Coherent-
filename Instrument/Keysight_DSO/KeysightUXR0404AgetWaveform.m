function Waveform = KeysightUXR0404AgetWaveform(obj, Channel)

% Get waveform from Agilent DSA91204A Oscilloscope

% Select what channel we want to get information about.
fprintf(obj, [':WAVeform:SOURce ', Channel]);

%fprintf(obj,':WAVEFORM:FORMAT WORD');
% Set the byte order on the instrument as well
%fprintf(obj,':WAVEFORM:BYTEORDER LSBFirst');
%fprintf(obj,':WAVEFORM:STREAMING 0');

% Get some information about the waveform
num = query(obj,':WAVeform:POINTs?','%s\n','%d');
%bn_fmt = query(obj,':WAVeform:FORmat?','%s\n','%s');
%byt_or = query(obj,':WAVeform:BYTeorder?','%s\n','%s');
%byt_nr = query(obj,'WFMOUTPRE:BYT_NR?','%s\n','%d');


datasize = 2;
numDataBytes = num * datasize;
% If the object passed does not have an InputBufferSize large
% enough to fit the data, fix the problem for the user.
if (get(obj,'InputBufferSize')<(numDataBytes))
	fclose(obj);
% 	warning([ERRORMSGIDprefix,'InputBufferSize'],...
        disp(['Increasing InputBufferSize to ', num2str(numDataBytes),'.']);
	set(obj,'InputBufferSize', numDataBytes);
	fopen(obj);
end;

% Tell instrument that we want these points.
%fprintf(obj, [':DIGitize ', Channel]);
%fprintf(obj,[':', Channel, ':DISPLAY ON']);
fprintf(obj, ['WAVeform:DATA? 1, ', num2str(num)]);

% Based on what channel and format we need to different types
% of reads.  So do the correct one and get the data.
% pres = 'int16';
waveform_raw = binblockread(obj, 'int16');

% Get information about the Channel
pause(1e-3);
YInc = str2double(query(obj, ':WAVeform:YINCrement?','%s\n','%s'));
pause(1e-3);
YOrigin = str2double(query(obj, ':WAVeform:YORigin?','%s\n','%s'));
pause(1e-3);
YRef = str2double(query(obj, ':WAVeform:YREFerence?','%s\n','%s'));

Waveform = YInc * (waveform_raw - YRef) + YOrigin;



