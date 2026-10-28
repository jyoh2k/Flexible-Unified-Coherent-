function [ TekScope, dt ] = initialize_KeysightUXR0404A(N, SR, SC, IPaddr)

TekScope = instrfind('Type', 'visa-tcpip', 'RemoteHost', IPaddr);

%Create TCPIP object if it does not exist

if isempty(TekScope)
    %TekScope = visa('keysight',['TCPIP0::' IPaddr '::INSTR']);
    TekScope = visa('keysight',['TCPIP0::' IPaddr '::hislip0::INSTR']);
else
    fclose(TekScope);
    TekScope=TekScope(1);
end

%set sufficiently large buffer
set(TekScope, 'InputBufferSize', round(2*N));
set(TekScope, 'Timeout', 10);

%Conncet device object to hardware
fopen(TekScope);

fprintf(TekScope, ':SYSTEM:HEADER OFF');
%fprintf(TekScope, 'DATA:ENCDG SRIBINARY');
fprintf(TekScope, ':TRIGger:MODE EDGE');
fprintf(TekScope, ':TRIGger:EDGE:SOURce CHAN3');
fprintf(TekScope, ':TRIGger:EDGE:SLOPe Negative');
fprintf(TekScope, ':TRIGger:EDGE:COUPling DC');
fprintf(TekScope, ':TRIGger:LEVel CHAN1,0.0');
fprintf(TekScope, ':TRIG:SWEEP TRIGgered');

%fprintf(TekScope, 'ACQUIRE:STATE OFF');
fprintf(TekScope, ':ACQuire:MODE:RTIMe');
fprintf(TekScope, ':ACQuire:SRATe:AUTO OFF');
fprintf(TekScope, [':ACQuire:SRATe ' num2str(SR)]);
fprintf(TekScope, ':ACQuire:POINTs:AUTO OFF');
fprintf(TekScope, [':ACQuire:POINts ' num2str(N)]);
fprintf(TekScope, ':ACQuire:INTerpolate OFF');

TR = N/SR;
fprintf(TekScope, [':TIMebase:RANGe ' num2str(TR)]);
fprintf(TekScope, [':TIMebase:POSition ' num2str(0)]);
%fprintf(TekScope, [':TIMebase:POSition ' num2str(12.5e-6)]);
%fprintf(TekScope, [':TIMebase:POSition ' num2str(37.5e-6)]);

fprintf(TekScope, [':CHANnel1:SCALe ' num2str(SC)]);
fprintf(TekScope, [':CHANnel2:SCALe ' num2str(SC)]);
fprintf(TekScope, [':CHANnel3:SCALe ' num2str(SC)]);
fprintf(TekScope, [':CHANnel4:SCALe ' num2str(SC)]);
%fprintf(TekScope, ':CHANnel1:OFFSet 0');
%fprintf(TekScope, ':CHANnel2:OFFSet 0');
%fprintf(TekScope, ':CHANnel3:OFFSet 0');
%fprintf(TekScope, ':CHANnel4:OFFSet 0');

fprintf(TekScope, ':WAVeform:FORMat WORD');
fprintf(TekScope, ':WAVeform:BYTeorder LSBFirst');
fprintf(TekScope, ':WAVeform:STReaming 0');

fprintf(TekScope, ':SINGle');

pause(0.5);

disp 'setting UXR0404A scope parameters for waveform transfer'

% returns samplinge interval
dt = str2double(query(TekScope, ':WAVeform:XINCrement?'));




