function [ TekScope, dt ] = initialize_TekscopeDPO72004B(N, SR, SC, IPaddr)

TekScope = instrfind('Type', 'visa-tcpip', 'RemoteHost', IPaddr);

%Create TCPIP object if it does not exist

if isempty(TekScope)
%     TekScope = visa('Tek',['TCPIP0::' IPaddr '::inst0::INSTR']);
    TekScope = visa('ni',['TCPIP0::' IPaddr '::inst0::INSTR']);
       
else
    fclose(TekScope);
    TekScope=TekScope(1);
end

%set sufficiently large buffer
set(TekScope, 'InputBufferSize', round(2*N));
set(TekScope, 'Timeout', 100);

%Conncet device object to hardware
fopen(TekScope);

fprintf(TekScope, 'HEADER OFF');
fprintf(TekScope, 'DATA:ENCDG SRI');
fprintf(TekScope, 'TRIGGER:A:EDGE:SOURCE CH1');
fprintf(TekScope, 'TRIGGER:A:LEVEL 0.0');
fprintf(TekScope, 'TRIGGER:A:EDGE:SLOPE FALL');
fprintf(TekScope, 'ACQUIRE:STATE OFF');
fprintf(TekScope, 'ACQUIRE:MODE SAMPLE');
fprintf(TekScope, 'HORizontal:MODE MANUAL');
fprintf(TekScope, ['HORizontal:MODE:SAMPLERATE ' num2str(SR)]);
fprintf(TekScope, ['HORizontal:MODE:RECOrdlength ' num2str(N)]);
fprintf(TekScope, ['CH1:SCALE ' num2str(SC)]);
fprintf(TekScope, ['CH2:SCALE ' num2str(SC)]);
fprintf(TekScope, ['CH3:SCALE ' num2str(SC)]);
fprintf(TekScope, ['CH4:SCALE ' num2str(SC)]);

% Single shot
% fprintf(TekScope1, 'ACQUIRE:STOPAFTER SEQUENCE');
fprintf(TekScope, 'ACQUIRE:STOPAFTER SEQUENCE');
fprintf(TekScope, 'ACQUIRE:STATE ON');
disp 'setting DPO72004B scope parameters for waveform transfer'

% returns sampling interval
dt = str2double(query(TekScope, 'WFMOutpre:XINcr?'));


% DATa:SOUrce CH1   -> CURV? 를 사용하거나, SAVEON 을 사용하여 data 저장 가능.


