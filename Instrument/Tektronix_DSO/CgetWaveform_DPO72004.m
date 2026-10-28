
function [mode1_X, mode1_Y]=CgetWaveform_DPO72004(wfileind,SR,SC)


% DPO72004B
N2 = 10e5; % Datalength
SR2 = SR * 1e9; % Sample Rate
SC2 = SC * 1e-3; % Vertical Scale

%IPaddr1 = '192.168.0.3';  % TDS6154C
%IPaddr2 = '192.168.0.5';  % DPO72004B
% IPaddr2 = '169.254.135.147';  % DSA73304D
IPaddr2 = '192.168.10.8';  % DSA73304D

% % Initialize Tek TDS6154C
% [TekScope1, dt1] = initialize_TekscopeTDS6154C(N1, SR1, SC1, IPaddr1);

% % Initialize Tek DPO72004B
[TekScope2, dt2] = initialize_TekscopeDPO72004B(N2, SR2, SC2, IPaddr2);

% Initialize both scopes
%[TekScope1, dt1, TekScope2, dt2] = initialize_TekscopeBoth(N1, SR1, SC1, IPaddr1, N2, SR2, SC2, IPaddr2);

%Len1 = str2double(query(TekScope1, 'HORizont
% al:RECOrdlength?'));
Len2 = str2double(query(TekScope2, 'HORizontal:RECOrdlength?'));

% dt1 = 1 / SR1;
% dt2 = 1 / SR2;

% TotalTime1 = dt1 * N1
% TotalTime2 = dt2 * N2

%TotalTime1 = dt1 * Len1
TotalTime2 = dt2 * Len2


% Get Waveform
%SCP1_CH1 = TekTDS6154CgetWaveform(TekScope1, 'CH1');
%SCP1_CH2 = TekTDS6154CgetWaveform(TekScope1, 'CH2');
%SCP1_CH3 = TekTDS6154CgetWaveform(TekScope1, 'CH3');
%SCP1_CH4 = TekTDS6154CgetWaveform(TekScope1, 'CH4');

% Get Waveform
SCP2_CH1 = TekDPO72004BgetWaveform(TekScope2, 'CH1');
% SCP2_CH2 = TekDPO72004BgetWaveform(TekScope2, 'CH2');
SCP2_CH3 = TekDPO72004BgetWaveform(TekScope2, 'CH3');
% SCP2_CH4 = TekDPO72004BgetWaveform(TekScope2, 'CH4');
pause(0.1);
% % Close object
 %fclose(TekScope1);
% fclose(TekScope2);
%%

mode1_X = (SCP2_CH1+1i*SCP2_CH3);
mode1_Y = mode1_X;

%  mode1_X=(SCP2_CH1+1i*SCP2_CH2);
%  mode1_Y=(SCP2_CH3+1i*SCP2_CH4);
 

end

    




