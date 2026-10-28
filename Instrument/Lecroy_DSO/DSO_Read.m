 function [scope_out] = DSO_Read( sims, params )  
%  Usage      :  [scope_out] = DSO_Read( sims, params )  
 

    SR =25;
    SC =params.OSCScale;
    wfileind =1;

%   [channelout] = LeCroy_Scope_Read( sims, params );
    [channelout] = LeCroyOscRead( wfileind,SR,SC);

    PAPR =SC*4/sqrt(mean(mean(abs(channelout) .^2 )))/1000;
    AVG  =sqrt(mean(mean(abs(channelout) .^2 )))*1000;
    disp2(sims.logfile, ['OSC PAPR ' num2str( PAPR) ' Avg ' num2str( AVG) ]);

%% import from files
load('C:\Users\USER\Documents\Work\TOI\Experiment\16-Feb-2023\DP_AWG_32QAM_160GS_30GBaud_0km_0ps_-12dBm_1.mat');
% load('C:\Users\USER\Documents\Work\TOI\Experiment\29-Nov-2022\PTBC_AWG_16QAM_160GS_30GBaud_0km_0ps_-15dBm_1_cal_SRRC0.1.mat');
% channelout = [mode1_X, mode1_Y]';
% channelout = conj(channelout) ;
%% 
    [channelout] =  rxmapping ( channelout,params.RXmapping);
    SaveOsc(channelout, sims, params); 

%     save('temp1.mat','channelout'); 

    figure(2);
    xxx = [(-1/2):1/(length(channelout(1,:))-1):1/2]*160;
    plot(xxx,log10(fftshift(abs(fft((channelout(1,:)))))));
    grid on;
    pause(1);

end 
