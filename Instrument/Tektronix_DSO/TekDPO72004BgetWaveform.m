function Waveform = TekDPO72004BgetWaveform(obj, Channel)

% Get waveform from Tektronix DPO72004B Oscilloscope

% Select what channel we want to get information about.
fprintf(obj, ['DATA:SOURCE ' , Channel]);

% Get some information about the waveform
num = query(obj,'HORIZONTAL:RECORDLENGTH?','%s\n','%d');
bn_fmt = query(obj,'WFMOUTPRE:BN_FMT?','%s\n','%s');
byt_nr = query(obj,'WFMOUTPRE:BYT_NR?','%s\n','%d');
byt_or = query(obj,'WFMOUTPRE:BYT_OR?','%s\n','%s');
if strcmp(byt_or(1:3),'MSB')
    obj.ByteOrder = 'bigEndian';
else
    obj.ByteOrder = 'littleEndian';
end;

if strcmp(bn_fmt,'RI') && byt_nr == 1
   datasize=1;
   pres = 'int8';
elseif strcmp(bn_fmt,'RI') && byt_nr == 2
   datasize=2;
   pres = 'int16';
elseif strcmp(bn_fmt,'RI') && byt_nr == 4
   datasize=4;
   pres = 'int32';
elseif strcmp(bn_fmt,'FP') && byt_nr == 4
   datasize=8;
   pres = 'float32';
else
   error([ERRORMSGIDprefix,':UnknownDataFormat'],...
   'Unrecognized binary format.')
end

% datasize = 1;
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
fprintf(obj, 'DATA:START ON');
fprintf(obj, ['DATA:STOP ' num2str(numDataBytes)]);      

% Ask the instrument for the data.
fprintf(obj, 'CURVE?');

% Based on what channel and format we need to different types
% of reads.  So do the correct one and get the data.
% pres = 'int8';
waveform_raw = binblockread(obj, pres);

% Get information about the Channel
YOff = str2double(query(obj, 'WFMOutpre:YOFf?','%s\n','%s'));
YMult = str2double(query(obj, 'WFMOutpre:YMUlt?','%s\n','%s'));
YZero = str2double(query(obj, 'WFMOutpre:YZERO?','%s\n','%s'));

Waveform = YMult * (waveform_raw - YOff) + YZero;
% Waveform = waveform_raw;

