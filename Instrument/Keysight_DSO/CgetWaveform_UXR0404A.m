
function [mode1_X,mode1_Y]=CgetWaveform_UXR0404A(wfileind,SR,SC)
%clear all
%close all
%clc

%load E:\expdata\offlinepg\TMF-MIMO-EXP\shfpatt\shfmoddata_211_11bitdelay_DA_10.7G_QPSK.mat
%sdate='D:\user\shchang\Data\Data20211026';
%fileind=1;

% UXR0404A
N2 = 100e5; % Datalength
SR2 = SR * 1e9; % Sample Rate
SC2 = SC * 1e-3; % Vertical Scale

%IPaddr1 = '192.168.0.3';  % TDS6154C
%IPaddr2 = '192.168.0.5';  % DPO72004B
%IPaddr2 = '192.168.10.5';  % DSA73304D
IPaddr2 = '192.168.10.9';  % UXR0404A


% % Initialize Keysight UXR0404A
[TekScope2, dt2] = initialize_KeysightUXR0404A(N2, SR2, SC2, IPaddr2);


% Len2 = str2double(query(TekScope2, 'HORizontal:RECOrdlength?'));

% dt1 = 1 / SR1;
% dt2 = 1 / SR2;

% TotalTime1 = dt1 * N1
% TotalTime2 = dt2 * N2

%TotalTime1 = dt1 * Len1
TotalTime2 = N2/(SR2*1e9);

% Get Waveform
SCP2_CH1 = KeysightUXR0404AgetWaveform(TekScope2, 'CHAN1');
SCP2_CH2 = KeysightUXR0404AgetWaveform(TekScope2, 'CHAN2');
SCP2_CH3 = KeysightUXR0404AgetWaveform(TekScope2, 'CHAN3');
SCP2_CH4 = KeysightUXR0404AgetWaveform(TekScope2, 'CHAN4');
pause(0.1);

% % Close object
 %fclose(TekScope1);
% fclose(TekScope2);
%%


mode1_X=(SCP2_CH1+1i*SCP2_CH2);
mode1_Y=(SCP2_CH3+1i*SCP2_CH4);

%ws1=sprintf('%s_%ddBOSNR.mat',wsdate,wfileind);
% ws1=sprintf('%s\\DPQPSK_30GBd_singlemode_%d.mat',wsdate,wfileind);
% ws1=sprintf('%s\\ICR_test_withcompensation7_%d.mat',wsdate,wfileind);

% save(ws1, 'mode1_X',  'mode1_Y');

end

    




